use anyhow::{ensure, Context, Result};
use std::fs;

fn process_fields(pid: u32) -> Result<Vec<String>> {
    let stat = fs::read_to_string(format!("/proc/{pid}/stat"))?;
    let (_, fields) = stat.rsplit_once(')').context("Invalid process stat")?;
    Ok(fields.split_whitespace().map(str::to_owned).collect())
}

pub fn process_identity(pid: u32) -> Result<String> {
    let fields = process_fields(pid)?;
    ensure!(
        fields.first().map(String::as_str) != Some("Z"),
        "Agent process has exited"
    );
    let start = fields.get(19).context("Missing process start time")?;
    let boot = fs::read_to_string("/proc/sys/kernel/random/boot_id")?;
    Ok(format!("{}:{start}", boot.trim()))
}

pub fn belongs_to_window(mut pid: u32, window_pid: u32) -> Result<bool> {
    while pid > 1 {
        if pid == window_pid {
            return Ok(true);
        }
        pid = process_fields(pid)?
            .get(1)
            .context("Missing parent PID")?
            .parse()?;
    }
    Ok(false)
}
