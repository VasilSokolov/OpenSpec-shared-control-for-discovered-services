# Control configuration

One place to configure the teams this control plane governs, their execution
workspaces, and the naming conventions that tie a Jira ticket to a repository,
a branch, and an OpenSpec change. Adding a new team should not require touching
any tool — it is a config edit here plus the workspace/discovery wiring the
tools already read.

## How configuration is layered

Nothing about a specific repository, branch, or ticket is hardcoded in a tool.
Configuration lives at three altitudes:

| Altitude              | Where                                             | What it holds                                                                 | Authoritative for |
| --------------------- | ------------------------------------------------- | ----------------------------------------------------------------------------- | ----------------- |
| Control plane         | `openspec/config.yaml`                            | Schema, approval policy, validation/preflight/router/discovery script paths.  | Workflow gates    |
| Discovery / seed      | `openspec/repository-catalog.yaml`                | Discovery provider (mob-code-search MCP) + optional seed repo metadata.        | Repo discovery    |
| This registry         | `CONFIG.md` (below)                               | Team → orgs, host, discovery topics, execution workspace, naming conventions. | Team onboarding   |
| Per-change instance   | `openspec/changes/<change>/workset.yaml`          | The actual `repository_id`, caraoke `REPO`, branch, and worktree per task.     | A single change   |

The registry here is the **template** an operator fills once per team. The
per-change `workset.yaml` records the **instances** discovered/derived for one
change. Tools read the workset; the workset is populated using the conventions
declared here.

## Teams registry

Each governed team declares how its repositories are discovered and executed,
and which Jira project it tickets against. To onboard a team, add a row here and
a block in the YAML template that follows.

| Team               | Jira project | Discovery topics                          | Execution workspace                         | Host                        |
| ------------------ | ------------ | ----------------------------------------- | ------------------------------------------- | --------------------------- |
| Swifty / Caraoke   | `QCT`        | `owned-by-mob-team-swifty`, `owned-by-mob-team-caraoke` | `caraoke-workspace` (`../Mobile-de/caraoke-workspace`) | `github.mpi-internal.com`   |

```yaml
# Declarative team registry. This is the single edit point for onboarding a
# team; per-change worksets reference a team by `id` and inherit its
# conventions. Discovery still runs live (mob-code-search) — topics/orgs only
# scope the universe, they do not pin a repo list.
teams:
  - id: swifty-caraoke
    jira_project: QCT
    orgs:
      - mobile-de
      - mobile-de-incubation
    host: github.mpi-internal.com
    discovery:
      provider: mob-code-search        # authoritative for the change's repo set
      topics:                          # physical clone availability in caraoke
        - owned-by-mob-team-swifty
        - owned-by-mob-team-caraoke
    execution:
      substrate: caraoke-workspace
      local_path: ../Mobile-de/caraoke-workspace
      worktree_layout: worktrees/<repo>/<branch>
      toolchain_wrapper: run           # mise-resolved per worktree
    naming:
      jira_ticket: "QCT-<number>"                 # e.g. QCT-1234
      branch: "QCT-<number>-<short-kebab>"        # slash-free (caraoke rule)
      change_id: "<page>-<feature>[-<action>]"    # control change folder name

  # To add another team, copy the block above:
  # - id: <team-slug>
  #   jira_project: <PROJECTKEY>
  #   orgs: [ ... ]
  #   host: <git-host>
  #   discovery: { provider: mob-code-search, topics: [ ... ] }
  #   execution: { substrate: <workspace-or-standalone>, local_path: <path>, ... }
  #   naming: { jira_ticket: "...", branch: "...", change_id: "..." }
```

## Naming conventions

These are the contracts every change must satisfy; validation enforces their
presence at propose time.

- **Jira ticket** — `<PROJECTKEY>-<number>` (e.g. `QCT-1234`). Optional intake
  metadata; a change may exist without a ticket but records one when it has it.
- **OpenSpec `change_id`** — `<page>-<feature>` or `<page>-<feature>-<action>`
  (see `openspec/project.md`). This is the change folder name and is independent
  of the Jira key.
- **Implementation branch** — `<PROJECTKEY>-<number>-<short-kebab>`, e.g.
  `QCT-1234-shared-service-control`. Must be **slash-free**: the caraoke backend
  nests worktrees under `worktrees/<repo>/<branch>/`, so a `/` in the branch
  desyncs the reconstructed path (`tools/router/create-worktree.sh` rejects it).
- **`repository_id` → caraoke `REPO`** — the discovered `repository_id` (from
  mob-code-search) maps to the caraoke `REPO` name (the bare clone under
  `repos/<REPO>.git`). Record the mapping per work item in `workset.yaml`; the
  two discovery mechanisms (MCP index vs `gh search repos --topic`) cover the
  same universe but may briefly disagree — treat mob-code-search as
  authoritative for the change, caraoke topics for physical clone availability.

## Adding a new team — checklist

1. Add the team row + YAML block above (id, Jira project, orgs, host, topics,
   execution workspace, naming rules).
2. Ensure the team's execution workspace exists locally (a caraoke-style
   multi-repo workspace, or set `substrate: standalone` to use the router's
   direct `git worktree` backend).
3. Confirm `gh` is authenticated to the team's `host`.
4. No tool change is required: `/opsx:propose` records the mapping into the
   change's `workset.yaml`, and `/opsx:apply` provisions worktrees through the
   router using these conventions. See the seam runbook in
   [`README.md`](README.md#running-with-caraoke-workspace).
