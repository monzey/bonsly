use anyhow::{bail, ensure, Context, Result};
use serde::{Deserialize, Serialize};
use serde_json::{json, Value};
use sha2::{Digest, Sha256};
use std::{
    collections::HashSet,
    env,
    fs::{self, File, OpenOptions},
    io::{self, Read},
    os::unix::net::UnixStream,
    path::{Path, PathBuf},
    process::{Child, Command, ExitStatus, Stdio},
    sync::{
        atomic::{AtomicBool, Ordering},
        Arc,
    },
    thread,
    time::{Duration, Instant},
};
use tungstenite::{Message, WebSocket};

struct CodexServer {
    socket: WebSocket<UnixStream>,
    sequence: u64,
}

impl CodexServer {
    fn connect(path: &Path) -> Result<Self> {
        let stream =
            UnixStream::connect(path).context("Cannot connect to Codex's native socket")?;
        stream.set_read_timeout(Some(Duration::from_secs(15)))?;
        stream.set_write_timeout(Some(Duration::from_secs(15)))?;
        let (socket, _) = tungstenite::client("ws://localhost/", stream)?;
        let mut server = Self {
            socket,
            sequence: 0,
        };
        server.request(
            "initialize",
            json!({"clientInfo": {"name": "openvide", "version": "1.0.0"}}),
        )?;
        server.write(json!({"method": "initialized"}))?;
        Ok(server)
    }

    fn write(&mut self, message: Value) -> Result<()> {
        self.socket
            .send(Message::Text(message.to_string().into()))?;
        Ok(())
    }

    fn request(&mut self, method: &str, params: Value) -> Result<Value> {
        self.sequence += 1;
        self.write(json!({"id": self.sequence, "method": method, "params": params}))?;
        let deadline = Instant::now() + Duration::from_secs(15);
        loop {
            let remaining = deadline
                .checked_duration_since(Instant::now())
                .context("Codex request timed out")?;
            self.socket.get_mut().set_read_timeout(Some(remaining))?;
            let text = match self.socket.read()? {
                Message::Text(text) => text,
                Message::Close(_) => bail!("Codex closed its connection"),
                _ => continue,
            };
            let response: Value = serde_json::from_str(&text)?;
            if response["id"] != self.sequence {
                // Discovery never starts turns or answers approvals.
                ensure!(
                    response.get("id").is_none() || response.get("method").is_none(),
                    "Unexpected Codex server request"
                );
                continue;
            }
            ensure!(
                response.get("error").is_none(),
                "Codex {method}: {}",
                response["error"]
            );
            return response
                .get("result")
                .cloned()
                .context("Missing Codex result");
        }
    }

    fn root_thread(&mut self) -> Result<Value> {
        let mut roots = Vec::new();
        let mut cursor = Value::Null;
        let mut cursors = HashSet::new();
        loop {
            let page = self.request("thread/loaded/list", json!({"cursor": cursor}))?;
            for identifier in page["data"]
                .as_array()
                .context("Invalid Codex thread list")?
            {
                let thread = self.request(
                    "thread/read",
                    json!({"threadId": identifier, "includeTurns": false}),
                )?;
                if thread["thread"]["parentThreadId"].is_null() {
                    roots.push(thread["thread"].clone());
                }
            }
            cursor = page["nextCursor"].clone();
            if cursor.is_null() {
                break;
            }
            ensure!(
                cursors.insert(cursor.to_string()),
                "Repeated Codex pagination cursor"
            );
        }
        ensure!(
            roots.len() == 1,
            "Expected exactly one loaded root Codex session; no message sent"
        );
        Ok(roots.remove(0))
    }
}

impl Drop for CodexServer {
    fn drop(&mut self) {
        let _ = self.socket.close(None);
    }
}

#[derive(Clone, Deserialize, Serialize)]
struct Binding {
    directory: PathBuf,
    socket: PathBuf,
    pid: u32,
    identity: String,
    server_pid: u32,
    server_identity: String,
    codex_home: PathBuf,
}

mod session;
use session::{belongs_to_window, process_identity};

fn home() -> Result<PathBuf> {
    Ok(env::var_os("HOME").context("HOME is missing")?.into())
}

fn codex_home() -> Result<PathBuf> {
    let path = env::var_os("CODEX_HOME")
        .map(PathBuf::from)
        .unwrap_or(home()?.join(".codex"));
    path.canonicalize().context("Cannot resolve CODEX_HOME")
}

fn binding_path(directory: &Path) -> Result<PathBuf> {
    let cache = env::var_os("XDG_CACHE_HOME")
        .map(PathBuf::from)
        .unwrap_or(home()?.join(".cache"));
    let key = format!(
        "{:x}",
        Sha256::digest(directory.as_os_str().as_encoded_bytes())
    );
    Ok(cache
        .join("caelestia/openvide/codex")
        .join(format!("{key}.json")))
}

