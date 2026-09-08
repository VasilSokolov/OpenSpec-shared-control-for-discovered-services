# Migration Guide: dispatchTrackEvent → dispatchTrackEventAsync

Guide for migrating from the deprecated `dispatchTrackEvent` to the recommended `dispatchTrackEventAsync` function.

> **Note:** This is a companion guide to the main [SKILL.md](../SKILL.md). For general tracking concepts, see the main skill documentation.

## Why Migrate?

### Benefits of dispatchTrackEventAsync

- ✅ **Better INP (Interaction to Next Paint)** - Defers tracking to next frame using requestAnimationFrame
- ✅ **Prevents blocking user interactions** - Non-blocking execution improves perceived performance
- ✅ **Reliable event delivery** - Has page leave listener to ensure events are sent before navigation
- ✅ **Modern async/await patterns** - Better error handling and flow control

### Status of dispatchTrackEvent

- ❌ **Deprecated** - Will be removed in future versions
- ⚠️ **Blocking** - Can negatively impact INP scores
- ⚠️ **No guarantees** - May lose events on rapid navigation

## Migration Steps

### 1. Identify Usage

Search your codebase for all occurrences:

```bash
# Find all usages
grep -r "dispatchTrackEvent" src/

# Count occurrences
grep -r "dispatchTrackEvent(" src/ | wc -l

# Exclude async version
grep -r "dispatchTrackEvent[^A]" src/
```

Common locations:
- Event handlers (onClick, onChange, etc.)
- useEffect hooks
- Component methods
- Route change handlers

### 2. Add async/await

The primary change is adding `async`/`await`:

#### ❌ Before (deprecated)

```typescript
import { dispatchTrackEvent } from '@mobile-de/trackking';

function handleClick() {
  dispatchTrackEvent('BUTTON_CLICKED', { buttonId: 'submit' });
}
```

#### ✅ After (recommended)

```typescript
import { dispatchTrackEventAsync } from '@mobile-de/trackking';

async function handleClick() {
  await dispatchTrackEventAsync('BUTTON_CLICKED', { buttonId: 'submit' });
}
```

### 3. Handle Async in Different Contexts

#### React Event Handlers

```typescript
// ❌ Before
<button onClick={() => {
  dispatchTrackEvent('BUTTON_CLICKED');
  doSomething();
}}>
  Click me
</button>

// ✅ After - Option 1: Fire and forget (most common)
<button onClick={() => {
  void dispatchTrackEventAsync('BUTTON_CLICKED'); // void = intentional fire-and-forget
  doSomething();
}}>
  Click me
</button>

// ✅ After - Option 2: Wait for tracking (rare)
<button onClick={async () => {
  await dispatchTrackEventAsync('BUTTON_CLICKED');
  doSomething(); // Only runs after tracking
}}>
  Click me
</button>
```

**When to await:**
- ✅ Await if subsequent logic depends on tracking completion
- ✅ Await in critical flows (e.g., checkout, payments)
- ❌ Don't await for simple interactions (clicks, hovers)

#### useEffect Hooks

```typescript
// ❌ Before
useEffect(() => {
  dispatchTrackEvent('PAGE_VIEW');
}, []);

// ✅ After - Fire and forget with void (preferred)
useEffect(() => {
  void dispatchTrackEventAsync('PAGE_VIEW');
}, []);
```

**Note:** No need to await in useEffect cleanup, as the function handles page leave automatically. useEffect callbacks cannot be async, so fire-and-forget is the correct pattern.

#### React Component Methods

```typescript
// ❌ Before
class MyComponent extends React.Component {
  handleSubmit() {
    dispatchTrackEvent('FORM_SUBMITTED');
    this.props.onSubmit();
  }
}

// ✅ After
class MyComponent extends React.Component {
  async handleSubmit() {
    await dispatchTrackEventAsync('FORM_SUBMITTED');
    this.props.onSubmit();
  }
}
```

#### Next.js Router Events

```typescript
// ❌ Before
router.events.on('routeChangeComplete', (url) => {
  dispatchTrackEvent('PAGE_VIEW', { url });
});

// ✅ After
router.events.on('routeChangeComplete', (url) => {
  void dispatchTrackEventAsync('PAGE_VIEW', { url });
});
```

#### Redux Effects (Rematch)

When using Rematch, update effect functions to use `dispatchTrackEventAsync`:

