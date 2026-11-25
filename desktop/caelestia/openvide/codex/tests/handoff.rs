use serde_json::{json, Value};
use sha2::{Digest, Sha256};
use std::{
    env, fs,
    io::Write,
    os::unix::{fs::PermissionsExt, net::UnixListener},
    process::{Command, Output},
    thread,
    time::{Duration, Instant},
};
use tungstenite::Message;

const ID: &str = "019abcde-1234-7000-8000-000000000001";

fn identity() -> String {
    let pid = std::process::id();
    let stat = fs::read_to_string(format!("/proc/{pid}/stat")).unwrap();
    let fields: Vec<_> = stat
        .rsplit_once(')')
        .unwrap()
        .1
        .split_whitespace()
        .collect();
    format!(
        "{}:{}",
        fs::read_to_string("/proc/sys/kernel/random/boot_id")
            .unwrap()
            .trim(),
        fields[19]
    )
}

// Real Unix WebSocket + real executable boundary; only Codex's model/queue is a fixture.
fn handoff(
    root_count: usize,
    subagent: bool,
    paginated: bool,
    mut empty_lists: usize,
    queue_status: i32,
    message: &str,
) -> (Output, Vec<String>) {
    let temp = tempfile::tempdir().unwrap();
    let dir = temp.path().canonicalize().unwrap();
    let socket_path = dir.join("server.sock");
    let listener = UnixListener::bind(&socket_path).unwrap();
    listener.set_nonblocking(true).unwrap();
    let cwd = dir.clone();
    let server = thread::spawn(move || {
        let deadline = Instant::now() + Duration::from_secs(10);
        let stream = loop {
            if let Ok((stream, _)) = listener.accept() {
                break stream;
            }
            assert!(Instant::now() < deadline, "Client never connected");
            thread::sleep(Duration::from_millis(10));
        };
        stream
            .set_read_timeout(Some(Duration::from_secs(10)))
            .unwrap();
        let mut socket = tungstenite::accept(stream).unwrap();
        while let Ok(Message::Text(text)) = socket.read() {
            let request: Value = serde_json::from_str(&text).unwrap();
            if request.get("id").is_none() {
                continue;
            }
            let result = match request["method"].as_str().unwrap() {
                "initialize" => json!({}),
                "thread/loaded/list" if empty_lists > 0 => {
                    empty_lists -= 1;
                    json!({"data": []})
                }
                "thread/loaded/list" if paginated && request["params"]["cursor"].is_null() => {
                    json!({"data": [], "nextCursor": "page2"})
                }
                "thread/loaded/list" => {
                    let mut ids = vec![ID; root_count];
                    if subagent {
                        ids.push("subagent");
                    }
                    json!({"data": ids})
                }
                "thread/read" => json!({"thread": {
                    "id": request["params"]["threadId"], "cwd": cwd,
                    "parentThreadId": if request["params"]["threadId"] == "subagent" { json!(ID) } else { Value::Null },
                }}),
                unexpected => panic!("Unexpected method: {unexpected}"),
            };
            socket
                .send(Message::Text(
                    json!({"method":"test/notification", "params":{}})
                        .to_string()
                        .into(),
                ))
                .unwrap();
            socket
                .send(Message::Text(
                    json!({"id":request["id"], "result":result})
                        .to_string()
                        .into(),
                ))
                .unwrap();
        }
    });

    let cache = dir.join("cache/caelestia/openvide/codex");
    fs::create_dir_all(&cache).unwrap();
    let key = format!("{:x}", Sha256::digest(dir.as_os_str().as_encoded_bytes()));
    fs::write(
        cache.join(format!("{key}.json")),
        json!({
            "directory": dir, "socket": socket_path,
            "pid":std::process::id(), "identity":identity(),
            "server_pid":std::process::id(), "server_identity":identity(), "codex_home":dir,
        })
        .to_string(),
    )
    .unwrap();

    let sh = env::split_paths(&env::var_os("PATH").unwrap())
        .map(|p| p.join("sh"))
        .find(|p| p.is_file())
        .expect("sh must be available for the queue fixture")
        .canonicalize()
        .unwrap();
    let codex = dir.join("codex");
    fs::write(&codex, format!("#!{}\nprintf '%s\\0' \"$@\" > \"$OPENVIDE_QUEUE_LOG\"\nexit \"$OPENVIDE_QUEUE_STATUS\"\n", sh.display())).unwrap();
    fs::set_permissions(&codex, fs::Permissions::from_mode(0o755)).unwrap();
    let log = dir.join("queue-args");
    let mut child = Command::new(env!("CARGO_BIN_EXE_openvide-codex"))
        .args([
            "send",
            dir.to_str().unwrap(),
            "--window-pid",
            &std::process::id().to_string(),
        ])
        .env("CODEX_HOME", &dir)
        .env("XDG_CACHE_HOME", dir.join("cache"))
        .env_remove("CODEX_THREAD_ID")
        .env("PATH", &dir)
        .env("OPENVIDE_QUEUE_LOG", &log)
        .env("OPENVIDE_QUEUE_STATUS", queue_status.to_string())
        .stdin(std::process::Stdio::piped())
        .stdout(std::process::Stdio::piped())
        .stderr(std::process::Stdio::piped())
        .spawn()
        .unwrap();
    child
        .stdin
        .take()
        .unwrap()
        .write_all(message.as_bytes())
        .unwrap();
    let output = child.wait_with_output().unwrap();
    server.join().unwrap();
    let args = fs::read(log)
        .unwrap_or_default()
        .split(|byte| *byte == 0)
        .filter(|part| !part.is_empty())
        .map(|part| String::from_utf8(part.to_vec()).unwrap())
        .collect();
    (output, args)
}

