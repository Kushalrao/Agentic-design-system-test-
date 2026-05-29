# Design System — Claude Code context

## Repo layout
```
packages/tokens/   design tokens — color, spacing, radius, typography (source of truth: Figma)
packages/ds/       themed Flutter widgets; depends on packages/tokens
apps/app/          product app — depends on packages/ds
tools/tokens/      token pipeline: Figma → Dart (generate.js + figma-variables.json snapshot)
```

## MCP servers available
- **figma-console** — Figma Console MCP by Southleft. Full read/write access to Figma Desktop
  via WebSocket bridge. Desktop Bridge plugin must be running before calling any figma-console tools.

## Token pipeline
Tokens originate in Figma variables. To regenerate:
```bash
melos run tokens        # reads tools/tokens/figma-variables.json → writes packages/tokens/lib/src/
dart analyze packages/  # verify
```
To refresh the Figma snapshot (when variables change in Figma):
- Open Figma Desktop with the Desktop Bridge plugin running
- Claude re-exports via figma_execute → updates tools/tokens/figma-variables.json
- Then re-run `melos run tokens`

## Token class structure (two tiers, mirrors Figma)

**Tier 1 — primitives (raw values, never reference these directly in widgets)**
| Class | Contents |
|---|---|
| `ColorPrimitives` | Full color palette — `orange500`, `neutral900`, `white`, … (112 colors) |
| `Foundation` | Font family, sizes, weights, line heights — `fontFamilyFigtree`, `fontSize17`, … |
| `SpacingPrimitives` | Raw spacing values |
| `RadiusTokens` | `none` `sm` `md` `lg` `xl` `full` |

**Tier 2 — semantic aliases (use these in widgets — they reference Tier 1)**
| Class | Contents |
|---|---|
| `ColorScale` | `light` ThemeExtension — `surfaceBrand`, `textPrimary`, `borderDefault`, … |
| `TypographyScale` | `labelLgSize`, `labelLgWeight`, `bodyMdSize`, … (reference `Foundation`) |
| `SpacingScale` | `xs`, `sm`, `md`, `lg`, `xl`, … (reference `SpacingPrimitives`) |

## Knowledgebase
Detailed guidance lives in `knowledgebase/` — load the relevant file before acting:
- `knowledgebase/foundations/quality.md` — widget authoring obligations checklist
- `knowledgebase/foundations/spacing.md` — composition recipes
- `knowledgebase/foundations/typography.md` — type hierarchy guide
- `knowledgebase/foundations/color.md` — semantic color intent rules
- `knowledgebase/decisions/` — architecture decision records (ADRs) for cross-cutting constraints
- `knowledgebase/components/{widget}.md` — per-widget API contract (Step D, built after widgets exist)

## Rules for writing widgets
- **Always use Tier 2** for widget styling — `ColorScale`, `TypographyScale`, `SpacingScale`
- **Never hardcode** hex colors, font sizes, or spacing values
- **Never use `Colors.*`** from Flutter — always go through token classes
- Access colors in widgets: `Theme.of(context).extension<ColorScale>()!.surfaceBrand`
- Tier 2 = single source of truth. If it doesn't exist as a Tier 2 token, raise it — don't hardcode

## Trust levels for agent actions
- **Auto** — safe: token value updates, formatting, test additions
- **Draft PR** — medium: new widget APIs, token renames
- **Suggest only** — high impact: breaking API changes, new token categories

## Commands
```bash
melos run tokens          # regenerate Dart token files from Figma snapshot
dart analyze packages/ apps/   # lint the whole workspace
dart format packages/ apps/    # format all Dart files
flutter test packages/tokens/  # run token tests (alias chain + tier contract)
```
