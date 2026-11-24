use serde_json::{json, Value};
use sha2::{Digest, Sha256};
use std::{
    env, fs,
    io::{BufRead, BufReader, Write},
    os::unix::fs::PermissionsExt,
    path::Path,
    process::{Child, Command, Stdio},
    thread,
    time::{Duration, Instant},
};

const BRIDGE: &str = env!("CARGO_BIN_EXE_openvide-claude");

fn write_message(writer: &mut impl Write, message: Value) {
    writeln!(writer, "{message}").unwrap();
    writer.flush().unwrap();
}

// Spawned as a fake Claude executable: the actual channel process and IPC are real.
#[test]
fn claude_fixture() {
    let Ok(config) = env::var("OPENVIDE_TEST_CONFIG") else {
        return;
    };
    let config: Value = serde_json::from_str(&config).unwrap();
    let server = &config["mcpServers"]["openvide"];
    for attempt in 0..2 {
        let mut channel = Command::new(server["command"].as_str().unwrap())
            .args(
                server["args"]
                    .as_array()
                    .unwrap()
                    .iter()
                    .map(|v| v.as_str().unwrap()),
            )
            .stdin(Stdio::piped())
            .stdout(Stdio::piped())
            .spawn()
            .unwrap();
        let mut input = channel.stdin.take().unwrap();
        let mut output = BufReader::new(channel.stdout.take().unwrap());
        write_message(
            &mut input,
            json!({"jsonrpc":"2.0","id":1,"method":"initialize",
        "params":{"protocolVersion":"2025-06-18","capabilities":{},"clientInfo":{"name":"test","version":"1"}}}),
        );
        let mut line = String::new();
        output.read_line(&mut line).unwrap();
        let initialized: Value = serde_json::from_str(&line).unwrap();
        assert_eq!(
            initialized["result"]["capabilities"]["experimental"]["claude/channel"],
            json!({})
        );
        write_message(
            &mut input,
            json!({"jsonrpc":"2.0","method":"notifications/initialized"}),
        );
        let path = Path::new(server["args"][3].as_str().unwrap());
        let deadline = Instant::now() + Duration::from_secs(5);
        loop {
            let binding: Value = serde_json::from_reader(fs::File::open(path).unwrap()).unwrap();
            if binding["channel_pid"] == channel.id() {
                break;
            }
            assert!(Instant::now() < deadline, "Channel never bound");
            thread::sleep(Duration::from_millis(10));
        }
        if attempt == 0 {
            // MCP reconnect: stop the channel but keep the same Claude terminal.
            drop(input);
            assert!(channel.wait().unwrap().success());
            continue;
        }
        fs::write(env::var_os("OPENVIDE_TEST_READY").unwrap(), "ready").unwrap();
        loop {
            line.clear();
            if output.read_line(&mut line).unwrap() == 0 {
                break;
            }
            let message: Value = serde_json::from_str(&line).unwrap();
            if message["method"] != "notifications/claude/channel" {
                continue;
            }
            fs::write(env::var_os("OPENVIDE_TEST_MESSAGE").unwrap(), &line).unwrap();
            let self_send = send(
                &env::current_dir().unwrap(),
                Path::new(&env::var_os("XDG_CACHE_HOME").unwrap()),
                std::process::id(),
                "self task",
            );
            assert!(!self_send.status.success());
            assert!(String::from_utf8_lossy(&self_send.stderr)
                .contains("Already running in the target Claude session"));
            if env::var("OPENVIDE_TEST_ACK").as_deref() == Ok("no") {
                continue;
            }
            write_message(
                &mut input,
                json!({"jsonrpc":"2.0","id":2,"method":"tools/call",
            "params":{"name":"acknowledge_task","arguments":{"task_id":message["params"]["meta"]["task_id"]}}}),
            );
        }
        drop(input);
        channel.wait().unwrap();
    }
}

struct Launcher(Child);
impl Drop for Launcher {
    fn drop(&mut self) {
        unsafe {
            libc::kill(self.0.id() as i32, libc::SIGTERM);
        }
        self.0.wait().unwrap();
    }
}

fn send(dir: &Path, cache: &Path, window: u32, message: &str) -> std::process::Output {
    let mut command = Command::new(BRIDGE)
        .arg("send")
        .arg(dir)
        .args(["--window-pid", &window.to_string()])
        .env("XDG_CACHE_HOME", cache)
        .stdin(Stdio::piped())
        .stdout(Stdio::piped())
        .stderr(Stdio::piped())
        .spawn()
        .unwrap();
    command
        .stdin
        .take()
        .unwrap()
        .write_all(message.as_bytes())
        .unwrap();
    command.wait_with_output().unwrap()
}

