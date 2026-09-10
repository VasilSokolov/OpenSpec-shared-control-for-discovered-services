//! Agent bridge: opt-in headless `/opsx:*` runs.
//!
//! Shells out to headless Claude Code (`claude -p`) in the control root. This is
//! the only bridge to the agent loop; the console does not embed or replace it.
//! Requires an authenticated `claude` on PATH — a missing/failed launch returns
//! a clear error rather than failing silently.

use std::path::Path;
use std::process::Command;

use crate::changes::is_safe_id;
use crate::gates::CommandOutput;

pub fn run_opsx(root: &Path, phase: &str, id: &str) -> Result<CommandOutput, String> {
    let phase = match phase {
        "propose" | "apply" | "verify" => phase,
        other => return Err(format!("unsupported opsx phase: {other}")),
    };
    if !is_safe_id(id) {
        return Err(format!("invalid change id: {id}"));
    }

    let prompt = format!("/opsx:{phase}");
    let output = Command::new("claude")
        .arg("-p")
        .arg(&prompt)
        .current_dir(root)
        .env("OPSX_CHANGE_ID", id)
        .output()
        .map_err(|e| {
            format!("failed to launch headless Claude Code (is `claude` installed and authenticated?): {e}")
        })?;

    Ok(CommandOutput {
        script: format!("claude -p {prompt}"),
        args: vec![id.to_string()],
        exit_code: output.status.code(),
        stdout: String::from_utf8_lossy(&output.stdout).to_string(),
        stderr: String::from_utf8_lossy(&output.stderr).to_string(),
    })
}
