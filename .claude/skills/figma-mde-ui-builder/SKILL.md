---
name: figma-mde-ui-builder
description: Build React pages by translating Figma designs into code using mde-ui components. Triggers on Figma URLs or requests to build UI from designs.
disable-model-invocation: true
user-invocable: true
metadata:
  author: mobile.de
  tags:
    - figma
    - react
    - mde-ui
    - design-to-code
    - frontend
---

# Figma to mde-ui React Page Builder

Build React pages by translating Figma designs into code using the mde-ui component library.

## When to Use

- User provides a Figma URL
- Building UI from a design mockup
- Adding features to existing pages based on Figma designs

## Prerequisites

MCP servers required: `figma`, `mde-ui`

---

## Workflow

### Step 0 — Determine Mode

**Build mode** — user provides a Figma URL to implement from scratch. If the user has not specified a target path, ask:
> "Where should I create this component? Please provide the target directory or file path."

**Update mode** — user wants to update an existing component based on a Figma design. Ask:
> "Which file should I update? Please provide the file path."

Once you have the file path:
1. Read the existing component file(s)
2. Fetch the Figma design (Step 1)
3. Compare: identify what needs to change vs what should stay the same
4. Only add/change what the design requires — do not rewrite working code
5. Preserve existing class names, state variables, and component splits unless the design explicitly changes them

---

### Step 1 — Fetch Design Data

Call `mcp__figma__get_figma_design` with the full Figma URL. This is the **only** tool call needed to get design data — it returns everything in one response.

**Response structure:**

```
{
  screenshotAvailable: boolean
  screenshotPath: string          // path to cached PNG — read this to see what you're building
  data: {
    _meta                         // fileKey, nodeId, cachedAt
    metadata.componentMatches     // Figma component name → mde-ui package mapping (PRIMARY SOURCE)
    nodes                         // full node tree with layout, text, fills, _variant
    globalVars.styles             // deduplicated style definitions with _tokens CSS variable mappings
  }
}
```

**Always read the screenshot first** (`screenshotPath`) — it gives you the full visual context before parsing the JSON. It reveals icons, decorative elements, and visual states that the JSON does not capture.

---

### Step 2 — Read componentMatches (PRIMARY SOURCE for imports)

`data.metadata.componentMatches` maps every Figma component instance to its mde-ui equivalent. **Use this before reaching for any other tool.**

Each entry contains:
- `importStatement` — exact import to use in code
- `packageName` — the `@mde-ui/` package
- `confidence` — `key-exact` | `description-parse` | `name-exact` | `name-fuzzy`
- `props` — available props list
- `propMappings` — **maps Figma variant values directly to React props**

**`propMappings` is the most important field.** Each INSTANCE node in the tree has a `_variant` object — cross-reference it with `propMappings` to get the exact React props:

```
// Node in tree:
{ "name": "Button", "_variant": { "Type": "Disabled", "Icon": "Icon Left", "Size": "M" } }

// propMappings for Button:
{ "Type": { "Disabled": { "disabled": true } } }
{ "Icon": { "Icon Left": { "iconPosition": "left" } } }
{ "Size": { "M": "medium" } }

// Result → <Button disabled iconPosition="left" size="medium" />
```

**When to skip `componentMatches` and fall back to `mcp__mde-ui__list_components` / `mcp__mde-ui__get_component_details`:**
- Component is not in `componentMatches`
- `confidence` is `name-fuzzy` and you're uncertain about the match

**Icons — always search explicitly:**

Icon INSTANCE nodes in the tree often do not appear in `componentMatches` (their Figma names like `"Icon"`, `"close"`, `"arrow-next"` are too generic to match). For every icon you need:

1. Look at the node name and any nearby context (parent name, screenshot) to understand what the icon represents semantically (e.g. `"arrow-next"` → next/chevron, `"close"` → close/dismiss)
2. Call `mcp__mde-ui__list_icons` with a keyword to search: `mcp__mde-ui__list_icons({ search: "chevron" })`
3. Pick the closest match by name — use `mcp__mde-ui__get_icon_details` if you need the exact import
4. Import from `@mde-ui/icons`: `import { ChevronRight } from '@mde-ui/icons'`

