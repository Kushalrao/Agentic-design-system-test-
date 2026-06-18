# Skill: manage-tokens

Manage the Seasonal DLS token system — sync from Figma, add new tokens, validate accuracy.
Invoked as: `/manage-tokens [sync | add <description> | validate]`

---

## Why this skill exists

The token system is the foundation every DS component builds on. Three failure modes recur without a defined process:

1. **Silent drift** — Figma's variable values change (a designer updates a spacing value, renames a color semantic) but the Dart files are never regenerated. Components continue shipping the stale value.
2. **Wrong tier reference** — A Tier 2 token is manually wired to the wrong Tier 1 primitive (`contentSecondary → neutralGrey700` instead of `neutralGrey600`). No gate catches it until a component looks wrong in widgetbook.
3. **New token added incorrectly** — A new typography style or spacing value is added to Dart by hand without the full procedure: Foundation primitive missing → alias chain breaks → tier contract test fails → agent panics and guesses.

---

## Three-tier architecture (load before any operation)

```
Tier 1 — Primitives (raw values, auto-generated, never used directly in widgets)
  color_primitives.dart    ColorPrimitives — 60 hex colors
  foundation.dart          Foundation — font families, sizes, weights, line heights
  spacing_primitives.dart  SpacingPrimitives — raw dp values
  radius_tokens.dart       RadiusTokens — named radii r4→r44, full
  opacity_tokens.dart      OpacityTokens — opacity0→opacity100

Tier 2 — Semantic aliases (what widgets use, some auto-generated, some human-reviewed)
  color_scale.dart         ColorScale ThemeExtension — 13 semantic fields
  typography_scale.dart    TypographyScale — 22 TextStyle statics (NEVER auto-generate)
  spacing_scale.dart       SpacingScale — named gaps spaceNone→space10xl

Tier 3 — Component tokens (context-dependent, always human-authored)
  button_tokens.dart       ButtonTokens — 4 context functions
```

**Rules that never change:**
- Widgets import ONLY Tier 2 tokens. Tier 1 is internal to the alias chain.
- Tier 2 values are always Dart references to Tier 1 constants — never hardcoded hex.
- TypographyScale is **never auto-generated** — each static is hand-crafted with `height`, `leadingDistribution`, `decoration` all set correctly.

---

## Standard vs. component-specific collections

Figma has two kinds of variable collections:

| Kind | Examples | Action |
|---|---|---|
| **Standard** — shared across the whole DS | Color Semantics, Containers, Colors, Typography, Button | Sync to Dart token files |
| **Component-specific** — per-component theming | `Base • AP Cards`, `Base • Pills surface colors` | Skip — handled per-component in implement-figma-component |

Always start with `figma_get_variables(format=summary)` to list all collections. Classify each before doing anything else.

---

## Operation: SYNC

> Pull the latest variable values from Figma, diff against current Dart files, and apply safe changes.

### Phase S1 — Discover all collections

Call `figma_get_variables(format=summary)` (figma-console MCP, hard-block if empty).

List every collection:

| Collection | Modes | Kind | Target Dart file |
|---|---|---|---|
| Colors | 1 | Standard Tier 1 | `color_primitives.dart` |
| Typography | 1 | Standard Tier 1 | `foundation.dart` |
| Containers | 1 | Standard Tier 1+2 | `spacing_primitives.dart`, `spacing_scale.dart`, `radius_tokens.dart`, `opacity_tokens.dart` |
| Color Semantics | Light / Dark | Standard Tier 2 | `color_scale.dart` |
| Button | 1 | Standard Tier 3 | `button_tokens.dart` |
| Base • AP Cards | Shop/Meal/Spa/Lounge | Component-specific | Skip |
| Base • Pills surface colors | 5 color modes | Component-specific | Skip |
| *(any others found)* | — | Classify first | — |

### Phase S2 — Fetch full variable data

For each **standard** collection, call `figma_get_variables(format=full, resolveAliases=true)`.