```typescript
// ❌ Before - Sync tracking
export const submitLeadEffects = (dispatch: Dispatch) => ({
  trackFinancingAttempt({ leadType }: TrackingPayload) {
    dispatchTrackEvent(FinancingEventActionType.FINANCING_ATTEMPT, {
      leadType,
      pagePath: PagePath.SUBMIT,
    });
  },
});
```

```typescript
// ✅ After - Async tracking
export const submitLeadEffects = (dispatch: Dispatch) => ({
  async trackFinancingAttempt({ leadType }: TrackingPayload) {
    await dispatchTrackEventAsync(FinancingEventActionType.FINANCING_ATTEMPT, {
      leadType,
      pagePath: PagePath.SUBMIT,
    });
  },
});
```

**Important Notes:**
- Mark effect functions as `async` and `await` dispatchTrackEventAsync inside
- You do NOT need to await the Rematch dispatch call itself (e.g., `dispatch.lead.trackFinancingAttempt()`)
- Rematch handles async effects automatically - they run in the background
- Only await dispatches if you need sequential execution for business logic

**Example: Effect Functions**

```typescript
// Effect definitions
export const submitLeadEffects = (dispatch: Dispatch) => ({
  async submitAOLeadAndRedirect(funnelId: FunnelId, { lead, router }: any) {
    try {
      // Await tracking inside the effect
      await dispatch.lead.trackFinancingAttempt({
        leadType: LeadType.AO_SHORTLEAD,
        funnelId,
      });

      const response = await submitAODataAndGetAoRedirectUrl(/* ... */);

      if (response.success) {
        await dispatch.lead.trackFinancingSuccess({
          leadType: LeadType.AO_SHORTLEAD,
          funnelId,
        });
      } else {
        await dispatch.lead.trackFinancingFail({
          leadType: LeadType.AO_SHORTLEAD,
          funnelId,
        });
      }
    } catch (error) {
      await dispatch.lead.trackFinancingFail({
        leadType: LeadType.AO_SHORTLEAD,
        funnelId,
      });
    }
  },

  async trackFinancingAttempt({ leadType }: TrackingPayload) {
    // Await dispatchTrackEventAsync here
    await dispatchTrackEventAsync(FinancingEventActionType.FINANCING_ATTEMPT, {
      leadType,
      pagePath: PagePath.SUBMIT,
    });
  },
});
```

**Component Usage:**

```typescript
function handleSubmit() {
  // No await needed when calling Rematch dispatch
  dispatch.lead.submitAOLeadAndRedirect(funnelId);
}
```

## Unit Testing with Jest/Vitest

### Mock Setup

Create a mock file for trackking:

```typescript
// __mocks__/@mobile-de/trackking.ts
export const dispatchTrackEventAsync = jest.fn().mockResolvedValue(undefined);
export const dispatchTrackEvent = jest.fn(); // For legacy tests
export const initialize = jest.fn();
export const registerEvents = jest.fn();
export const unregisterEvents = jest.fn();
```

### Common Test Mock Patterns

#### Pattern 1: Basic Mock (Inline)

```typescript
jest.mock('@mobile-de/trackking', () => ({
  dispatchTrackEventAsync: jest.fn().mockResolvedValue(undefined),
}))
```

**Use when:** Simple component tests with straightforward tracking

#### Pattern 2: Mock with beforeEach

```typescript
import * as trackking from '@mobile-de/trackking'

let mockedDispatchTrackEventAsync: jest.Mock

beforeEach(() => {
  mockedDispatchTrackEventAsync = trackking.dispatchTrackEventAsync as jest.Mock
  mockedDispatchTrackEventAsync.mockClear()
})
```

**Use when:** Need to clear or verify mock between tests

#### Pattern 3: Mock with spyOn

```typescript
import * as trackking from '@mobile-de/trackking'

const spy = jest.spyOn(trackking, 'dispatchTrackEventAsync')
  .mockResolvedValue(undefined)
```

**Use when:** Need to restore original implementation or spy on real module

### Testing Async Dispatch

#### Test 1: Verify Event is Dispatched

```typescript
import { dispatchTrackEventAsync } from '@mobile-de/trackking';
import { render, screen, waitFor } from '@testing-library/react';
import userEvent from '@testing-library/user-event';
import MyComponent from './MyComponent';

jest.mock('@mobile-de/trackking');

describe('MyComponent', () => {
  beforeEach(() => {
    jest.clearAllMocks();
  });

  it('should dispatch tracking event on button click', async () => {
    render(<MyComponent />);

    const button = screen.getByRole('button', { name: /click me/i });
    await userEvent.click(button);

    // Wait for async tracking
    await waitFor(() => {
      expect(dispatchTrackEventAsync).toHaveBeenCalledWith(
        'BUTTON_CLICKED',
        { buttonId: 'submit' }
      );
    });
  });
});
```

