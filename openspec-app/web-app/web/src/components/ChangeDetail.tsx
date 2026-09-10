import { useState } from "react";
import { useMutation, useQuery } from "@tanstack/react-query";
import { api } from "../api";
import { CommandResult } from "./CommandResult";

export function ChangeDetail({ id }: { id: string }) {
  const change = useQuery({ queryKey: ["change", id], queryFn: () => api.getChange(id) });
  const validate = useMutation({ mutationFn: () => api.validate(id) });
  const [evidence, setEvidence] = useState<{ path: string; content: string } | null>(null);
  const [evidenceError, setEvidenceError] = useState<string | null>(null);

  if (change.isLoading) return <div className="detail empty">Loading…</div>;
  if (change.isError) return <div className="detail empty error">{(change.error as Error).message}</div>;
  const c = change.data!;

  const openEvidence = async (path: string) => {
    setEvidenceError(null);
    try {
      setEvidence(await api.readEvidence(id, path));
    } catch (e) {
      setEvidence(null);
      setEvidenceError((e as Error).message);
    }
  };

  return (
    <div className="detail">
      <div className="detail-head">
        <div>
          <h2>{c.id}</h2>
          {c.title && <p className="detail-title">{c.title}</p>}
          <p className="detail-meta">
            <span className={`badge badge-${c.approval}`}>{c.approval}</span>
            <span className="status-chip">{c.status || "unknown"}</span>
          </p>
        </div>
        <button type="button" onClick={() => validate.mutate()} disabled={validate.isPending}>
          {validate.isPending ? "Validating…" : "Validate"}
        </button>
      </div>

      {validate.isError && <div className="banner error">{(validate.error as Error).message}</div>}
      {validate.data && <CommandResult output={validate.data} />}

      <section>
        <h3>Work items</h3>
        {c.work_items.length ? (
          <table className="work-items">
            <thead>
              <tr>
                <th>ID</th>
                <th>Status</th>
                <th>Module</th>
                <th>Branch</th>
              </tr>
            </thead>
            <tbody>
              {c.work_items.map((w) => (
                <tr key={w.id}>
                  <td>{w.id}</td>
                  <td>
                    <span className={`badge badge-${w.status}`}>{w.status}</span>
                  </td>
                  <td>
                    <code>{w.module_id}</code>
                  </td>
                  <td>{w.branch || "—"}</td>
                </tr>
              ))}
            </tbody>
          </table>
        ) : (
          <p className="empty">No work items.</p>
        )}
      </section>

      <section>
        <h3>Evidence</h3>
        {c.evidence.length ? (
          <ul className="evidence-list">
            {c.evidence.map((path) => (
              <li key={path}>
                <button type="button" className="link" onClick={() => openEvidence(path)}>
                  {path}
                </button>
              </li>
            ))}
          </ul>
        ) : (
          <p className="empty">No evidence files.</p>
        )}
        {evidenceError && <div className="banner error">{evidenceError}</div>}
        {evidence && (
          <div className="evidence-view">
            <div className="evidence-head">
              <code>{evidence.path}</code>
            </div>
            <pre>{evidence.content}</pre>
          </div>
        )}
      </section>
    </div>
  );
}
