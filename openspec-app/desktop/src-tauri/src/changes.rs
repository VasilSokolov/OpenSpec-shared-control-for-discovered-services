//! Read model over the file-based control plane.
//!
//! Parses the change packages under `openspec/changes/<id>/` defensively:
//! unknown/optional fields never crash the console. This module reads and makes
//! one surgical, single-line edit to `approval.yaml`; it never reimplements any
//! governance rule — validation and approval semantics stay in the bash gates.

use serde::Serialize;
use serde_yaml::Value;
use std::path::{Path, PathBuf};

#[derive(Serialize, Clone)]
pub struct WorkItem {
    pub id: String,
    pub status: String,
    pub module_id: String,
    pub branch: String,
    pub commit: String,
}

#[derive(Serialize, Clone)]
pub struct ChangeSummary {
    pub id: String,
    /// `.openspec.yaml` status (proposed/…).
    pub status: String,
    /// `approval.yaml` status (approved/pending/unknown).
    pub approval: String,
    pub title: String,
    pub work_items: Vec<WorkItem>,
    /// Paths relative to `context/evidence/`.
    pub evidence: Vec<String>,
}

/// A change id must be a single safe path segment (no traversal, no separators).
pub fn is_safe_id(id: &str) -> bool {
    !id.is_empty()
        && id.len() <= 128
        && id != "."
        && id != ".."
        && id
            .chars()
            .all(|c| c.is_ascii_alphanumeric() || c == '-' || c == '_' || c == '.')
}

/// A repository id, worktree path, or git ref handed to the router scripts.
/// Permits nested segments (`/`) for branch names and relative paths, but
/// forbids traversal (`..`), absolute paths, option-injection (leading `-`),
/// and any shell/whitespace metacharacters so the value can never escape the
/// control tree or be reinterpreted as a flag by the underlying git scripts.
pub fn is_safe_ref(s: &str) -> bool {
    !s.is_empty()
        && s.len() <= 200
        && !s.starts_with('/')
        && !s.starts_with('-')
        && !s.split('/').any(|seg| seg.is_empty() || seg == "." || seg == "..")
        && s
            .chars()
            .all(|c| c.is_ascii_alphanumeric() || c == '-' || c == '_' || c == '.' || c == '/')
}

pub fn changes_dir(root: &Path) -> PathBuf {
    root.join("openspec/changes")
}

fn read_yaml(path: &Path) -> Option<Value> {
    let text = std::fs::read_to_string(path).ok()?;
    serde_yaml::from_str(&text).ok()
}

fn str_field(v: &Value, key: &str) -> String {
    v.get(key)
        .and_then(|x| x.as_str())
        .unwrap_or("")
        .to_string()
}

pub fn list_changes(root: &Path) -> Result<Vec<ChangeSummary>, String> {
    let dir = changes_dir(root);
    let entries = std::fs::read_dir(&dir).map_err(|e| format!("{}: {e}", dir.display()))?;
    let mut out = Vec::new();
    for entry in entries.flatten() {
        let path = entry.path();
        if !path.is_dir() {
            continue;
        }
        let name = entry.file_name().to_string_lossy().to_string();
        if name == "archive" || !is_safe_id(&name) {
            continue;
        }
        if !path.join(".openspec.yaml").is_file() {
            continue;
        }
        out.push(load_change(root, &name)?);
    }
    out.sort_by(|a, b| a.id.cmp(&b.id));
    Ok(out)
}

pub fn get_change(root: &Path, id: &str) -> Result<ChangeSummary, String> {
    if !is_safe_id(id) {
        return Err(format!("invalid change id: {id}"));
    }
    load_change(root, id)
}

fn load_change(root: &Path, id: &str) -> Result<ChangeSummary, String> {
    let base = changes_dir(root).join(id);
    if !base.is_dir() {
        return Err(format!("change not found: {id}"));
    }

    let status = read_yaml(&base.join(".openspec.yaml"))
        .map(|v| str_field(&v, "status"))
        .unwrap_or_default();

    let approval = read_yaml(&base.join("approval.yaml"))
        .map(|v| str_field(&v, "status"))
        .filter(|s| !s.is_empty())
        .unwrap_or_else(|| "unknown".to_string());

    let title = read_yaml(&base.join("context/intake/work-item.yaml"))
        .map(|v| str_field(&v, "title"))
        .unwrap_or_default();

    let mut work_items = Vec::new();
    if let Some(ws) = read_yaml(&base.join("workset.yaml")) {
        if let Some(items) = ws.get("work_items").and_then(|x| x.as_sequence()) {
            for it in items {
                work_items.push(WorkItem {
                    id: str_field(it, "id"),
                    status: str_field(it, "status"),
                    module_id: str_field(it, "module_id"),
                    branch: str_field(it, "branch"),
                    commit: str_field(it, "commit"),
                });
            }
        }
    }

    Ok(ChangeSummary {
        id: id.to_string(),
        status,
        approval,
        title,
        work_items,
        evidence: list_evidence(&base),
    })
}

fn list_evidence(base: &Path) -> Vec<String> {
    let root = base.join("context/evidence");
    let mut files = Vec::new();
    collect_files(&root, &root, &mut files);
    files.sort();
    files
}

fn collect_files(root: &Path, dir: &Path, out: &mut Vec<String>) {
    let Ok(entries) = std::fs::read_dir(dir) else {
        return;
    };
    for entry in entries.flatten() {
        let path = entry.path();
        if path.is_dir() {
            collect_files(root, &path, out);
        } else if let Ok(rel) = path.strip_prefix(root) {
            out.push(rel.to_string_lossy().to_string());
        }
    }
}

pub fn read_evidence(root: &Path, id: &str, rel: &str) -> Result<String, String> {
    if !is_safe_id(id) {
        return Err(format!("invalid change id: {id}"));
    }
    let evidence_root = changes_dir(root).join(id).join("context/evidence");
    let canon_root = std::fs::canonicalize(&evidence_root).map_err(|e| e.to_string())?;
    let canon_target = std::fs::canonicalize(evidence_root.join(rel)).map_err(|e| e.to_string())?;
    // Path-traversal guard: the resolved file must stay under context/evidence/.
    if !canon_target.starts_with(&canon_root) {
        return Err("evidence path escapes the change directory".to_string());
    }
    std::fs::read_to_string(&canon_target).map_err(|e| e.to_string())
}

/// Toggle the top-level `status:` of `approval.yaml` with a single-line,
/// comment-preserving edit. It never rewrites the whole document (which would
/// drop comments and reorder keys) and it never touches any other field.
pub fn set_approval(root: &Path, id: &str, approved: bool) -> Result<ChangeSummary, String> {
    if !is_safe_id(id) {
        return Err(format!("invalid change id: {id}"));
    }
    let path = changes_dir(root).join(id).join("approval.yaml");
    let text = std::fs::read_to_string(&path).map_err(|e| e.to_string())?;
    let new_status = if approved { "approved" } else { "pending" };

    let mut replaced = false;
    let mut lines: Vec<String> = Vec::with_capacity(text.lines().count());
    for line in text.lines() {
        if !replaced && line.starts_with("status:") {
            lines.push(format!("status: {new_status}"));
            replaced = true;
        } else {
            lines.push(line.to_string());
        }
    }
    if !replaced {
        return Err("no top-level `status:` line in approval.yaml".to_string());
    }
    let mut new_text = lines.join("\n");
    if text.ends_with('\n') {
        new_text.push('\n');
    }
    std::fs::write(&path, new_text).map_err(|e| e.to_string())?;
    load_change(root, id)
}
