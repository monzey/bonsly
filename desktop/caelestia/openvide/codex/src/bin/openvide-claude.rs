use anyhow::{bail, ensure, Context, Result};
use serde::{Deserialize, Serialize};
use serde_json::{json, Value};
use sha2::{Digest, Sha256};
use std::{
    env, fs,
    io::{self, BufRead, Read, Write},
    os::unix::{
        fs::PermissionsExt,
        net::{UnixListener, UnixStream},
    },
    path::{Path, PathBuf},
    process::{Child, Command},
    sync::{
        atomic::{AtomicBool, Ordering},
        mpsc, Arc, Mutex,
    },
    thread,
    time::{Duration, Instant},
};

#[path = "../session.rs"]
mod session;
use session::{belongs_to_window, process_identity};

const LIMIT: u64 = 1024 * 1024;
const INSTRUCTIONS: &str = "Messages from the openvide channel are tasks from the user for this checkout. Call acknowledge_task with the task_id before doing the task, then work normally and reply in this terminal. Acknowledging only confirms receipt, never completion. Keep the session's normal tool permissions.";

#[derive(Clone, Deserialize, Serialize)]
struct Binding {
    directory: PathBuf,
    socket: PathBuf,
    pid: u32,
    identity: String,
    channel_pid: Option<u32>,
    channel_identity: Option<String>,
}

fn binding_path(directory: &Path) -> Result<PathBuf> {
    let cache = env::var_os("XDG_CACHE_HOME")
        .map(PathBuf::from)
        .unwrap_or(PathBuf::from(env::var_os("HOME").context("HOME is missing")?).join(".cache"));
    let key = format!(
        "{:x}",
        Sha256::digest(directory.as_os_str().as_encoded_bytes())
    );
    Ok(cache
        .join("caelestia/openvide/claude")
        .join(format!("{key}.json")))
}

fn write_binding(path: &Path, binding: &Binding) -> Result<()> {
    let mut file = tempfile::NamedTempFile::new_in(path.parent().context("Invalid binding path")?)?;
    serde_json::to_writer(file.as_file_mut(), binding)?;
    file.persist(path)?;
    Ok(())
}

fn validate(binding: &Binding, directory: &Path, window: u32) -> Result<()> {
    ensure!(
        binding.directory == directory && process_identity(binding.pid)? == binding.identity,
        "Stale or mismatched Openvide Claude binding"
    );
    ensure!(
        belongs_to_window(binding.pid, window)?,
        "Bound Claude process does not belong to this set's terminal"
    );
    ensure!(
        fs::canonicalize(format!("/proc/{}/cwd", binding.pid))? == directory,
        "Claude changed directory; no message sent"
    );
    let channel = binding
        .channel_pid
        .context("Claude channel is not ready; accept its startup confirmation first")?;
    ensure!(
        Some(process_identity(channel)?) == binding.channel_identity
            && belongs_to_window(channel, binding.pid)?,
        "Stale or unrelated Claude channel"
    );
    Ok(())
}

struct Cleanup {
    path: PathBuf,
    child: Child,
}
impl Drop for Cleanup {
    fn drop(&mut self) {
        let _ = fs::remove_file(&self.path);
        if matches!(self.child.try_wait(), Ok(Some(_))) {
            return;
        }
        unsafe {
            libc::kill(self.child.id() as i32, libc::SIGTERM);
        }
        let deadline = Instant::now() + Duration::from_secs(5);
        while Instant::now() < deadline {
            if matches!(self.child.try_wait(), Ok(Some(_))) {
                return;
            }
            thread::sleep(Duration::from_millis(50));
        }
        let _ = self.child.kill();
        let _ = self.child.wait();
    }
}

fn launch(directory: &Path) -> Result<()> {
    let path = binding_path(directory)?;
    let parent = path.parent().context("Invalid binding path")?;
    fs::create_dir_all(parent)?;
    let lock = fs::OpenOptions::new()
        .create(true)
        .truncate(false)
        .write(true)
        .open(path.with_extension("lock"))?;
    fs2::FileExt::try_lock_exclusive(&lock)
        .context("An Openvide Claude terminal already owns this checkout")?;
    // A private runtime directory also keeps the Unix socket below its path limit.
    let runtime = tempfile::Builder::new()
        .prefix("openvide-claude-")
        .tempdir()?;
    let socket = runtime.path().join("channel.sock");
    let config = json!({"mcpServers":{"openvide":{
        "command": env::current_exe()?, "args":["channel",directory,socket,path]
    }}});
    let child = Command::new("claude")
        .current_dir(directory)
        .args([
            "--mcp-config",
            &config.to_string(),
            "--dangerously-load-development-channels",
            "server:openvide",
        ])
        .spawn()
        .context("Cannot start Claude Code")?;
    let mut cleanup = Cleanup {
        path: path.clone(),
        child,
    };
    write_binding(
        &path,
        &Binding {
            directory: directory.into(),
            socket,
            pid: cleanup.child.id(),
            identity: process_identity(cleanup.child.id())?,
            channel_pid: None,
            channel_identity: None,
        },
    )?;
    let interrupted = Arc::new(AtomicBool::new(false));
    for signal in [libc::SIGINT, libc::SIGTERM, libc::SIGHUP] {
        signal_hook::flag::register(signal, interrupted.clone())?;
    }
    loop {
        if let Some(status) = cleanup.child.try_wait()? {
            ensure!(status.success(), "Claude terminal exited unsuccessfully");
            return Ok(());
        }
        ensure!(!interrupted.load(Ordering::Relaxed), "Interrupted");
        thread::sleep(Duration::from_millis(100));
    }
}