If no reasonable match is found after searching, use a placeholder comment: `{/* TODO: icon — replace with correct @mde-ui/icons import */}`

---

### Step 3 — Read the Node Tree

`data.nodes` is an array containing the root node. Traverse `children` recursively to extract:

- `type: "TEXT"` nodes → use `.text` for content, `.textStyle` to look up typography in `globalVars.styles`
- `type: "INSTANCE"` nodes → use `.name` to match against `componentMatches`, `._variant` for prop mapping
- `layout` refs → look up in `globalVars.styles` to get `mode`, `gap`, `padding`, `sizing`
- `fills` refs → look up in `globalVars.styles` to get `_tokens.cssVar`

---

### Step 4 — Read Design Tokens

Every style ref in `globalVars.styles` may have a `_tokens` object:

```json
"_tokens": {
  "fills[0]": { "cssVar": "--color-content-lead", "confidence": "hex-match" },
  "gap":       { "cssVar": "--space-M",            "confidence": "px-match"  }
}
```

**Use `cssVar` directly in generated code.** Do not hardcode hex values or pixel values.

**Confidence levels — when to use vs. verify:**

| Confidence | Action |
|---|---|
| `exact`, `hex-match`, `px-match`, `name-match` | Use `cssVar` directly |
| `closest-color`, `closest-spacing` | Use `cssVar` but add `/* TODO: verify token */` |
| `unmatched` | Use `originalValue` as fallback and add `/* TODO: verify token */` |

For `unmatched` tokens, check `bestCandidate` — if it fits semantically, use it. If not (e.g. `--color-background-*` for an icon fill), fall back to `originalValue`.

**AI gradient tokens** — mde-ui includes gradient tokens for AI-themed surfaces. These are gradients, not solid colors, so they cannot be used with `background-color` — use the `background` shorthand:

| Token | Use |
|---|---|
| `--color-ai-secondary` | Background fill for AI-branded surfaces (light gradient) |
| `--color-ai-primary` | Foreground/prominent AI gradient |
| `--color-ai-primary-border` | Gradient border for AI-branded elements |

For gradient borders, use the `padding-box` / `border-box` technique:
```css
border: 1.5px solid transparent;
background:
  var(--color-ai-secondary) padding-box,
  var(--color-ai-primary-border) border-box;
```

---

### Step 5 — Print Component Mapping Table (MANDATORY)

**Before writing any code**, print this table:

```
## Component Mapping Table

| # | Figma Component | mde-ui Match | Package | Source | Status |
|---|-----------------|--------------|---------|--------|--------|
| 1 | Button          | Button       | @mde-ui/button | componentMatches | ✅ Found |
| 2 | Checkbox        | Checkbox     | @mde-ui/checkbox | componentMatches | ✅ Found |
| 3 | CustomBadge     | —            | — | not in componentMatches | ❌ Custom |

### Summary
- Total: 3 | Matched: 2 | Custom: 1

### Custom implementations:
- CustomBadge: styled div with inline SVG
```

**Status legend:**
- ✅ Found — in `componentMatches` with `key-exact`, `description-parse`, or `name-exact` confidence
- ⚠️ Partial — `name-fuzzy` match, may need verification
- ❌ Custom — not in `componentMatches`, needs custom implementation

**For every ❌ Custom component**, before writing any code ask the user:
> "I couldn't find a match for **[Component Name]** in mde-ui. Should I implement it as a custom component, or is there a specific mde-ui component you'd like me to use?"

Wait for the user's answer before proceeding with that component. If the user confirms custom, implement it. If the user names a component, use it.

---

### Step 6 — Build the Component

**Imports** — use `importStatement` from `componentMatches` directly. Only call `mcp__mde-ui__get_component_details` if a component is not in `componentMatches`.

**Props** — derive from `_variant` + `propMappings`. For props not covered by `propMappings`, refer to `props` array in `componentMatches`.

