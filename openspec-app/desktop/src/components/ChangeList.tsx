import type { ChangeSummary } from "../types";

type Lifecycle = "proposed" | "approved" | "implemented";

function lifecycle(c: ChangeSummary): Lifecycle {
  if (c.approval !== "approved") return "proposed";
  const done =
    c.work_items.length > 0 && c.work_items.every((w) => w.status === "implemented");
  return done ? "implemented" : "approved";
}

const GROUPS: Lifecycle[] = ["proposed", "approved", "implemented"];

export function ChangeList(props: {
  changes: ChangeSummary[];
  selected: string | null;
  onSelect: (id: string) => void;
}) {
  return (
    <nav className="changelist" aria-label="Changes">
      {props.changes.length === 0 && (
        <p className="changelist__empty muted">No changes found.</p>
      )}
      {GROUPS.map((group) => {
        const items = props.changes.filter((c) => lifecycle(c) === group);
        if (items.length === 0) return null;
        return (
          <section key={group}>
            <h2 className="changelist__group">{group}</h2>
            <ul>
              {items.map((c) => (
                <li key={c.id}>
                  <button
                    className={c.id === props.selected ? "is-active" : ""}
                    onClick={() => props.onSelect(c.id)}
                  >
                    <span className="changelist__id">{c.id}</span>
                    <span className={`pill pill--${c.approval}`}>{c.approval}</span>
                  </button>
                </li>
              ))}
            </ul>
          </section>
        );
      })}
    </nav>
  );
}
