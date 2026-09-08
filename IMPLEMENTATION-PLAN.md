# MDE OpenSpec SDLC Implementation Plan

## 1. Objective

Build a Mobile.de-specific engineering workflow on top of OpenSpec that:

- Starts from the current user's existing Jira work.
- Imports Jira, Figma, or screenshot-based input.
- Analyses dependencies across all configured and discovered repositories.
- Routes work using repository and module capabilities rather than hardcoded
  repository names.
- Supports frontend, backend, data, platform, and other dependency types.
- Generates an approved OpenSpec change before implementation.
- Routes tasks to the correct repository and worktree.
- Supports two users working on frontend and backend tasks in parallel.
- Captures API, Postman, MongoDB, GDPR, security, logging, tracing, metrics,
  testing, and deployment information.
- Requires BA and engineering approval before code implementation.

## 2. Final command decision

OpenSpec is the only user-facing workflow command system.

Users run:

```text
/opsx:propose [optional page-feature name or Jira key]
/opsx:apply
/opsx:verify
/opsx:sync
/opsx:archive
```

There will be no separate user-facing `/mde:spec`, `/mde:plan`, or
`/mde:implement` commands.

Mobile.de-specific behavior is implemented through OpenSpec custom skills,
hooks, repository configuration, and validation scripts. MDE is the name of
that integration layer, not a second workflow.

Every user-facing `/opsx` command starts with the same mandatory Git
freshness preflight. The preflight fetches the latest remote refs for the
control repository and all repositories required by the current workset,
records the fetched revisions, and then validates the approved specification
revision. It must not silently overwrite local changes.

Preflight policy:

- Run `git fetch --prune` before `/opsx:propose`, `/opsx:apply`,
  `/opsx:verify`, `/opsx:sync`, and `/opsx:archive`.
- If the fetch fails, stop the command and report the stale or unreachable
  repository.
- If a required checkout is dirty, do not pull, reset, or rebase it
  automatically. Use a generated worktree or ask the user to resolve the
  local changes.
- `/opsx:apply` and `/opsx:verify` must use the exact approved commit or
  content hash obtained after the fetch.
- Record the fetch time, remote, branch, and commit in `context/work-log.yaml`.
- There is no default offline mode. An explicit, separately approved offline
  mode would be required for exceptional recovery work.

## 3. Generic repository and module responsibilities

Repository responsibilities must be data-driven. They must not be embedded in
the orchestrator code or in fixed repository names.

Maintain a repository catalog containing only connection and capability
metadata. The catalog is a seed; dependency discovery can add candidate
repositories and modules for a particular change.

```yaml
repositories:
  - id: <repository-id>
    source: <repository-source>
    capabilities: []
    skills: []
```

The actual repository name, URL, branch, modules, languages, and capabilities
are filled by the repository discovery process. A project may have any number
of repositories, modules, languages, or services.

Rules:

- A task targets a discovered `repository_id` and `module_id`.
- The agent is selected from declared or detected capabilities.
- Dependencies may be direct or transitive and may cross any number of
  repositories.
- The current working directory is never used as the dependency decision.
- If a discovered dependency is not registered, it is added as a candidate and
  engineering approval is required before implementation.
- If a target repository or worktree is unavailable, the agent stops instead of
  writing to another repository.

## 4. Target control-repository structure

Use one control repository for the shared specification and orchestration
configuration. Its name and location are discovered or supplied during
bootstrap.