#### Test 2: Verify Event Parameters

```typescript
it('should dispatch tracking with correct parameters', async () => {
  const props = { carId: '12345', price: 25000 };
  render(<CarCard {...props} />);

  const viewButton = screen.getByText('View Details');
  await userEvent.click(viewButton);

  await waitFor(() => {
    expect(dispatchTrackEventAsync).toHaveBeenCalledWith(
      'CAR_VIEWED',
      expect.objectContaining({
        carId: '12345',
        price: 25000
      })
    );
  });
});
```

#### Test 3: Test Execution Order (When Awaiting)

```typescript
it('should complete tracking before navigation', async () => {
  const mockNavigate = jest.fn();
  render(<CheckoutButton onNavigate={mockNavigate} />);

  const button = screen.getByRole('button');
  await userEvent.click(button);

  // Ensure tracking happens before navigation
  await waitFor(() => {
    expect(dispatchTrackEventAsync).toHaveBeenCalled();
  });

  expect(mockNavigate).toHaveBeenCalledAfter(dispatchTrackEventAsync);
});
```

#### Test 4: Test Multiple Events

```typescript
it('should dispatch multiple tracking events in sequence', async () => {
  render(<MultiStepForm />);

  // Step 1
  await userEvent.click(screen.getByText('Next'));
  await waitFor(() => {
    expect(dispatchTrackEventAsync).toHaveBeenNthCalledWith(
      1,
      'STEP_1_COMPLETED'
    );
  });

  // Step 2
  await userEvent.click(screen.getByText('Next'));
  await waitFor(() => {
    expect(dispatchTrackEventAsync).toHaveBeenNthCalledWith(
      2,
      'STEP_2_COMPLETED'
    );
  });
});
```

#### Test 5: Test Error Handling

```typescript
it('should handle tracking errors gracefully', async () => {
  const consoleError = jest.spyOn(console, 'error').mockImplementation();
  (dispatchTrackEventAsync as jest.Mock).mockRejectedValueOnce(
    new Error('Tracking failed')
  );

  render(<MyComponent />);
  await userEvent.click(screen.getByRole('button'));

  // Component should still work even if tracking fails
  await waitFor(() => {
    expect(screen.getByText('Success')).toBeInTheDocument();
  });

  consoleError.mockRestore();
});
```

### Testing useEffect with Tracking

```typescript
it('should dispatch page view on mount', async () => {
  render(<PageComponent />);

  await waitFor(() => {
    expect(dispatchTrackEventAsync).toHaveBeenCalledWith('PAGE_VIEW');
  });
});

it('should not dispatch page view on re-render', async () => {
  const { rerender } = render(<PageComponent prop="value1" />);

  await waitFor(() => {
    expect(dispatchTrackEventAsync).toHaveBeenCalledTimes(1);
  });

  rerender(<PageComponent prop="value2" />);

  // Should still be 1 call
  expect(dispatchTrackEventAsync).toHaveBeenCalledTimes(1);
});
```

### Vitest-Specific Setup

For Vitest, the mock setup is similar but uses Vitest's mocking:

```typescript
// __mocks__/@mobile-de/trackking.ts
import { vi } from 'vitest';

export const dispatchTrackEventAsync = vi.fn().mockResolvedValue(undefined);
export const dispatchTrackEvent = vi.fn();
export const initialize = vi.fn();
export const registerEvents = vi.fn();
export const unregisterEvents = vi.fn();
```

Test syntax is nearly identical:

```typescript
import { describe, it, expect, beforeEach, vi } from 'vitest';
import { dispatchTrackEventAsync } from '@mobile-de/trackking';

vi.mock('@mobile-de/trackking');

describe('MyComponent', () => {
  beforeEach(() => {
    vi.clearAllMocks();
  });

  it('should dispatch tracking event', async () => {
    // Same test as Jest
  });
});
```

## Common Patterns

### Pattern 1: Fire and Forget (Most Common)

For non-critical tracking, use `void` to explicitly signal fire-and-forget intent. Since `dispatchTrackEventAsync` is designed to never throw, `void` is the idiomatic pattern — it suppresses "floating promise" lint warnings without needing `async/await`:

```typescript
function handleClick() {
  void dispatchTrackEventAsync('CLICK'); // void = intentional fire-and-forget
  navigate('/next-page');
}
```

