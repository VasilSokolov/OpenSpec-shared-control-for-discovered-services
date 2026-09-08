---
name: mob-jira-sdd-refinement
description: Guide technical refinement of Jira tickets following mobile.de's two-stage Spec-Driven Development workflow. Use this skill when you need to perform technical refinement on a Jira ticket (Stage 2), create a validated technical plan with mob-code-search, break down implementation into tasks, or prepare a ticket for development. Triggers when the user asks to "refine" or "tech refine" a Jira ticket, mentions "technical refinement", "create technical plan", "validate against codebase", "break down into tasks", or provides a Jira ticket key (TNS-XXX, MFE-XXX) for refinement. Works with both structured specs (already refined) and unstructured ticket descriptions (creates spec collaboratively). Always produces Spec + Validation + Technical Plan + Tasks directly in Jira (no local files).
license: MIT
compatibility: Requires atlassian MCP server and mob-code-search MCP server
advisor_mode: advisor_20260301
metadata:
  author: Mobile.de Team
  version: "3.0"
  based_on: LeSS Multi-team PBR, Shape Up Building prep, Three Amigos pattern
  tags:
    - jira
    - sdd
    - spec-driven-development
    - refinement
    - tech-refinement
    - planning
    - validation
    - openspec
    - two-stage-refinement
    - mobile-de
---

Guide tech teams through technical refinement of Jira tickets, creating validated plans and implementation tasks.

**Input**: Jira ticket key (e.g., "TNS-332")
**Output**: Updated ticket with **Spec + Validation + Technical Plan + Tasks**

---

## Quick Start

```bash
/mob-jira-sdd-refinement TNS-332
```

**What happens**:
1. Fetches ticket from Jira
2. Ensures structured Spec exists (creates with you if needed)
3. Creates Technical Plan through conversation
4. Validates plan against codebase using mob-code-search
5. Breaks down into implementation tasks
6. Updates Jira ticket with all sections

**Result**: Ticket ready for `/opsx:apply TNS-332`

