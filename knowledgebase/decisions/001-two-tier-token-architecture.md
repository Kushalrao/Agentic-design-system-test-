# ADR 001 — Multi-tier token architecture

**Status:** Accepted  
**Date:** 2026-05-24  
**Updated:** 2026-05-29 — extended to 3 tiers, updated to Seasonal DLS collections

---

## Context

Design tokens needed to work in two places simultaneously:
1. **Figma** — variables that designers edit and reference in component fills/strokes
2. **Flutter/Dart** — constants that widget code imports and uses at runtime

A naive approach generates a flat list of resolved hex values in Dart. That breaks
the semantic link between Figma and code, makes theme-switching impossible, and
means a single token rename propagates as a manual find-replace across every widget.

---

## Decision

Use a strict three-tier structure in both Figma and Dart, where each tier holds
**references** to the tier below, never resolved values.

**Tier 1 — Primitives** (`abstract final class`, static consts, raw values)

| Dart class | Figma collection | What it holds |
|---|---|---|
| `ColorPrimitives` | `Colors` | Raw `Color(0xAARRGGBB)` — 6 families × 10 shades |
| `Foundation` | `Typography` | Font families, sizes, weights, line heights |
| `SpacingPrimitives` | `Containers` › Spacing | Raw `double` spacing values (0–115 dp) |
| `RadiusTokens` | `Containers` › Radius | Raw `double` radius values (4–44 dp, full=999) |
| `OpacityTokens` | `Containers` › Opacity | Raw `double` opacity values (0.0–1.0) |

**Tier 2 — Semantic aliases** (Dart references to Tier 1; Figma aliases)

| Dart class | Figma collection | What it holds |
|---|---|---|
| `ColorScale` | `Color Semantics` | `ThemeExtension<ColorScale>` — e.g. `brandPrimary = ColorPrimitives.primaryScapia800` |
| `TypographyScale` | `Typography` (pairings) | `abstract final class` — e.g. `titleMdSize = Foundation.fontSize19` |
| `SpacingScale` | `Containers` (pairings) | `abstract final class` — e.g. `spaceMd = SpacingPrimitives.spacing9` |

**Tier 3 — Component tokens** (Dart methods wrapping Tier 2; Figma component collections)

| Dart class | Figma collection | What it holds |
|---|---|---|
| `ButtonTokens` | `Button` | Static getters that read `ColorScale` from context — e.g. `primaryOrangeBackground(context)` |

Widgets **only** consume Tier 2 or Tier 3. Tier 1 is for the token generator,
tests, and Tier 2/3 internal implementation.

---

## Rationale

**Alias chain preserved end-to-end.** When a designer changes a Tier 1 value in
Figma and the token pipeline runs, the change flows through automatically because
every tier holds a reference, not a copy.

**Theme-switching without widget changes.** `ColorScale` as `ThemeExtension<T>`
means swapping light → dark → seasonal override is a single `extensions` swap on
`ThemeData`. Every widget that calls `Theme.of(context).extension<ColorScale>()!`
picks up the new values automatically.

**Contract-testable.** `tokens_test.dart` asserts that every `ColorScale` field
equals a value from `ColorPrimitives`. This fails at CI if anyone accidentally
hardcodes a hex in the generated file — the alias chain is machine-verifiable.

**Clear Figma/code parity.** When a designer looks at
`Color Semantics / Brand/Primary → Colors / Primary/Scapia/800` in Figma, a developer
reads the exact same structure in Dart:
`brandPrimary: ColorPrimitives.primaryScapia800`. No cognitive translation.

---

## Rejected alternatives

**Flat resolved values** — All tokens as direct hex/dp constants. Rejected because
it destroys the alias chain, makes theme-switching impossible, and means every
palette update requires re-checking every widget.

**Single-class everything** — One `Tokens` class with all values. Rejected because
it offers no tier boundary to enforce, makes tree-shaking impossible, and has no
clear Figma counterpart.

**CSS custom properties style** — Runtime map of `String → dynamic`. Rejected
because Dart's static typing and tree-shaking are lost.

---

## Consequences

- Widget authors must never import `ColorPrimitives`, `Foundation`, or
  `SpacingPrimitives` directly. The `quality.md` checklist enforces this.
- `RadiusTokens` and `OpacityTokens` are Tier 1 only — no semantic Tier 2 layer
  exists yet. When semantic radius/opacity aliases land in Figma, introduce
  `RadiusScale` and `OpacityScale` following the same pattern.
- Tier 3 (`ButtonTokens`) uses `BuildContext` getters, not static consts, because
  component colors are theme-dependent at runtime.
