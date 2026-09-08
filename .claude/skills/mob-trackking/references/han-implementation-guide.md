# han (Hashed Application Name) Implementation Guide

Implementation guide for the **han** (**H**ashed **A**pplication **N**ame) property required in `trackPageMeta` for all mobile.de applications.

> **Note:** This is a companion guide to the main [SKILL.md](SKILL.md). For general tracking concepts, event maps, and helper functions, see the main skill documentation.

## When to Use This Guide

Refer to this guide when:
- Implementing `trackPageMeta` and need to add `han` (Hashed Application Name)
- Working with page view tracking in mobile.de applications
- Questions about the `han` property or application name hashing
- Setting up tracking in Next.js or Express.js applications
- Missing or incorrect `han` implementation
- Errors related to missing `han` field in trackPageMeta

## What is han?

**han** stands for **H**ashed **A**pplication **N**ame:
- **Required for ALL applications** (consumer and dealer)
- Sent to GTM for application identification and analytics
- Must be hashed on the server side for security
- Derived from `process.env.APP_NAME` environment variable

## Why han is Required

- **Application identification**: GTM uses it to identify which application sent the event
- **Analytics segmentation**: Allows filtering and grouping data by application
- **Security**: Hashing prevents exposing internal application names to clients
- **Consistency**: Standardized approach across all mobile.de applications

## Implementation by Application Type

⚠️ **IMPORTANT: Architecture Differences**

- **Next.js applications** using `mobile-nextjs-starter` follow a **standardized pattern** - the implementation is consistent across all Next.js apps
- **Express.js applications** are **highly customized** - each app has its own unique architecture, state management, and data flow patterns

**For Express.js apps:** You MUST investigate the specific app's architecture to understand how data flows from server to client before implementing `han`. Do not assume patterns from other Express apps will apply.

### Next.js Applications (mobile-nextjs-starter)

✅ **Standardized Pattern** - Follow these steps for all Next.js apps using mobile-nextjs-starter.

In Next.js applications using `mobile-nextjs-starter`, the `han` value is **already hashed** by the starter template. You just need to retrieve and pass it through.

#### Step 1: Add han to AppContextProvider

Extract `han` from `getAppContext` in `src/app/layout.tsx`:

```typescript
// src/app/layout.tsx
import { getAppContext } from './getAppContext';

export default function RootLayout({ children }) {
  const appContext = getAppContext();
  const han = appContext.han; // Hashed Application Name - already hashed in mobile-nextjs-starter

  return (
    <AppContextProvider han={han} {...otherProps}>
      {children}
    </AppContextProvider>
  );
}
```

**Note:** Do NOT hash it again - it's already hashed by the starter template.

#### Step 2: Add han to types.ts

Update tracking types in `src/shared/tracking/src/types.ts`:

```typescript
// Before
export type InitTrackingComponentProps = Pick<
  PageMetaOptions,
  'userId' | 'clientId' | 'gaProperty' | 'environment' | 'selectedLanguage'
>;

// After
export type InitTrackingComponentProps = Pick<
  PageMetaOptions,
  | 'userId'
  | 'clientId'
  | 'gaProperty'
  | 'environment'
  | 'selectedLanguage'
  | 'han'  // ← Add this
>;
```

#### Step 3: Update initTrackingComponent.tsx

Pass `han` through to tracking initialization in `src/shared/tracking/src/initTrackingComponent.tsx`:

```typescript
// src/shared/tracking/src/initTrackingComponent.tsx
export function InitTrackingComponent({
  userId,
  clientId,
  gaProperty,
  environment,
  selectedLanguage,
  han  // ← Add this
}: InitTrackingComponentProps) {
  useEffect(() => {
    dispatchTrackEventAsync('PAGE_VIEW');
  }, []);

  // Pass han to event maps via context or props
  return null;
}
```

#### Step 4: Use in trackPageMeta

Include `han` in your page view event map:

```typescript
import {
  trackPageView,
  trackPageMeta,
} from '@mobile-de/trackking/services/google-tag-manager';

const eventsMap = {
  PAGE_VIEW: () => [
    trackPageMeta({
      clientId,
      userId,
      han, // ← From app context (already hashed)
      gaProperty,
      pageType: pageName,
      environment,
      selectedLanguage,
      campaignOwner
    }),
    trackPageView({
      page_type: pageName,
      attributes: {}
    })
  ]
};
```

