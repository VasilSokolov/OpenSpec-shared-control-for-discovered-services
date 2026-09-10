# OpsX Web Console (Spring Boot)

A browser-based, **read-and-safe-gates-only** console over the file-based
OpenSpec SDLC control plane, rendered server-side with Thymeleaf + Bootstrap and
made interactive with HTMX. It is the Java sibling of the Rust web server in
`openspec-app/web-app/` and the Tauri desktop app in `openspec-app/desktop/`.

Use it when you want to browse changes and run the safe deterministic gates from
a browser without a Rust toolchain or the desktop app.

## Stack

- **Spring Boot 3.4** (`spring-boot-starter-web` + `spring-boot-starter-thymeleaf`), Java 21.
- **Thymeleaf** server-side rendering; **Bootstrap 5** + **HTMX** via WebJars (served at `/webjars/**`).
- **SnakeYAML** for the change-package read model.
- No SPA, no JS build step, no nginx — one process serves pages and API.

This project is **self-contained**: unlike the Rust server (which shares
`opsx-core` with the desktop app via a path dependency), the Java read model and
gate runners are reimplemented here in Java. That is a deliberate, accepted
consequence of the Java rewrite — the desktop app stays on Rust/`opsx-core`.

## What it can and cannot do

The HTTP surface is deliberately narrow because an HTTP endpoint has a larger
blast radius than the desktop app's capability/ACL model.

**Can (read + safe gates + approval toggle):**
- Browse active **and archived** changes on a **Jira-style Kanban board**
  (Proposed / Approved lanes + a read-only Archived lane).
- List and inspect change packages (proposal metadata, work items, evidence).
- Read a change's evidence files (path-traversal guarded, canonicalized under the change dir).
- Run the **fetch-only** Git preflight (`tools/git-preflight.sh`).
- Run the **read-only** change-package validator (`tools/validate-change-package.sh --change …`).
- **Approve / unapprove** an active change by dragging its card between the
  Proposed and Approved lanes (or via the detail-page buttons) — a reversible,
  comment-preserving single-line edit of the top-level `status:` in `approval.yaml`.
  It marks the change ready-to-apply; it does **not** run `/opsx:apply`. Archived
  changes are immutable (their cards cannot be dragged).
- **Copy the apply command** for an approved change — the card exposes a button
  that copies the exact `/opsx:apply <change>` string to the clipboard for you to
  run in Claude Code or the terminal. The console never executes it.

**Cannot (desktop-only, never over HTTP):**
- Run `/opsx:apply`, provision worktrees, or bootstrap code repos.
- Run the `claude -p /opsx:*` agent bridge.
- Archive / move changes (view-only for archives).

> **Scope note:** approval writes were added on top of the original
> "read + safe gates only" scope by explicit decision. The write is reversible,
> loopback-bound, touches only the `status:` line, and never spawns a process —
> so its blast radius stays small.

The server binds **loopback by default** (`127.0.0.1:8787`); the compose file
maps the host port to `127.0.0.1` only, so nothing is exposed on the LAN.

## Security posture (ported verbatim from the Rust core)

- Gates run via `ProcessBuilder` with a **fixed script path + explicit arg list**
  (`bash <script> <args…>`) — no shell string is ever interpolated, so there is
  no command-injection surface.
- Each gate run has a **120s hard timeout** (`git-preflight.sh` does a `git fetch`);
  on expiry the child is `destroyForcibly`-ed and a timed-out result is returned,
  so a network stall or credential prompt cannot pin a request thread. Both process
  streams are drained on daemon threads and closed, avoiding pipe deadlock and FD leaks.
- State-mutating POSTs (approve/unapprove/preflight/validate) require HTMX's
  `HX-Request: true` header (`HtmxCsrfFilter`). A cross-origin auto-submitted
  `<form>` is a "simple" request and cannot set that header, so this closes the
  CSRF / DNS-rebinding vector against the loopback port; read-only GETs are never gated.
- `SafePaths.isSafeId` validates every change id (single safe path segment).
- Evidence reads canonicalize the target and assert it stays under
  `context/evidence/` (path-traversal guard).
- No generic "run any command" endpoint; only preflight and validate exist.

## Run with docker-compose (recommended)

From `openspec-app/web-app-java/`:

```bash
docker compose up --build
```

Then open **http://127.0.0.1:8787**. The control repository is mounted into the
container at `/workspace` (the `../..` volume, i.e. this repo's root). Point that
volume elsewhere if your control repo lives at another path.

## Run locally without Docker

Requires a Maven install and a JDK 21+ on PATH, plus `bash` and `git`:

```bash
cd openspec-app/web-app-java
OPSX_CONTROL_ROOT=/absolute/path/to/control-repo mvn spring-boot:run
# serves on http://127.0.0.1:8787
```

If `OPSX_CONTROL_ROOT` is unset, the app walks up from the working directory
looking for a control root (`openspec/config.yaml` + `tools/git-preflight.sh`).

## Configuration

| Variable            | Default            | Meaning                                          |
| ------------------- | ------------------ | ------------------------------------------------ |
| `OPSX_CONTROL_ROOT` | walk up from cwd   | Absolute path to the control repository.         |
| `SERVER_ADDRESS`    | `127.0.0.1`        | Listen address (compose sets `0.0.0.0`).         |
| `SERVER_PORT`       | `8787`             | Listen port.                                     |

## Routes

| Method | Path                                 | Purpose                                   |
| ------ | ------------------------------------ | ----------------------------------------- |
| GET    | `/`                                  | Kanban board of active + archived changes. |
| GET    | `/changes/{id}`                      | One change (work items, evidence).        |
| GET    | `/changes/{id}/evidence?path=…`      | Evidence file (HTMX fragment).            |
| POST   | `/preflight`                         | Run the fetch-only Git preflight (HTMX).  |
| POST   | `/changes/{id}/validate`             | Run the change-package validator (HTMX).  |
| POST   | `/changes/{id}/approve`              | Set `approval.yaml` status to `approved` (HTMX). |
| POST   | `/changes/{id}/unapprove`            | Set `approval.yaml` status to `pending` (HTMX). |
| POST   | `/changes/{id}/move?to=approved\|proposed` | Drag-drop lane move; sets approval and re-renders the board (HTMX). |

> All POSTs require HTMX's `HX-Request` header (`HtmxCsrfFilter`), which the
> browser cannot attach to a cross-origin form submit — closing the CSRF vector
> against the loopback port.

## Known runtime limitation

`tools/git-preflight.sh` runs `git fetch`. Inside the container this may fail if
the mounted repo's remotes require credentials not present in the container
(no SSH agent / HTTPS creds). That surfaces as a non-zero exit in the preflight
result panel — expected, not a bug. Browsing, evidence reading, and validation
do not need network access and work regardless.