For multi-mode standard collections (Color Semantics), fetch all modes.

### Phase S3 — Diff against current Dart files

For each standard collection, compare Figma variable values against what the corresponding Dart file declares:

**Added variables** (in Figma, not in Dart):
- Tier 1: safe to auto-add
- Tier 2: present to user — semantic meaning needs human decision before adding

**Changed values** (variable exists in both, value differs):
- Tier 1 → safe to auto-update (pure numbers/hex, no semantic meaning)
- Tier 2 → **stop and present diff** — a changed semantic alias affects every component using it; human must confirm before applying
  ```
  CHANGED: Color Semantics / Surface/Content/Secondary
    Figma: Neutral/Grey/600 (#8C9AAA)
    Code:  neutralGrey700   (#4B545E)   ← BUG — wrong primitive reference
  Accept change? This will affect every component using colors.contentSecondary.
  Run flutter test packages/ds/test/ --update-goldens after applying.
  ```

**Removed variables** (in Dart, not in Figma):
- NEVER auto-delete. Surface to user:
  ```
  REMOVED from Figma: SpacingScale.spaceMd17
  This is a breaking change — removing it will break any widget that references it.
  Action required: either add it back to Figma, or manually migrate all usages first.
  ```

**Unchanged**: skip.

### Phase S4 — Apply changes (with confirmation for Tier 2+)

**Auto-apply (no confirmation needed):**
- New Tier 1 constants (new hex color, new spacing dp value)
- Tier 1 value changes (pure number/color update, no semantic meaning)

**Require confirmation before applying:**
- Any Tier 2 change (semantic meaning, breaks existing components)
- Any removal at any tier

**Never auto-apply:**
- `typography_scale.dart` — always hand-authored; if a new text style was added to Figma, follow the Typography token addition procedure instead
- Any Tier 3 change
- Breaking changes (removals, renames)

### Phase S5 — Validate after applying

After any changes:

```bash
dart analyze packages/tokens/
flutter test packages/tokens/            # alias chain + tier contract
melos run ds-mcp:generate               # regenerate DS MCP snapshot
```

If Tier 2 colors changed:
```bash
flutter test packages/ds/test/ --update-goldens   # regenerate component goldens
# Then visually inspect each updated golden
```

**Color Semantics cross-check** (always run after any color change):
For every Color Semantics variable, verify the resolved Figma hex matches the `color_scale.dart` primitive reference:
1. Fetch resolved hex from Figma (e.g. `Surface/Content/Secondary → #8C9AAA`)
2. Read the Dart field (e.g. `contentSecondary: ColorPrimitives.neutralGrey600`)
3. Verify `neutralGrey600.value == #8C9AAA` — if not, it's a wrong primitive reference (a bug, not a gap)

### Phase S6 — Update knowledgebase

After any color semantic value change:
- Update `knowledgebase/foundations/color.md` — the hex value in the token group table
- Update any component knowledgebase docs that reference the changed token

After any spacing/radius/opacity change:
- Update `knowledgebase/foundations/spacing.md` if a token value changed

---

## Operation: ADD

> Add a single new token to the Dart token system, following the correct tier procedure.

### Phase A1 — Classify the new token

Answer these questions before touching any file:

| Question | Answer options |
|---|---|
| What type of value? | Color / Spacing / Radius / Opacity / Typography / Custom |
| Which tier? | Tier 1 (raw primitive) / Tier 2 (semantic alias) / Tier 3 (component token) |
| Does it exist in Figma already? | Yes → fetch its variable ID and resolved value; No → note as code-only |
| Does a Tier 1 primitive already exist for this value? | Check existing Dart files first |

**Tier determination rules:**
- If the value is a raw primitive with no semantic meaning → Tier 1
- If it's a semantic alias pointing to a Tier 1 value → Tier 2
- If it's context-dependent (needs `BuildContext`) → Tier 3
- If it's a raw value used in exactly one component → do NOT add a DS token; use a raw literal with a gap comment