```text
<control-repository>/
├── AGENTS.md
├── .claude/
│   ├── commands/                         # OpenSpec-generated commands
│   └── skills/
│       ├── mde-jira-intake/
│       ├── mde-figma-intake/
│       ├── mde-mob-code-search/
│       ├── mobile-frontend/
│       ├── mobile-java-backend/
│       ├── mde-mongodb/
│       ├── mde-api-contract/
│       ├── mde-postman/
│       ├── mde-observability/
│       ├── mde-security-gdpr/
│       ├── mde-multi-repository-router/
│       ├── mde-git-preflight/
│       └── mde-release-validation/
├── tools/                              # Deterministic runtime, not prompt-only logic
│   ├── discovery/
│   ├── router/
│   ├── coordination/
│   ├── approvals/
│   └── validation/
├── schemas/
│   ├── workset.schema.yaml
│   ├── task-status.schema.yaml
│   ├── task-claim.schema.yaml
│   └── skill-manifest.schema.yaml
├── mde-agent-library/              # Complete adapted agent source
│   ├── .claude-plugin/
│   ├── .claude/
│   ├── .github/workflows/
│   ├── categories/
│   ├── tools/subagent-catalog/
│   ├── .gitignore
│   ├── CLAUDE.md
│   ├── CONTRIBUTING.md
│   ├── install-agents.sh
│   ├── README.md
│   ├── LICENSE
│   └── source-manifest.yaml
└── openspec/
    ├── config.yaml
    ├── project.md
    ├── AGENTS.md
    ├── repository-catalog.yaml              # Seed catalog, not routing logic
    ├── skill-bundle.yaml                    # Pinned common and selected skills
    ├── specs/                              # Current approved capabilities
    │   └── <capability>/
    │       ├── spec.md
    │       └── design.md                   # Optional
    └── changes/                            # In-flight work
        ├── <change-id>/
        └── archive/
```

OpenSpec's standard artifacts are `proposal.md`, delta `specs/`, `design.md`,
and `tasks.md`. Mobile.de-specific evidence is kept under `context/` inside
the same change folder; it is not a second change system.

## 4.1 OpenSpec and Claude setup across repositories

The `.claude/` command and skill bundle must be available in every repository
where a user may run `/opsx`. It must be installed from one pinned source by a
bootstrap process; users must not copy files manually or edit different
versions in different repositories.

The `openspec/` source of truth is stored once in the control repository. It is
not duplicated as independent change folders in every code repository.

Each discovered code repository receives only a small workspace pointer:

```text
<discovered-repository>/
├── .claude/                         # Same pinned command/skill bundle
├── AGENTS.md                        # Repository-local engineering rules
└── .openspec-workspace.yaml        # Points to shared change/workset
```

The pointer contains the shared specification location, change ID, approved
specification revision, and repository ID. The Mobile.de OpenSpec adapter uses
it when a user switches repositories.

```yaml
control_repository: <discovered-control-repository-id>
spec_root: openspec
change_id: <feature-based-change-id>
approved_revision: <commit-or-content-hash>
repository_id: <current-repository-id>
workset: context/worksets/<current-repository-id>.yaml
```

The pointer is generated by the bootstrap process and must not contain a
hardcoded repository name.

Before running `/opsx:apply`, the adapter verifies:

1. The shared change exists.
2. The current repository is assigned a workset.
3. The workset's specification revision is approved.
4. The local repository and branch match the workset.
5. The task's target repository and module match the current checkout.

If these checks fail, the command stops. It does not create a second local
specification or write to an unrelated repository.

If a shared control repository is not available, OpenSpec must be initialized
in every repository using the same pinned configuration. In that fallback
mode, synchronization and conflict management become mandatory because the
specification is duplicated. The primary implementation should use the shared
control repository instead.

## 4.2 Control-repository collaboration and revisioning

The control repository is a normal Git repository. A specification must be
committed and pushed before another developer can reliably use it.

Recommended lifecycle:

```text
Draft change branch
        ↓
Control-repository pull request
        ↓
BA and engineering approval
        ↓
Merge approved change
        ↓
Developers fetch the approved revision
        ↓
Code implementation in repository worktrees
```

The approved specification revision is immutable for implementation. Every
workset records:

```yaml
control_repository: <control-repository-id>
change_id: <feature-based-change-id>
approved_revision: <commit-sha>
```

Before `/opsx:apply`, the adapter must verify that:

- The approved revision exists on the remote control repository.
- The change has the required approvals.
- The current workset references that revision.
- The task has not been invalidated by a later specification change.

If the specification changes after implementation starts, the change receives
a new revision. Affected approvals and dependent tasks are invalidated and
must be reviewed again.

Developers see only committed and pushed work. Uncommitted local edits are not
available to other developers and must not be treated as dependency evidence.