**Layout** — translate `globalVars.styles` layout objects to CSS:
- `mode: "row"` → `display: flex; flex-direction: row`
- `mode: "column"` → `display: flex; flex-direction: column`
- `justifyContent`, `alignItems`, `gap`, `padding` → use directly with `_tokens.cssVar` values

**Container components** — prefer mde-ui layout components over plain `<div>` when the Figma node matches one of these patterns:

| Pattern | Use | Import |
|---|---|---|
| Card-like container that is a **self-contained content unit** (listing card, detail panel, result item) | `<ContentBox>` | `import { ContentBox } from '@mde-ui/content-box'` |
| Highlighted block **inside** a page (info callout, tip box, feature highlight) — not a full-page notification | `<ContentHighlight>` | `import { ContentHighlight } from '@mde-ui/content-highlight'` |
| Underlined text, or node has `_isLink: true` | `<Link>` | `import { Link } from '@mde-ui/link'` |

**`ContentBox` criteria** — use it when ALL of these are true:
- The FRAME is a standalone card (not a generic wrapper or layout row)
- It has a white/primary background (`--color-background-primary`)
- It has a `borderRadius`
- The Figma node name suggests content grouping (contains "card", "box", "panel", "item", or "component")

**`ContentHighlight` criteria** — use it when:
- The block has a non-white tinted background (e.g. grey, blue, green)
- It is nested inside a larger container, not the outermost card
- Choose `priority` based on background semantic: `high` (error/warning), `medium` (info/default), `low` (subtle), `success`

**`Link` criteria** — use it when:
- The node has `_isLink: true` (annotated by MCP — text with `textDecoration: UNDERLINE` or textStyle name contains "Link")
- Use `type="action"` (default) for standard links; `type="silent"` for subtle/muted links

**`Button` as anchor** — when a Figma node looks like a button but navigates to a URL (e.g. a CTA that opens an external page), use `<Button href="..." target="_blank" type="secondary">` rather than `<Link>`. `Button` renders as `<a>` when `href` is passed, giving full button styling (padding, border, font, color) without conflicts.

**Respecting component style ownership** — mde-ui components own their own visual properties (color, padding, border, font) through their `type`, `variant`, and `size` props. When a rendered style doesn't match the Figma design, the fix is almost always a prop change — not a CSS override. CSS overrides fight the component's internal stylesheet and often lose or break on hover/focus states. Map Figma tokens named `Component/[Name]/[Variant]/[Property]` to the component's variant prop first before reaching for CSS.

**When none of the above match** — use plain semantic HTML (`<section>`, `<div>`, `<article>`) and add `{/* TODO: consider ContentBox? */}` only if the container looks like a card but you're unsure.

**Typography** — look up `textStyle` ref in `globalVars.styles` to get font token mappings. Use the `Text` component from `@mde-ui/text` for standalone text nodes (headings, paragraphs, labels).

> **Exception:** Inside mde-ui component `label` props (e.g. `Checkbox`, `RadioButton`), use a plain string or `<span>` — not the `Text` component. `Text` applies block-level styles that break inline component layout.

**State** — add `'use client'` and `useState` when the design contains interactive elements (checkboxes, selects, inputs, buttons with handlers).

**Component splitting** — do not put everything in one file. Split into separate components when ANY of these are true:
- A Figma node has a meaningful name (e.g. `SelectionCard`, `VehicleOption`) and appears more than once, OR represents a self-contained unit
- A component will exceed ~50 lines
- A component has its own local state

Each sub-component gets its own file (e.g. `SelectionCard.tsx`, `BookingAssistant.tsx`). The parent file imports from them.