fn validate_binding(
    binding: &Binding,
    directory: &Path,
    home: &Path,
    window_pid: u32,
) -> Result<()> {
    ensure!(
        binding.directory == directory
            && binding.codex_home == home
            && process_identity(binding.pid)? == binding.identity
            && process_identity(binding.server_pid)? == binding.server_identity,
        "Stale or mismatched Openvide Codex binding"
    );
    ensure!(
        belongs_to_window(binding.pid, window_pid)?,
        "Bound Codex process does not belong to this set's terminal"
    );
    Ok(())
}

fn validate_target(
    thread: &Value,
    directory: &Path,
    current_thread: Option<&str>,
) -> Result<String> {
    let id = uuid::Uuid::parse_str(thread["id"].as_str().context("Missing Codex thread UUID")?)?
        .to_string();
    let cwd = Path::new(
        thread["cwd"]
            .as_str()
            .context("Missing Codex session directory")?,
    )
    .canonicalize()?;
    ensure!(
        cwd == directory,
        "Codex session changed directory; no message sent"
    );
    ensure!(
        current_thread != Some(id.as_str()),
        "Already running in the target Codex session; continue the task here"
    );
    Ok(id)
}

// Always reap owned children; include a deadline for an unresponsive server/TUI.
struct Process(Child);
impl Drop for Process {
    fn drop(&mut self) {
        if matches!(self.0.try_wait(), Ok(Some(_))) {
            return;
        }
        unsafe {
            libc::kill(self.0.id() as libc::pid_t, libc::SIGTERM);
        }
        let deadline = Instant::now() + Duration::from_secs(5);
        while Instant::now() < deadline {
            if matches!(self.0.try_wait(), Ok(Some(_))) {
                return;
            }
            thread::sleep(Duration::from_millis(50));
        }
        let _ = self.0.kill();
        let _ = self.0.wait();
    }
}

struct BindingCleanup(PathBuf);
impl Drop for BindingCleanup {
    fn drop(&mut self) {
        let _ = fs::remove_file(&self.0);
    }
}

fn wait(
    process: &mut Process,
    timeout: Option<Duration>,
    interrupted: &AtomicBool,
) -> Result<ExitStatus> {
    let started = Instant::now();
    loop {
        if let Some(status) = process.0.try_wait()? {
            return Ok(status);
        }
        ensure!(!interrupted.load(Ordering::Relaxed), "Interrupted");
        ensure!(timeout.is_none_or(|limit| started.elapsed() < limit), "Codex command timed out; delivery may already have occurred, do not retry automatically");
        thread::sleep(Duration::from_millis(100));
    }
}

fn launch(directory: &Path, interrupted: &AtomicBool) -> Result<()> {
    let path = binding_path(directory)?;
    let parent = path.parent().context("Invalid binding path")?;
    fs::create_dir_all(parent)?;
    let lock = OpenOptions::new()
        .create(true)
        .truncate(false)
        .write(true)
        .open(path.with_extension("lock"))?;
    fs2::FileExt::try_lock_exclusive(&lock)
        .context("An Openvide Codex terminal already owns this checkout")?;
    let _cleanup = BindingCleanup(path.clone());
    let runtime = tempfile::Builder::new()
        .prefix("openvide-codex-")
        .tempdir()?;
    let socket = runtime.path().join("server.sock");
    let remote = format!("unix://{}", socket.display());
    let log = File::create(runtime.path().join("server.log"))?;
    let mut server = Process(
        Command::new("codex")
            .args(["app-server", "--listen", &remote])
            .current_dir(directory)
            .stdin(Stdio::null())
            .stdout(log.try_clone()?)
            .stderr(log)
            .spawn()?,
    );
    let deadline = Instant::now() + Duration::from_secs(10);
    while !socket.exists() {
        ensure!(
            server.0.try_wait()?.is_none(),
            "Codex native server exited before startup"
        );
        ensure!(
            Instant::now() < deadline,
            "Codex native server startup timed out"
        );
        ensure!(!interrupted.load(Ordering::Relaxed), "Interrupted");
        thread::sleep(Duration::from_millis(100));
    }
    let mut child = Process(
        Command::new("codex")
            .args(["--remote", &remote, "--cd"])
            .arg(directory)
            .current_dir(directory)
            .spawn()?,
    );
    let binding = Binding {
        directory: directory.to_owned(),
        socket,
        pid: child.0.id(),
        identity: process_identity(child.0.id())?,
        server_pid: server.0.id(),
        server_identity: process_identity(server.0.id())?,
        codex_home: codex_home()?,
    };
    let mut temporary = tempfile::NamedTempFile::new_in(parent)?;
    serde_json::to_writer(temporary.as_file_mut(), &binding)?;
    temporary.persist(&path)?;
    ensure!(
        wait(&mut child, None, interrupted)?.success(),
        "Codex terminal exited unsuccessfully"
    );
    Ok(())
}

