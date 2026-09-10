import type { ChangeSummary, CommandOutput } from "./types";

async function req<T>(url: string, init?: RequestInit): Promise<T> {
  const res = await fetch(url, init);
  const body = await res.json().catch(() => ({}));
  if (!res.ok) {
    const message = (body as { error?: string }).error ?? `request failed: ${res.status}`;
    throw new Error(message);
  }
  return body as T;
}

export const api = {
  controlRoot: () => req<{ control_root: string }>("/api/control-root"),
  listChanges: () => req<ChangeSummary[]>("/api/changes"),
  getChange: (id: string) => req<ChangeSummary>(`/api/changes/${encodeURIComponent(id)}`),
  readEvidence: (id: string, path: string) =>
    req<{ path: string; content: string }>(
      `/api/changes/${encodeURIComponent(id)}/evidence?path=${encodeURIComponent(path)}`,
    ),
  preflight: () => req<CommandOutput>("/api/preflight", { method: "POST" }),
  validate: (id: string) =>
    req<CommandOutput>(`/api/changes/${encodeURIComponent(id)}/validate`, { method: "POST" }),
};
