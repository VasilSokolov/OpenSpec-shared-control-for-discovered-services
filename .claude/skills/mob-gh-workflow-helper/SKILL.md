---
name: mob-gh-workflow-helper
description: Set up GitHub workflows — either standalone workflows or using shared workflows from mobile-de/gh-workflows (Java/Node apps, Java/Node libraries, Node monorepos, Build and Deploy Docker Images).
argument-hint: "[use-case or repo type]"
allowed-tools: Read, Grep, Glob
metadata:
  author: mobile.de
  version: "1.0"
  tags: github
---

# GitHub Workflows Setup

Use this skill when you need to **create or update GitHub Actions workflows**. Either create a **standalone** workflow with the mobile-de custom setup, or—when the use-case fits—reuse **shared workflows** from [mobile-de/gh-workflows](https://github.mpi-internal.com/mobile-de/gh-workflows).

## 1. Decide: Standalone vs shared workflow

- **Standalone**: Custom workflow with your own jobs and steps (e.g. simple lint/test, one-off scripts, or a stack not covered by shared workflows).
- **Shared workflow**: Use when the repo matches one of these:
  - **Deployable Java or Node (or both) application** → `build-application.yml`
  - **Java library** (Maven, publish to Nexus) → `build-java-library.yml` (+ optionally `analyze-java-build.yml` for PRs)
  - **Node library** (single package or non-Lerna multi-package) → `build-node-library.yml`
  - **Node monorepo** `npm-publish-monorepo` **action** inside your own workflow
  - **Build Docker Images** `build-docker` **action** inside your own workflow

**Rules:** Prefer shared when the use case is Java app, Node app, Java library, Node library, Docker Image or Node monorepo. Use standalone otherwise and add a failure-notification step for standalone workflows. For shared build plus custom job (e.g. shared build + custom lint): use the shared workflow for the build and a separate job or workflow for the custom part, with failure notification on the standalone part where applicable.

If the use-case fits a shared workflow, prefer it for consistency, runner sizing, and built-in steps.

---

## 2. mobile-de org specifics: `runs-on` labels

In the mobile-de GitHub Enterprise instance, **self-hosted runners** use custom labels. Use these in **standalone** workflows (shared workflows already set them internally).

### Runner size labels

| Label        | Use for                                                                 |
| ------------ | ----------------------------------------------------------------------- |
| `size/small` | Light jobs: lint, small unit tests, metadata checks, deploy triggers   |
| `size/medium`| Default for most Node builds and moderate test suites                   |
| `size/big`   | Heavy work: large Java/Maven builds, Docker builds, SBOM, big test runs |

### Org label (optional)

- **`mobile-de`**: Organization-level label. Can be **combined** with a size, e.g. `runs-on: [mobile-de, size/big]`, when your org runners are tagged that way (e.g. for monorepo publish jobs in the README). If your repo only uses size labels, `[size/medium]` or `[size/big]` is enough.

### Summary for standalone workflows

- Prefer **one** size label: `[size/small]`, `[size/medium]`, or `[size/big]`.
- If your org uses `mobile-de` runners, you can use `[mobile-de, size/big]` (or other size) as in the gh-workflows README monorepo example.
- For **Node**, always pass a token to `actions/setup-node` (e.g. `token: ${{ secrets.GH_COM_TOKEN }}`) to avoid GitHub API rate limits; prefer `node-version-file: .nvmrc`.

---

## 3. Standalone workflow: basic setup

When **not** using a shared workflow, create a workflow file (e.g. `.github/workflows/build.yml`) with:

- `on`: e.g. `push`, `pull_request`, and/or `workflow_dispatch`.
- `jobs.<job_id>.runs-on`: one of `[size/small]`, `[size/medium]`, `[size/big]` (or `[mobile-de, size/<size>]` if your org uses it).
- Steps: checkout, setup language/runtime, install, test/build as needed.
- **Slack notification on failure**: Always add a step that runs only when the job has failed (`if: failure()`), using the exact format below. Use secret `SLACK_NOTIFICATION_TOKEN`; the channel id is set by the repo (placeholder in the step). Shared workflows already include their own notifications; this applies only to standalone workflows.

Example (Node, size/medium, with Slack on failure):

```yaml
name: Build

on:
  push:
    branches: [main]
  pull_request:
    types: [opened, synchronize]

jobs:
  build:
    runs-on: [size/medium]
    steps:
      - uses: actions/checkout@v4

      - name: Set up Node
        uses: actions/setup-node@v4
        with:
          node-version-file: .nvmrc
          token: ${{ secrets.GH_COM_TOKEN }}

      - name: Install dependencies
        run: npm ci

      - name: Run tests
        run: npm test

      - name: Send Slack notification
        if: failure()
        uses: slackapi/slack-github-action@v2.1.1
        env:
          SLACK_BOT_TOKEN: ${{ secrets.SLACK_NOTIFICATION_TOKEN }}
        with:
          channel-id: "[Slack Channel ID here]"
          slack-message: ":alert: run failed. Please check logs."
```

- Replace `[Slack Channel ID here]` with the repo's Slack channel ID. Ensure `SLACK_NOTIFICATION_TOKEN` is set in the repo/organization secrets. Do not block workflow creation if the channel is missing—include the placeholder so the user or repo can set it.
- Use `size/big` for Docker builds, heavy Java builds, or large test suites.

---

## 4. Shared workflows from mobile-de/gh-workflows

Reference: **`uses: mobile-de/gh-workflows/.github/workflows/<workflow-name>.yml@master`** and **`secrets: inherit`**. Add the required `with:` inputs as below.

### 4.1 Deployable application (Node and/or Java, Docker)

**Workflow:** `build-application.yml`  
**Use for:** Services that build and deploy (Node, Java/Go, Docker, mOrlo release).

- Reference from `.github/workflows/build.yml`.
- Required input: `jobs-yaml` (e.g. `src/main/resources/static/internal/jobs.yml`) when you use mOrlo.
- Optional: `base-path`, `runs-on` (JSON array, default `["size/big"]`), `pre-build`, `pre-node-build`, `post-node-build`, `pre-java-build`, `dockerfile`, `k8s-yaml`, etc.
- **Output:** `outputs.version` — required if you chain with `deploy-pr-to-staging.yml`.

Example:

```yaml
name: Build
on:
  workflow_dispatch:
  push: {}

jobs:
  build:
    uses: mobile-de/gh-workflows/.github/workflows/build-application.yml@master
    name: Build
    secrets: inherit
    with:
      jobs-yaml: src/main/resources/static/internal/jobs.yml
```

### 4.2 Java library

**Workflow:** `build-java-library.yml`  
**Use for:** Maven-based Java libraries published to internal Nexus.

- **Preconditions:** `mvnw` (Maven wrapper); `distributionManagement` with repo id used by the org (e.g. `repo.mobint.io`); `scm` with HTTPS repo URL.
- Optional inputs: `base-path`, `maven-goals` (e.g. `deploy` or `release:prepare release:perform`), `pre-java-build`, `extra-build-output`, `artefact-owner`, `build-sbom-enabled`.
- For **PR analysis** (e.g. Sonar/Findings on PR): add a separate workflow that calls `analyze-java-build.yml` on `pull_request` (see gh-workflows README).

Example:

```yaml
name: Build and Release
on:
  push: {}
  workflow_dispatch:
    inputs:
      goals:
        type: choice
        description: Maven goals to execute
        options:
          - verify
          - deploy
          - 'release:prepare release:perform'

jobs:
  build:
    uses: mobile-de/gh-workflows/.github/workflows/build-java-library.yml@master
    secrets: inherit
    with:
      maven-goals: ${{ github.event.inputs.goals || 'deploy' }}
```

### 4.3 Node library

**Workflow:** `build-node-library.yml`  
**Use for:** Single Node package or non-Lerna multi-package: build, version, optional publish to internal npm.

- Optional inputs: `version-bump`, `pre-release-command`, `post-release-command`, `publish-directory`, `publish-registry`, `automatic-publish`, `base-path`, `skip-node-build`, `pre-node-build`, `post-node-build`, `node-env-vars`.
- Supports conventional-commits–based version bump and PR canary publishing when `automatic-publish: true`.

Example:

```yaml
name: Build & Publish
on:
  push:
    branches: [master]
  pull_request:
    types: [opened, synchronize]
  workflow_dispatch:
    inputs:
      version-bump:
        type: choice
        options: [major, minor, patch]
        default: patch

jobs:
  build:
    uses: mobile-de/gh-workflows/.github/workflows/build-node-library.yml@master
    secrets: inherit
    with:
      version-bump: ${{ inputs.version-bump }}
      automatic-publish: true
      base-path: '.'
```

### 4.4 Node monorepo (Lerna)

**Use the action** `npm-publish-monorepo`, not a full workflow. Build and install in your own job first; then run the action.

- **runs-on:** e.g. `[mobile-de, size/big]` or `[size/big]` (see gh-workflows README).
- **Inputs:** `publish-cmd` (e.g. `yarn publish`), `package-scope` (e.g. `@mobile-de`), `npm-token`, `github-token`, `slack-token`.
- Checkout with `fetch-depth: 0` and `fetch-tags: true`.

Example:

```yaml
jobs:
  publish:
    runs-on: [mobile-de, size/big]
    steps:
      - uses: actions/checkout@v4
        with:
          fetch-depth: 0
          fetch-tags: true
      # ... install and build steps ...
      - name: Publish Packages
        uses: mobile-de/gh-workflows/.github/actions/npm-publish-monorepo@master
        with:
          publish-cmd: yarn publish
          package-scope: '@mobile-de'
          npm-token: ${{ secrets.ARTIFACTORY_TOKEN }}
          github-token: ${{ secrets.GITHUB_TOKEN }}
          slack-token: ${{ secrets.SLACK_HUB_AUTH_KEY }}
```

---

## 5. Edge cases

- **Mixed Java + Node in one repo:** Recommend the **build-application** workflow; it supports multiple stacks. Document how to pass options for each part (e.g. `pre-node-build`, `pre-java-build`).
- **Library vs application unclear:** Define the distinction: deployable service (Dockerfile, deploy config) vs publishable package (package.json with publish script). Infer from context or ask the user.
- **Missing Slack channel:** Do not block workflow creation. Include the placeholder `channel-id: "[Slack Channel ID here]"` and state that the user or repo must set it. Use org secret `SLACK_NOTIFICATION_TOKEN` for the token.
- **Repos that cannot use `secrets: inherit`:** Document that required secrets must be passed explicitly when inherit is not used. Commonly needed per workflow type: build-application → `GH_COM_TOKEN`, `ARTIFACTORY_*`, `MORLO_TOKEN` if mOrlo; Java library → `NEXUS_*`, `SONAR_TOKEN`; Node library → `GH_COM_TOKEN`, `ARTIFACTORY_TOKEN`/`NEXUS_NPM_TOKEN`; monorepo → `ARTIFACTORY_TOKEN`, `GITHUB_TOKEN`, `SLACK_HUB_AUTH_KEY`. See §7 for the full org list.

---

## 6. Other shared workflows (reference)

- **deploy-pr-to-staging.yml** — Deploys PR build to staging; **requires** `needs.build.outputs.version` from a preceding `build-application` job. Inputs: `stagingNumber`, `prNumber`, `branchName`, `serviceVersion`, `serviceBaseName`; secret `MORLO_TOKEN`.
- **check-coverage.yml** — Compares coverage to base branch; needs `coverage.config.json` on base branch and lcov report from `test-coverage-cmd`.
- **analyze-java-build.yml** — PR-only; analyzes Java build output and comments on PR.
- **jira-ticket-validation-and-notification.yml** — Jira ticket in PR/branch; optional SOX enforcement with `fail_on_missing_ticket: true`.
- **bundlewatch.yml** — Bundle size checks.
- **dpm-validation.yml** — Data Product Manager validation/publish (needs `DATASTRATEGY_GH_TOKEN` and path config).
- **validate-and-publish-schema.yml** / **delete-schema-version.yml** — Avro schema validation/publish; support custom `runs-on` via inputs.

Full parameter and usage details: see the [gh-workflows README](https://github.mpi-internal.com/mobile-de/gh-workflows/blob/master/README.md) and the workflow YAML files under `.github/workflows/`.

---

## 7. Global GitHub secrets and variables (mobile-de org)

When wiring workflows, use these **organization-level** secrets and variables. Reference them as `${{ secrets.SECRET_NAME }}` and `${{ vars.VAR_NAME }}`. For reusable workflows, `secrets: inherit` passes org secrets; pass variables via `with:` if the workflow accepts them, or they are available in the runner environment when defined at org level.

When generating or explaining a step that needs auth or config, reference the appropriate name from the lists below (e.g. Slack → SLACK_NOTIFICATION_TOKEN, Node → GH_COM_TOKEN, Artifactory/Nexus → ARTIFACTORY_TOKEN / NEXUS_NPM_TOKEN, Sonar → SONAR_TOKEN and SONAR_HOST_URL). For the standalone failure-notification step, use secret **SLACK_NOTIFICATION_TOKEN** and state that the channel id must be set by the repo.

### Global secrets

APP_INVENTORY_SECRET, ARTIFACTORY_CONTEXT, ARTIFACTORY_NPM_SECRET, ARTIFACTORY_PWD, ARTIFACTORY_SERVICE_USER, ARTIFACTORY_SERVICE_USER_KEY, ARTIFACTORY_TOKEN, ARTIFACTORY_URL, ARTIFACTORY_USER, CLAUDE_CODE_APP_PRIVATE_KEY, DATASTRATEGY_GH_TOKEN, DEPENDENCYTRACK_APIKEY, DEPENDENCY_DISCO_TOKEN, DEPENDENCY_TRACK_API_KEY, DEVHOSE_CLI_SECRET, DEVHOSE_KEY, DEVHOSE_TENANT, EXTERNAL_GITHUB_TOKEN, EXTERNAL_GITHUB_USER, GH_COM_TOKEN, GH_MPI_TOKEN, GRADLE_WRAPPER_GITHUB_TOKEN, JIRA_TOKEN, LANGDOCK_TOKEN, MOBILE_PUBLISHER, MORLO_TOKEN, NEXUS_MAVEN_PASSWORD, NEXUS_MAVEN_USER, NEXUS_NPM_TOKEN, ORG_READ_TOKEN, QUALITY_GATE_REPORTS_KEY, QUALITY_GATE_REPORTS_SECRET, QUAY_API_TOKEN_VISIBILITY, REGISTRY_PASSWORD, REGISTRY_REPOSITORY, REGISTRY_USERNAME, SLACK_NOTIFICATION_TOKEN (use for standalone Slack-on-failure step), SNYK_TOKEN, SONAR_HOST, SONAR_TOKEN, SPT_ENGPROD_REPORT_KEY, SPT_ENGPROD_REPORT_SECRET, SRV_BTS_ES_GH_TOKEN, UNICRON_GITHUB_TOKEN

### Global variables

APP_INVENTORY_URL, CLAUDE_CODE_APP_ID, CLAUDE_CODE_AWS_ROLE, CLAUDE_CODE_MODEL, DEV_LAKE_URL, ECR_REGISTRY_REPOSITORY, JIRA_URL, LANGDOCK_TECH_FOLDER, MORLO_URL, REGISTRY_REPOSITORY, SONAR_HOST_URL  

Use these when a workflow needs registry URLs, Sonar host, Jira URL, Slack token, Artifactory/Nexus credentials, or other org-wide config. Do not hardcode URLs or tokens; reference secrets and variables so they can be rotated at org level.

### Special mappings

#### actions/setup-node
This action needs the GH_COM_TOKEN.

---

## 8. How to help when this skill is active

1. **Identify the use-case**: Deployable app vs library; Java vs Node; single package vs monorepo vs docker build.
2. **Choose**:
   - Standalone workflow → use correct `runs-on` (and optional `mobile-de`), Node token, and minimal steps.
   - Shared workflow/action → pick the right one from the table above and wire `with:` and `secrets`.
3. **Generate or adapt** workflow YAML that:
   - Uses `mobile-de/gh-workflows` when reusing.
   - Uses `secrets: inherit` for reusable workflows.
   - Chains outputs/inputs where needed (e.g. `build-application` → `deploy-pr-to-staging`).
4. **Mention** required secrets and config (see **§7 Global GitHub secrets and variables** for the full org list.
