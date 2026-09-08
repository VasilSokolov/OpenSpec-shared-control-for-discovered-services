# mde-ab-testing

A/B testing and feature-flag lifecycle skill for Kameleoon experiments at mobile.de.

This skill is **dormant by default**. It activates only when the `mobile-ab-testing`
capability is detected (i.e. `@kameleoon/sdk` or `kameleoon-client` appears in
`package.json` of the target module). See `openspec/capability-skill-matrix.yaml`.

---

## Philosophy: tradition → evolution

Every user-facing feature at mobile.de starts as a **fixed implementation** — one
design, no variants. This is the tradition. It ships, it runs, it generates data.

The evolution path to an A/B experiment has four phases:

```
1. Fixed implementation (tradition)
      ↓  (product has a hypothesis)
2. Experiment design  ← THIS SKILL GATES THIS STEP
      ↓  (approved by analytics + product)
3. Experiment live    ← Kameleoon is active
      ↓  (results reach statistical significance)
4. Conclude & clean up ← winning variant ships, experiment code removed
```

**Never go directly from Figma → A/B experiment.** The fixed implementation is
mandatory first. Running an experiment on an unproven feature produces noise,
not signal.

---

## Mandatory pre-conditions before any experiment code is merged

### Step 1 — Hypothesis document

The change package must contain `context/evidence/ab-test-hypothesis.md` with:

- **Hypothesis**: "We believe that [variant X] will [outcome Y] for [segment Z]"
- **Primary metric**: one measurable KPI (e.g. contract completion rate, CTR)
- **Secondary metrics**: up to two supporting signals
- **Minimum sample size**: calculated from expected effect size and power (80%)
- **Maximum runtime**: days, not months
- **Approval**: product owner sign-off

Without this document, block the task. Write the path in the blocker message.

### Step 2 — Kameleoon experiment registration

The experiment must be registered in the Kameleoon dashboard before code ships:
- **Experiment ID**: must match the constant in `src/.../experiments/<name>.ts`
- **Variants**: `control` (unchanged UI) + exactly one or more named treatment variants
- **Traffic split**: declared (do not default to 50/50 unless product approves)
- **Goal event**: maps to the analytics event fired in code

Record the experiment ID and dashboard URL in `context/evidence/ab-test-hypothesis.md`.

### Step 3 — Figma spec for every non-control variant

Each treatment variant must have a separate Figma frame with a `Ready` label.
Use `mde-figma-intake` to capture and store the spec under `context/evidence/`.
The control variant is the existing fixed implementation — no new Figma needed.

### Step 4 — Impact matrix

Fill this table in `context/evidence/ab-test-impact.md`:

| Area | Impact | Notes |
|------|--------|-------|
| Analytics events | [YES/NO] | Which events change? |
| SEO / meta | [YES/NO] | Server-rendered content variants? |
| Accessibility | [PASS/FAIL per variant] | Both must be WCAG AA |
| Performance (CWV) | [PASS/FAIL per variant] | No CLS or TTI regression |
| GDPR | [PASS/FAIL] | No PII in cohort assignment |

---

## Code conventions (apply when experiment code is written)

### Experiment ID constant

```ts
// src/digitalcontract/experiments/buyerFormLayout.experiment.ts
export const BUYER_FORM_LAYOUT_EXPERIMENT_ID = 'buyer-form-layout-v1';
export type BuyerFormLayoutVariant = 'control' | 'compact';
```

- One file per experiment, named `<feature>.experiment.ts`
- Exported ID string matches Kameleoon dashboard exactly
- Exported union type lists all variant names; `'control'` is always present

### useExperiment hook

Wrap the Kameleoon SDK in a single local hook — never call the SDK directly
from components:

```ts
// src/digitalcontract/experiments/useBuyerFormLayout.ts
import { useExperiment } from '@/shared/hooks/useKameleoon';
import { BUYER_FORM_LAYOUT_EXPERIMENT_ID, BuyerFormLayoutVariant } from './buyerFormLayout.experiment';

export function useBuyerFormLayout(): BuyerFormLayoutVariant {
  return useExperiment<BuyerFormLayoutVariant>(
    BUYER_FORM_LAYOUT_EXPERIMENT_ID,
    'control',  // default = control
  );
}
```

### Test-mode bypass (mandatory)

The shared `useKameleoon` hook must return the `default` variant in test
environments so that all existing tests exercise the control path:

```ts
// src/shared/hooks/useKameleoon.ts
export function useExperiment<T extends string>(id: string, defaultVariant: T): T {
  if (process.env.NODE_ENV === 'test' || process.env.NEXT_PUBLIC_AB_DISABLED === 'true') {
    return defaultVariant;
  }
  // … real Kameleoon call
}
```

`NEXT_PUBLIC_AB_DISABLED=true` is the local dev bypass — add to `.env.development`.
Never ship feature-flag-based bypasses to production.

### Analytics event on variant assignment

Fire once on mount, never on every render:

```ts
useEffect(() => {
  trackEvent('ab_variant_assigned', {
    experimentId: BUYER_FORM_LAYOUT_EXPERIMENT_ID,
    variant,
  });
}, [variant]);
```

The event name `ab_variant_assigned` is the shared standard across all experiments.

---

## Cleanup (mandatory when experiment concludes)

When results are statistically significant:

1. Ship the **winning variant** as the fixed implementation
2. Delete the `*.experiment.ts` file
3. Delete the `use<Feature>.ts` experiment hook
4. Remove the variant branch from the component
5. Remove `NEXT_PUBLIC_AB_DISABLED` from `.env.development`
6. Archive the Kameleoon experiment (do not delete — preserves audit trail)
7. Record the winning variant and final metric in the original `ab-test-hypothesis.md`

A change package that adds experiment code **must** include a linked cleanup task
in the workset before it can be approved. No dangling experiment flags.

---

## What NOT to use Kameleoon for

- Developer-only bypasses (`isMockUI`, `NEXT_PUBLIC_MOCK_UI`) — those are not experiments
- Feature flags for unfinished features — use a feature branch instead
- Infrastructure toggles — use Helm values / environment config
- Anything that processes PII as the cohort key — use anonymised visitor IDs only