### Express.js Applications

⚠️ **Highly Customized Architecture** - Express.js apps at mobile.de are NOT standardized. Each app has unique:
- State management patterns (Redux, Rematch, MobX, etc.)
- SSR implementation (custom rendering, templates, etc.)
- Data flow from server to client (preloaded state, window objects, props, etc.)

**Before implementing:** You MUST investigate how the specific app passes data from server to client.

#### Investigation Steps

1. **Identify the SSR pattern:**
   - Look for server-side rendering files (e.g., `src/server/rendering/`, `src/server/routes/`)
   - Find where initial data is passed to the client
   - Check for patterns like `__PRELOADED_STATE__`, `window.__INITIAL_DATA__`, or props injection

2. **Identify state management:**
   - Check for Redux, Rematch, MobX, Context API, or custom state
   - Find where environment/config data is stored
   - Locate where tracking data accesses this state

3. **Find the data flow:**
   - Server → Client: How does server data reach the client?
   - Client → Tracking: How does tracking code access this data?

#### General Implementation Pattern

Once you understand the app's architecture:

**Step 1: Hash on Server Side**

Hash the application name where initial data is prepared for the client:

```typescript
// Example: In SSR rendering (specific location varies by app)
import { hashValue } from '@mobile-de/trackking/core/utils';

// Hash han on server
const han = hashValue(process.env.APP_NAME || 'app-name');

// Pass to client via app-specific pattern:
// - Redux/Rematch: store.dispatch.env.setEnv({ han, ... })
// - Window object: window.__INITIAL_DATA__ = { han, ... }
// - Template: res.render('template', { han, ... })
```

**Important:**
- Always hash on the server side
- Never expose plain `process.env.APP_NAME` to the client
- Use `hashValue` from `@mobile-de/trackking/core/utils`

**Step 2: Update State/Type Definitions**

Add `han` to wherever environment/config types are defined:

```typescript
// Example: Redux/Rematch state type
type EnvState = {
  userId: string;
  clientId: string;
  han: string;  // ← Add this
  // ... other fields
};
```

**Step 3: Use in Client-Side Tracking**

Access `han` from wherever your app stores it and pass to `trackPageMeta`:

```typescript
// Example: Accessing from Redux state
import {
  trackPageMeta,
  trackPageView,
} from '@mobile-de/trackking/services/google-tag-manager';

const eventsMap = {
  PAGE_VIEW: () => {
    const { env, userId, clientId, han } = state.env; // App-specific access pattern

    return [
      trackPageMeta({
        clientId,
        userId,
        han, // ← From app's state (already hashed)
        gaProperty,
        pageType,
        environment: env,
        selectedLanguage,
        campaignOwner
      }),
      trackPageView({
        page_type: pageName,
        attributes: {}
      })
    ];
  }
};
```

#### Example: Rematch/Redux App

Real example from a financing app using Rematch:

```typescript
// src/server/rendering/ssr.tsx
import { hashValue } from '@mobile-de/trackking/core/utils';

const serverSideRendering = async (...) => {
  const store = createStore();

  store.dispatch.env.setEnv({
    userId: visitorInfo.userId,
    clientId: visitorInfo.clientId,
    han: hashValue(process.env.APPLICATION_NAME || 'app-name'), // ← Add this
    // ... other fields
  });

  // ... rest of SSR
};
```

```typescript
// src/client/common/analytics/events/googleTagManager.ts
const addPageViewTracking = (...pages) =>
  pages.reduce((pageViewEventMap, pageView) => ({
    ...pageViewEventMap,
    [pageView]: (params, getState) => {
      const state = getState();
      const { env, userId, clientId, han } = state.env; // ← Access han from state

      return [
        trackPageMeta({
          userId: hashValue(userId),
          clientId: hashValue(clientId),
          han, // ← Already hashed from server
          gaProperty: 'Desktop',
          pageType: 'FinancingFlow',
          environment: env,
          selectedLanguage: 'de',
        }),
        trackPageView({ /* ... */ })
      ];
    },
  }), {});
```

## Best Practices

### ✅ DO