See [Complete Example](#complete-example) for what the final ticket looks like.

---

## Concepts

### Two-Stage Refinement

**Stage 1: Product Refinement** (PO + Tech Lead - may already be done)
- Output: **Spec** (WHAT/WHY) - Problem, Context, Expected Outcome, Acceptance Criteria
- Format: May be **structured** (has ## Spec header) OR **unstructured** (raw description)

**Stage 2: Technical Refinement** (This skill - Full dev team)
- Input: Ticket from Stage 1
- Output: **Validation + Technical Plan + Tasks** (HOW + verified)
- Tool: mob-code-search (codebase search tool that verifies plan matches existing code)

### Two Paths, Same Outcome

**Path A: Structured Spec exists**
1. Extract existing Spec
2. Create Validation + Technical Plan + Tasks
3. **Update**: Append to original description

**Path B: Unstructured description**
1. Create Spec collaboratively with user
2. Create Validation + Technical Plan + Tasks
3. **Update**: Replace with structured sections + preserve original as reference

**Result**: Both produce **Spec + Validation + Technical Plan + Tasks**

### Key Terms

- **Spec** = WHAT/WHY (functional requirements, no implementation details)
- **Validation** = Codebase findings (what exists, patterns to follow)
- **Technical Plan** = HOW (components, architecture, implementation approach)
- **Tasks** = DO (step-by-step implementation with references to validation findings)

---

## Workflow

### 1. Fetch & Determine Path

**Why**: Understand what was decided in Product Refinement before creating technical plan.

**What**: Load ticket and determine if it has structured Spec or needs one created.

**How**:

Load tools:
```
ToolSearch(query: "select:mcp__plugin_atlassian_atlassian__getJiraIssue")
```

Fetch ticket:
```
mcp__plugin_atlassian_atlassian__getJiraIssue(issueKey: "<JIRA-KEY>")
```

Store original description (preserved either way).

Check structure: Look for "## Spec" or "## Product Spec" header with Problem/Context/Outcome/Acceptance Criteria sections.

**Determine path**:
- **Has structured Spec** → Path A: Extract and use
- **No structured Spec** → Path B: Create with user

---

### 2. Ensure Spec Exists

**Why**: Need clear functional requirements before designing technical solution.

**What**: Extract existing Spec or create structured Spec collaboratively.

**How**:

**Path A (Structured Spec found)**:
- Extract Spec sections (Problem, Context, Expected Outcome, Acceptance Criteria)
- Show to user with summary
- Confirm and proceed

**Path B (No structured Spec)**:
- Show unstructured content to user
- Guide through creating Spec by asking:
  - **Problem**: "What problem does this solve? Why is it needed?"
  - **Context**: "What's the background? Any constraints or dependencies?"
  - **Expected Outcome**: "What does success look like?"
  - **Acceptance Criteria**: "What are the functional MUST-HAVEs?"

Build Spec collaboratively (see [Complete Example](#complete-example) → Spec section for format):
- Problem: 2-3 sentences explaining WHY
- Context: Brief background, current state, dependencies
- Expected Outcome: Single paragraph describing WHAT success looks like
- Acceptance Criteria: Functional requirements only (no implementation details like "uses Redis" or "injects X class")

Show created Spec to user, note that original description will be preserved as reference.

**Display refinement overview**:
```
## Tech Refinement: <JIRA-KEY>

**Jira**: <URL>
**Summary**: <Title>
**Priority**: <Priority> | **Status**: <Status>

### Stage 1: Product Refinement ✅
- Spec: [Path A: extracted | Path B: created]
- Problem: <brief summary>
- Expected Outcome: <brief summary>
- Acceptance Criteria: <count> criteria

[Path B only] Note: Original description preserved as reference

### Stage 2: Tech Refinement (Starting)
Will create:
1. ✅ Spec (done)
2. ⏳ Validation (codebase verification)
3. ⏳ Technical Plan (implementation approach)
4. ⏳ Tasks (step-by-step)

Ready to proceed?
```

---

### 3. Create & Validate Technical Plan

**Why**: Design implementation approach and verify it matches codebase patterns before breaking into tasks. Validation catches misalignments that would cause rework.

**What**: Create Technical Plan through conversation, then validate against actual codebase using mob-code-search.

**How**:

#### 3a. Create Technical Plan

Guide user through key questions:

**Technical Approach**:
- "What's the high-level solution?"
- "Which architecture pattern fits best?"
- "What are the main components?"
- "What tradeoffs exist?"

**Components**:
- "Which files need creation or modification?"
- "What classes/functions are needed?"
- "Where do they fit in the architecture?"
- "Are there existing patterns to follow?"

**Data Flow**:
- "How does data flow through the system?"
- "What are inputs and outputs?"
- "Where could failures occur?"

**Error Handling**:
- "What failure scenarios exist?"
- "How should we handle them?"

**Testing**:
- "What testing strategy? Unit? Integration?"
- "What are critical paths?"

Build plan through conversation (see [Complete Example](#complete-example) → Technical Plan section for format).

#### 3b. Validate Plan (MANDATORY)

Load validation tools:
```
ToolSearch(query: "select:mcp__mob-code-search__search,mcp__mob-code-search__find_files,mcp__mob-code-search__find_symbol,mcp__mob-code-search__read_code")
```

For each component, verify:
- ✓ Do mentioned files/services exist? Naming correct?
- ✓ Are there similar implementations to reference?
- ✓ Do proposed patterns align with codebase architecture?
- ✓ Any conflicts with existing code?
- ✓ Reusable utilities available?

Record findings (see [Complete Example](#complete-example) → Validation section for format):
- Date, Status (✅ validated / ⚠️ concerns / ❌ blocked)
- 3-5 findings (what exists in codebase, patterns established)
- Concerns (only if ⚠️/❌: blockers, conflicts, missing dependencies)
- Reference files (list with purpose)

**Handle validation results**:
- **✅ Validated**: Announce success, proceed to tasks
- **⚠️ Concerns**: Show findings to user, explain concerns, confirm proceed or revise plan
- **❌ Blocked**: Stop. Explain conflicts clearly, propose specific plan adjustments with tradeoffs, get user approval, revise plan, re-validate before proceeding

---

### 4. Create Tasks

**Why**: Break plan into concrete, actionable implementation steps that developers can execute.

**What**: Convert Technical Plan into 6-10 focused tasks with references to validation findings.

**How**:

For each component in plan, create tasks that:
- Are small and focused (single responsibility)
- Reference specific files from validation
- Include verification steps
- Are ordered by dependencies

Task format (see [Complete Example](#complete-example) → Tasks section):
```markdown
- [ ] **Task description** (file: path/to/file)
      Reference: path/to/similar.ts (from validation)
      - Sub-step 1
      - Sub-step 2
      Verify: How to test this task
```

Guidelines:
- 6-10 tasks total (not too granular, not too coarse)
- Each task includes file location
- Each task references validation findings (similar implementations, patterns, utilities)
- Each task has verification criteria
- Tasks are ordered logically (dependencies first)

---

### 5. Update Jira Ticket

**Why**: Put all refinement artifacts in Jira for visibility and handoff to developers.

**What**: Update ticket description with complete refinement (Spec + Validation + Technical Plan + Tasks).

**How**:

Show complete summary to user for confirmation:
```
## Tech Refinement Summary: <JIRA-KEY>

### Sections Created ✅
1. ✅ Spec [Path A: extracted | Path B: created]
2. ✅ Validation - mob-code-search findings (<count> reference files)
3. ✅ Technical Plan - <count> components
4. ✅ Tasks - <count> implementation tasks

### Validation Status: <✅/⚠️>
Key findings: [brief list]

### Tasks Overview:
1. <Task 1 summary>
2. <Task 2 summary>
...

Ready to update Jira?
[Path A] Will append: Validation + Technical Plan + Tasks
[Path B] Will structure as: Spec + Validation + Plan + Tasks + Original (reference)
```

After confirmation, load edit tool:
```
ToolSearch(query: "select:mcp__plugin_atlassian_atlassian__editJiraIssue")
```

Build complete description based on path:

**Path A (Structured Spec existed)**:
```markdown
<Original description with Spec - KEEP AS IS>

---

# Validation
<Validation content>

---

# Technical Plan
<Plan content>

---

# Tasks
<Tasks content>
```

**Path B (Spec created)**:
```markdown
# Spec
<Spec content created in Step 2>

---

# Validation
<Validation content>

---

# Technical Plan
<Plan content>

---

# Tasks
<Tasks content>

---

# Original Ticket Description (Reference)
<Original unstructured description>
```

Update ticket:
```
mcp__plugin_atlassian_atlassian__editJiraIssue(
  issueKey: "<JIRA-KEY>",
  update: {
    description: "<Complete description>"
  }
)
```

Announce success:
```
✅ Jira ticket updated: <URL>

Sections added:
- ✅ Spec [Path A: preserved | Path B: created]
- ✅ Validation
- ✅ Technical Plan
- ✅ Tasks (<count>)
[Path B only] - ✅ Original Description (reference)

View: <URL>
```

---

### 6. Complete Refinement

**Why**: Finalize ticket status and confirm readiness for implementation.

**What**: Update ticket status and provide final summary.

**How**:

Recommend status update:
```
📝 Update ticket status?

Current: <Current Status>
Suggested: Tech Refined (or Ready for Development)

Update status? (yes/no)
```

If yes, update status to appropriate value.

Show final summary:
```
## ✅ Tech Refinement Complete: <JIRA-KEY>

**Jira**: <URL>
**Status**: Tech Refined

### Summary
- Spec ✅ (Problem, Context, Outcome, Acceptance Criteria)
- Validation ✅ (<count> reference files found)
- Technical Plan ✅ (<count> components)
- Tasks ✅ (<count> implementation tasks)

### Implementation Ready

Everything needed is in Jira:
1. **Spec** - WHAT/WHY
2. **Validation** - Codebase findings, patterns to follow
3. **Technical Plan** - HOW to implement
4. **Tasks** - Step-by-step with verification

**Developer can start**:
```bash
/opsx:apply <JIRA-KEY>
```

Next Steps:
1. Assign to developer
2. Developer runs: `/opsx:apply <JIRA-KEY>`
3. Developer implements tasks using validation references
```

---

## Complete Example

Shows what TNS-332 looks like after tech refinement (use this as format reference):

```markdown
# Spec

## Problem
Users cannot track their saved searches because the notification system only supports vehicle alerts. This creates a 40% drop-off in repeat user engagement for search-based workflows.

## Context
Current notification-service supports vehicle alerts via FCM. Search service maintains user search history but has no notification integration. Product analytics show users want search alerts more than vehicle alerts (65% vs 35% from survey).

## Expected Outcome
Users can enable notifications for saved searches and receive alerts when new results match their criteria, increasing engagement by 20% (target from Product).

## Acceptance Criteria
- User can toggle notifications on/off per saved search
- Notifications delivered within 5 minutes of new matching results
- Notification includes search name and count of new results
- User can disable all search notifications from settings
- Performance: No impact on existing vehicle alert latency

---

# Validation

**Date**: 2026-05-10 | **Status**: ✅ Validated

**Findings:**
- notification-service already has FCM infrastructure and template system
- search-service exposes GET /users/{id}/searches API
- Similar pattern exists: vehicle-alert-service uses event-driven architecture with Kafka
- Constants in notification-service: NOTIFICATION_DELAY_MS = 300000 (5min)
- Auth middleware available: AuthorizationFilter validates user tokens

**Reference Files:**
- `notification-service/src/main/java/VehicleAlertProcessor.java` - Event processing pattern to follow
- `notification-service/src/main/java/templates/AlertTemplate.java` - Template system for notifications
- `search-service/src/main/java/api/SearchController.java` - Existing search API
- `shared-lib/kafka/EventProducer.java` - Kafka producer utility

---

# Technical Plan

## Components

### SearchNotificationEvent (new)
- **Purpose**: Kafka event carrying search results
- **Location**: `events-schema/src/main/avro/SearchNotificationEvent.avsc`
- **Changes**: Create new Avro schema with searchId, userId, newResultCount

### SearchAlertProcessor (new)
- **Purpose**: Consumes search events, checks notification preferences, sends FCM
- **Location**: `notification-service/src/main/java/SearchAlertProcessor.java`
- **Changes**: New class following VehicleAlertProcessor pattern

### SearchController (modify)
- **Purpose**: Publish event when new results match saved search
- **Location**: `search-service/src/main/java/api/SearchController.java`
- **Changes**: Add event publishing after search execution

### SearchNotificationPreferences (new)
- **Purpose**: Store user preferences for search alerts
- **Location**: `notification-service/src/main/java/model/SearchNotificationPreferences.java`
- **Changes**: New entity with user_id, search_id, enabled fields

## Data Flow
User enables notification → Preference stored → New search results → search-service publishes SearchNotificationEvent → Kafka → SearchAlertProcessor consumes → Checks preference → Sends FCM via existing NotificationSender

## Error Handling
- Kafka publish failure: Log error, continue search (notifications non-critical)
- FCM send failure: Retry 3x with exponential backoff (existing pattern)
- Invalid preference: Treat as disabled, log warning

## Testing Strategy
- Unit: SearchAlertProcessor logic, preference checks
- Integration: End-to-end Kafka flow with test consumer
- Staging: Enable for 10% users, verify delivery latency < 5min

---

# Tasks

- [ ] **Create SearchNotificationEvent schema** (events-schema/src/main/avro/)
      Reference: VehicleAlertEvent.avsc for structure
      - Define searchId, userId, newResultCount, timestamp fields
      - Add schema to gradle build
      - Generate Java classes
      Verify: Schema compiles, classes generated in target/

- [ ] **Implement SearchAlertProcessor** (notification-service/src/main/java/)
      Reference: VehicleAlertProcessor.java for pattern
      - Create processor consuming SearchNotificationEvent
      - Check SearchNotificationPreferences for user
      - Use existing NotificationSender if enabled
      - Follow error handling pattern from VehicleAlertProcessor
      Verify: Unit tests pass, processor starts without errors

- [ ] **Add event publishing to SearchController** (search-service/src/main/java/api/)
      Reference: shared-lib/kafka/EventProducer.java
      - Inject EventProducer in constructor
      - After search execution, check if results > 0
      - Publish SearchNotificationEvent with result count
      - Handle publish failure gracefully (log only)
      Verify: Integration test confirms event published

- [ ] **Create SearchNotificationPreferences entity** (notification-service/src/main/java/model/)
      Reference: VehicleAlertPreferences.java
      - Add entity with user_id, search_id, enabled columns
      - Create repository interface
      - Add Liquibase migration
      Verify: Migration runs, table created

- [ ] **Add preferences API endpoint** (notification-service/src/main/java/api/)
      Reference: VehicleAlertController.java for auth pattern
      - POST /notifications/search-alerts/preferences
      - Use AuthorizationFilter from reference
      - Validate user can only set own preferences
      Verify: API tests pass, auth works

- [ ] **Create notification template** (notification-service/src/main/java/templates/)
      Reference: AlertTemplate.java for FCM format
      - Create SearchAlertTemplate with title, body format
      - Include search name and result count
      - Follow existing template naming
      Verify: Template renders correctly in unit test

- [ ] **Integration test end-to-end flow** (notification-service/src/test/java/integration/)
      Reference: VehicleAlertIntegrationTest.java
      - Publish test event to Kafka
      - Verify processor consumes
      - Mock FCM, verify send called with correct data
      Verify: Test passes, logs show full flow

- [ ] **Deploy to staging, enable for 10% users**
      Reference: Deployment runbook in Confluence
      - Deploy search-service, notification-service
      - Enable feature flag for 10% traffic
      - Monitor latency dashboard
      Verify: Notifications delivered < 5min, no errors in logs
```

---

## Guardrails

- **Always produce Spec + Validation + Plan + Tasks** - regardless of input structure
- **Preserve original content** - Never lose information (append as reference if needed)
- **Validation is mandatory** - Cannot skip; must pass (✅ or ⚠️ reviewed) before tasks
- **Reference validation findings in tasks** - Tasks must cite files from mob-code-search
- **Confirm before updating Jira** - Show complete summary, get approval
- **No estimations** - Never add hours, days, story points
- **Keep sections concise**: Spec = WHAT, Plan = HOW, Tasks = DO (no repetition)
- **Acceptance Criteria = functional only** - No implementation details in ACs

---

## Error Handling

**If mob-code-search unavailable**:
- Warn: "Validation is CRITICAL - cannot proceed safely without codebase verification"
- Offer: Wait for availability OR proceed at risk (not recommended)

**If validation blocked (❌)**:
- Stop task creation
- Explain conflicts clearly (what doesn't match, why it matters)
- Propose plan adjustments with tradeoffs
- Get user approval, revise plan, re-validate

**If Jira update fails**:
- Show content that would be added
- Offer retry or export to clipboard

**If original description very long**:
- Still preserve as reference (Path B)
- Can summarize key points but keep full original text

---

## Integration Points

**Required MCP Servers**:
1. **atlassian** - Read/update Jira tickets (`getJiraIssue`, `editJiraIssue`)
2. **mob-code-search** - Validate plan against codebase (MANDATORY for validation step)

**No OpenSpec CLI needed** - Works entirely with Jira, no local files.

---

## Example Usage

```bash
# Tech Lead or Developer runs:
/mob-jira-sdd-refinement TNS-332

# Skill guides through:
# 1. ✅ Fetch TNS-332, determine path (structured/unstructured)
# 2. ✅ Ensure Spec exists (extract or create)
# 3. ✅ Create Technical Plan + Validate with mob-code-search
# 4. ✅ Create implementation tasks (with validation references)
# 5. ✅ Update Jira: Spec + Validation + Plan + Tasks
# 6. ✅ Update status to "Tech Refined"

# Result: Ticket ready for implementation
# Developer runs: /opsx:apply TNS-332
```

---

**Version**: 3.0 (Refactored for clarity and conciseness)
