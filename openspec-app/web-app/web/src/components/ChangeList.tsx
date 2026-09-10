import type { ChangeSummary } from "../types";

const ORDER = ["proposed", "approved", "implemented"];

function rank(status: string): number {
  const i = ORDER.indexOf(status);
  return i === -1 ? ORDER.length : i;
}

export function ChangeList({
  changes,
  selectedId,
  onSelect,
}: {
  changes: ChangeSummary[];
  selectedId: string | null;
  onSelect: (id: string) => void;
}) {
  const groups = new Map<string, ChangeSummary[]>();
  for (const c of changes) {
    const key = c.status || "unknown";
    const list = groups.get(key) ?? [];
    list.push(c);
    groups.set(key, list);
  }
  const keys = [...groups.keys()].sort((a, b) => rank(a) - rank(b) || a.localeCompare(b));

  return (
    <nav className="change-list">
      {keys.map((k) => (
        <section key={k}>
          <h3 className="group-title">{k}</h3>
          <ul>
            {groups.get(k)!.map((c) => (
              <li key={c.id}>
                <button
                  type="button"
                  className={c.id === selectedId ? "change-item selected" : "change-item"}
                  aria-current={c.id === selectedId}
                  onClick={() => onSelect(c.id)}
                >
                  <span className="change-id">{c.id}</span>
                  <span className={`badge badge-${c.approval}`}>{c.approval}</span>
                </button>
              </li>
            ))}
          </ul>
        </section>
      ))}
    </nav>
  );
}