Task completion, validation evidence, and workset status are committed through
separate pull requests or automated CI commits. The parent specification is
not edited concurrently by every developer.

Branching rules:

- One draft/specification branch per feature change.
- One implementation branch per affected repository and workset.
- Protected `master` branch for the control repository.
- Required BA and engineering reviewers through `CODEOWNERS`.
- CI validation required before merging specifications or implementation.
- No force-pushes to shared approved branches.

The bootstrap process distributes the pinned `.claude` bundle version to every
participating repository. A bundle update is also versioned and reviewed; it
must not silently change while an implementation is in progress.

### Real-time task claiming

Git pull and push provide durable synchronization, but they are not an atomic
real-time lock when two users claim the same task simultaneously. The adapter
must therefore claim a task before `/opsx:apply` starts. The live claim is held
by the coordination service; the control repository stores its audit record:

```yaml
task_id: <task-id>
owner: <user-or-agent-id>
repository_id: <discovered-repository-id>
worktree_id: <generated-worktree-id>
spec_revision: <approved-commit-or-content-hash>
claimed_at: <timestamp>
lease_expires_at: <timestamp>
status: in_progress
```

The claim operation must be atomic. If the task is already claimed, the
second user receives the owner, worktree, and status and cannot write to that
task. A claim can be released, transferred, or expire after an explicit
recovery policy. Every claim, release, transfer, and expiry is committed or
otherwise exported to the change's audit trail.

## 4.3 Skill distribution between the control and code repositories

The complete imported agent library is adapted into Mobile.de naming and
workflow conventions, then maintained as a controlled skill library. It may
be installed in individual repositories; there is no restriction against
that. The restriction is on uncontrolled copies and unbounded permissions.

The control repository owns the curated, pinned skill source and distribution
manifest:

```text
<control-repository>/
├── .claude/
│   ├── commands/
│   └── skills/
│       ├── mde-jira-intake/
│       ├── mde-figma-intake/
│       ├── mde-mob-code-search/
│       ├── mde-multi-repository-router/
│       ├── mde-approval-policy/
│       ├── mde-git-preflight/
│       └── mde-validation/
├── mde-agent-library/
│   ├── .claude-plugin/
│   ├── .claude/
│   ├── .github/workflows/
│   ├── categories/
│   ├── tools/subagent-catalog/
│   ├── .gitignore
│   ├── CLAUDE.md
│   ├── CONTRIBUTING.md
│   ├── install-agents.sh
│   ├── README.md
│   ├── LICENSE
│   └── source-manifest.yaml
└── openspec/
    └── skill-bundle.yaml
```

Each discovered code repository receives a generated runtime bundle:

```text
<discovered-repository>/
├── .claude/
│   ├── commands/
│   ├── skills/
│   │   └── <selected-skill-id>/
│   └── skill-manifest.yaml
├── AGENTS.md
└── .openspec-workspace.yaml
```

`skill-manifest.yaml` records the bundle version, selected skills, source
revision, and tool permissions. The bootstrap process installs or refreshes it
from the control repository. Developers must not install arbitrary versions
directly into a working repository.

The imported library is copied as a complete source snapshot so all catalog
files remain available. Adapted Mobile.de agents are the executable runtime;
the source manifest records the original source URL, commit, import date,
checksums, and each local modification. Required license and copyright notices
must be preserved. Renaming branding does not permit removal of those notices.

Use this distribution model:

- Common skills: OpenSpec workflow, Jira/Figma intake, mob-code search,
  routing, policy, approvals, audit, and shared validation.
- Repository-selected skills: language, framework, database, deployment, and
  test skills required by the capabilities discovered in that repository.
- Repository-local context: `AGENTS.md`, build commands, test commands, source
  layout, ownership, and security restrictions.

The complete library is maintained once in the control repository, but each
code repository receives only the selected Mobile.de agents needed for its
discovered capabilities. This keeps every required agent available without
creating version drift, unnecessary context, or excessive tool permissions.

## 5. Feature-based OpenSpec change structure

The OpenSpec change folder is named after the product page and feature, not
after Jira. Jira remains optional metadata inside the change.

For the Vehicle section on the Digital Contract page, create:

