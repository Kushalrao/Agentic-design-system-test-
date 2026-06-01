# Design System — Claude Code context

## Repo layout

```
packages/tokens/        design tokens — color, spacing, radius, typography (source of truth: Figma)
packages/ds/            themed Flutter widgets; depends on packages/tokens
packages/ds/widgetbook/ component catalog (Widgetbook 3.x)
apps/app/               product app — depends on packages/ds
tools/tokens/           token pipeline: Figma → Dart (generate.js + figma-variables.json snapshot)
tools/code-connect/     Figma Code Connect CLI + custom parser for Flutter
packages/ds/figma/      Code Connect definition files (*.figma.js, one per component)
```

---

## Always-on foundations — read before ANY widget work

> This is non-negotiable. Spacing, typography, and color invented by the agent are the #1 source of DS drift (Failure Mode 4 from DS-AI-LEARNINGS.md §4).

Before modifying or creating any widget, read ALL of these:

- `knowledgebase/foundations/quality.md` — widget authoring obligations checklist
- `knowledgebase/foundations/typography.md` — type hierarchy, `TypographyScale` statics
- `knowledgebase/foundations/color.md` — semantic color intent rules
- `knowledgebase/foundations/spacing.md` — composition recipes, `SpacingScale` tokens

If the widget already exists in the DS, also read:
- `knowledgebase/components/{widget}.md` — API contract, token usage, known gaps

---

## Always-on rules for widget code

These apply to every widget edit, not just new components:

### Colors
- **Always** access color via `Theme.of(context).extension<ColorScale>()!.fieldName`
- **Never** use `Colors.*` from Flutter
- **Never** hardcode hex values — `Color(0xFF...)` is banned in widget files
- **Never** import `ColorPrimitives` directly in a widget

### Typography
- **Always** use a `TypographyScale.*` static as the base — `TypographyScale.pMedium`, `TypographyScale.hdSmall`, etc.
- **Always** apply color via `.copyWith(color: colors.fieldName)` — never inside the static itself
- **Never** assemble `TextStyle(fontSize: ..., fontWeight: ..., height: ...)` from raw numbers
- **Never** read `fontSize` / `fontWeight` from Figma node data — use the named text style

### Spacing
- **Always** use `SpacingScale.*` — `SpacingScale.spaceMd`, `SpacingScale.spaceLg`, etc.
- **Never** use raw `dp` values or arithmetic (`8 + 1`)
- **Never** import `SpacingPrimitives` directly in a widget

### Radius & Opacity
- **Always** use `RadiusTokens.*` — `RadiusTokens.r20`, `RadiusTokens.full`, etc.
- **Always** use `OpacityTokens.*` for opacity values

### Gaps
- If a design value has no Tier 2 token — **stop and ask** what to use. Never silently fall back.

---

## Token class structure (three tiers, mirrors Figma Seasonal DLS)

**Tier 1 — primitives (raw values, never use directly in widgets)**

| Class | Contents |
|---|---|
| `ColorPrimitives` | Full palette — 60 colors across 6 families (orange, blue, red, green, yellow, grey) |
| `Foundation` | Font families (Lexend Deca, GT Ultra Median, GT Flaire), sizes, weights, line heights |
| `SpacingPrimitives` | Raw spacing values (0–115dp) |
| `RadiusTokens` | Named radii — `r4` `r8` `r12` `r16` `r20` `r24` `r32` `r36` `r40` `r44` `full` |
| `OpacityTokens` | `opacity0` → `opacity100` |

**Tier 2 — semantic aliases (use these in widgets)**

| Class | Contents |
|---|---|
| `ColorScale` | `ThemeExtension` — `brandPrimary`, `brandDark`, `feedbackNegative`, `feedbackWarning`, `feedbackPositive`, `backgroundPrimary/Secondary/Tertiary`, `contentPrimary/Secondary/Tertiary`, `borderOpaque`, `borderSelection` |
| `TypographyScale` | 21 `TextStyle` statics matching Figma names: `pSmall`→`pMax`, `shdSmall/Medium`, `hdSmall`→`hdRare`, `lbSmall/Regular`, `prMax`→`prBase`, `dpMax`→`dpBase`. Each has `height`, `leadingDistribution: .even`, `decoration: none` |
| `SpacingScale` | `spaceNone` `space2xs` `spaceXs` `spaceSm` `spaceMd` `spaceMdLg` `spaceLg` `spaceXl` `space2xl`→`space10xl` |

