# /opsx:propose

Before doing anything else, run the repository's pinned Git preflight
(`tools/git-preflight.sh` in control, `.claude/tools/git-preflight.sh` in a
bootstrapped code repository). If it fails, stop.

Create or resume a feature-based OpenSpec change in the control repository.
When a ticket key is supplied, call the configured `fetch_jira_ticket` MCP
tool. Show the current user's active Jira work only when a separate Jira
search/list tool is configured; otherwise ask for a ticket key. Accept pasted
Jira details or screenshots when connectors are unavailable. Discover affected
repositories, modules, dependencies, contracts, tests, observability, and
deployment requirements. Generate proposal, design, tasks, delta specs,
worksets, and approval records. Do not implement product code.

Before generating implementation tasks, enforce this source-first gate:

1. Preserve the Jira response and normalize its acceptance criteria.
2. Resolve the exact Figma URL, file key, node ID, and visual source. A node
   ID or a `Ready` label alone is not visual evidence.
3. If Figma access is unavailable, accept a user-provided screenshot/export and
   record its source and timestamp; otherwise leave the change pending.
4. Reconcile the Figma scope with the Jira acceptance criteria. If the ticket
   mentions one section, do not generate tasks for other sections. If Jira and
   user clarification disagree, record a blocker and stop scope expansion.
5. Store pasted translation tables in a standalone change Markdown reference
   and generate tasks only from the rows in the approved scope.
6. Create an acceptance traceability matrix mapping each criterion to design
   evidence, task IDs, tests, and final verification evidence.

When the affected repositories are executed through caraoke-workspace (the
configured execution substrate — see `CONFIG.md`), record the seam mapping in
the generated `workset.yaml` at propose time so `/opsx:apply` can provision
worktrees data-driven:
- a top-level `caraoke_workspace:` block (local path, host, discovery topics,
  worktree layout, branch convention), and
- per work item, the `repository_id → caraoke REPO` name and the
  `QCT-XXXX-short-kebab` branch.
Do not hardcode repository names or branches in any tool; they live in the
workset only.

A proposal may be generated with `status: proposed`, but it must remain
unapprovable while any source, scope, Figma, translation, or traceability
blocker remains unresolved.

After writing the change package, the agent must run the automatic validation
gate itself; do not ask the user to run it as a required manual step:

```bash
./tools/validate-change-package.sh --change <generated-change-directory> --structural-only
```

If a design source is declared, run a separate visual-evidence phase before
the proposal is presented for approval. The agent must open the exact design
source using the configured design connector or an authenticated browser,
capture the selected screen/node as an image or export under the change's
`context/evidence/` directory, and compare it criterion-by-criterion with the
normalized Jira acceptance criteria. Record the comparison in the path named
by `acceptance_review_path` in `context/intake/figma-reference.md`. If access
is unavailable, accept an uploaded screenshot/export, record its source and
timestamp, and keep the change blocked.

After the visual-evidence phase, the agent must run the full gate:

```bash
./tools/validate-change-package.sh --change <generated-change-directory>
```

The `<generated-change-directory>` value is discovered from the current
change; no ticket key, repository name, URL, or module is hardcoded in the
validator. Report the gate result and every blocker in the proposal response.