type Output = Arc<Mutex<io::Stdout>>;
fn emit(output: &Output, message: Value) -> Result<()> {
    let mut output = output
        .lock()
        .map_err(|_| anyhow::anyhow!("Channel output lock failed"))?;
    serde_json::to_writer(&mut *output, &message)?;
    output.write_all(b"\n")?;
    output.flush()?;
    Ok(())
}

fn channel(directory: &Path, socket: &Path, path: &Path) -> Result<()> {
    let output = Arc::new(Mutex::new(io::stdout()));
    let pending = Arc::new(Mutex::new(std::collections::HashMap::<
        String,
        mpsc::Sender<()>,
    >::new()));
    let mut started = false;
    // MCP stdio uses one JSON-RPC message per line. Never log to stdout.
    for line in io::stdin().lock().lines() {
        let request: Value = serde_json::from_str(&line?)?;
        let id = request.get("id").cloned();
        let result = match request["method"].as_str().unwrap_or("") {
            "initialize" => json!({
                "protocolVersion": request["params"]["protocolVersion"],
                "serverInfo":{"name":"openvide","version":"0.1.0"},
                "capabilities":{"experimental":{"claude/channel":{}},"tools":{}},
                "instructions": INSTRUCTIONS,
            }),
            "notifications/initialized" if !started => {
                let deadline = Instant::now() + Duration::from_secs(5);
                while !path.exists() && Instant::now() < deadline {
                    thread::sleep(Duration::from_millis(20));
                }
                let mut binding: Binding = serde_json::from_reader(fs::File::open(path)?)?;
                ensure!(
                    binding.directory == directory
                        && binding.socket == socket
                        && process_identity(binding.pid)? == binding.identity
                        && belongs_to_window(std::process::id(), binding.pid)?,
                    "Channel is not owned by this Claude terminal"
                );
                if let Some(pid) = binding.channel_pid {
                    ensure!(
                        process_identity(pid).ok() != binding.channel_identity,
                        "This Claude terminal already has a live Openvide channel"
                    );
                    // Reconnecting MCP can leave the previous process's socket on disk.
                    if socket.exists() {
                        fs::remove_file(socket)?;
                    }
                }
                let listener = UnixListener::bind(socket)?;
                fs::set_permissions(socket, fs::Permissions::from_mode(0o600))?;
                binding.channel_pid = Some(std::process::id());
                binding.channel_identity = Some(process_identity(std::process::id())?);
                write_binding(path, &binding)?;
                let output = output.clone();
                let pending = pending.clone();
                let directory = directory.to_owned();
                thread::spawn(move || {
                    for stream in listener.incoming() {
                        let result = stream.map_err(anyhow::Error::from).and_then(|stream| {
                            forward(stream, &binding, &directory, &output, &pending)
                        });
                        if let Err(error) = result {
                            eprintln!("Openvide Claude channel: {error:#}");
                        }
                    }
                });
                started = true;
                continue;
            }
            "ping" => json!({}),
            "tools/list" => json!({"tools":[{
                "name":"acknowledge_task", "description":"Confirm receipt of an Openvide task before working on it.",
                "inputSchema":{"type":"object","properties":{"task_id":{"type":"string"}},"required":["task_id"],"additionalProperties":false},
                "annotations":{"readOnlyHint":true,"idempotentHint":true,"openWorldHint":false}
            }]}),
            "tools/call" if request["params"]["name"] == "acknowledge_task" => {
                let task = request["params"]["arguments"]["task_id"]
                    .as_str()
                    .unwrap_or("");
                let acknowledged = pending
                    .lock()
                    .unwrap()
                    .remove(task)
                    .is_some_and(|sender| sender.send(()).is_ok());
                json!({"content":[{"type":"text","text":if acknowledged {"Receipt confirmed; task is not completed yet."} else {"Unknown or expired receipt; do not resend the task."}}]})
            }
            _ if id.is_none() => continue,
            _ => {
                emit(
                    &output,
                    json!({"jsonrpc":"2.0","id":id,"error":{"code":-32601,"message":"Method not found"}}),
                )?;
                continue;
            }
        };
        if let Some(id) = id {
            emit(&output, json!({"jsonrpc":"2.0","id":id,"result":result}))?;
        }
    }
    Ok(())
}

