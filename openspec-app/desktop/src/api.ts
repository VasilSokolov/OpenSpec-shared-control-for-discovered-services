import { invoke } from "@tauri-apps/api/core";
import type { ChangeSummary, CommandOutput, OpsxPhase } from "./types";

export const controlRoot = () => invoke<string>("control_root");
export const listChanges = () => invoke<ChangeSummary[]>("list_changes");
export const getChange = (id: string) => invoke<ChangeSummary>("get_change", { id });
export const readEvidence = (id: string, path: string) =>
  invoke<string>("read_evidence", { id, path });
export const setApproval = (id: string, approved: boolean) =>
  invoke<ChangeSummary>("set_approval", { id, approved });

export const runPreflight = () => invoke<CommandOutput>("run_preflight");
export const runValidate = (id: string) => invoke<CommandOutput>("run_validate", { id });
export const runOpsx = (phase: OpsxPhase, id: string) =>
  invoke<CommandOutput>("run_opsx", { phase, id });
