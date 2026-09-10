// Mirrors the serde types returned by opsx-core (see crates/opsx-core).

export interface WorkItem {
  id: string;
  status: string;
  module_id: string;
  branch: string;
  commit: string;
}

export interface ChangeSummary {
  id: string;
  status: string;
  approval: string;
  title: string;
  work_items: WorkItem[];
  evidence: string[];
}

export interface CommandOutput {
  script: string;
  args: string[];
  exit_code: number | null;
  stdout: string;
  stderr: string;
}
