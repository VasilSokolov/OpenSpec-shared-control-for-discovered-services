//! Gate runners: one function per pinned control script. Each invokes a fixed
//! script path under the control root with structured, validated arguments.
//! There is deliberately no generic "run any command" entry point, and no push
//! is ever issued (preflight is fetch-only by the script's own guarantee).

use serde::Serialize;
use std::path::Path;
use std::process::Command;

use crate::changes::{is_safe_id, is_safe_ref};

#[derive(Serialize)]
pub struct CommandOutput {
    pub script: String,
    pub args: Vec<String>,
    pub exit_code: Option<i32>,
    pub stdout: String,
    pub stderr: String,
}

fn run_script(root: &Path, script_rel: &str, args: &[String]) -> Result<CommandOutput, String> {
    let script = root.join(script_rel);
    if !script.is_file() {
        return Err(format!("pinned script not found: {}", script.display()));
    }
    // `bash <script> <args...>` — no shell string is ever interpolated, so no
    // command-injection surface exists even when args carry user input.
    let output = Command::new("bash")
        .arg(&script)
        .args(args)
        .current_dir(root)
        .output()
        .map_err(|e| format!("failed to run {script_rel}: {e}"))?;

    Ok(CommandOutput {
        script: script_rel.to_string(),
        args: args.to_vec(),
        exit_code: output.status.code(),
        stdout: String::from_utf8_lossy(&output.stdout).to_string(),
        stderr: String::from_utf8_lossy(&output.stderr).to_string(),
    })
}

pub fn run_preflight(root: &Path) -> Result<CommandOutput, String> {
    run_script(root, "tools/git-preflight.sh", &[])
}

pub fn run_validate(root: &Path, id: &str) -> Result<CommandOutput, String> {
    if !is_safe_id(id) {
        return Err(format!("invalid change id: {id}"));
    }
    let change_dir = format!("openspec/changes/{id}");
    run_script(
        root,
        "tools/validate-change-package.sh",
        &["--change".to_string(), change_dir],
    )
}

pub fn run_create_worktree(
    root: &Path,
    repository: String,
    worktree: String,
    branch: String,
    base: String,
) -> Result<CommandOutput, String> {
    for (label, value) in [
        ("repository", &repository),
        ("worktree", &worktree),
        ("branch", &branch),
        ("base", &base),
    ] {
        if !is_safe_ref(value) {
            return Err(format!("invalid {label}: {value}"));
        }
    }
    run_script(
        root,
        "tools/router/create-worktree.sh",
        &[
            "--repository".to_string(),
            repository,
            "--worktree".to_string(),
            worktree,
            "--branch".to_string(),
            branch,
            "--base".to_string(),
            base,
        ],
    )
}

pub fn run_bootstrap(root: &Path, repo: String) -> Result<CommandOutput, String> {
    if !is_safe_ref(&repo) {
        return Err(format!("invalid repo: {repo}"));
    }
    run_script(
        root,
        "tools/bootstrap-code-repo.sh",
        &["--repo".to_string(), repo],
    )
}