1. **Always include `han` in trackPageMeta** - it's required for all applications
2. **Hash on server side** (Express apps) using `hashValue(process.env.APP_NAME)`
3. **Retrieve from app context** (Next.js apps) - already hashed by starter
4. **Pass through consistently** - ensure han flows from server to trackPageMeta
5. **Verify availability** - check that `process.env.APP_NAME` is set in your environment

### ❌ DON'T

1. **Never hash on client side** (Express apps) - always hash on server
2. **Never expose plain APP_NAME** to the client - only send hashed value
3. **Don't hash twice** (Next.js apps) - it's already hashed in the starter
4. **Don't access process.env.APP_NAME directly** in client code
5. **Don't omit han** - it's mandatory for all trackPageMeta calls

## Common Mistakes

### ❌ Wrong: Hashing on client side (Express apps)

```typescript
// Client-side - DON'T DO THIS
import { hashValue } from '@mobile-de/trackking/core/utils';

const han = hashValue(process.env.APP_NAME); // ❌ process.env not available on client
```

### ✅ Correct: Hash on server, pass to client

```typescript
// Server-side
res.locals.han = hashValue(process.env.APP_NAME);

// Client-side
const { han } = window.__INITIAL_DATA__; // ✅ Use hashed value from server
```

### ❌ Wrong: Double hashing (Next.js apps)

```typescript
// Next.js - DON'T DO THIS
import { hashValue } from '@mobile-de/trackking/core/utils';

const han = hashValue(appContext.han); // ❌ Already hashed!
```

### ✅ Correct: Use already hashed value

```typescript
// Next.js - DO THIS
const han = appContext.han; // ✅ Already hashed by starter
```

### ❌ Wrong: Missing han in trackPageMeta

```typescript
trackPageMeta({
  clientId,
  userId,
  // ❌ han is missing!
  gaProperty,
  pageType,
  environment,
  selectedLanguage,
  campaignOwner
})
```

### ✅ Correct: Always include han

```typescript
trackPageMeta({
  clientId,
  userId,
  han, // ✅ Required
  gaProperty,
  pageType,
  environment,
  selectedLanguage,
  campaignOwner
})
```

## Troubleshooting

### Issue: "process.env.APP_NAME is undefined"

**Solution:** Ensure the `APP_NAME` environment variable is set in your deployment configuration:

```bash
# .env or deployment config
APP_NAME=my-application-name
```

### Issue: "han is undefined in trackPageMeta"

**Checklist:**
1. ✅ Is `APP_NAME` set in your environment?
2. ✅ Are you hashing it on the server side (Express)?
3. ✅ Are you retrieving it from app context (Next.js)?
4. ✅ Are you passing it through your component chain?
5. ✅ Are you including it in the event map?

### Issue: "Different han values across pages"

**Cause:** Likely hashing different values or not using consistent source.

**Solution:** Always use the same source (`process.env.APP_NAME`) and hash once on initialization.

## Key Differences: Next.js vs Express

| Aspect | Next.js (mobile-nextjs-starter) | Express.js |
|--------|--------------------------------|------------|
| **Architecture** | ✅ Standardized across all apps | ⚠️ Highly customized per app |
| **Investigation** | No investigation needed | **MUST investigate** app-specific patterns |
| **Hashing** | Already hashed in starter | Must hash manually on server |
| **Location** | Retrieve from `appContext.han` | App-specific (SSR, middleware, etc.) |
| **Client Access** | Via React context | App-specific (Redux, window, props, etc.) |
| **Double Hashing** | ❌ No - already hashed | ✅ Only once on server |
| **Implementation Time** | ~15 minutes (predictable) | Varies - depends on app complexity |

## Summary

- **han** = **H**ashed **A**pplication **N**ame
- **Required** for all mobile.de applications in `trackPageMeta`
- **Next.js**: Retrieve from app context (already hashed)
- **Express**: Hash on server with `hashValue(process.env.APP_NAME)`
- **Never** expose plain application name to client
- **Always** include in `trackPageMeta` calls

## Related Resources

- [SKILL.md](SKILL.md) - Main tracking skill covering `trackPageMeta`, `trackPageView`, `trackAnalyticsEvent`, and general tracking setup
- Documentation: https://pages.github.mpi-internal.com/mobile-de/trackking
- Support: Slack channel **#mob-trackking**
