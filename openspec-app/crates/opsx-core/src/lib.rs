//! Shared OpsX core.
//!
//! The read model over the file-based control plane plus the pinned gate
//! runners live here — with no UI and no server. Both the Tauri desktop app
//! (`openspec-app/desktop`) and the axum web server (`openspec-app/web-app`)
//! depend on this crate, so the governance-facing logic (change parsing,
//! argument validation, script invocation) has exactly one implementation.
//!
//! This crate never reimplements a governance rule: validation and approval
//! semantics stay in the bash gates; here we only read files and invoke the
//! pinned scripts by fixed path with validated, structured arguments.

use std::path::{Path, PathBuf};

pub mod agent;
pub mod changes;
pub mod gates;

/// A directory is a control repository when it carries the config and the pinned
/// preflight script. Used to resolve the root without hardcoding a path.
pub fn is_control_root(dir: &Path) -> bool {
    dir.join("openspec/config.yaml").is_file() && dir.join("tools/git-preflight.sh").is_file()
}

/// Resolve the control repo from `OPSX_CONTROL_ROOT`, else by walking up from the
/// current directory. Never hardcoded.
pub fn resolve_control_root() -> Result<PathBuf, String> {
    if let Ok(p) = std::env::var("OPSX_CONTROL_ROOT") {
        let path = PathBuf::from(&p);
        return if is_control_root(&path) {
            Ok(path)
        } else {
            Err(format!("OPSX_CONTROL_ROOT is not a control repository: {p}"))
        };
    }
    let mut dir = std::env::current_dir().map_err(|e| e.to_string())?;
    loop {
        if is_control_root(&dir) {
            return Ok(dir);
        }
        if !dir.pop() {
            break;
        }
    }
    Err("could not locate the control repository; set OPSX_CONTROL_ROOT".to_string())
}
