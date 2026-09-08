---
name: mob-trackking
description: >-
  Use when working with @mobile-de/trackking: implementing or migrating tracking events,
  calling dispatchTrackEventAsync, setting up event maps with
  trackAnalyticsEvent/trackPageView/trackPageMeta, adding page view tracking with han
  (Hashed Application Name), integrating GTM (Google Tag Manager), debugging analytics
  events, registering/unregistering events dynamically, or migrating from sync to async
  tracking for better INP performance. Trigger on imports from @mobile-de/trackking,
  mentions of "trackking", "tracking events", "analytics", "GTM", or "dispatchTrackEventAsync".
metadata:
  author: mobile.de
  version: "10.1.0"
  tags: tracking, trackking, analytics, gtm, google-tag-manager, events, redux, performance, inp, han, hashed-application-name
---

# @mobile-de/trackking

A browser tracking solution that decouples UI/data layer from tracking implementation, supporting multiple analytics providers with optional Redux integration.

## When to Use This Skill

Trigger when:

- User mentions "trackking", "tracking", "analytics", or "GTM" in mobile.de context
- Code imports from `@mobile-de/trackking`
- Working with event tracking, page views, or analytics implementation
- Questions about Google Tag Manager integration
- Debugging tracking events or analytics issues

## General Philosophy

- **Prefer explicit over implicit**: Pass data via event parameters rather than accessing global state (Redux)
- **Use official helpers**: Always use `trackAnalyticsEvent`, `trackPageView`, `trackPageMeta`
- **Performance first**: Use `dispatchTrackEventAsync` for better INP scores
- **Privacy by design**: Hash sensitive data on server side, never expose to client

## Core Concepts

### Architecture

The library uses a service-based architecture:

- **TrackingService**: Abstract base class for custom services
- **Event Maps**: Key-value objects mapping event names to tracking functions
- **Services**: Implementations like GoogleTagManager that handle actual tracking
- **Lifecycle**: Events flow through dispatch → event map → service → tracking provider

### Event Maps

Event maps are key-value objects where each key is a sync function:

```typescript
const eventsMap = {
  EVENT_NAME: (params, getState?) => {
    return {
      event: "analytics_event",
      attributes: {
        /* local attributes */
      },
      // global attributes at root level
    };
  },
};
```

**Important:**

- Each value MUST be a function that returns event details
- Functions can return single events or arrays of multiple events
- Events can access Redux state if provided during initialization
- Use callbacks, NOT plain objects

## Installation & Initialization

```bash
npm install @mobile-de/trackking
```

### Basic Initialization (Recommended)

```typescript
import { initialize } from "@mobile-de/trackking";
import GoogleTagManager from "@mobile-de/trackking/services/google-tag-manager";

// Without Redux (recommended for new applications)
initialize([new GoogleTagManager(eventsMap)]);
```

### With Redux (Not Recommended)

```typescript
// With Redux store (not recommended, use only for legacy applications)
initialize([new GoogleTagManager(eventsMap)], store);
```

**Note:** Redux integration is supported but not encouraged. Pass data explicitly through event parameters instead.

## Main APIs

### dispatchTrackEventAsync (RECOMMENDED)

**Use this for all new implementations:**

```typescript
import { dispatchTrackEventAsync } from "@mobile-de/trackking";

await dispatchTrackEventAsync("EVENT_NAME", { param1: "value" });
```

**Benefits:** Improves INP (Interaction to Next Paint), prevents blocking user interactions, ensures events are sent before page navigation.

**`void` vs `await`:** Since `dispatchTrackEventAsync` is designed to never throw, using `void` is idiomatic for fire-and-forget calls:

```typescript
// ✅ Preferred for fire-and-forget (suppresses unhandled promise lint warnings)
void dispatchTrackEventAsync('EVENT_NAME', { param1: 'value' });

// ✅ Use await only when you need to sequence actions after tracking
await dispatchTrackEventAsync('CHECKOUT_STARTED');
await processPayment();
```

