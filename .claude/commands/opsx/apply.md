# /opsx:apply

## Step 1 — Git preflight (mandatory, stop if it fails)

Run the repository's pinned Git preflight:
- In the control repository: `tools/git-preflight.sh`
- In a bootstrapped code repository: `.claude/tools/git-preflight.sh`

## Step 2 — Change package validation (mandatory, stop if blocked)

Before claiming or implementing any task, run:

```bash
tools/validate-change-package.sh --change <change-directory>
```

Do not apply an unapproved or evidence-blocked change. Run the separate design
screenshot-to-acceptance comparison whenever the change declares a design source.

## Step 3 — Claim the task atomically

Read the approved change and current repository workset. Atomically claim the
selected task using `mde-task-coordination`. Resolve the target repository and
module from the workset, not from the current directory. Create or open the
generated worktree. Never write to the current repository as a fallback.

## Step 4 — Dynamic capability detection (mandatory before any code is written)

This step MUST complete before any implementation begins. No code, no tests,
no file edits until all required agents have reported.

### 4.1 Detect capabilities

Load `openspec/capability-skill-matrix.yaml`. For the task's `repository_id`
and `module_id`:

1. Read `openspec/repository-catalog.yaml` for declared capabilities.
2. Perform a live scan of the target repository worktree:
   - Check for `next.config.*`, `pom.xml`, `build.gradle`, `playwright.config.*`,
     `.storybook/main.*`, Helm charts, Kubernetes manifests, Terraform files.
   - Check `package.json` / `pom.xml` / `build.gradle` dependencies.
   - Check for authentication patterns: keycloak config, auth middleware,
     IAM env vars, OAuth references.
   - Check for PII fields in changed scope: email, phoneNumber, dateOfBirth,
     identificationNumber.
   - Check for observability imports: logger, metrics, tracing.
3. Merge catalog capabilities with live-detected capabilities.
4. Record every detected capability in the task's workset `capabilities_detected[]`.

### 4.2 Load required agents and skills

For each detected capability, load ALL agents and mde-skills from
`capability-skill-matrix.yaml`. Add unconditional entries from `always` and
`always_skills`. Deduplicate — if `refactoring-specialist` appears under three
capabilities, it still runs once.

### 4.3 Invoke required mde-skills

Invoke every required mde-skill from `.claude/skills/mde-*/SKILL.md` for the
detected capabilities. These are non-negotiable process gates:
- `mde-figma-intake` → if `mobile-frontend` or `mobile-storybook` detected
- `mde-api-contract` → if ANY of the following:
  - `mobile-api-contract`, `mobile-java-backend`, or `mobile-api-gateway` detected
  - **A field that maps to an API request/response is renamed, split, merged, or reformatted**
  - Any schema file (`*.schema.ts`, `*.schema.kt`, DTO classes) is changed
  - Any data mapping function is changed (`*Mapping.ts`, `*RequestBody.ts`, `*Dto.java`)
  - **This gate must complete before Step 5 (implementation). It is never skipped.**
- `mde-security-gdpr` → if `mobile-security-gdpr`, `mobile-auth-iam`, PII
  fields, or auth patterns detected
- `mde-observability` → if `mobile-observability` or logging changes detected
- `mde-postman` → if `mobile-api-contract` or `mobile-api-gateway` detected
- `mde-mongodb` → if `mobile-mongodb` detected
- `mde-release-validation` → if `mobile-infrastructure` detected

**API contract pre-check (mandatory when schema or mapping files change):**

Before writing any implementation code that changes a field name or format:
1. Call `mcp__mde-swagger-docs__get_schema` or `mcp__mde-swagger-docs__get_api_endpoint`
   for the affected backend service.
2. Verify the ACTUAL format of the field as stored/returned (not the TypeScript type).
3. Confirm the new format is backward-compatible: does the concatenated/split output
   round-trip to the same bytes the backend stored?
4. Write `context/discovery/field-impact-matrix.md` per the `mde-api-contract` skill.
5. If verdict is BREAKING or UNKNOWN → raise BLOCKER, do not proceed to implementation.

### 4.4 Invoke required agents in phase order

Run agents from `capability-skill-matrix.yaml` in this sequence:
1. **Architecture agents** — review design, contracts, module boundaries
2. **Implementation** — write code (only after architecture phase is clean)
3. **Quality agents** — `refactoring-specialist` (KISS/DRY/YAGNI) runs first,
   then `code-reviewer`, then all specialist quality agents
4. **Validation agents** — `test-automator`, `qa-expert`, and `mde-validation`

Record every invoked agent and skill in `workset.yaml agents_invoked[]` with
timestamp, finding severity, and outcome.

### 4.5 Resolve all blockers before proceeding

If any agent raises a BLOCKER:
- Fix the issue immediately
- Re-run the affected agent to confirm resolution
- Record the blocker, fix, and re-run result in `context/evidence/task-results/`
- Only proceed to commit after all BLOCKERs are resolved

WARNINGs must either be fixed or formally deferred to a named follow-up task in
the workset. Undocumented warnings are not acceptable.

## Step 5 — Implement

Write code in the target repository worktree only. Stay within the declared
`module_id`. Do not write to any other repository as a fallback.

## Step 6 — Record evidence and commit

Record code commit, changed files, test results, and agent evidence in
`context/evidence/task-results/`. Update `workset.yaml`:
- `status: implemented`
- `agents_invoked[]` — complete list with timestamps
- `commit` — the implementation commit SHA
