import { useCallback, useEffect, useState } from "react";
import { listen } from "@tauri-apps/api/event";
import type { ChangeSummary } from "./types";
import { controlRoot, listChanges } from "./api";
import { ChangeList } from "./components/ChangeList";
import { ChangeDetail } from "./components/ChangeDetail";

export default function App() {
  const [changes, setChanges] = useState<ChangeSummary[]>([]);
  const [selected, setSelected] = useState<string | null>(null);
  const [root, setRoot] = useState<string>("");
  const [error, setError] = useState<string | null>(null);

  const refresh = useCallback(async () => {
    try {
      const list = await listChanges();
      setChanges(list);
      setError(null);
      setSelected((cur) =>
        cur && list.some((c) => c.id === cur) ? cur : list[0]?.id ?? null
      );
    } catch (e) {
      setError(String(e));
    }
  }, []);

  useEffect(() => {
    void refresh();
    void controlRoot().then(setRoot).catch(() => undefined);
  }, [refresh]);

  // Live updates: the Rust core emits `changes-updated` on any package mutation.
  useEffect(() => {
    const unlisten = listen("changes-updated", () => {
      void refresh();
    });
    return () => {
      void unlisten.then((f) => f());
    };
  }, [refresh]);

  const current = changes.find((c) => c.id === selected) ?? null;

  return (
    <div className="app">
      <header className="app__header">
        <div>
          <h1>OpsX Console</h1>
          {root && <span className="app__root" title={root}>{root}</span>}
        </div>
        <button onClick={() => void refresh()}>Refresh</button>
      </header>

      {error && <div className="banner banner--error">{error}</div>}

      <div className="app__body">
        <ChangeList changes={changes} selected={selected} onSelect={setSelected} />
        {current ? (
          <ChangeDetail key={current.id} change={current} onChanged={refresh} />
        ) : (
          <div className="detail detail--empty">Select a change to inspect.</div>
        )}
      </div>
    </div>
  );
}