**Tier 3 — component tokens (context-dependent, use in component internals)**

| Class | Contents |
|---|---|
| `ButtonTokens` | `primaryOrangeBackground(context)`, `primaryOrangeLabel(context)`, `primaryBlackBackground(context)`, `primaryBlackLabel(context)` |

---

## MCP servers

- **ds** — Scapia DS knowledge server. **Always prefer this over reading token files directly.**
  Auto-regenerates its snapshot on startup if source files have changed — always fresh.

  | Tool | When to call |
  |---|---|
  | `check_token(hex)` | Any unrecognised hex value — returns token + `doNotUseFor` hint, or gap |
  | `get_color_guidance(tokenName)` | When `check_token` returns a `doNotUseFor` — get pairing rules + depth model to validate usage |
  | `get_typography_style(figmaName)` | Map a Figma text style name to `TypographyScale.*` static |
  | `get_typography_guidance(figmaName)` | After `get_typography_style` — get choosing guidance between similar styles + color pairings |
  | `get_spacing_token(valueDp)` | Map a Figma spacing value to `SpacingScale.*` |
  | `get_spacing_recipe(pattern)` | Get composition recipe for a layout pattern — more than just the token value |
  | `get_radius_token(valueDp)` | Map a Figma radius value to `RadiusTokens.*` |
  | `list_components()` | Phase 0.5 of any component build — reuse check |
  | `get_component(name)` | Get file path, figma node, knowledgebase doc for a component |

  Spacing patterns: `icon_label` `component_padding` `vertical_rhythm` `card` `page_margins` `sections` `list_item`

- **figma-console** — Figma Console MCP (Southleft). Full read/write to Figma Desktop via WebSocket.
  Desktop Bridge plugin must be running. Use for: `figma_get_text_styles`, `figma_get_variables`, `figma_execute`.
- **figma** — Figma REST MCP. Use for: `get_design_context`, `get_context_for_code_connect`.

---

## Knowledgebase

```
knowledgebase/foundations/quality.md        widget authoring obligations (always-on)
knowledgebase/foundations/typography.md     type hierarchy, when to use each style
knowledgebase/foundations/color.md          semantic color intent, pairing rules
knowledgebase/foundations/spacing.md        composition recipes
knowledgebase/decisions/001-*.md            two-tier token architecture ADR
knowledgebase/decisions/002-*.md            ColorScale as ThemeExtension ADR
knowledgebase/components/{widget}.md        per-widget API contract + token gaps
```

---

## Skills

- `/implement-figma-component <figma-url>` — full 9-phase procedure for building a DS component from Figma. Enforces fetch-everything → map-everything → write → test → connect order. **Use this for every new component — do not skip it.**

---

## Token pipeline

```bash
melos run tokens                # Figma snapshot → Dart token files in packages/tokens/lib/src/
dart analyze packages/          # lint
flutter test packages/tokens/   # verify alias chain + tier contract
```

To refresh the Figma snapshot: open Figma Desktop + Desktop Bridge plugin, then re-run `melos run tokens`.

---

## Widgetbook

```bash
melos run widgetbook             # launches component catalog on Chrome
```

---

## Code Connect

```bash
melos run code-connect:publish   # publishes *.figma.js definitions to Figma Dev Mode
melos run code-connect:check     # validates templates without publishing
```

Definition files: `packages/ds/figma/{component}.figma.js` — one per DS component.
Requires `FIGMA_ACCESS_TOKEN` env var (File content read + Code Connect write scopes).

---

## Trust levels for agent actions

| Level | When | Examples |
|---|---|---|
| **Auto** | Safe, reversible | Token value updates, formatting, test additions, doc fixes |
| **Draft PR** | Medium impact | New widget APIs, token renames, new component |
| **Suggest only** | High impact | Breaking API changes, new token categories, Tier 1 additions |

---

## All commands

```bash
melos run tokens                 # regenerate token files from Figma
melos run widgetbook             # open Widgetbook in Chrome
melos run code-connect:publish   # sync Code Connect to Figma Dev Mode
melos run code-connect:check     # validate Code Connect templates
dart analyze packages/ apps/     # lint whole workspace
dart format packages/ apps/      # format all Dart files
flutter test packages/tokens/    # token alias chain + tier contract tests
```
