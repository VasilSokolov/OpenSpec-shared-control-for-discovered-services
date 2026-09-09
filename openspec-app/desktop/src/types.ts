export interface WorkItem {
  id: string;
  status: string;
  module_id: string;
  branch: string;
  commit: string;
}

export interface ChangeSummary {
  id: string;
  /** `.openspec.yaml` status. */
  status: string;
  /** `approval.yaml` status: approved | pending | unknown. */
  approval: string;
  title: string;
  work_items: WorkItem[];
  /** Paths relative to `context/evidence/`. */
  evidence: string[];
}

export interface CommandOutput {
  script: string;
  args: string[];
  exit_code: number | null;
  stdout: string;
  stderr: string;
}

export type OpsxPhase = "propose" | "apply" | "verify";
