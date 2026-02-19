# Claude Design Guide

## Warm Neutral Professional – Bid Tracking Application

**Primary Accent: Dusty Indigo**
**Theme Support: Light + Dark Mode**

---

# 1. Design Philosophy

The bid tracking application should feel:

* Calm
* Mature
* Professional
* Structured
* Easy to scan
* Data-first

It should NOT feel:

* Startup flashy
* Corporate blue-heavy
* Cold or sterile
* Visually loud
* Overly decorative

Color is used intentionally and sparingly.
Status indicators must visually outrank the brand accent.
Spacing must feel comfortable but efficient.

---

# 2. Core Design Principles

1. Use warm neutrals as the foundation.
2. Use Dusty Indigo only for primary actions and focus.
3. Use status colors only for badges and small indicators.
4. Avoid gradients.
5. Avoid heavy shadows.
6. Avoid decorative elements.
7. All styling must reference design tokens (CSS variables).
8. Support light and dark mode using CSS variables.

---

# 3. Color System

## 3.1 Light Mode Tokens

```css
:root {
  --color-bg: #F4F1ED;
  --color-surface: #FFFFFF;
  --color-surface-alt: #FAF7F2;
  --color-border: #E7E1DA;

  --color-text-primary: #2A2623;
  --color-text-secondary: #6B625C;
  --color-text-muted: #9C928A;

  --color-accent: #5C5AAE;
  --color-accent-subtle: #E6E5F9;

  --status-open: #3B82F6;
  --status-in-progress: #D4A017;
  --status-submitted: #4C6EF5;
  --status-awarded: #2F855A;
  --status-lost: #B4533A;
  --status-archived: #857A72;
}
```

---

## 3.2 Dark Mode Tokens

Dark mode is activated via:

```html
<html data-theme="dark">
```

```css
[data-theme="dark"] {
  --color-bg: #1C1917;
  --color-surface: #26221F;
  --color-surface-alt: #2E2925;
  --color-border: #3A342F;

  --color-text-primary: #EDE6E1;
  --color-text-secondary: #C8BEB7;
  --color-text-muted: #A89E94;

  --color-accent: #8A89E6;
  --color-accent-subtle: #3F3D6C;
}
```

Status colors remain consistent across modes.

---

# 4. Color Usage Rules

## Accent Color (Dusty Indigo)

Use ONLY for:

* Primary buttons
* Active sidebar item
* Links
* Focus outlines
* Selected states

Never use accent for:

* Large backgrounds
* Entire table rows
* Cards
* Large UI sections

---

## Status Colors

Status colors are used ONLY for:

* Pill badges
* Small indicators
* Optional thin left borders

Never use status colors for:

* Full row backgrounds
* Major layout sections
* Navigation

Status must always include text label (do not rely on color alone).

---

# 5. Typography

Font Family:

```css
"Inter", system-ui, -apple-system, BlinkMacSystemFont, "Segoe UI", sans-serif;
```

## Typography Scale

| Element       | Size | Weight |
| ------------- | ---- | ------ |
| Page Title    | 28px | 600    |
| Section Title | 20px | 500    |
| Body          | 15px | 400    |
| Table Text    | 14px | 400    |
| Labels        | 12px | 500    |
| Buttons       | 14px | 500    |

Do not use:

* Serif fonts
* Condensed fonts
* Decorative fonts

---

# 6. Spacing System

Base grid: 4px

```css
--space-1: 4px;
--space-2: 8px;
--space-3: 12px;
--space-4: 16px;
--space-5: 24px;
--space-6: 32px;
--space-7: 48px;
```

Layout constants:

* Page padding: 24px
* Card padding: 18–20px
* Section spacing: 24–32px
* Table row height: 44–48px
* Sidebar width: 240px
* Header height: 56px

Spacing should feel balanced and structured.

Not cramped.
Not airy marketing style.

---

# 7. Layout Structure

## Sidebar

* Width: 240px
* Background: `var(--color-surface-alt)`
* Navigation items: icon + label
* Active item:

  * Background: `var(--color-accent-subtle)`
  * Text: `var(--color-accent)`
* Hover: subtle surface variation

---

## Top Header

* Height: 56px
* Background: `var(--color-surface)`
* Border-bottom: `1px solid var(--color-border)`
* Contains:

  * Page title or breadcrumbs
  * Search input
  * Primary action button
  * User menu

---

## Main Content

* Uses cards or table-based layout
* Section gap: 24–32px
* Avoid clutter
* Avoid stacked heavy borders

---

# 8. Component Specifications

## Buttons

### Primary

* Background: `var(--color-accent)`
* Text: White
* Hover: slightly darker accent
* Border-radius: 6px
* Padding: 8px 16px

### Secondary

* Transparent background
* Text: `var(--color-accent)`
* Border: 1px solid `var(--color-border)`
* Hover: subtle accent-subtle background

### Danger

* Background: `var(--status-lost)`
* Text: White

---

## Status Badges

* Shape: pill (border-radius: 9999px)
* Padding: 4px 12px
* Font size: 12px
* Font weight: 500
* Text: White

Classes:

* `.status-open`
* `.status-in-progress`
* `.status-submitted`
* `.status-awarded`
* `.status-lost`
* `.status-archived`

---

## Cards

* Background: `var(--color-surface)`
* Padding: 18–20px
* Border-radius: 8px
* Subtle shadow only in light mode
* Title: 20px, weight 500

---

## Tables

* Header:

  * Background: `var(--color-surface-alt)`
  * Text: bold
* Row height: 44–48px
* Hover row: `var(--color-accent-subtle)`
* Border: `1px solid var(--color-border)`
* Status column uses badges only

---

## Inputs

* Background: `var(--color-surface-alt)`
* Border: `1px solid var(--color-border)`
* Border-radius: 6px
* Focus:

  * Border: `var(--color-accent)`
  * Subtle glow

Labels:

* 12px
* Weight 500
* Color: `var(--color-text-secondary)`

---

# 9. Dark Mode Rules

1. Use warm dark charcoal, not blue-black.
2. Surfaces must remain distinguishable.
3. Accent becomes slightly lighter.
4. Status colors remain recognizable.
5. Ensure 4.5:1 minimum contrast ratio.

---

# 10. Accessibility

* All interactive elements must show visible focus state.
* Do not rely on color alone for meaning.
* Maintain sufficient text contrast.
* Ensure keyboard navigability.
* Use consistent hover feedback.

---

# 11. Prohibited Design Patterns

Do not:

* Use gradients
* Use heavy drop shadows
* Use bright neon colors
* Mix multiple strong colors in one section
* Hardcode colors instead of tokens
* Use accent color as decorative filler

---

# 12. Implementation Requirements for Claude

When generating UI:

* Always reference CSS variables.
* Do not hardcode colors.
* Do not invent new colors.
* Use spacing tokens.
* Use typography scale exactly as defined.
* Maintain structural consistency.
* Keep visual hierarchy clean and restrained.

---

# Final Visual Identity Summary

This product should feel like:

> A calm, structured, professional internal system designed for serious work.

It should communicate:

* Stability
* Clarity
* Maturity
* Efficiency

Not hype.
Not marketing.
Not trend-chasing.
