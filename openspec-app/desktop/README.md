# OpsX Console

A local desktop app that turns the file-based OpenSpec control plane into an
operable UI. Built with **Tauri v2** (Rust core) + **Vite / React / TypeScript**.

It is a **view/controller over the control plane, not a second source of truth**.
Every governance rule stays in the YAML change packages and the pinned bash gates
(`tools/git-preflight.sh`, `tools/validate-change-package.sh`,
`tools/router/create-worktree.sh`, `tools/bootstrap-code-repo.sh`). The Rust core
only *reads* those packages and *invokes* those scripts — it never reimplements
validation, approval, or preflight logic. If a script changes, the console
inherits the new behaviour for free.

## What it does

- **Changes dashboard** — every change under `openspec/changes/`, grouped by
  lifecycle (proposed → approved → implemented), with its approval state.
- **Change detail** — title, work items (status / module / commit), and the
  evidence files under `context/evidence/`.
- **Approve / set pending** — a single-line, comment-preserving edit to the
  change's `approval.yaml` `status:`.
- **Gate runners** — run **Preflight** and **Validate** for a change and see the
  exit code + stdout/stderr, identical to running the scripts on the CLI.
- **`/opsx:apply` bridge** — opt-in: shells out to headless Claude Code
  (`claude -p`) in the control root to run the apply workflow.
- **Evidence viewer** — open any evidence file in the change package.
- **Live updates** — a filesystem watcher refreshes the UI when a package changes.

## Prerequisites

- **Node.js** ≥ 18 and **Yarn** (v1 classic is fine).
- **Rust** (stable) + **Cargo** — <https://rustup.rs>.
- **Tauri v2 system dependencies** for your OS — see
  <https://v2.tauri.app/start/prerequisites/>. On macOS that is just Xcode
  Command Line Tools (`xcode-select --install`).
- The **Tauri CLI** (installed as a dev dependency below; or `cargo install
  tauri-cli --version '^2'`).
- For the `/opsx:apply` bridge only: an authenticated **`claude`** CLI on `PATH`.

## Install

```bash
cd openspec-app/desktop
yarn install
```

### Generate app icons (one-time)

Tauri needs a bundle icon set. Generate it from any square PNG (it is
`.gitignore`d, so do this locally):

```bash
yarn tauri icon path/to/logo.png    # writes src-tauri/icons/*
```

## Run (development)

```bash
cd openspec-app/desktop
yarn tauri dev
```

This starts Vite on `http://localhost:5173` and launches the desktop window
pointing at it, with hot reload for the frontend. The Rust core recompiles on
change.

By default the console locates the control repo by walking up from its working
directory until it finds `openspec/config.yaml` + `tools/git-preflight.sh`. To
point it elsewhere, set:

```bash
OPSX_CONTROL_ROOT=/path/to/control-repo yarn tauri dev
```

## Build (release)

```bash
cd openspec-app/desktop
yarn tauri build     # produces a signed-if-configured native bundle in src-tauri/target/release/bundle
```

macOS distribution to others additionally needs an Apple Developer identity +
notarization (deferred from the MVP).

## How to use

1. **Pick a change** in the left sidebar. It shows title, work items, and evidence.
2. **Preflight** — click *Preflight* to run the fetch-only freshness check. A
   dirty control tree or an unreachable remote surfaces here exactly as on the CLI.
3. **Validate** — click *Validate* to run the change-package gate. Green =
   `IMPLEMENTATION GATE PASSED`; a pending approval or missing file is reported.
4. **Approve** — click *Approve* to flip `approval.yaml` to `approved` (or *Set
   pending* to revert). Re-run *Validate* to confirm the gate now passes.
5. **Run `/opsx:apply`** — click it to stream a headless apply run (needs an
   authenticated `claude`). The console does not replace the agent; it launches it.
6. **Inspect evidence** — click any file under *Evidence* to read it inline.

## Security model

- **No generic command execution.** The frontend can only call the app's named
  commands (`run_preflight`, `run_validate`, `run_create_worktree`,
  `run_bootstrap`, `run_opsx`, plus read/approval commands). Each invokes a fixed
  script path with structured arguments — there is no `run(cmd: string)`.
- **Least-privilege ACL.** `src-tauri/capabilities/default.json` grants only
  `core:default`; no shell, fs, or http plugin scope is enabled.
- **No push, no destructive ops.** No command issues a push; preflight is
  fetch-only by the script's own guarantee; destructive caraoke operations
  (`make worktree-rm FORCE=1`) are never wired to a button.
- **Path-traversal guards.** Change ids are validated as single safe segments and
  evidence reads are confined to the change's `context/evidence/` directory.

## Layout

```
openspec-app/desktop/
├── index.html, vite.config.ts, tsconfig*.json, package.json
├── src/                      # React + TS frontend
│   ├── App.tsx               # layout, live-update listener
│   ├── api.ts, types.ts      # typed invoke() wrappers
│   └── components/           # ChangeList, ChangeDetail
└── src-tauri/                # Rust core
    ├── Cargo.toml, build.rs, tauri.conf.json
    ├── capabilities/default.json
    └── src/
        ├── main.rs, lib.rs   # entry, command registration, fs watcher
        ├── changes.rs        # read model + approval status edit
        ├── gates.rs          # one runner per pinned script
        └── agent.rs          # headless /opsx:* bridge
```