fn send(directory: &Path, window_pid: u32, message: &str, interrupted: &AtomicBool) -> Result<()> {
    ensure!(!message.trim().is_empty(), "Task message is empty");
    let file = File::open(binding_path(directory)?)
        .context("No bound Codex session; reopen Codex through the updated Openvide launcher")?;
    let binding: Binding = serde_json::from_reader(file)?;
    validate_binding(&binding, directory, &codex_home()?, window_pid)?;
    let mut server = CodexServer::connect(&binding.socket)?;
    let target = server.root_thread()?;
    let current = env::var("CODEX_THREAD_ID").ok();
    let id = validate_target(&target, directory, current.as_deref())?;
    let remote = format!("unix://{}", binding.socket.display());
    // No --resume: never revive an inactive session or interrupt a running turn.
    let mut queue = Process(
        Command::new("codex")
            .args([
                "queue",
                "--remote",
                &remote,
                "--thread",
                &id,
                "--message",
                message,
            ])
            .spawn()?,
    );
    ensure!(
        wait(&mut queue, Some(Duration::from_secs(30)), interrupted)?.success(),
        "Codex queue failed"
    );
    println!(
        "{}",
        json!({"status": "queued", "thread_id": id, "directory": directory})
    );
    Ok(())
}

fn main() {
    if let Err(error) = run() {
        eprintln!("Openvide Codex: {error:#}");
        std::process::exit(1);
    }
}

fn run() -> Result<()> {
    let args: Vec<_> = env::args().skip(1).collect();
    ensure!(
        args.len() >= 2,
        "Usage: openvide-codex launch <directory> | send <directory> --window-pid <pid>"
    );
    let directory = Path::new(&args[1]).canonicalize()?;
    ensure!(directory.is_dir(), "Expected a checkout directory");
    let interrupted = Arc::new(AtomicBool::new(false));
    for signal in [libc::SIGINT, libc::SIGTERM, libc::SIGHUP] {
        signal_hook::flag::register(signal, interrupted.clone())?;
    }
    match args[0].as_str() {
        "launch" if args.len() == 2 => launch(&directory, &interrupted),
        "send" if args.len() == 4 && args[2] == "--window-pid" => {
            let pid = args[3].parse()?;
            ensure!(pid > 1, "Invalid terminal PID");
            let mut message = String::new();
            io::stdin().read_to_string(&mut message)?;
            send(&directory, pid, &message, &interrupted)
        }
        _ => {
            bail!("Usage: openvide-codex launch <directory> | send <directory> --window-pid <pid>")
        }
    }
}

#[cfg(test)]
mod tests {
    use super::*;

    const ID: &str = "019abcde-1234-7000-8000-000000000001";

    fn binding(directory: &Path) -> Binding {
        let pid = std::process::id();
        Binding {
            directory: directory.into(),
            socket: "/tmp/test.sock".into(),
            pid,
            identity: process_identity(pid).unwrap(),
            server_pid: pid,
            server_identity: process_identity(pid).unwrap(),
            codex_home: directory.into(),
        }
    }

    #[test]
    fn live_process_and_terminal_are_validated() {
        let dir = tempfile::tempdir().unwrap();
        validate_binding(
            &binding(dir.path()),
            dir.path(),
            dir.path(),
            std::process::id(),
        )
        .unwrap();
        assert!(!belongs_to_window(std::process::id(), u32::MAX).unwrap());
    }

    #[test]
    fn recycled_pid_and_wrong_server_are_rejected() {
        let dir = tempfile::tempdir().unwrap();
        let original = binding(dir.path());
        for server in [false, true] {
            let mut stale = original.clone();
            if server {
                stale.server_identity = "old-boot:123".into();
            } else {
                stale.identity = "old-boot:123".into();
            }
            assert!(validate_binding(&stale, dir.path(), dir.path(), stale.pid).is_err());
        }
    }

    #[test]
    fn wrong_checkout_and_codex_home_are_rejected() {
        let a = tempfile::tempdir().unwrap();
        let b = tempfile::tempdir().unwrap();
        let binding = binding(a.path());
        assert!(validate_binding(&binding, b.path(), a.path(), binding.pid).is_err());
        assert!(validate_binding(&binding, a.path(), b.path(), binding.pid).is_err());
    }

    #[test]
    fn target_must_match_directory_uuid_and_not_self() {
        let a = tempfile::tempdir().unwrap();
        let b = tempfile::tempdir().unwrap();
        let target = json!({"id": ID, "cwd": a.path()});
        assert_eq!(validate_target(&target, a.path(), None).unwrap(), ID);
        assert!(validate_target(&target, b.path(), None).is_err());
        assert!(validate_target(&target, a.path(), Some(ID)).is_err());
        assert!(validate_target(
            &json!({"id": "not-a-uuid", "cwd": a.path()}),
            a.path(),
            None
        )
        .is_err());
    }

    #[test]
    fn empty_task_fails_before_accessing_a_session() {
        let error = send(
            Path::new("/"),
            std::process::id(),
            " \n",
            &AtomicBool::new(false),
        )
        .unwrap_err();
        assert!(error.to_string().contains("empty"));
    }
}
