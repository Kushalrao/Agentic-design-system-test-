# Skill: implement-figma-component

Implement a Flutter DS component from a Figma node URL.
Invoked as: `/implement-figma-component <figma-url>`

---

## Why this skill exists

Without a strict procedure, three failure modes recur:
1. **Missed text styles** — raw numbers are extracted and `TextStyle(...)` is assembled inline instead of using `TypographyScale.*` statics.
2. **Missed variable bindings** — design values are treated as magic numbers instead of being traced back to their Figma token → Dart token.
3. **Premature coding** — the widget is written before a full token-mapping table exists, so gaps and wrong tokens are discovered only after the fact.

This skill enforces the correct order: **fetch everything → map everything → then write code**.

---

## Inputs

- `$FIGMA_URL` — the Figma node URL passed by the user.

---

## Procedure

### Phase 0 — Load context (do not skip)

Read these files before doing anything else:
- `knowledgebase/decisions/001-two-tier-token-architecture.md`
- `knowledgebase/decisions/002-color-scale-as-theme-extension.md`
- `knowledgebase/foundations/color.md`
- `knowledgebase/foundations/typography.md`
- `knowledgebase/foundations/spacing.md`
- `knowledgebase/foundations/quality.md`

Also read the current state of:
- `packages/tokens/lib/src/typography_scale.dart` — to know which `TextStyle` statics exist
- `packages/tokens/lib/src/color_scale.dart` — to know which color tokens exist
- `packages/tokens/lib/src/spacing_scale.dart` — to know which spacing tokens exist

---

### Phase 1 — Fetch text styles (ALWAYS first)

**Before fetching the component node**, call `figma_get_text_styles` (figma-console MCP).

Build a lookup table from the result:

| Figma style name | Size | Weight | Line height | Dart static |
|---|---|---|---|---|
| P-Medium | 15 | 400 | 23 | `TypographyScale.pMedium` |
| Hd-Small | 17 | 600 | 23 | `TypographyScale.hdSmall` |
| Lb-Regular | 13 | 400 | 21 | `TypographyScale.lbRegular` |
| … | … | … | … | … |

If new styles appear in Figma that don't yet have a Dart static, **stop and add them** to `TypographyScale` before continuing.

---

### Phase 2 — Fetch variables

Call `figma_get_variables` (figma-console MCP) or `figma_browse_tokens` to get all variables in the current file.

Build a variable → Dart token lookup:

| Figma variable path | Dart token |
|---|---|
| `Color Semantics/Brand/Primary` | `colors.brandPrimary` |
| `Color Semantics/Surface/Background/Primary` | `colors.backgroundPrimary` |
| `Containers/Spacing/13` | `SpacingScale.spaceMdLg` |
| `Containers/Radius/20` | `RadiusTokens.r20` |
| … | … |

---

### Phase 3 — Fetch design context

Call `mcp__figma__get_design_context` with the node URL.

For each node in the result, extract and record:

#### Text nodes
For every `TEXT` node:
- `characters` — the actual text content (use as `String` param default)
- `textStyleId` / `textStyle.name` — the Figma style name (must be in Phase 1 table)
- `fills[].boundVariables.color` — the color variable (must be in Phase 2 table)

❌ **Never** read `fontSize`, `fontWeight`, or `lineHeightPx` from node data to assemble a `TextStyle`. Always use the named style from Phase 1.

#### Frame / container nodes
For every `FRAME` or `GROUP`:
- `paddingLeft`, `paddingRight`, `paddingTop`, `paddingBottom` — map each to `SpacingScale.*`
- `itemSpacing` — the gap between children, map to `SpacingScale.*`
- `cornerRadius` — map to `RadiusTokens.*`
- `fills[].boundVariables.color` — map to `ColorScale.*`

#### Image nodes
- Note dimensions (height is usually fixed, width usually fills card)
- Note any overlay Stack children (blur pills, pagination, buttons)

---

### Phase 4 — Build the token mapping table

Before writing a single line of Dart, produce this table in full:

| Widget property | Figma node | Figma value | Figma variable / style | Dart token | Gap? |
|---|---|---|---|---|---|
| Hotel name text style | `Text/hotel-name` | 15 / Regular / 23 | P-Medium | `TypographyScale.pMedium` | No |
| Hotel name color | `Text/hotel-name` | `#121212` | `Color Semantics/Content/Primary` | `colors.contentPrimary` | No |
| Card bg color | `Frame/card` | `#FFFFFF` | `Color Semantics/BG/Primary` | `colors.backgroundPrimary` | No |
| Card radius | `Frame/card` | `20dp` | `Containers/Radius/20` | `RadiusTokens.r20` | No |
| Price text | `Text/price` | 17 / SemiBold / 23 | Hd-Small | `TypographyScale.hdSmall` | No |
| `/night` color | `Text/night` | `#8C9AAA` | *(no Tier 2 alias)* | `colors.contentSecondary` | **Yes** |

#### Gap protocol
When a gap is found:
1. Use the closest Tier 2 token.
2. Add a `// Gap: Figma shows #XXXXXX (tokenName); closest Tier 2 is X.` comment inline.
3. Record it in the `knowledgebase/components/{component}.md` under a "Token gaps" section.
4. Do **not** hardcode the hex value directly.

---

### Phase 5 — Write the component

Only start coding once Phase 4 is complete.

Rules (enforced by `knowledgebase/foundations/quality.md`):
- Every text style → `TypographyScale.*` static + `.copyWith(color: ...)`
- Every color → `Theme.of(context).extension<ColorScale>()!.fieldName`
- Every spacing → `SpacingScale.*`
- Every radius → `RadiusTokens.*`
- No `Colors.*`, no hardcoded hex, no magic numbers
- No assembling `TextStyle(fontSize:..., fontWeight:..., height:...)` from scratch — always start from a named static

Component location:
- Widget: `packages/ds/lib/src/components/{category}/{ds_name}.dart`
- Export: add to `packages/ds/lib/scapia_ds.dart`
- Story: `packages/ds/widgetbook/lib/components/{name}_story.dart`
- Register: add to `packages/ds/widgetbook/lib/main.dart`

---

### Phase 6 — Validate

```bash
dart analyze packages/
flutter test packages/tokens/
```

Zero errors, zero warnings required before declaring done.

---

### Phase 7 — Document

Create or update `knowledgebase/components/{component}.md` with:
- API table (all constructor params)
- Typography table: each text element → Figma style → Dart static
- Token usage table: each visual property → Figma variable → Dart token
- Token gaps section (if any)
- Widgetbook use-cases list

---

## Checklist (tick every box before marking done)

- [ ] `figma_get_text_styles` called and lookup table built
- [ ] `figma_get_variables` called and variable→token map built
- [ ] Every text node has a named style (not raw numbers)
- [ ] Every fill/stroke has a variable binding traced to a Dart token
- [ ] Every spacing value traced to `SpacingScale.*`
- [ ] Every radius traced to `RadiusTokens.*`
- [ ] Token mapping table (Phase 4) written out before coding started
- [ ] All gaps documented with closest-token + comment
- [ ] `dart analyze packages/` → No issues found
- [ ] `flutter test packages/tokens/` → All tests passed
- [ ] Widgetbook story added with Interactive + edge-case use-cases
- [ ] `knowledgebase/components/{component}.md` created/updated
