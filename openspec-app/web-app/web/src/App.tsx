import { useState } from "react";
import { useMutation, useQuery } from "@tanstack/react-query";
import { api } from "./api";
import { ChangeList } from "./components/ChangeList";
import { ChangeDetail } from "./components/ChangeDetail";
import { CommandResult } from "./components/CommandResult";

export default function App() {
  const [selectedId, setSelectedId] = useState<string | null>(null);
  const root = useQuery({ queryKey: ["control-root"], queryFn: api.controlRoot });
  const changes = useQuery({ queryKey: ["changes"], queryFn: api.listChanges });
  const preflight = useMutation({ mutationFn: api.preflight });

  return (
    <div className="app">
      <header className="topbar">
        <div>
          <h1>OpsX Web Console</h1>
          <p className="subtitle">Read-only view + safe gates over the file-based control plane</p>
        </div>
        <div className="topbar-actions">
          {root.data && <code className="root-path">{root.data.control_root}</code>}
          <button type="button" onClick={() => preflight.mutate()} disabled={preflight.isPending}>
            {preflight.isPending ? "Running preflight…" : "Run preflight"}
          </button>
        </div>
      </header>

      {preflight.isError && <div className="banner error">{(preflight.error as Error).message}</div>}
      {preflight.data && (
        <div className="preflight-result">
          <CommandResult output={preflight.data} />
        </div>
      )}

      <div className="body">
        <aside>
          {changes.isLoading && <div className="empty">Loading changes…</div>}
          {changes.isError && <div className="empty error">{(changes.error as Error).message}</div>}
          {changes.data &&
            (changes.data.length ? (
              <ChangeList changes={changes.data} selectedId={selectedId} onSelect={setSelectedId} />
            ) : (
              <div className="empty">No changes found.</div>
            ))}
        </aside>
        <main>
          {selectedId ? (
            <ChangeDetail key={selectedId} id={selectedId} />
          ) : (
            <div className="detail empty">Select a change to view its work items and evidence.</div>
          )}
        </main>
      </div>
    </div>
  );
}
