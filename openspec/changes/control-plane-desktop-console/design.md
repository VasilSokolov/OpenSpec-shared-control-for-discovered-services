## Context

See proposal.md — Why. The control plane's state is entirely on disk (YAML/JSON/
Markdown change packages) and its behaviour is a set of deterministic bash gates
plus the `/opsx:*` agent workflow. This change adds a desktop console over that
state; it does not alter the state model or the gates.

No design source (Figma) applies — this is internal tooling / architecture.

Tauri v2 relevant facts that shape the design:
- The frontend is served as **static assets** by Tauri's asset protocol; there
  is no Node/SSR server in the bundle at runtime.
- The Rust "core" process exposes `#[tauri::command]` functions invoked from the
  frontend via `invoke()`; native access (filesystem, process spawn) lives there.
- Tauri v2 has a **capability/ACL permission system**: the frontend can only call
  the commands and use the APIs explicitly granted in the capability files.

## Goals / Non-Goals

**Goals:**
- Present the file-based control plane as an operable desktop UI (browse, review,
  approve, run gates, provision worktrees, stream an agent run).
- Keep the YAML packages + bash gates the single source of truth; the console is
  a view/controller only.
- Ship a signed, cross-platform native binary with a small footprint.
- Preserve every existing safety rail (fetch-only preflight, never-push,
  dirty-tree guard) at the console boundary.

**Non-Goals:**
- Reimplementing validation/approval/preflight logic in Rust.
- Replacing the `/opsx:*` agent loop.
- A hosted multi-user web deployment with server-side auth/RBAC.
- Tauri mobile targets.

## Key Decisions

### Tauri v2 (Rust core + web frontend), not Electron or a web app
**Decision**: Build a Tauri v2 desktop app. It gives native filesystem + process
access (needed to read change packages and invoke the gate scripts), a granular
capability/ACL security model, single-binary distribution, and a fraction of
Electron's footprint.
**Alternatives rejected**:
- *Electron* — much larger binary, ships a full Chromium + Node; no ACL model.
- *Local web app (localhost server)* — loses native FS/process integration and
  single-binary distribution; adds a server to run and secure.
- *VS Code extension* — viable and devs already live in the IDE; kept as a
  documented alternative (see open_questions), but it couples the console to the
  editor and its extension host lifecycle rather than being a standalone artefact.
- *TUI* — lightweight and matches the shell-first nature, but no evidence/diff
  viewer or rich dashboard.

### The console is a view/controller, never a second source of truth
**Decision**: All governance logic stays in the existing YAML schema and bash
gates. The Rust core reads the files and invokes the scripts; it must not
duplicate validation, approval, or preflight rules. If a rule changes in a
script, the console inherits it for free.
**Alternative rejected**: Porting validation/approval logic into Rust for a
"richer" UI — creates two sources of truth that drift; violates DRY and the
control plane's authority model.

### Frontend framework — Vite + React + TypeScript
**Decision**: Build the frontend with **Vite + React + TypeScript**, served by
Tauri's asset protocol. Because Tauri serves the frontend as static assets, a
server-side framework's core strengths (SSR, RSC, route handlers, middleware)
are dead weight here; Vite delivers the identical static-asset result with far
less config and lower maintenance. Node.js is a build-time-only dependency (Vite
tooling); nothing Node-related ships in the Tauri bundle.
**Chosen stack**:
- **Components/styling**: shadcn/ui + Tailwind — component source is vendored
  into the repo (no library lock-in or upgrade churn), Radix gives accessibility.
- **Data from Rust**: TanStack Query wraps every `invoke()`; a Tauri event from
  the `notify` watcher invalidates queries so the UI updates live.
- **UI state**: Zustand (selection, panel open/closed) — not server data.
- **Tables/boards**: TanStack Table (headless, styled with shadcn).
- **Routing**: React Router.
**Alternative rejected**: Next.js static export — its server half is unusable
under Tauri, so it adds framework weight and config for no runtime benefit. Only
revisit if reusing mobile.de's Next.js components / `@mde-ui` becomes a hard
driver.

### Rust core stays thin — orchestration and marshalling only
**Decision**: `#[tauri::command]` functions (a) parse change packages with
`serde_yaml`/`serde_json`, (b) invoke named scripts via `std::process::Command`,
(c) watch the filesystem with `notify` to push live updates. Business logic lives
in the scripts, not in Rust.
**Alternative rejected**: A "smart" Rust backend that models the workflow — see
the view/controller decision.

### No generic command execution — one runner per named gate
**Decision**: Expose one command per gate (`preflight`, `validate`,
`create_worktree`, `bootstrap`, `run_opsx`), each invoking a fixed script path
with validated, structured arguments. Never expose a `run(cmd: String)` command.
Grant only these commands in the Tauri v2 capability files; deny broad
`shell`/`fs` scopes.
**Alternative rejected**: A generic shell-passthrough command — a command-
injection and blast-radius hazard that would let the frontend run anything.

### Safety rails carried into the Rust boundary
**Decision**: The gate runners inherit the scripts' guarantees and add none that
weaken them: preflight stays fetch-only, no push command is exposed, and a
dirty-tree state is surfaced (not auto-resolved). Destructive caraoke operations
(`make worktree-rm FORCE=1`) are never wired to a button.

### Agent bridge is opt-in and observable
**Decision**: `run_opsx` shells out to headless Claude Code (`claude -p`) / the
Agent SDK and streams the transcript to the UI so the operator sees exactly what
the agent does. It is opt-in per action, not a background daemon.

## Risks / Trade-offs

- [Two sources of truth drift] → Rust never reimplements gate logic; it only
  parses files and invokes scripts. Enforced in review.
- [Command-injection / over-broad ACL] → One runner per named script with
  validated args; Tauri v2 capabilities grant only those commands; no generic
  shell scope.
- [Frontend framework rework] → Vite + React + TS is the committed decision;
  Next.js is rejected unless `@mde-ui` reuse becomes a hard driver. shadcn/ui
  components are vendored per view so the stack grows incrementally without an
  upgrade-churn dependency.
- [macOS signing / notarization] → Distribution to the team needs an Apple
  Developer identity + notarization; treat as a packaging precondition, deferred
  from the local-build MVP.
- [Headless agent auth in a GUI context] → `claude -p` must find valid
  credentials in the desktop app's environment; document the precondition and
  fail with a clear message, don't hide it.
- [Console outpaces the schema] → The read model must tolerate missing/optional
  fields and unknown change states rather than crash; parse defensively at the
  file boundary (the only untrusted-shape input).
