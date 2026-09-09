## 0. Decisions and preconditions

- [ ] 0.1 Confirm Tauri v2 desktop app (vs VS Code extension / TUI / web app).
- [ ] 0.2 Confirm the frontend framework: Vite + React (default) vs Next.js
  static export (only if `@mde-ui` / mobile.de component reuse is the driver).
- [ ] 0.3 Confirm hosting: new `apps/console/` module in this control repo vs a
  separate repository.
- [ ] 0.4 Record the view/controller boundary: no governance logic reimplemented
  in Rust; YAML + scripts stay authoritative.
- [ ] 0.5 Record preconditions: Rust toolchain, Tauri v2 prerequisites, and (for
  the agent bridge) an authenticated headless Claude Code in the app environment.

## 1. Tauri v2 shell + Rust core

- [ ] 1.1 Scaffold `apps/console/` with `src-tauri/` (Rust) and the chosen
  frontend, pinned to Tauri v2.
- [ ] 1.2 Define the Tauri v2 capability/ACL files granting only the named
  commands below; deny broad `shell`/`fs` scopes.
- [ ] 1.3 Resolve the control-repo root from the app (config/env), not from a
  hardcoded path.

## 2. Change read model

- [ ] 2.1 Rust commands enumerate `openspec/changes/*/` and parse
  `proposal.md`/`design.md`/`tasks.md`/`workset.yaml`/`approval.yaml` with serde.
- [ ] 2.2 Expose a typed change list (id, status, approval state, work items,
  evidence paths, traceability) to the frontend.
- [ ] 2.3 Add a `notify` filesystem watcher that pushes live updates on package
  mutation. Parse defensively: missing/optional fields and unknown states must
  not crash.

## 3. Gate runners (one command per named script)

- [ ] 3.1 `preflight` → `tools/git-preflight.sh` (stream output, surface exit).
- [ ] 3.2 `validate` → `tools/validate-change-package.sh --change <dir>`.
- [ ] 3.3 `create_worktree` → `tools/router/create-worktree.sh` with validated,
  structured args (no free-form command string).
- [ ] 3.4 `bootstrap` → `tools/bootstrap-code-repo.sh` with validated args.
- [ ] 3.5 Confirm no generic command-execution command exists and no push
  command is exposed; preflight stays fetch-only; dirty tree is surfaced.

## 4. Agent bridge

- [ ] 4.1 `run_opsx` shells out to headless `claude -p` / Agent SDK for
  `/opsx:propose` and `/opsx:apply`, streaming the transcript to the UI.
- [ ] 4.2 Detect missing/invalid Claude credentials and fail with a clear
  message; make the bridge opt-in per action.

## 5. UI views

- [ ] 5.1 Changes dashboard grouped by lifecycle (proposed → approved → implemented).
- [ ] 5.2 Approval action that writes `approval.yaml` (surfacing required BA +
  engineering approvals) and reflects the resulting validator gate state.
- [ ] 5.3 Evidence / diff viewer over `context/evidence/` and changed files.
- [ ] 5.4 Workset task board (work items, status, worktree, branch, commit).
- [ ] 5.5 Gate runner panel wired to the section-3 commands with live output.

## 6. Packaging & observability

- [ ] 6.1 Local build/run instructions; small-footprint release config.
- [ ] 6.2 Log console actions to a file (structured), including every gate/agent
  invocation and its exit status.
- [ ] 6.3 (Deferred) macOS signing + notarization for team distribution.

## 7. Documentation

- [ ] 7.1 Update `README.md` / `openspec/project.md` with the console, the
  view/controller boundary, and the single-source-of-truth rule.
- [ ] 7.2 Add a runbook: open console → review change → run preflight/validate →
  approve → provision + bootstrap → stream apply → inspect evidence.

## 8. Verification

- [ ] 8.1 Read model renders the existing changes (`caraoke-workspace-integration`,
  `contract-fields-ui`, this change) with correct status/approval.
- [ ] 8.2 Each gate runner reproduces the CLI result (exit code + output) for a
  known change; validate matches `tools/validate-change-package.sh` directly.
- [ ] 8.3 Confirm the Tauri capability files grant only the named commands; a
  denied API call fails closed.
- [ ] 8.4 Confirm no push / no destructive caraoke op is reachable from the UI.

## 9. Scope guard

- [ ] 9.1 No governance logic reimplemented in Rust (scripts stay authoritative).
- [ ] 9.2 No change to any gate script, the change-package schema, or `/opsx:*`.
- [ ] 9.3 No product-code change in any governed service; caraoke unmodified.