**See also:** [references/migrate-to-async.md](references/migrate-to-async.md) for migration guide and testing patterns.

### dispatchTrackEvent (DEPRECATED)

```typescript
dispatchTrackEvent("EVENT_NAME", { param1: "value" });
```

**⚠️ Deprecated:** Use `dispatchTrackEventAsync` instead. See [migration guide](references/migrate-to-async.md).

### Dynamic Event Registration

Register and unregister events at runtime:

```typescript
import { registerEvents, unregisterEvents } from "@mobile-de/trackking";

// Register with scope
registerEvents(
  {
    FEATURE_VIEWED: () => ({ category: "feature", action: "view" }),
  },
  "my-feature",
  "GoogleTagManager",
); // serviceName is optional

// Unregister by scope
unregisterEvents("my-feature");
```

**Important:**

- Events with 'global' scope cannot be overridden or unregistered
- Non-global events can be overridden (with warning)
- Useful for component-specific tracking

## Google Tag Manager Service

### IMPORTANT: Use Provided Helper Functions

**ALWAYS use the provided helper functions** from `@mobile-de/trackking/services/google-tag-manager`:

- `trackAnalyticsEvent` - for event tracking
- `trackPageView` - for page view events
- `trackPageMeta` - for page metadata

**DO NOT create custom event structures** or build events manually. These helpers ensure:

- Correct event structure for GTM
- Proper attribute handling (local vs global)
- Consistent naming conventions
- Automatic hashing of sensitive data (in trackPageMeta)

### Basic Event Tracking

**✅ CORRECT:** Use `trackAnalyticsEvent` helper

```typescript

import { trackAnalyticsEvent } from "@mobile-de/trackking/services/google-tag-manager";

const eventsMap = {
  SEARCH_SUBMITTED: (placement) =>
    trackAnalyticsEvent({
      eventCategory: "Homepage",
      eventAction: "SubmitSearch",
      eventLabel: `placement=${placement};target=ResultsSearch`,
      nonInteraction: false, // default
      attributes: {
        // custom dimensions
      },
    }),
};
```

**❌ WRONG:** Custom event structure

```typescript
// Don't do this!
const eventsMap = {
  SEARCH_SUBMITTED: (placement) => ({
    event: "analytics_event",
    event_category: "Homepage", // Wrong naming
    event_action: "SubmitSearch",
  }),
};
```

**Required fields:**

- `eventCategory`: Meridian category
- `eventAction`: Meridian action

**Optional fields:**

- `eventLabel`: Meridian label (separate multiple with `;`)
- `nonInteraction`: Boolean (false = user interaction, true = programmatic)
- `attributes`: Custom dimensions as key-value pairs

### Page View Tracking

**ALWAYS use `trackPageMeta` and `trackPageView` helpers** - never create custom page view structures.

Page views require TWO events sent sequentially using the official helpers:

**✅ CORRECT:** Use the helpers

```typescript
import {
  trackPageView,
  trackPageMeta,
  hashValue,
} from "@mobile-de/trackking/services/google-tag-manager";

const eventsMap = {
  PAGE_VIEW: () => {
    const pageName = "homepage";
    const clientId = "..."; // from vi token (not hashed)
    const userId = "..."; // from vi token (not hashed)
    const han = hashValue(process.env.APP_NAME); // REQUIRED - Hashed Application Name for GTM

    return [
      trackPageMeta({
        clientId, // REQUIRED - Will be auto-hashed
        userId, // REQUIRED - Will be auto-hashed
        han, // REQUIRED - Hashed app name from process.env.APP_NAME
        gaProperty, // REQUIRED - "mweb" or "desktop"
        pageType: pageName, // REQUIRED
        environment, // REQUIRED - "production" or "staging"
        selectedLanguage, // REQUIRED - 'en' | 'de' | 'es' | etc.
        campaignOwner, // REQUIRED - "Dealer" or "Sales_Agent"
        selectedMode, // OPTIONAL - "SystemMode" or "LightMode"
      }),
      trackPageView({
        page_type: pageName,
        screen_name: pageName,
        attributes: {},
      }),
    ];
  },
};
```

