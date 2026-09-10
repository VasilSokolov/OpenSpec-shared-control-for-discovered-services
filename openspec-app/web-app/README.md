# OpsX Web Console

A browser-based, **read-and-safe-gates-only** view over the file-based OpenSpec
SDLC control plane. It is the web sibling of the Tauri desktop app in
`openspec-app/desktop/` and shares the same Rust core (`openspec-app/crates/opsx-core`).

Use it when you want to browse changes and run the safe deterministic gates from
a browser (locally, or on a host you control) without installing the desktop app.

## What it can and cannot do

The HTTP surface is deliberately narrow because an HTTP endpoint has a much
larger blast radius than the desktop app's capability/ACL model.

**Can (read + safe gates):**
- List and inspect change packages (`proposal`, `tasks`, `workset`, `approval`, work items).
- Read a change's evidence files (path-traversal guarded, canonicalized under the change dir).
- Run the **fetch-only** Git preflight (`tools/git-preflight.sh`).
- Run the **read-only** change-package validator (`tools/validate-change-package.sh --change …`).

**Cannot (desktop-only, never over HTTP):**
- Write approvals.
- Provision worktrees or bootstrap code repos.
- Run the `claude -p /opsx:*` agent bridge.

The server binds **loopback by default** (`127.0.0.1:8787`); the compose file
maps the host port to `127.0.0.1` only, so nothing is exposed on the LAN.

## Architecture

```
openspec-app/
├── crates/opsx-core/     shared Rust: read model + gate runners (no UI, no server)
├── desktop/              Tauri v2 desktop app  → uses opsx-core
└── web-app/
    ├── server/           axum HTTP server      → uses opsx-core (path dependency)
    ├── web/              Vite + React + TanStack Query frontend
    ├── Dockerfile.server multi-stage Rust build → slim runtime (bash + git)
    ├── Dockerfile.web    Node build → nginx (serves SPA, proxies /api → server)
    ├── docker-compose.yml
    └── nginx.conf
```

`opsx-core` is consumed by the server via a **path dependency**, not a Cargo
workspace — so building the server image never compiles the Tauri desktop app.

## Run with docker-compose (recommended)

From `openspec-app/web-app/`:

```bash
docker compose up --build
```

Then open **http://127.0.0.1:8080**. nginx serves the SPA and proxies `/api/*`
to the Rust server on the compose network.

The control repository is mounted into the server at `/workspace` (via the
`../..` volume in `docker-compose.yml`, i.e. this repo's root). Point that volume
elsewhere if your control repo lives at another path.

## Run locally without Docker

Terminal 1 — the server (needs a Rust toolchain, `bash`, and `git` on PATH):

```bash
cd openspec-app/web-app/server
OPSX_CONTROL_ROOT=/absolute/path/to/control-repo cargo run
# listens on 127.0.0.1:8787
```

Terminal 2 — the frontend dev server:

```bash
cd openspec-app/web-app/web
npm install
npm run dev
# Vite on http://localhost:5174, proxies /api → http://localhost:8787
```

Override the API target with `OPSX_API_TARGET` if the server runs elsewhere.

## Configuration

| Variable            | Where    | Default            | Meaning                                  |
| ------------------- | -------- | ------------------ | ---------------------------------------- |
| `OPSX_CONTROL_ROOT` | server   | walk up from cwd   | Absolute path to the control repository. |
| `OPSX_WEB_ADDR`     | server   | `127.0.0.1:8787`   | Listen address (compose sets `0.0.0.0`). |
| `OPSX_API_TARGET`   | vite dev | `http://localhost:8787` | Dev-proxy target for `/api`.        |

## HTTP API

| Method | Path                          | Purpose                                  |
| ------ | ----------------------------- | ---------------------------------------- |
| GET    | `/api/health`                 | Liveness (`ok`).                         |
| GET    | `/api/control-root`           | Resolved control-root path.              |
| GET    | `/api/changes`                | List change summaries.                   |
| GET    | `/api/changes/:id`            | One change (work items, evidence, etc.). |
| GET    | `/api/changes/:id/evidence?path=…` | Read one evidence file.             |
| POST   | `/api/preflight`              | Run the fetch-only Git preflight.        |
| POST   | `/api/changes/:id/validate`   | Run the change-package validator.        |

Errors are returned as `400` with `{ "error": "<message>" }`.

## Known runtime limitation

`tools/git-preflight.sh` runs `git fetch`. Inside the container this may fail if
the mounted repo's remotes require credentials that aren't present in the
container (no SSH agent / HTTPS creds). That surfaces as a non-zero exit in the
preflight command output — expected, not a bug. Browsing, evidence reading, and
validation do not need network access and work regardless.
