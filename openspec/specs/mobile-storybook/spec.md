# mobile-storybook — UI Component Library Standards

status: stub — fill with actual Storybook setup and component standards

## What this spec covers

How shared UI components are developed, documented, reviewed, and published at
mobile.de using Storybook.

## Required information (to be filled)

- Storybook repository / package location
- Published Storybook URL (internal)
- Component contribution workflow (who reviews, how components are published)
- Required story types per component: Default, Interactive, Responsive, A11y
- Design token source: which package provides the CSS custom properties / tokens
- Relationship between Figma component library and Storybook (Figma Connect?)
- Visual regression testing tool (Chromatic, Percy, or other)
- Interaction testing setup (`@storybook/test`, `@storybook/addon-interactions`)
- Accessibility testing setup (`@storybook/addon-a11y`)
- How components from the shared library are consumed in Next.js applications

## Standards gates (enforced by mobile-storybook capability)

Before any Storybook component story is committed:

1. `mde-figma-intake` must have run — component design matches Figma
2. All required story variants exist (Default, states, responsive breakpoints)
3. `@storybook/addon-a11y` passes — no WCAG 2.1 AA violations
4. Interaction tests cover primary user actions
5. Design tokens used for all spacing, color, and typography — no hardcoded values
6. Component prop types documented with JSDoc or autodoc

## Links

- [ ] Add Storybook URL
- [ ] Add Figma component library link
- [ ] Add visual regression CI link