```text
openspec/changes/digital-contract-vehicle-section/
├── proposal.md
├── design.md
├── tasks.md
├── .openspec.yaml
├── specs/
│   └── seller-evolution/
│       └── spec.md
└── context/
    ├── intake/
    │   ├── jira.json
    │   ├── work-item.yaml
    │   ├── figma.json
    │   └── screenshots/
    ├── discovery/
    │   ├── repository-map.json
    │   ├── dependency-report.md
    │   ├── dependency-graph.json
    │   ├── repository-analysis/
    │   │   └── <discovered-repository-id>.md
    │   ├── mongodb-analysis.md
    │   └── observability-analysis.md
    ├── contracts/
    │   ├── openapi.yaml
    │   ├── postman-collection.json
    │   └── mongodb-schema.json
    ├── worksets/
    │   └── <discovered-repository-id>.yaml
    ├── claims/
    │   └── <task-id>.yaml
    ├── task-status/
    │   └── <task-id>.yaml
    ├── approvals/
    │   ├── ba.yaml
    │   ├── engineering.yaml
    │   ├── security.yaml
    │   ├── gdpr.yaml
    │   ├── qa.yaml
    │   └── platform.yaml
    ├── evidence/
    │   ├── task-results/
    │   ├── validation-results.json
    │   └── traceability-report.md
    ├── state.json
    └── work-log.yaml
```

The change metadata identifies the page, feature, and optional Jira issue:

```yaml
change_id: digital-contract-vehicle-section
page: digital-contract
feature: vehicle-section
jira_key: QCT-1001
issue_type: story
```

The folder name remains stable even when Jira is unavailable. In that case,
`jira_key` is `null` and the specification can still proceed through review.

If the same feature has multiple independent changes, use an action suffix:

```text
digital-contract-vehicle-section-add
digital-contract-vehicle-section-validation-fix
digital-contract-vehicle-section-accessibility
```

The orchestrator must detect duplicate active feature names and ask whether to
continue an existing change or create an action-specific change.

`tasks.md` is the human-readable implementation checklist.

`context/worksets/` routes work to repositories and prevents frontend and
backend users from accidentally modifying the wrong checkout.

## 6. Jira and Figma intake

### Existing Jira ticket

When the user runs:

```text
/opsx:propose
```

the customized proposal workflow must:

1. Query the current user's active Jira issues.
2. Display the issue key, type, summary, status, and updated time.
3. Let the user select a ticket.
4. Save the original Jira response to `context/intake/jira.json`.
5. Normalize the issue into `work-item.yaml`.
6. Continue with Figma and repository discovery.

The user does not need to recreate an existing Jira ticket.

### Jira fallback

If Jira is unavailable, allow the user to paste:

- Jira key
- Issue type
- Summary
- Description
- Acceptance criteria
- Priority
- Dependencies
- Affected service
- Environment
- Bug reproduction information, when applicable

Store this as user-provided input and mark its provenance.

### Figma fallback

If the Figma connector or link is unavailable, allow screenshot uploads and a
plain-language description. Store screenshots under:

```text
context/intake/screenshots/
```

Missing interaction, responsive, or accessibility information must be marked
as unresolved rather than invented.

## 7. Dependency discovery

The `mde-mob-code-search` skill must run before specification approval when
the ticket may affect existing behavior.

It searches every repository in the catalog plus repositories discovered from
the ticket, source code, API contracts, dependency manifests, and deployment
configuration.

It searches:

- All declared repositories
- All discovered repositories
- All modules and services inside those repositories
- API clients and endpoints
- Java services and controllers
- MongoDB collections, queries, and indexes
- Existing Postman collections
- Logging, metrics, and tracing
- Gateway and authentication configuration
- Deployment, Helm, Istio, and Vault configuration
- Tests and test fixtures
- Code ownership and existing Jira links

The output must include repository ID, repository name, module ID, branch,
commit, file, symbol, dependency type, risk, confidence, and evidence. An
incomplete search blocks engineering approval.

The installed MCP tool mapping is:

```text
mcs_system_status       -> verify service health
mcs_list_indexed_repos  -> discover indexed repository IDs
mcs_search              -> semantic code and dependency search
mcs_find_symbol         -> locate definitions and usages
mcs_read_symbol         -> read verified symbol implementation
mcs_file_outline        -> inspect file/module structure
mcs_ask                 -> repository-specific Q&A when direct evidence is insufficient
```

Discovery must call `mcs_system_status` first, then
`mcs_list_indexed_repos`, and must preserve each result reference and indexed
revision in the change evidence.

The discovery algorithm is:

1. Load the seed repository catalog.
2. Identify repositories named by Jira, Figma, configuration, or ownership
   metadata.
3. Search code, manifests, API clients, events, databases, and deployment
   references.
4. Add newly discovered repositories and modules as dependency candidates.
5. Build a directed dependency graph.
6. Ask for engineering confirmation when a candidate is ambiguous or outside
   the seed catalog.
7. Generate one workset per affected repository from the approved graph.

## 8. Generic dependency ordering rules

### Multi-module or cross-repository feature

Default sequence:

1. Approve requirements and acceptance criteria.
2. Approve OpenAPI and MongoDB contracts.
3. Implement data or persistence changes in the repository that owns the data
   capability.
4. Implement the producing service or API in its owning repository.
5. Implement consuming clients or frontend modules in their owning
   repositories using the approved contract or a mock.
6. Run contract, integration, and end-to-end tests across all affected
   repositories.
7. Validate deployment and rollback for every affected deployment unit.

Consumer implementation may run in parallel with producer implementation after
the contract is approved.

### Client-only feature

Implement only in the repository and module classified as the client owner if
the existing API is unchanged.

### Service-only feature

Implement only in the repository and module classified as the service owner.

### Bug

Create a failing regression test first. For a cross-stack bug, identify the
fault boundary before assigning frontend or backend work.

## 9. Task routing

Every task in `tasks.md` must have a corresponding entry in
`context/worksets/`.

Example:

```yaml
change_id: digital-contract-vehicle-section
jira_key: QCT-1001
tasks:
  - id: 1.1
    repository_id: <discovered-repository-id>
    module_id: <discovered-module-id>
    worktree: <generated-worktree-name>
    agent: selected-from-capabilities
    depends_on: []

  - id: 1.2
    repository_id: <discovered-repository-id>
    module_id: <discovered-module-id>
    worktree: <generated-worktree-name>
    agent: selected-from-capabilities
    depends_on: [1.1]

  - id: 2.1
    repository_id: <discovered-repository-id>
    module_id: <discovered-module-id>
    worktree: <generated-worktree-name>
    agent: selected-from-capabilities
    depends_on: [1.1]
```

The router must use `repository_id`, `module_id`, and `worktree` from this map.
The current shell directory is only a safety check, not the routing source.
The agent is selected by the module's capabilities, language, framework, and
task type.

## 10. Dependency completion and gating

Dependencies are represented as directed edges in `dependency-graph.json` and
as task prerequisites in `task-map.yaml`. They are never inferred from folder
names or from the order in which users happen to work.

```yaml
dependency:
  consumer_task: <consumer-task-id>
  provider_task: <provider-task-id>
  type: api-contract
  required_provider_state: contract-verified
  contract_file: context/contracts/openapi.yaml
  contract_hash: <hash>
```

Every task has a machine-readable state:

```text
not_started
→ in_progress
→ implemented
→ verified
→ merged
→ deployed
```

It may also enter:

```text
blocked
failed
needs_rework
```

The meanings are strict:

- `implemented`: code exists in the assigned worktree and the agent's local
  checks completed.
- `verified`: required tests, contract checks, and policy checks passed.
- `merged`: the corresponding pull request was merged into the configured
  integration branch.
- `deployed`: the change was deployed to the required environment and passed
  post-deployment checks.

An unchecked box in `tasks.md` is not completion evidence. The orchestrator
updates task state only from recorded evidence, CI results, pull-request
events, and deployment checks.

### Example dependency behavior

If a client module consumes an API produced by a service module:

1. The API contract is approved first.
2. The client may start against the approved contract and a mock.
3. Client implementation can be marked `implemented` while the provider is
   still being built.
