import { useState } from "react";
import type { ChangeSummary, CommandOutput } from "../types";
import { readEvidence, runOpsx, runPreflight, runValidate, setApproval } from "../api";

export function ChangeDetail(props: {
  change: ChangeSummary;
  onChanged: () => Promise<void>;
}) {
  const { change } = props;
  const [output, setOutput] = useState<CommandOutput | null>(null);
  const [evidence, setEvidence] = useState<{ path: string; body: string } | null>(null);
  const [busy, setBusy] = useState<string | null>(null);
  const [err, setErr] = useState<string | null>(null);

  const run = async (label: string, fn: () => Promise<CommandOutput>) => {
    setBusy(label);
    setErr(null);
    setEvidence(null);
    try {
      setOutput(await fn());
    } catch (e) {
      setErr(String(e));
      setOutput(null);
    } finally {
      setBusy(null);
    }
  };

  const toggleApproval = async () => {
    setBusy("approval");
    setErr(null);
    try {
      await setApproval(change.id, change.approval !== "approved");
      await props.onChanged();
    } catch (e) {
      setErr(String(e));
    } finally {
      setBusy(null);
    }
  };

  const openEvidence = async (path: string) => {
    setErr(null);
    setOutput(null);
    try {
      setEvidence({ path, body: await readEvidence(change.id, path) });
    } catch (e) {
      setErr(String(e));
    }
  };

  const approved = change.approval === "approved";

  return (
    <div className="detail">
      <div className="detail__head">
        <div>
          <h2>{change.id}</h2>
          <p className="detail__title">{change.title || "—"}</p>
        </div>
        <div className="detail__approval">
          <span className={`pill pill--${change.approval}`}>{change.approval}</span>
          <button disabled={busy !== null} onClick={() => void toggleApproval()}>
            {busy === "approval" ? "Saving…" : approved ? "Set pending" : "Approve"}
          </button>
        </div>
      </div>

      <div className="detail__actions">
        <button disabled={busy !== null} onClick={() => void run("preflight", runPreflight)}>
          {busy === "preflight" ? "Running…" : "Preflight"}
        </button>
        <button
          disabled={busy !== null}
          onClick={() => void run("validate", () => runValidate(change.id))}
        >
          {busy === "validate" ? "Running…" : "Validate"}
        </button>
        <button
          disabled={busy !== null}
          title="Streams a headless /opsx:apply run (requires an authenticated claude CLI)"
          onClick={() => void run("apply", () => runOpsx("apply", change.id))}
        >
          {busy === "apply" ? "Running…" : "Run /opsx:apply"}
        </button>
      </div>

      {err && <div className="banner banner--error">{err}</div>}

      <section className="detail__grid">
        <div>
          <h3>Work items</h3>
          <table className="workitems">
            <tbody>
              {change.work_items.length === 0 && (
                <tr>
                  <td className="muted">none</td>
                </tr>
              )}
              {change.work_items.map((w) => (
                <tr key={w.id}>
                  <td>{w.id}</td>
                  <td>
                    <span className="pill">{w.status || "—"}</span>
                  </td>
                  <td className="mono">{w.module_id}</td>
                  <td className="mono">{w.commit}</td>
                </tr>
              ))}
            </tbody>
          </table>

          <h3>Evidence</h3>
          <ul className="evidence">
            {change.evidence.length === 0 && <li className="muted">none yet</li>}
            {change.evidence.map((p) => (
              <li key={p}>
                <button className="link" onClick={() => void openEvidence(p)}>
                  {p}
                </button>
              </li>
            ))}
          </ul>
        </div>

        <div>
          <h3>Output</h3>
          {output && (
            <div>
              <div className={`exit ${output.exit_code === 0 ? "exit--ok" : "exit--bad"}`}>
                {output.script} → exit {output.exit_code ?? "signal"}
              </div>
              {output.stdout && <pre>{output.stdout}</pre>}
              {output.stderr && <pre className="stderr">{output.stderr}</pre>}
            </div>
          )}
          {evidence && (
            <div>
              <div className="exit">{evidence.path}</div>
              <pre>{evidence.body}</pre>
            </div>
          )}
          {!output && !evidence && (
            <p className="muted">Run a gate or open an evidence file to see output here.</p>
          )}
        </div>
      </section>
    </div>
  );
}