### Phase A2 — Follow the type-specific procedure

#### Adding a COLOR token

**New Tier 1 primitive:**
1. Add to `color_primitives.dart`: `static const Color {familyName}{shade} = Color(0xFF{HEX});`
2. Run `flutter test packages/tokens/` — tier contract test must pass
3. Run `melos run ds-mcp:generate`

**New Tier 2 semantic alias:**
1. Confirm a Tier 1 primitive exists for the hex value. If not, add it first.
2. Update `color_scale.dart`:
   - Add field to the class
   - Add to constructor `required this.newField`
   - Add to `light` static: `newField: ColorPrimitives.{primitive}`
   - Add to `copyWith` and `lerp`
3. Run `flutter test packages/tokens/` — tier contract test
4. Update `knowledgebase/foundations/color.md` — add to the appropriate token group table
5. Run `melos run ds-mcp:generate`

#### Adding a TYPOGRAPHY token (text style)

> TypographyScale is **never auto-generated**. Follow every step.

1. **Check Foundation** — does the required `fontSize` and `fontLineheight` already exist?
   - If not, add: `static const double fontSizeN = N;` and `static const double fontLineheightN = N;`

2. **Add to `typography_scale.dart`:**
   ```dart
   /// N / Weight / lh N — [when to use].
   static const TextStyle pExtraSmall = TextStyle(
     fontFamily: Foundation.fontFamilyLexendDeca,
     fontSize:   Foundation.fontSizeN,
     fontWeight: FontWeight.wNNN,
     height:     Foundation.fontLineheightN / Foundation.fontSizeN,
     leadingDistribution: TextLeadingDistribution.even,
     decoration:            TextDecoration.none,
   );
   ```
   Also add raw numeric constants:
   ```dart
   static const double pExtraSmallSize       = Foundation.fontSizeN;
   static const double pExtraSmallWeight     = Foundation.fontWeightRegular;
   static const double pExtraSmallLineheight = Foundation.fontLineheightN;
   ```

3. **Verify name matches Figma exactly** — the static name in camelCase must derive from the Figma text style name (e.g. `P-extra-small` → `pExtraSmall`). This is what makes `get_typography_style(figmaName)` work.

4. Run `flutter test packages/tokens/`
5. Run `melos run ds-mcp:generate`
6. Verify: call `get_typography_style(figmaName)` → must return `found: true`

#### Adding a SPACING token

**New Tier 1 primitive:**
1. Add to `spacing_primitives.dart`: `static const double spacingN = N;`

**New Tier 2 alias:**
1. Add to `spacing_scale.dart`: `static const double spaceXxx = SpacingPrimitives.spacingN;`
2. Update `knowledgebase/foundations/spacing.md` — add to the scale table
3. Run `flutter test packages/tokens/`
4. Run `melos run ds-mcp:generate`

#### Adding a RADIUS or OPACITY token

Same pattern as spacing — Tier 1 constant in the appropriate file, run tests, regenerate snapshot.

#### Adding a COMPONENT token (Tier 3)

