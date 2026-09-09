## Why

This control repository is a governance control plane for specification-driven
development. Its entire operational state is **files on disk**: OpenSpec change
packages under `openspec/changes/<change>/` (`proposal.md`, `design.md`,
`tasks.md`, `workset.yaml`, `approval.yaml`), evidence, work logs, and the
acceptance-traceability matrix. Its behaviour is a set of deterministic **shell
gates** (`tools/git-preflight.sh`, `tools/validate-change-package.sh`,
`tools/router/create-worktree.sh`, `tools/bootstrap-code-repo.sh`) plus the
`/opsx:*` agent workflow that Claude drives on top of them.

Today the only surface over this state is the CLI and a text editor. There is no
at-a-glance view of "which changes are proposed vs approved vs implemented",
no one-click approval, no evidence/diff viewer, and no guided runner for the
gates. Operators reconstruct the picture by reading YAML by hand.

This change proposes a **desktop console** — a Tauri v2 application (Rust core +
web frontend) — that presents the file-based control plane as an operable UI:
browse changes, review evidence and traceability, run the preflight/validate
gates, trigger worktree provisioning + bootstrap, and stream an `/opsx:*` agent
run. The app is a **view/controller over the existing state and scripts, not a
reimplementation of them** — the YAML packages and bash gates remain the single
source of truth.

There is no Jira ticket and no design source for this change; it is internal
tooling / architecture. It is recorded with `status: proposed` and kept
unapprovable (see `approval.yaml`) until the framework and hosting decisions in
`open_questions` are confirmed.

## What Changes

- **Desktop shell (Tauri v2)**: a new `apps/console/` module — a Tauri v2 app
  whose Rust core is a thin orchestration layer and whose frontend is a web UI.
  Distributed as a signed, cross-platform native binary (not Electron).
- **Read model over change packages**: Rust `#[tauri::command]` functions
  enumerate `openspec/changes/*/`, parse the YAML/JSON/Markdown with `serde`,
  and expose a typed change list (id, status, approval state, work items,
  evidence, traceability) to the frontend. A filesystem watcher (`notify`)
  pushes live updates as opsx runs mutate the packages.
- **Gate runners**: scoped Rust commands wrap the existing scripts
  (`git-preflight.sh`, `validate-change-package.sh`, `create-worktree.sh`,
  `bootstrap-code-repo.sh`) via `std::process::Command`, stream their output,
  and surface exit status. No generic "run arbitrary command" command is
  exposed; each runner invokes one named script with validated arguments.
- **Agent bridge**: an opt-in command shells out to headless Claude Code
  (`claude -p …`) / the Agent SDK to run `/opsx:propose` and `/opsx:apply`,
  streaming the transcript into the UI. The console *complements* the agent
  loop; it does not replace it.
- **UI views**: a changes dashboard (proposed → approved → implemented), an
  approval action wired to `approval.yaml`, an evidence/diff viewer, a workset
  task board, and a preflight/validate runner panel.

## Capabilities

### New Capabilities
- `control-plane-console`: a desktop UI that renders the file-based control
  plane state and lets an operator drive the governed workflow.
- `gate-runner-bridge`: named, argument-validated invocation of the pinned
  control scripts from the desktop app, with streamed output and exit status.
- `agent-run-bridge`: opt-in headless `/opsx:*` execution surfaced with a live
  transcript in the console.

### Modified Capabilities
- none. The console reads and invokes existing artefacts; it does not change the
  gates, the change-package schema, or the `/opsx:*` workflow contract.

## Impact

- `apps/console/` (new) — Tauri v2 project: `src-tauri/` (Rust core, ACL
  capabilities, gate + agent bridges, change read model) and the frontend
  (framework decision pending — see `design.md`).
- `openspec/project.md` / `README.md` — document the console, the
  view/controller boundary, and the "single source of truth is the files +
  scripts" rule.
- No change to any gate script, the change-package schema, or `/opsx:*` behaviour.
- No product code in any governed service is modified.
- `caraoke-workspace` is not modified; the console invokes control scripts that
  already integrate with it.

## Out of Scope

- Reimplementing governance logic (validation, approval rules, preflight) in
  Rust — the scripts stay authoritative; the console only invokes them.
- Replacing Claude Code / the `/opsx:*` agent loop with the desktop app.
- A hosted/web multi-user deployment (server, auth, RBAC) — this is a local,
  single-operator desktop tool.
- Mobile (Tauri mobile) targets.
- CI wiring for building/signing the app (a later change once the local app works).