**❌ WRONG:** Custom page view structure

```typescript
// Don't do this!
const eventsMap = {
  PAGE_VIEW: () => ({
    event: "page_view",
    page_name: "homepage", // Wrong structure
    user_id: userId,
  }),
};
```

**Required trackPageMeta fields (ALL applications - consumer and dealer):**

- `clientId` - from vi token (will be auto-hashed)
- `userId` - from vi token (will be auto-hashed)
- `han` - **REQUIRED**: **H**ashed **A**pplication **N**ame sent to GTM (see [references/han-implementation-guide.md](references/han-implementation-guide.md) for details)
- `gaProperty` - "mweb" or "desktop"
- `pageType` - Page name/type
- `environment` - "production" or "staging"
- `selectedLanguage` - Language code ('en', 'de', 'es', etc.)
- `campaignOwner` - "Dealer" or "Sales_Agent"

**Additional fields for DEALER applications only:**

- `hashedSellerAccountId` - Optional, only for dealer apps
- `hashedSellerSubAccountId` - Optional, only for dealer apps
- `sellerAccountType` - Optional, only for dealer apps

**Important:**

- `trackPageMeta` auto-hashes `clientId` and `userId` - don't use both hashed and non-hashed props
- **Always include `han`** - see [references/han-implementation-guide.md](references/han-implementation-guide.md) for implementation by app type

### Dealer Applications Only

**Note:** The following fields are **only for dealer applications**. Consumer applications do NOT need these fields.

For dealer area applications, include additional seller account information:

```typescript
trackPageMeta({
  // Required fields for ALL applications (consumer and dealer)
  clientId,
  userId,
  han: hashValue(process.env.APP_NAME), // REQUIRED - Hashed Application Name for GTM
  gaProperty,
  pageType,
  environment,
  selectedLanguage,
  campaignOwner,

  // Additional fields ONLY for dealer applications
  // Consumer applications: DO NOT include these
  hashedSellerAccountId: hashValue(sellerAccountId),
  hashedSellerSubAccountId: hashValue(sellerSubAccountId),
  sellerAccountType: seller_account_type,
});
```

**IMPORTANT:**