fn forward(
    mut stream: UnixStream,
    binding: &Binding,
    directory: &Path,
    output: &Output,
    pending: &Arc<Mutex<std::collections::HashMap<String, mpsc::Sender<()>>>>,
) -> Result<()> {
    stream.set_read_timeout(Some(Duration::from_secs(5)))?;
    stream.set_write_timeout(Some(Duration::from_secs(5)))?;
    // Only the owning user can reach the socket; verify the live Claude process again.
    ensure!(
        process_identity(binding.pid)? == binding.identity
            && fs::canonicalize(format!("/proc/{}/cwd", binding.pid))? == directory,
        "Claude session changed or exited"
    );
    let mut message = String::new();
    (&stream).take(LIMIT + 1).read_to_string(&mut message)?;
    ensure!(
        !message.trim().is_empty() && message.len() as u64 <= LIMIT,
        "Empty or oversized task"
    );
    let task = fs::read_to_string("/proc/sys/kernel/random/uuid")?
        .trim()
        .to_owned();
    let (sender, receiver) = mpsc::channel();
    pending.lock().unwrap().insert(task.clone(), sender);
    let result = emit(
        output,
        json!({"jsonrpc":"2.0","method":"notifications/claude/channel",
        "params":{"content":message,"meta":{"task_id":task}}}),
    );
    if let Err(error) = result {
        pending.lock().unwrap().remove(&task);
        return Err(error);
    }
    let pending = pending.clone();
    let directory = directory.to_owned();
    // Receipt waiting must not block subsequent tasks from reaching a busy Claude.
    thread::spawn(move || {
        let acknowledged = receiver.recv_timeout(Duration::from_secs(30)).is_ok();
        pending.lock().unwrap().remove(&task);
        let receipt = json!({"status":if acknowledged {"received"} else {"forwarded"},
            "task_id":task,"directory":directory,"acknowledged":acknowledged});
        if let Err(error) = writeln!(stream, "{receipt}") {
            eprintln!("Openvide Claude receipt: {error}");
        }
    });
    Ok(())
}

fn send(directory: &Path, window: u32) -> Result<()> {
    let mut message = String::new();
    io::stdin().take(LIMIT + 1).read_to_string(&mut message)?;
    ensure!(!message.trim().is_empty(), "Task message is empty");
    ensure!(message.len() as u64 <= LIMIT, "Task exceeds 1 MiB");
    let binding: Binding =
        serde_json::from_reader(fs::File::open(binding_path(directory)?).context(
            "No bound Claude session; reopen Claude through the updated Openvide launcher",
        )?)?;
    validate(&binding, directory, window)?;
    ensure!(
        !belongs_to_window(std::process::id(), binding.pid)?,
        "Already running in the target Claude session; continue the task here"
    );
    let mut stream = UnixStream::connect(&binding.socket)?;
    stream.set_read_timeout(Some(Duration::from_secs(40)))?;
    stream.set_write_timeout(Some(Duration::from_secs(5)))?;
    stream
        .write_all(message.as_bytes())
        .context("Uncertain Claude delivery; do not retry automatically")?;
    stream.shutdown(std::net::Shutdown::Write)?;
    let receipt: Value = serde_json::from_reader((&stream).take(4096))
        .context("Uncertain Claude delivery; do not retry automatically")?;
    ensure!(
        receipt["directory"] == directory.to_string_lossy().as_ref()
            && matches!(receipt["status"].as_str(), Some("received" | "forwarded")),
        "Invalid Claude receipt; do not retry automatically"
    );
    println!("{receipt}");
    if receipt["acknowledged"] != true {
        eprintln!("Openvide Claude: forwarded without model acknowledgement (busy, unapproved or blocked channel). Do not resend automatically.");
    }
    Ok(())
}

fn run() -> Result<()> {
    let args: Vec<_> = env::args().skip(1).collect();
    ensure!(
        args.len() >= 2,
        "Usage: openvide-claude launch <directory> | send <directory> --window-pid <pid>"
    );
    let directory = Path::new(&args[1]).canonicalize()?;
    ensure!(directory.is_dir(), "Expected a checkout directory");
    match args[0].as_str() {
        "launch" if args.len() == 2 => launch(&directory),
        "channel" if args.len() == 4 => {
            channel(&directory, Path::new(&args[2]), Path::new(&args[3]))
        }
        "owns" if args.len() == 4 && args[2] == "--window-pid" => {
            let binding: Binding =
                serde_json::from_reader(fs::File::open(binding_path(&directory)?)?)?;
            ensure!(
                binding.directory == directory
                    && process_identity(binding.pid)? == binding.identity
                    && belongs_to_window(binding.pid, args[3].parse()?)?,
                "No Claude binding for this terminal"
            );
            Ok(())
        }
        "send" if args.len() == 4 && args[2] == "--window-pid" => {
            let window = args[3].parse()?;
            ensure!(window > 1, "Invalid terminal PID");
            send(&directory, window)
        }
        _ => bail!("Invalid Openvide Claude command"),
    }
}

fn main() {
    if let Err(error) = run() {
        eprintln!("Openvide Claude: {error:#}");
        std::process::exit(1);
    }
}