Component tokens require `BuildContext` because they reference `ColorScale` values:
```dart
static Color primaryOrangeBackground(BuildContext ctx) =>
    Theme.of(ctx).extension<ColorScale>()!.brandPrimary;
```
Add to `button_tokens.dart` (or create a new `{component}_tokens.dart` file if it's a new component family).

### Phase A3 — Document the new token

- Update `knowledgebase/foundations/{type}.md` with the new token, its use-when, and any do-not-use-for constraints
- If the token fills a previously documented gap, remove it from the gaps table and update any component knowledgebase docs that referenced the workaround

---

## Operation: VALIDATE

> Cross-check all token values in Dart against Figma's current variable values. Surfaces bugs (wrong primitive references) before they ship in components.

### Phase V1 — Fetch all standard variables

Call `figma_get_variables(format=full, resolveAliases=true)` for all standard collections.

### Phase V2 — Color Semantics accuracy check

For every Color Semantics variable:
1. Read the resolved hex from Figma (e.g. `Surface/Content/Secondary → #8C9AAA`)
2. Find the corresponding `color_scale.dart` field (e.g. `contentSecondary: ColorPrimitives.neutralGrey600`)
3. Resolve the Tier 1 primitive to its hex (e.g. `neutralGrey600 = #8C9AAA`)
4. If Figma hex ≠ Dart primitive hex → **BUG** (not a gap). Report:
   ```
   BUG: contentSecondary
     Figma: Surface/Content/Secondary → #8C9AAA (Neutral/Grey/600)
     Code:  contentSecondary → ColorPrimitives.neutralGrey700 → #4B545E
   Fix: change color_scale.dart to use neutralGrey600, regenerate goldens.
   ```

### Phase V3 — Spacing accuracy check

For every Containers/Spacing variable:
1. Read the dp value from Figma (e.g. `Spacing/15 → 15dp`)
2. Find the corresponding `SpacingScale` constant (e.g. `spaceLg = SpacingPrimitives.spacing15`)
3. Resolve the primitive value
4. If values differ → report as bug

### Phase V4 — Known gaps report

After the accuracy checks, report all **known gaps** — values in Figma that have no Tier 2 alias:

```
KNOWN GAPS (no Tier 2 token — currently using raw values in components):
  • #389E0D (successGreen500) → workaround: colors.feedbackPositive per color.md
  • #E0EFFF (Base • AP Cards / Bg color) → component-specific, not a DS gap
  • Border/1 (1dp), Border/2 (2dp) → no BorderTokens class; raw 1.0/2.0 in components
  • Spacing/17 (17dp) → between spaceLg(15) and spaceXl(21); raw literal in components
  • size/icon/md, size/icon/lg → no IconTokens class
  • P-extra-small local style → now in TypographyScale as pExtraSmall ✓ (was a gap)
```

### Phase V5 — Summary

Present a structured summary:
```
VALIDATE RESULTS
  Bugs found:      N  ← wrong primitive references, must fix
  Gaps found:      N  ← no Tier 2 alias, documented workarounds exist
  All accurate:   NN  ← matches Figma
  New in Figma:    N  ← in Figma but not in Dart yet (run sync to add)
```

---

## When to use each operation

| Trigger | Operation |
|---|---|
| Designer updated a variable value in Figma | `sync` |
| Designer added new variables to a standard collection | `sync` |
| You need to add `P-extra-small` or similar to TypographyScale | `add` |
| A component uses `#FFEAE0` and you want to add a Tier 2 alias | `add` |
| A component color looks wrong in widgetbook vs Figma | `validate` |
| Before building a new component | `validate` (run Phase V2+V4 as part of Phase 2 in implement-figma-component) |
| After any token change | `validate` (confirm no other mismatches slipped in) |

---

## What this skill does NOT cover

| Not covered | Why / where handled |
|---|---|
| Component-specific variable collections (`Base • AP Cards`) | Handled per-component in implement-figma-component Phase 2c |
| Dark mode token values | Color Semantics Dark mode is defined in Figma; adding `ColorScale.dark` is a deliberate breaking change deferred until dark mode ships |
| `TypographyScale` auto-generation | Hand-authored to ensure correct `height`, `leadingDistribution`, `decoration` — the three properties that make Figma match Flutter |
| Icon exports | Handled by `melos run icons:export` / `tools/export_icons.py` |
| Tier 3 component tokens | Always human-authored; depend on semantic decisions the designer and engineer must agree on |

---

## Quality gates (run after any operation)

```bash
dart analyze packages/tokens/             # no syntax errors
flutter test packages/tokens/            # alias chain + tier contract intact
melos run ds-mcp:generate               # DS MCP snapshot current
```

After Tier 2 color changes additionally:
```bash
flutter test packages/ds/test/ --update-goldens   # regenerate component goldens
# Open each updated golden and visually verify
```
