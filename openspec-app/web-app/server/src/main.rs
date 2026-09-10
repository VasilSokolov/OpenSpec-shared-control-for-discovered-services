//! opsx-web-server — a thin HTTP surface over the file-based OpsX control plane.
//!
//! It reuses `opsx-core` (the same read model + gate runners the Tauri desktop
//! app uses) and exposes a deliberately narrow, read-and-safe-gates-only API:
//! browse changes, read evidence, run the fetch-only preflight, and run the
//! read-only validator. It never exposes approval writes, worktree/bootstrap
//! provisioning, or the `claude -p` agent bridge — those stay desktop-only,
//! because putting process-spawning mutations on an HTTP endpoint is a much
//! larger blast radius. The listener also defaults to loopback.

use std::path::PathBuf;
use std::sync::Arc;

use axum::{
    extract::{Path, Query, State},
    http::StatusCode,
    response::IntoResponse,
    routing::{get, post},
    Json, Router,
};
use serde::Deserialize;
use serde_json::json;

use opsx_core::{changes, gates, resolve_control_root};

struct AppState {
    control_root: PathBuf,
}

type Shared = Arc<AppState>;

#[tokio::main]
async fn main() {
    tracing_subscriber::fmt()
        .with_env_filter(
            tracing_subscriber::EnvFilter::try_from_default_env()
                .unwrap_or_else(|_| "opsx_web_server=info,tower_http=info".into()),
        )
        .init();

    let control_root = resolve_control_root().unwrap_or_else(|e| {
        eprintln!("opsx-web-server: {e}");
        std::process::exit(1);
    });
    tracing::info!(root = %control_root.display(), "resolved control root");

    let state: Shared = Arc::new(AppState { control_root });

    let app = Router::new()
        .route("/api/health", get(|| async { "ok" }))
        .route("/api/control-root", get(control_root_handler))
        .route("/api/changes", get(list_changes_handler))
        .route("/api/changes/:id", get(get_change_handler))
        .route("/api/changes/:id/evidence", get(read_evidence_handler))
        .route("/api/preflight", post(preflight_handler))
        .route("/api/changes/:id/validate", post(validate_handler))
        .layer(tower_http::trace::TraceLayer::new_for_http())
        .with_state(state);

    // Loopback by default; docker-compose sets OPSX_WEB_ADDR=0.0.0.0:8787 and maps
    // the host port to 127.0.0.1 only, so the surface is never LAN-exposed.
    let addr = std::env::var("OPSX_WEB_ADDR").unwrap_or_else(|_| "127.0.0.1:8787".to_string());
    let listener = tokio::net::TcpListener::bind(&addr)
        .await
        .unwrap_or_else(|e| {
            eprintln!("opsx-web-server: cannot bind {addr}: {e}");
            std::process::exit(1);
        });
    tracing::info!(%addr, "opsx-web-server listening");
    axum::serve(listener, app)
        .await
        .expect("server error");
}

/// Map an `opsx-core` `Result<T, String>` into a JSON HTTP response. Errors are
/// surfaced to the client as 400 with the message; this is a local tool, not a
/// public API, so a single client-error status keeps the mapping honest.
fn respond<T: serde::Serialize>(result: Result<T, String>) -> axum::response::Response {
    match result {
        Ok(value) => Json(value).into_response(),
        Err(message) => (StatusCode::BAD_REQUEST, Json(json!({ "error": message }))).into_response(),
    }
}

async fn control_root_handler(State(state): State<Shared>) -> impl IntoResponse {
    Json(json!({ "control_root": state.control_root.to_string_lossy() }))
}

async fn list_changes_handler(State(state): State<Shared>) -> impl IntoResponse {
    respond(changes::list_changes(&state.control_root))
}

async fn get_change_handler(
    State(state): State<Shared>,
    Path(id): Path<String>,
) -> impl IntoResponse {
    respond(changes::get_change(&state.control_root, &id))
}

#[derive(Deserialize)]
struct EvidenceQuery {
    path: String,
}

async fn read_evidence_handler(
    State(state): State<Shared>,
    Path(id): Path<String>,
    Query(q): Query<EvidenceQuery>,
) -> impl IntoResponse {
    match changes::read_evidence(&state.control_root, &id, &q.path) {
        Ok(content) => Json(json!({ "path": q.path, "content": content })).into_response(),
        Err(message) => {
            (StatusCode::BAD_REQUEST, Json(json!({ "error": message }))).into_response()
        }
    }
}

async fn preflight_handler(State(state): State<Shared>) -> impl IntoResponse {
    let root = state.control_root.clone();
    let result = tokio::task::spawn_blocking(move || gates::run_preflight(&root))
        .await
        .unwrap_or_else(|e| Err(format!("preflight task failed: {e}")));
    respond(result)
}

async fn validate_handler(
    State(state): State<Shared>,
    Path(id): Path<String>,
) -> impl IntoResponse {
    let root = state.control_root.clone();
    let result = tokio::task::spawn_blocking(move || gates::run_validate(&root, &id))
        .await
        .unwrap_or_else(|e| Err(format!("validate task failed: {e}")));
    respond(result)
}