Note: the containing function does **not** need to be `async` when using `void`.

### Pattern 2: Sequential Tracking

When tracking must complete before next action:

```typescript
async function handleCheckout() {
  await dispatchTrackEventAsync('CHECKOUT_STARTED');
  await processPayment();
  await dispatchTrackEventAsync('CHECKOUT_COMPLETED');
}
```

### Pattern 3: Parallel Tracking

For multiple independent events:

```typescript
async function handleMultiAction() {
  await Promise.all([
    dispatchTrackEventAsync('ACTION_1'),
    dispatchTrackEventAsync('ACTION_2'),
    dispatchTrackEventAsync('ACTION_3')
  ]);
}
```

### Pattern 4: Error Handling

Handle tracking failures without breaking functionality:

```typescript
async function handleClick() {
  try {
    await dispatchTrackEventAsync('BUTTON_CLICKED');
  } catch (error) {
    console.error('Tracking failed:', error);
    // Don't block user action
  }

  doSomething(); // Always executes
}
```

## Best Practices

### ✅ DO

1. **Use dispatchTrackEventAsync** for all new implementations
2. **Don't await** for simple interactions (clicks, hovers)
3. **Do await** for critical flows (checkout, payments, conversions)
4. **Mock in tests** using Jest/Vitest mocks with `.mockResolvedValue(undefined)`
5. **Use waitFor** to test async tracking in Jest/Vitest
6. **Handle errors gracefully** - don't break UX if tracking fails
7. **Test tracking calls** - verify events are dispatched with correct params

### ❌ DON'T

1. **Don't use dispatchTrackEvent** - it's deprecated
2. **Don't block UI** by awaiting every tracking call
3. **Don't forget to await** in tests with waitFor
4. **Don't make tracking failure** break application flow
5. **Don't test implementation details** - test that events are dispatched, not how

## Migration Checklist

- [ ] Search for all `dispatchTrackEvent` usages
- [ ] Replace with `dispatchTrackEventAsync`
- [ ] Add `async` to containing functions
- [ ] Decide: await or fire-and-forget?
- [ ] **For Redux/Rematch effects:** Mark effect functions as `async` and `await` dispatchTrackEventAsync inside
- [ ] Update unit tests to handle async
- [ ] Use `waitFor` in tests
- [ ] Mock dispatchTrackEventAsync with `.mockResolvedValue(undefined)`
- [ ] Test error scenarios
- [ ] Verify INP improvement in production

## Real-World Migration Experience

Based on production migrations of medium to large applications:

### Migration Scope Estimation

For a typical medium-sized application:
- **Files affected:** 50-100 component files + tests
- **Function calls:** 100-200 replacements
- **Time estimate:**
  - Phase 1 - Shared utilities: 30-60 minutes
  - Phase 2 - Component files: 1-2 hours
  - Phase 3 - Test files: 1-2 hours
  - Phase 4 - Fixes & verification: 30-60 minutes
- **Total:** 3-5 hours for medium app

### Phased Migration Strategy

**Don't migrate everything at once.** Break it into phases:

#### Phase 1: Shared Utilities (30-60 min)
Highest leverage - these changes cascade to many files:
- Custom hooks (e.g., `useDispatchTrackEventOnce`)
- Utility functions (e.g., `bookFeatureAndTrack`)
- Tracking helpers
- Update their tests

#### Phase 2: Component Files (1-2 hours)
Use careful find-replace:
1. Import statements first
2. Function calls second
3. Review git diff for accuracy

#### Phase 3: Test Files (1-2 hours)
- Update all mock declarations
- Fix async assertions
- Remove any duplicate mocks (common issue)
- Verify all tests pass

#### Phase 4: Cleanup & Verification (30-60 min)
- Lint entire codebase
- Run full test suite
- Check production build
- Manual smoke testing

### Common Migration Issues

| Issue | Cause | Solution | Time |
|-------|-------|----------|------|
| Duplicate mocks | Multiple `jest.mock()` calls | Remove extras, keep one with implementation | 10-15 min |
| Undefined errors | Wrong import path | Check all import variations | 5-10 min |
| Test failures | Missing `waitFor` | Add async assertions | 15-20 min |
| Import variations | Monorepo aliases | Update all: `@app/tracking`, `@shared/tracking`, etc. | 10 min |

### Pattern Distribution (80/15/5 Rule)
- **80% Fire-and-forget**: Most tracking calls don't need await (clicks, hovers, filter changes)
- **15% Await before navigation**: MUST await before `window.location.href`, `router.push`, `window.open`
- **5% Tests**: Update all test mocks with `.mockResolvedValue(undefined)`