fn exercise(ack: bool) {
    let temp = tempfile::tempdir().unwrap();
    let dir = temp.path().canonicalize().unwrap();
    let cache = dir.join("cache");
    let bin = dir.join("bin");
    fs::create_dir(&bin).unwrap();
    let sh = Command::new("sh")
        .args(["-c", "command -v sh"])
        .output()
        .unwrap();
    fs::write(bin.join("claude"), format!(
        "#!{}\nexport OPENVIDE_TEST_CONFIG=\"$2\"\nexec \"$OPENVIDE_TEST_FIXTURE\" --exact claude_fixture --nocapture\n",
        String::from_utf8(sh.stdout).unwrap().trim())).unwrap();
    fs::set_permissions(bin.join("claude"), fs::Permissions::from_mode(0o755)).unwrap();
    let mut paths = vec![bin];
    paths.extend(env::split_paths(&env::var_os("PATH").unwrap()));
    let mut launcher = Launcher(
        Command::new(BRIDGE)
            .arg("launch")
            .arg(&dir)
            .env("PATH", env::join_paths(paths).unwrap())
            .env("XDG_CACHE_HOME", &cache)
            .env("OPENVIDE_TEST_FIXTURE", env::current_exe().unwrap())
            .env("OPENVIDE_TEST_MESSAGE", dir.join("message.json"))
            .env("OPENVIDE_TEST_READY", dir.join("ready"))
            .env("OPENVIDE_TEST_ACK", if ack { "yes" } else { "no" })
            .stdout(Stdio::null())
            .spawn()
            .unwrap(),
    );
    let key = format!("{:x}", Sha256::digest(dir.as_os_str().as_encoded_bytes()));
    let path = cache
        .join("caelestia/openvide/claude")
        .join(format!("{key}.json"));
    let deadline = Instant::now() + Duration::from_secs(5);
    let binding = loop {
        if let Ok(file) = fs::File::open(&path) {
            let binding: Value = serde_json::from_reader(file).unwrap();
            if binding["channel_pid"].is_number() && dir.join("ready").exists() {
                break binding;
            }
        }
        assert!(launcher.0.try_wait().unwrap().is_none(), "Launcher exited");
        assert!(Instant::now() < deadline, "Channel never initialized");
        thread::sleep(Duration::from_millis(10));
    };
    let window = std::process::id();
    let empty = send(&dir, &cache, window, " \n");
    assert!(!empty.status.success());
    assert!(String::from_utf8_lossy(&empty.stderr).contains("Task message is empty"));
    let wrong_window = send(&dir, &cache, 2147483647, "wrong terminal");
    assert!(!wrong_window.status.success());
    assert!(!dir.join("message.json").exists());
    let mut stale = binding.clone();
    stale["identity"] = json!("stale");
    fs::write(&path, stale.to_string()).unwrap();
    assert!(!send(&dir, &cache, window, "stale").status.success());
    fs::write(&path, binding.to_string()).unwrap();
    let mut unready = binding.clone();
    unready["channel_pid"] = Value::Null;
    fs::write(&path, unready.to_string()).unwrap();
    let unready = send(&dir, &cache, window, "unready");
    assert!(!unready.status.success());
    assert!(String::from_utf8_lossy(&unready.stderr).contains("not ready"));
    let mut wrong_checkout = binding.clone();
    wrong_checkout["directory"] = json!("/wrong/checkout");
    fs::write(&path, wrong_checkout.to_string()).unwrap();
    assert!(!send(&dir, &cache, window, "wrong checkout")
        .status
        .success());
    let mut stale_channel = binding.clone();
    stale_channel["channel_identity"] = json!("stale");
    fs::write(&path, stale_channel.to_string()).unwrap();
    assert!(!send(&dir, &cache, window, "stale channel").status.success());
    fs::write(&path, binding.to_string()).unwrap();
    let message = "Une tâche\navec 'quotes', $(touch NEVER_EXECUTE), `backticks` et émoji 🦆";
    let started = Instant::now();
    let second = if !ack {
        let dir = dir.clone();
        let cache = cache.clone();
        Some(thread::spawn(move || send(&dir, &cache, window, message)))
    } else {
        None
    };
    let result = send(&dir, &cache, window, message);
    assert!(
        result.status.success(),
        "{}",
        String::from_utf8_lossy(&result.stderr)
    );
    let receipt: Value = serde_json::from_slice(&result.stdout).unwrap();
    assert_eq!(receipt["acknowledged"], ack);
    if let Some(second) = second {
        let second = second.join().unwrap();
        assert!(
            second.status.success(),
            "{}",
            String::from_utf8_lossy(&second.stderr)
        );
        let other: Value = serde_json::from_slice(&second.stdout).unwrap();
        assert_eq!(other["status"], "forwarded");
        assert_ne!(other["task_id"], receipt["task_id"]);
        assert!(
            started.elapsed() < Duration::from_secs(38),
            "Receipts blocked subsequent tasks"
        );
    }
    assert_eq!(
        receipt["status"],
        if ack { "received" } else { "forwarded" }
    );
    let delivered: Value =
        serde_json::from_reader(fs::File::open(dir.join("message.json")).unwrap()).unwrap();
    assert_eq!(delivered["params"]["content"], message);
    assert!(!dir.join("NEVER_EXECUTE").exists());
    drop(launcher);
    assert!(!path.exists(), "Binding was not cleaned up");
    assert!(
        !Path::new(binding["socket"].as_str().unwrap()).exists(),
        "Socket was not cleaned up"
    );
}

#[test]
fn native_channel_receipt_and_rejected_targets() {
    exercise(true);
}

#[test]
fn unacknowledged_channel_never_claims_delivery() {
    exercise(false);
}