- These hashed seller fields are provided by [commercial-page-components-service](https://github.mpi-internal.com/mobile-de/commercial-page-components-service)
- Consumer applications should NOT include these fields

## Hashing Privacy-Sensitive Data

**Always hash privacy-sensitive IDs:**

```typescript
import { hashValue } from "@mobile-de/trackking/core/utils";

const hashedId = hashValue(sellerId);
```

**Auto-hashed by trackPageMeta:**

- `clientId` → `hashed_client_id`
- `userId` → `hashed_user_id`

**Must manually hash BEFORE passing to trackPageMeta:**

- `han` - **REQUIRED for ALL apps** (consumer and dealer) - see [references/han-implementation-guide.md](references/han-implementation-guide.md)
  - **H**ashed **A**pplication **N**ame sent to GTM for application identification
  - Implementation varies by app type (Next.js vs Express)

**Additional hashing for DEALER apps ONLY:**

- `hashedSellerAccountId` - Optional, only for dealer area applications
- `hashedSellerSubAccountId` - Optional, only for dealer area applications
- Not required for consumer applications

**Custom sensitive data:**

- Hash any custom sensitive data in event attributes using `hashValue`

## Redux Integration (Not Recommended)

**Note:** While Redux integration is supported, it is **not encouraged for new implementations**. Prefer passing data explicitly through event parameters instead of accessing global state.

**Why avoid Redux integration:**

- Creates tight coupling between tracking and application state
- Makes tracking logic harder to test in isolation
- Can lead to unnecessary re-renders and complexity
- Event parameters are more explicit and easier to trace

**If you must use Redux** (legacy codebases), the store can be provided during initialization:

```typescript
const eventsMap = {
  EVENT_NAME: (params, getState) => {
    const state = getState();
    const { foo, bar } = state;

    return trackAnalyticsEvent({
      eventCategory: "Category",
      eventAction: "Action",
      attributes: { foo },
    });
  },
};
```

**Better approach:** Pass data explicitly via event parameters:

```typescript
// ✅ Recommended: Explicit parameters
const eventsMap = {
  EVENT_NAME: ({ foo, bar }) =>
    trackAnalyticsEvent({
      eventCategory: "Category",
      eventAction: "Action",
      attributes: { foo },
    }),
};

// Dispatch with explicit data
await dispatchTrackEventAsync("EVENT_NAME", { foo: value, bar: value2 });
```

## React Component Integration

### Page View on Mount

```typescript
import { useEffect } from 'react';
import { dispatchTrackEventAsync } from '@mobile-de/trackking';

function Page() {
  useEffect(() => {
    void dispatchTrackEventAsync('PAGE_VIEW');
  }, []);

  return <div>Page content</div>;
}
```

### Click Event Tracking

```typescript
import { dispatchTrackEventAsync } from '@mobile-de/trackking';

function Button({ carId }) {
  return (
    <button onClick={() => {
      void dispatchTrackEventAsync('CAR_CLICKED', { carId });
    }}>
      View Car
    </button>
  );
}
```

### Dynamic Registration with Cleanup

```typescript
import { useEffect } from 'react';
import { registerEvents, unregisterEvents } from '@mobile-de/trackking';

function FeatureComponent() {
  useEffect(() => {
    registerEvents({
      FEATURE_OPEN: () => ({ category: 'feature', action: 'open' }),
      FEATURE_CLOSE: () => ({ category: 'feature', action: 'close' })
    }, 'feature-component');

    return () => {
      unregisterEvents('feature-component');
    };
  }, []);

  return <div>Feature content</div>;
}
```

## Event Structure

### Local vs Global Attributes

**Local attributes** (event-specific):

```typescript
{
  event: 'analytics_event',
  attributes: {
    localAttr: 'value'  // Only for this event
  }
}
```

**Global attributes** (like custom dimensions):

```typescript
{
  event: 'analytics_event',
  globalAttr: 'value',  // Available globally
  attributes: {}        // Always include, even if empty
}
```

**Warning:** Always pass empty `attributes: {}` if no local attributes, otherwise GTM reuses previous event's attributes.

## Consent Management

The library automatically handles user consent via `@mobile-de/consent-api-public`:

- Services with `isBehindConsent: true` wait for consent approval
- Events are queued until consent is granted
- Queue executes once `getAnalyticsPermissions()` resolves

**Note:** Frontend app must provide consent banner integration.

## Debugging

Enable logging and event storage in any environment. See docs at: https://pages.github.mpi-internal.com/mobile-de/trackking/docs/guides/debugging

## Common Patterns

### Multiple Events from One Dispatch

```typescript
const eventsMap = {
  COMPLEX_ACTION: () => [
    { event_label: "step1" },
    { event_label: "step2" },
    { event_label: "step3" },
  ],
};
```

### Passing External Params

```typescript
// Component
await dispatchTrackEventAsync("PHONE_CLICKED", {
  channel: "mobile",
  refererSource: "dc-df-flow",
});

// Event Map
const eventsMap = {
  PHONE_CLICKED: ({ channel, refererSource }) =>
    trackAnalyticsEvent({
      eventCategory: "Lead",
      eventAction: "PhoneClick",
      eventLabel: `channel=${channel}`,
      attributes: { refererSource },
    }),
};
```

## Best Practices

1. **Always use the official helper functions:** `trackAnalyticsEvent`, `trackPageView`, `trackPageMeta` - never create custom event structures
2. **Always use `dispatchTrackEventAsync`** instead of deprecated `dispatchTrackEvent` (see [migration guide](references/migrate-to-async.md))
3. **Pass data explicitly via event parameters** - avoid Redux integration for new implementations
4. **Hash privacy-sensitive data** before sending (use `hashValue`)
5. **Use empty attributes object** `{}` if no local attributes needed
6. **Separate event labels** with semicolons: `field=value;another=value`
7. **Register/unregister events** with scopes for component-specific tracking
8. **Don't override global scope** events
9. **Always dispatch two events** for page views: trackPageMeta then trackPageView (in that order)
10. **Always include `han` (Hashed Application Name)** in trackPageMeta - required for GTM application identification
11. **Never manually construct GTM event objects** - let the helpers handle the structure

## Common Mistakes

❌ **Wrong:** Plain object instead of function

```typescript
const eventsMap = {
  EVENT_NAME: { event: "analytics_event" },
};
```

✅ **Correct:** Function that returns object

```typescript
const eventsMap = {
  EVENT_NAME: () => ({ event: "analytics_event" }),
};
```

❌ **Wrong:** Custom event structure instead of helper

```typescript
const eventsMap = {
  CLICK_EVENT: () => ({
    event: "analytics_event",
    event_category: "Button",
    event_action: "Click",
  }),
};
```

✅ **Correct:** Use trackAnalyticsEvent helper

```typescript
import { trackAnalyticsEvent } from "@mobile-de/trackking/services/google-tag-manager";

const eventsMap = {
  CLICK_EVENT: () =>
    trackAnalyticsEvent({
      eventCategory: "Button",
      eventAction: "Click",
      attributes: {},
    }),
};
```

❌ **Wrong:** Custom page view structure

```typescript
const eventsMap = {
  PAGE_VIEW: () => ({
    event: "page_view",
    page_name: "homepage",
  }),
};
```

✅ **Correct:** Use trackPageMeta and trackPageView helpers

```typescript
import {
  trackPageView,
  trackPageMeta,
} from "@mobile-de/trackking/services/google-tag-manager";

const eventsMap = {
  PAGE_VIEW: () => [
    trackPageMeta({
      /* metadata */
    }),
    trackPageView({ page_type: "homepage", attributes: {} }),
  ],
};
```

❌ **Wrong:** Using deprecated function

```typescript
dispatchTrackEvent("EVENT_NAME");
```

✅ **Correct:** Use async version

```typescript
await dispatchTrackEventAsync("EVENT_NAME");
```

## Additional Documentation

**Related Guides:**
- [references/han-implementation-guide.md](references/han-implementation-guide.md) - Detailed implementation guide for `han` (Hashed Application Name) by application type
  - Next.js (mobile-nextjs-starter) standardized patterns
  - Express.js custom architecture investigation and implementation
  - Use when specifically implementing `han` in `trackPageMeta`

- [references/migrate-to-async.md](references/migrate-to-async.md) - Migration guide from deprecated `dispatchTrackEvent` to `dispatchTrackEventAsync`
  - Step-by-step migration instructions
  - Unit testing with Jest/Vitest (mocking, async testing, waitFor)
  - Common patterns (fire-and-forget, sequential, error handling)
  - Use when migrating legacy tracking code

## Additional Resources

- Documentation: https://pages.github.mpi-internal.com/mobile-de/trackking
- Support: Slack channel **#mob-trackking**
- Repository: https://github.mpi-internal.com/mobile-de/trackking

## Package Info

- Package: `@mobile-de/trackking`
- Current Version: 10.1.0
- Requires: `react >= 16.14`
- Dependencies: `@mobile-de/consent-api-public`, `tiny-hashes`