#[test]
fn native_handoff_preserves_text_and_skips_subagents_across_pages() {
    let message = "Fix it\n$(touch /tmp/should-not-exist) `echo no` 'quoted'";
    let (output, args) = handoff(1, true, true, 0, 0, message);
    assert!(
        output.status.success(),
        "{}",
        String::from_utf8_lossy(&output.stderr)
    );
    assert_eq!(&args[..2], &["queue", "--remote"]);
    assert_eq!(&args[3..], &["--thread", ID, "--message", message]);
    let receipt: Value = serde_json::from_slice(&output.stdout).unwrap();
    assert_eq!(receipt["status"], "queued");
    assert_eq!(receipt["thread_id"], ID);
}

#[test]
fn handoff_waits_for_the_startup_session() {
    let (output, args) = handoff(1, false, false, 2, 0, "Task");
    assert!(
        output.status.success(),
        "{}",
        String::from_utf8_lossy(&output.stderr)
    );
    assert_eq!(&args[3..], &["--thread", ID, "--message", "Task"]);
}

#[test]
fn ambiguous_or_unloaded_sessions_never_receive_a_message() {
    for (count, error) in [
        (0, "finish any startup prompt"),
        (2, "Multiple root Codex sessions"),
    ] {
        let (output, args) = handoff(count, false, false, 0, 0, "Task");
        assert!(!output.status.success());
        assert!(String::from_utf8_lossy(&output.stderr).contains(error));
        assert!(args.is_empty());
    }
}

#[test]
fn queue_failure_is_not_reported_as_success() {
    let (output, _) = handoff(1, false, false, 0, 7, "Task");
    assert!(!output.status.success());
    assert!(String::from_utf8_lossy(&output.stderr).contains("Codex queue failed"));
    assert!(output.stdout.is_empty());
}

#[test]
fn unbound_terminal_is_rejected() {
    let dir = tempfile::tempdir().unwrap();
    let output = Command::new(env!("CARGO_BIN_EXE_openvide-codex"))
        .args([
            "send",
            dir.path().to_str().unwrap(),
            "--window-pid",
            &std::process::id().to_string(),
        ])
        .env("XDG_CACHE_HOME", dir.path())
        .stdin(std::process::Stdio::piped())
        .stdout(std::process::Stdio::piped())
        .stderr(std::process::Stdio::piped())
        .spawn()
        .map(|mut child| {
            child.stdin.take().unwrap().write_all(b"Task").unwrap();
            child.wait_with_output().unwrap()
        })
        .unwrap();
    assert!(!output.status.success());
    assert!(String::from_utf8_lossy(&output.stderr).contains("No bound Codex session"));
}