**Dependencies** — before writing any code, check which `@mde-ui/*` packages are used. Ask the user:
> "The following packages need to be added to `package.json` — shall I add them?
> `@mde-ui/notification`, `@mde-ui/button`, ...`"

List only packages not likely already installed. Wait for confirmation before suggesting the install command.

---

## MCP Tools Reference

| Tool | When to use |
|---|---|
| `mcp__figma__get_figma_design` | Always — single call to get everything |
| `mcp__mde-ui__list_components` | When a component is not in `componentMatches` |
| `mcp__mde-ui__get_component_details` | When a component is not in `componentMatches` |
| `mcp__mde-ui__list_icons` | When design uses icons not in `componentMatches` |
| `mcp__mde-ui__get_icon_details` | To get exact import for a specific icon |

---

## Example Workflow

```typescript
// 1. Fetch design — single call
mcp__figma__get_figma_design({ figma_url: "https://..." })

// 2. Read screenshot to understand the visual
// screenshotPath → read the PNG

// 3. componentMatches gives you imports directly:
// "Button" → import Button from '@mde-ui/button'
// "Checkbox" → import { Checkbox } from '@mde-ui/checkbox'

// 4. Node tree gives you text, layout, variants:
// TEXT node .text = "Start booking"
// INSTANCE node ._variant = { "Type": "Disabled", "Icon": "Icon Left" }
// propMappings → disabled=true, iconPosition="left"

// 5. globalVars.styles gives you tokens:
// layout gap 18px → _tokens.cssVar = "--space-M"
// fill #1B1B21 → _tokens.cssVar = "--color-content-lead"

// 6. Print Component Mapping Table, then write code:
'use client';

import { useState } from 'react';
import Button from '@mde-ui/button';
import { Checkbox } from '@mde-ui/checkbox';
import { Select } from '@mde-ui/select';
import { Text, TextVariant } from '@mde-ui/text';
import { PlayerPlay } from '@mde-ui/icons';
import styles from './MyComponent.module.css';

export function MyComponent() {
  const [checked, setChecked] = useState(false);

  return (
    <div className={styles.card}>
      <Text variant={TextVariant.HeadlineLarge} as="h2">Top Ad</Text>
      <Checkbox
        checked={checked}
        onChange={(e) => setChecked(e.target.checked)}
        label="Use only paid quotas"  // plain string, not <Text>
      />
      <Button
        disabled
        iconPosition="left"
        icon={<PlayerPlay />}
        label="Start booking"
      />
    </div>
  );
}
```

---

## Best Practices

### DO ✓
- Read the screenshot before parsing the JSON
- Use `componentMatches` as the primary source for imports — avoid unnecessary `list_components` / `get_component_details` calls
- Read `propMappings` + `_variant` together to derive React props
- Use `_tokens.cssVar` for all colors, spacing, and typography
- Use `Text` component for standalone text nodes
- Use plain strings or `<span>` inside mde-ui component `label` props
- Add `'use client'` when the component has interactive state
- Print the Component Mapping Table before writing any code
- Use `<Link>` from `@mde-ui/link` for text links, or `<Button href="...">` for button-styled anchors (not `<a>` tags directly, and not the deprecated `LinkButton`)
- Fix a component's appearance by adjusting its `type`/`variant`/`size` props, not by overriding its CSS

### DON'T ✗
- Don't call `list_components` or `get_component_details` for components already in `componentMatches`
- Don't hardcode hex colors or pixel values — always use `cssVar`
- Don't use `Text` component inside mde-ui `label` props
- Don't write code before printing the Component Mapping Table
- Don't guess icon names — search with `mcp__mde-ui__list_icons`
- Don't wrap every FRAME in `<ContentBox>` — only use it for self-contained content cards

---

## Troubleshooting

**Component not in `componentMatches`**
→ Use `mcp__mde-ui__list_components` to search, then `mcp__mde-ui__get_component_details` for the import

**Token confidence is `unmatched`**
→ Check `bestCandidate` — if semantically appropriate use it; otherwise use `originalValue` and add `/* TODO: verify token */`

**Icon not rendering**
→ Search with `mcp__mde-ui__list_icons`, verify exact name and named import from `@mde-ui/icons`

**Checkbox / RadioButton label layout broken**
→ Use plain string or `<span>` for the `label` prop, not the `Text` component. The `label` prop renders inline next to the input — it is not a heading above it.