### Critical "Must Await" Scenarios
Only await tracking in these cases:
1. Before `window.location.href = url`
2. Before `router.push(url)`
3. Before `window.open(url)`
4. Inside critical flows (checkout, payments, conversions)

### Test Mock Requirement
All test mocks MUST include `.mockResolvedValue(undefined)`:
```typescript
jest.mock('@mobile-de/trackking', () => ({
  dispatchTrackEventAsync: jest.fn().mockResolvedValue(undefined),
}))
```

**Why?** Without `.mockResolvedValue(undefined)`, async tests may:
- Fail with "not a function" errors
- Pass incorrectly without actually testing
- Have flaky behavior

### Bulk Migration with sed

For similar patterns across multiple files, use careful sed commands:

```bash
# 1. Import statements - be specific
find src/ -name "*.ts" -o -name "*.tsx" | while read file; do
  sed -i.bak 's/import { dispatchTrackEvent,/import { dispatchTrackEventAsync,/g' "$file"
  sed -i.bak 's/import { dispatchTrackEvent }/import { dispatchTrackEventAsync }/g' "$file"
  rm -f "${file}.bak"
done

# 2. Function calls - careful regex
find src/ -name "*.ts" -o -name "*.tsx" | while read file; do
  # Only replace if not already "Async"
  sed -i.bak 's/\([^A-Za-z]\)dispatchTrackEvent(/\1dispatchTrackEventAsync(/g' "$file"
  rm -f "${file}.bak"
done
```

**⚠️ Important:** Always review changes manually after bulk replacements!

### Post-Migration Verification

Run these commands to verify complete migration:

```bash
# 1. Check for remaining old function calls
grep -r "dispatchTrackEvent[^A]" src/
# Should return 0 results

# 2. Run linter
yarn lint
# Look for: no-undef, no-unused-vars errors

# 3. Run tests
yarn test
# Verify no new failures

# 4. Check production build
yarn build
# Ensure build succeeds

# 5. Search for common issues
grep -r "jest.mock.*trackking" src/ | wc -l
# Count mock declarations - check for duplicates manually
```

## Troubleshooting

### Issue: Tests Fail with "Not Awaited"

**Solution:** Use `waitFor` to wait for async tracking:

```typescript
await waitFor(() => {
  expect(dispatchTrackEventAsync).toHaveBeenCalled();
});
```

### Issue: Tracking Not Called in Tests

**Solution:** Ensure mock is properly set up:

```typescript
jest.mock('@mobile-de/trackking', () => ({
  dispatchTrackEventAsync: jest.fn().mockResolvedValue(undefined), // ← Important!
}));
```

### Issue: "dispatchTrackEventAsync is not a function"

**Cause:** Mock missing `.mockResolvedValue(undefined)`

**Solution:**
```typescript
// ❌ Wrong
jest.mock('@mobile-de/trackking', () => ({
  dispatchTrackEventAsync: jest.fn(),
}))

// ✅ Correct
jest.mock('@mobile-de/trackking', () => ({
  dispatchTrackEventAsync: jest.fn().mockResolvedValue(undefined),
}))
```

### Issue: Events Sent Multiple Times

**Solution:** Check useEffect dependencies:

```typescript
// ✅ Correct - empty deps for mount only
useEffect(() => {
  dispatchTrackEventAsync('PAGE_VIEW');
}, []);

// ❌ Wrong - missing deps array
useEffect(() => {
  dispatchTrackEventAsync('PAGE_VIEW');
}); // Runs on every render!
```

### Issue: Duplicate Mock Declarations

**Cause:** Multiple `jest.mock()` calls in same file

**Solution:** Keep only ONE mock declaration with implementation:

```typescript
// ❌ Wrong - duplicate mocks
jest.mock('@mobile-de/trackking', () => ({
  dispatchTrackEventAsync: jest.fn().mockResolvedValue(undefined),
}))
// ... other code ...
jest.mock('@mobile-de/trackking') // ← This overrides above!

// ✅ Correct - single mock
jest.mock('@mobile-de/trackking', () => ({
  dispatchTrackEventAsync: jest.fn().mockResolvedValue(undefined),
}))
```

## Related Resources

- [SKILL.md](../SKILL.md) - Main tracking skill documentation
- Documentation: https://pages.github.mpi-internal.com/mobile-de/trackking
- Support: Slack channel **#mob-trackking**
