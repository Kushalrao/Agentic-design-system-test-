# Widget Quality Obligations

> Load before authoring or reviewing any widget in `packages/ds/`.
> Every box must be checked before marking a widget done.

---

## Figma measurement

These rules govern how design values are read from Figma before any code is written.
Violations here are the single most common source of layout drift.

- [ ] All container dimensions (`width`, `height`) come from the MCP response field — never from screenshot proportions, never from arithmetic on other nodes
- [ ] All padding values come from the specific Figma node's properties — never assumed from a visually similar node
- [ ] Every gap between siblings is traced to the `itemSpacing` of its **direct parent frame** — not inferred from any ancestor or sibling frame
- [ ] All blur/shadow effect values come from the `effects` field in the MCP response — never visually estimated
- [ ] `fills[].opacity` (fill only) and `node.opacity` (whole layer) are read separately and mapped to the correct Flutter construct — never conflated
- [ ] `fills[].type` is read before calling `check_token` — `check_token` is only valid for SOLID fills; gradients require `LinearGradient` / `RadialGradient`
- [ ] `layoutSizingH` is read on the root node before writing any fixed width constant — FILL means no hardcoded width
- [ ] `clipsContent` is read before adding `ClipRRect` — corner radius alone does not mean children are clipped
- [ ] `strokeWeight` is read and written as `Border.all(width: N)` — never bare `Border.all(color:)`
- [ ] `imageScaleMode` is read before writing `BoxFit` — never defaulted to `BoxFit.cover`
- [ ] `textAlignHorizontal` is read before writing `TextAlign` — never defaulted to left
- [ ] `letterSpacing` is read; if non-zero, applied via `.copyWith(letterSpacing: N)`
- [ ] `maxLines` comes from the Figma node, not from the character count in the sample text
- [ ] Component instance icons are resolved to DS assets or flagged as a gap — `Icons.*` is never guessed from visual shape
- [ ] All designed states (disabled, loading, error, empty) are implemented or explicitly documented as out-of-scope gaps
- [ ] `StatelessWidget` vs `StatefulWidget` is decided before writing — never defaulted to stateless
- [ ] Every spacing value is classified as EXACT / NEAREST / NONE before a token is chosen:
  - **EXACT** — Figma dp = DS token dp → use the token
  - **NEAREST** — closest token exists but dp differs → raw literal + `// Gap:` comment + user notified
  - **NONE** — no token near this value → raw literal + `// Gap:` comment + user notified
- [ ] No spacing value is silently rounded to the nearest token — rounding is a gap, not a match

---

## Variant completeness

These checks apply when the component has Figma component properties defined (COMPONENT WITH PROPERTIES classification).

- [ ] Node classified before any Phase 3 fetching — STATIC FRAME / FRAME WITH NESTED INSTANCES / COMPONENT WITH PROPERTIES
- [ ] All INSTANCE descendants with non-empty `properties` walked — icon names and sub-component variants read from Figma, never guessed visually
- [ ] If COMPONENT WITH PROPERTIES: COMPONENT_SET parent fetched and full property × options matrix built
- [ ] `get_design_context` called once per meaningful variant — not just the URL node
- [ ] Comparative inventory built — [S] structural rows separated from [D] differential rows
- [ ] Differential table complete — every [D] property has a Dart token per variant and a Dart pattern (`switch`, `if`, map)
- [ ] No token value in `build()` that cannot be traced to either the structural or differential table — assumed values are banned
- [ ] Golden test list derived from the variant matrix — one per designed combination, not invented
- [ ] If STATIC FRAME: Figma limitations documented — dynamic Code Connect wiring not possible until Figma properties are defined

---

## Token usage

- [ ] Zero hardcoded `Color(0xFF...)` values — every color from `ColorScale`
- [ ] Zero `Colors.*` from Flutter — no `Colors.white`, `Colors.black`, etc.
- [ ] Zero hardcoded font sizes, weights, line heights — use `TypographyScale.*` statics
- [ ] Zero hardcoded spacing or padding values — use `SpacingScale.*` (EXACT match) or raw literal with gap comment
- [ ] Zero hardcoded border radius — use `RadiusTokens.*`
- [ ] Zero `Icons.*` from Flutter — every icon uses `SvgPicture.asset(ScapiaIcons.{constant})` or is documented as a gap in `icons.md`
- [ ] Zero hardcoded opacity values — use `OpacityTokens.*`
- [ ] Colors accessed exclusively via `Theme.of(context).extension<ColorScale>()!`
- [ ] Widget references only Tier 2 tokens (`ColorScale`, `TypographyScale`, `SpacingScale`, `RadiusTokens`, `OpacityTokens`)
- [ ] Widget does **not** import `ColorPrimitives` or `Foundation` directly
- [ ] No gaps silently resolved — every unmatched design value raised with the user before coding

---

## Typography

- [ ] Every text style uses a `TypographyScale.*` static as the base (e.g. `TypographyScale.pMedium`)
- [ ] Color applied via `.copyWith(color: colors.fieldName)` — never hardcoded inside the style
- [ ] No inline `TextStyle(fontSize:..., fontWeight:..., height:...)` assembly from raw numbers
- [ ] `leadingDistribution` and `decoration` not overridden unless explicitly required

---

## API contract

- [ ] Widget constructor has a `///` doc comment: one line on what it is, one line on when to reach for it
- [ ] Every public parameter has a `///` doc comment
- [ ] Variants and states expressed as Dart `enum`, not raw `String` or `bool` flags
- [ ] Default values declared on every optional parameter
- [ ] No generically named parameters (`data`, `value`, `config`) — names match the concept

---

## Tests

- [ ] Golden test exists for every variant × state combination
- [ ] Goldens visually compared against the Figma node screenshot — not auto-accepted
- [ ] `dart analyze packages/` exits clean — zero issues, zero warnings
- [ ] `flutter test packages/tokens/` passes — alias chain + tier contract intact

---

## Catalog

- [ ] Widgetbook entry exists in `packages/ds/widgetbook/`
- [ ] Every variant and state is separately navigable in Widgetbook
- [ ] Widgetbook knobs cover all enum values, not just the default
- [ ] Interactive + edge-case use cases present (long text, broken image, empty state)

---

## Accessibility

- [ ] Interactive elements have a `Semantics` label (or `Tooltip` for icon-only targets)
- [ ] Tappable hit targets are minimum 44×44dp — wrap in `SizedBox` if the visual is smaller
- [ ] State is never conveyed by color alone — icon or text accompanies every color change
- [ ] Disabled state uses `contentTertiary` text on `backgroundTertiary` fill — the only valid disabled pairing

---

## Code Connect

- [ ] `packages/ds/figma/{widget}.figma.js` created with `figmaNode`, `component`, `source`, `imports`, `example`
- [ ] `melos run code-connect:publish` run — snippet renders in Figma Dev Mode without error

---

## Knowledgebase

- [ ] `knowledgebase/components/{widget}.md` created with API table, typography map, token usage table, gaps section
- [ ] Any cross-cutting constraint not obvious from the API captured in `knowledgebase/decisions/`

---

## Trust level (per CLAUDE.md)

| Change type | Required action |
|---|---|
| New widget, new API | Draft PR — requires review |
| New variant on existing widget | Draft PR |
| Token value update, doc fix | Auto — safe |
| Breaking API change | Suggest only — human decision |