4. Client integration tests remain `blocked` until the provider reaches the
   required state.
5. The feature cannot be marked complete until the provider, consumer, and
   integration validation all reach their required states.

The required state depends on the task:

```yaml
gates:
  client_implementation:
    provider_required_state: contract-approved
  integration_test:
    provider_required_state: verified
  release:
    provider_required_state: deployed
```

If the provider changes its contract after the client has started, the
contract hash changes. The orchestrator marks dependent tasks as
`needs_revalidation` and reruns the affected contract, integration, and end-
to-end checks.

Task status is stored separately from the human checklist:

```text
context/
├── task-status/
│   └── <task-id>.yaml
├── evidence/
│   └── task-results/
└── dependency-graph.json
```

This allows multiple users to work in parallel without overwriting one shared
progress file.

## 11. Multi-repository task execution

A task may contain multiple repository work items. The user may start
`/opsx:apply` from any assigned repository, but the current directory is not
used as the location for all changes.

The router reads the approved workset and creates or opens one isolated
worktree per affected repository:

```text
<workspace-root>/
└── <change-id>/
    └── worktrees/
        ├── <generated-worktree-for-repository-a>/
        ├── <generated-worktree-for-repository-b>/
        └── <generated-worktree-for-repository-c>/
```

The repository and worktree names are generated from discovered repository
identifiers. They are never hardcoded in the orchestrator.

For each work item, the router:

1. Resolves the repository ID and module ID from the workset.
2. Resolves the repository source, branch, and commit.
3. Creates or reuses the assigned worktree.
4. Starts the selected agent with that worktree as its working directory.
5. Restricts file writes to that repository and module.
6. Runs the repository-specific checks in that worktree.
7. Records the commit, changed files, tests, and evidence.
8. Returns control to the coordinator without changing the user's terminal
   directory.

For example, a single feature task may produce two work items:

```yaml
work_items:
  - id: W-001
    repository_id: <provider-repository-id>
    module_id: <provider-module-id>
    depends_on: []

  - id: W-002
    repository_id: <consumer-repository-id>
    module_id: <consumer-module-id>
    depends_on: [W-001]
```

The provider and consumer may be implemented in parallel after the approved
contract exists, but integration validation waits for both worktrees to pass.

If the router cannot access a required repository, create a worktree, or
obtain the required permissions, `/opsx:apply` must stop with a clear blocker.
It must never write the work item into the user's current repository as a
fallback.

Standard OpenSpec by itself does not provide this multi-repository routing;
the Mobile.de adapter and workspace manager are required for this behavior.

## 12. Two users working in parallel

For the same feature change:

```text
<generated-worktree-a>/
└── <discovered-repository-a>/   # first affected repository

<generated-worktree-b>/
└── <discovered-repository-b>/   # second affected repository
```

The users share the approved OpenSpec change but have separate code worktrees.

Rules:

- The approved specification is read-only during implementation.
- A task must be atomically claimed before any implementation agent starts.
- Two users may work on the same feature, but they may not own the same task
  at the same time. They must use separate task IDs or an explicit transfer.
- Each user modifies only the repository and module assigned in the workset.
- No user or agent may infer ownership from the current directory.
- The parent `tasks.md` is updated by the coordinator after task evidence or
  PR completion, not concurrently by every user.
- Each task writes separate evidence under `context/evidence/task-results/`.
- If both tasks modify the same API contract, CI reports an overlap and requires
  an explicit dependency and merge order.

## 13. Runtime scenarios

### Scenario A: Single-repository change

1. User runs `/opsx:propose` in the control repository.
2. The change contains tasks for one discovered repository.
3. The user or agent enters that repository and runs `/opsx:apply`.
4. The adapter reads the shared change and executes only its assigned tasks.
5. Validation evidence is written back to the control change.

### Scenario B: One feature affects multiple repositories

1. Discovery identifies multiple repositories and modules.
2. The approved change receives one workset per affected repository.
3. The router creates one worktree per workset.
4. Agents run with the corresponding worktree as their working directory.
5. Tasks with no unmet dependency can run in parallel.
6. Integration tasks wait for all required provider and consumer states.

