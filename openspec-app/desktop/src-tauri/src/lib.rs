//! OpsX Console — thin Tauri v2 core.
//!
//! The Rust side is orchestration only: it parses the change packages, invokes
//! the pinned gate scripts, bridges to headless `/opsx:*`, and watches the
//! filesystem for live updates. All governance logic stays in the YAML packages
//! and the bash gates — this crate never reimplements it.

use std::path::{Path, PathBuf};
use tauri::{Emitter, Manager, State};

mod agent;
mod changes;
mod gates;

use changes::ChangeSummary;
use gates::CommandOutput;

pub struct AppState {
    pub control_root: PathBuf,
}

fn is_control_root(dir: &Path) -> bool {
    dir.join("openspec/config.yaml").is_file() && dir.join("tools/git-preflight.sh").is_file()
}

/// Resolve the control repo from `OPSX_CONTROL_ROOT`, else by walking up from the
/// current directory. Never hardcoded.
fn resolve_control_root() -> Result<PathBuf, String> {
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

#[tauri::command]
fn control_root(state: State<'_, AppState>) -> String {
    state.control_root.to_string_lossy().to_string()
}

#[tauri::command]
fn list_changes(state: State<'_, AppState>) -> Result<Vec<ChangeSummary>, String> {
    changes::list_changes(&state.control_root)
}

#[tauri::command]
fn get_change(state: State<'_, AppState>, id: String) -> Result<ChangeSummary, String> {
    changes::get_change(&state.control_root, &id)
}

#[tauri::command]
fn read_evidence(state: State<'_, AppState>, id: String, path: String) -> Result<String, String> {
    changes::read_evidence(&state.control_root, &id, &path)
}

#[tauri::command]
fn set_approval(
    state: State<'_, AppState>,
    id: String,
    approved: bool,
) -> Result<ChangeSummary, String> {
    changes::set_approval(&state.control_root, &id, approved)
}

#[tauri::command]
async fn run_preflight(state: State<'_, AppState>) -> Result<CommandOutput, String> {
    let root = state.control_root.clone();
    tauri::async_runtime::spawn_blocking(move || gates::run_preflight(&root))
        .await
        .map_err(|e| e.to_string())?
}

#[tauri::command]
async fn run_validate(state: State<'_, AppState>, id: String) -> Result<CommandOutput, String> {
    let root = state.control_root.clone();
    tauri::async_runtime::spawn_blocking(move || gates::run_validate(&root, &id))
        .await
        .map_err(|e| e.to_string())?
}

#[tauri::command]
async fn run_create_worktree(
    state: State<'_, AppState>,
    repository: String,
    worktree: String,
    branch: String,
    base: String,
) -> Result<CommandOutput, String> {
    let root = state.control_root.clone();
    tauri::async_runtime::spawn_blocking(move || {
        gates::run_create_worktree(&root, repository, worktree, branch, base)
    })
    .await
    .map_err(|e| e.to_string())?
}

#[tauri::command]
async fn run_bootstrap(state: State<'_, AppState>, repo: String) -> Result<CommandOutput, String> {
    let root = state.control_root.clone();
    tauri::async_runtime::spawn_blocking(move || gates::run_bootstrap(&root, repo))
        .await
        .map_err(|e| e.to_string())?
}

#[tauri::command]
async fn run_opsx(
    state: State<'_, AppState>,
    phase: String,
    id: String,
) -> Result<CommandOutput, String> {
    let root = state.control_root.clone();
    tauri::async_runtime::spawn_blocking(move || agent::run_opsx(&root, &phase, &id))
        .await
        .map_err(|e| e.to_string())?
}

/// Emit `changes-updated` whenever anything under `openspec/changes/` changes.
/// Owns the watcher for the app's lifetime by blocking on the event channel.
fn watch_changes(root: PathBuf, app: tauri::AppHandle) {
    use notify::{RecursiveMode, Watcher};
    let changes_dir = root.join("openspec/changes");
    let (tx, rx) = std::sync::mpsc::channel();
    let mut watcher = match notify::recommended_watcher(tx) {
        Ok(w) => w,
        Err(_) => return,
    };
    if watcher.watch(&changes_dir, RecursiveMode::Recursive).is_err() {
        return;
    }
    for res in rx {
        if res.is_ok() {
            let _ = app.emit("changes-updated", ());
        }
    }
}

#[cfg_attr(mobile, tauri::mobile_entry_point)]
pub fn run() {
    let control_root = resolve_control_root().unwrap_or_else(|e| {
        eprintln!("OpsX Console: {e}");
        std::process::exit(1);
    });

    tauri::Builder::default()
        .manage(AppState {
            control_root: control_root.clone(),
        })
        .setup(move |app| {
            let handle = app.handle().clone();
            let root = control_root.clone();
            std::thread::spawn(move || watch_changes(root, handle));
            Ok(())
        })
        .invoke_handler(tauri::generate_handler![
            control_root,
            list_changes,
            get_change,
            read_evidence,
            set_approval,
            run_preflight,
            run_validate,
            run_create_worktree,
            run_bootstrap,
            run_opsx
        ])
        .run(tauri::generate_context!())
        .expect("error while running OpsX Console");
}