### Scenario C: Two users work on the same feature

1. Both users fetch the same approved specification revision.
2. The coordination service atomically claims each task and assigns a workset.
3. Each user receives a different repository worktree or assigned workset.
4. Each user commits only to their implementation branch.
5. CI records task evidence and pull-request status.
6. The coordinator updates the parent task status after evidence is accepted.
7. Neither user edits the shared approved specification during implementation.

### Scenario D: Two users work on different features

1. Each feature has a different change folder under `openspec/changes/`.
2. Each feature has its own state, tasks, approvals, and worksets.
3. Their code branches and worktrees are independent.
4. A shared file conflict is detected by CI and reviewed by its owner.

### Scenario E: A new dependency is discovered during implementation

1. The agent records the repository or module as a candidate dependency.
2. The task is paused with `dependency-review-required`.
3. Mob-code search collects evidence for the dependency.
4. Engineering reviews the impact and updates the graph.
5. A new workset is generated if implementation is required there.
6. The affected tasks resume only after the graph and approvals are updated.

### Scenario F: A dependency is incomplete

1. A consumer task may complete against an approved mock or contract.
2. Its integration task remains `blocked`.
3. The provider task publishes test and contract evidence.
4. The dependency state changes and the integration task becomes eligible.

### Scenario G: A specification changes after coding starts

1. A new specification revision is committed.
2. The system compares requirement and contract hashes.
3. Affected approvals and dependent tasks are invalidated.
4. The affected worksets are marked `needs_revalidation`.
5. Users must fetch the new approved revision before continuing.

### Scenario H: Repository or tool access fails

1. The task is marked `blocked` with the missing repository or tool recorded.
2. No fallback write is attempted in the current repository.
3. The user is shown the exact missing access or setup requirement.
4. After access is restored, the task resumes from its saved state.

## 14. Approval gates

The custom Mobile.de policy must prevent `/opsx:apply` until the required
approvals exist.

BA approval covers:

- Business objective
- Scope
- User journeys
- Business rules
- Acceptance criteria
- Story, Task, or Bug classification

Engineering approval covers:

- Architecture
- Repository impact
- API contract
- MongoDB schema and migration
- Frontend/backend ordering
- Test plan
- Observability
- Security and GDPR
- Deployment and rollback

Approvals must reference the exact specification commit or content hash. Any
change to an approved requirement invalidates the affected approval.

## 15. Implementation phases

### Phase 0: Confirm prerequisites

Deliverables:

- OpenSpec version and profile
- Jira connector contract
- Figma connector contract
- Mob-code search contract
- Repository registry
- Approval roles
- Target control repository

Exit condition: all required integrations and repositories are identified.

### Phase 1: Initialize OpenSpec

Run once in the control repository:

```bash
openspec init --tools claude
```

Configure:

- `openspec/config.yaml`
- `openspec/project.md`
- `openspec/AGENTS.md`
- Mobile.de rules
- Spec-driven workflow profile

Exit condition: `/opsx:propose` creates a valid standard change.

Implement a repository bootstrap command that installs the same pinned Claude
command and skill bundle into every discovered repository and writes its
`.openspec-workspace.yaml` pointer. The bootstrap must be idempotent and must
record the installed bundle version.

Exit condition: a user can switch to any assigned repository and `/opsx` sees
the same Mobile.de skills and the shared OpenSpec change.

### Phase 2: Add Mobile.de proposal intake

Implement:

- Current-user Jira query
- Jira selection
- Jira normalization
- Manual Jira fallback
- Figma import
- Screenshot fallback
- Provenance and missing-information reporting

Exit condition: a page-feature request produces a populated `context/intake/`
folder, with an optional Jira reference.

### Phase 3: Add repository discovery

Implement:

- Repository registry
- Mob-code search adapter
- Repository map
- Dependency graph
- Ownership discovery
- API and MongoDB discovery
- Observability discovery

Exit condition: discovery produces evidence for every affected repository,
module, capability, and dependency type.

### Phase 4: Add Mobile.de specification generation

Extend proposal/design generation with:

- Functional requirements
- Acceptance scenarios
- API contract
- MongoDB contract
- Security and GDPR
- Logging, tracing, and metrics
- Non-functional requirements
- Test plan
- Deployment plan

Exit condition: BA can review the complete change folder without reading source
code or prompts.

### Phase 5: Add task routing and worktrees

Implement:

- `task-map.yaml`
- Frontend/backend worksets
- Repository validation
- Branch/worktree creation
- File ownership restrictions
- Dependency-aware scheduling
- Per-task evidence

Exit condition: a task started from any workspace is either routed to its
declared repository worktree or safely blocked; it is never written into an
unrelated repository.

### Phase 6: Add approval enforcement

Implement:

- BA approval storage
- Engineering approval storage
- Security/GDPR approval storage
- QA approval storage
- Platform approval storage
- Spec version/content hash
- Apply blocking policy

Exit condition: `/opsx:apply` cannot execute an unapproved change.

### Phase 7: Add implementation skills

Implement and test capability-based skills, including the current Mobile.de
skills:

- Frontend skill selected for frontend-capable modules
- Java/Spring skill selected for Java service modules
- MongoDB skill selected for data-owning modules
- API-contract skill selected for API-producing or consuming modules
- Postman skill selected for HTTP contract validation
- Observability skill selected for telemetry changes
- Security/GDPR skill selected for compliance impact
- Playwright skill selected for browser-based validation

The repository catalog maps discovered repositories and modules to these
capabilities; the orchestrator must not contain repository-specific `if/else`
routing.

Exit condition: tasks are completed only in their declared repository and all
tasks produce verification evidence.

### Phase 8: Add validation and traceability

Implement CI checks for:

- OpenSpec structure
- Requirement-to-task mapping
- Task-to-code mapping
- Task-to-test mapping
- Postman validation
- MongoDB migration validation
- Java and frontend tests
- Playwright tests
- Security and GDPR checks
- Observability checks
- Deployment checks

Exit condition: the system can produce a traceability report for every
requirement.

### Phase 9: Add release and archive workflow

Implement:

- PR creation
- Required reviewer checks
- Deployment readiness checks
- Rollback checks
- Post-deployment verification
- `/opsx:sync`
- `/opsx:archive`

Exit condition: released behavior is represented in `openspec/specs/` and the
completed change is archived.

## 16. External reference usage

- Use VoltAgent as a source of specialized agent patterns; select only the
  required roles and rewrite them for Mobile.de.
- Use the harness-engineering collection as a design checklist for context,
  permissions, state, evaluation, observability, and safe execution.
- Use Superpowers practices such as worktrees, TDD, task-level reviews, and
  evidence-based completion. Do not install a second workflow controller.
- OpenSpec remains the sole specification lifecycle and user command system.

## 17. Information required before implementation begins

The following values must be supplied or discovered:

1. Exact OpenSpec version and whether the internal command is `/opsx` or a
   different `opx` command.
2. Location of the control repository.
3. Jira project, active-status query, required fields, and write permissions.
4. Figma connector details and screenshot storage policy.
5. Mob-code search plugin command/API and branch access.
6. Build, test, lint, and browser-test commands for every discovered repository.
7. Language, framework, package/build tool, and test commands for every
   discovered module.
8. MongoDB metadata source, migration process, and environment rules for each
   data-owning module.
9. Postman collection execution command.
10. CI, deployment, Helm, Istio, Vault, observability, security, and GDPR tool
    details.
11. Required BA, engineering, QA, security, GDPR, and platform approvers.

## 18. Pilot acceptance criteria

The first pilot should include:

- One Story affecting multiple repositories.
- One frontend-only Task.
- One backend or MongoDB Task.
- One Bug with a regression test.
- Two users working in separate worktrees.
- A Jira import without manual duplication.
- A Figma screenshot fallback.
- A dependency report from mob-code search.
- A blocked apply attempt without approval.
- Successful backend and frontend task routing.
- Postman and Playwright evidence.
- A final traceability report.
- Successful sync and archive.

The pilot is complete only when every task is written exclusively to its
declared repository and module, additional dependencies are discovered without
code changes to the orchestrator, and both users can work without overwriting
each other's state.
