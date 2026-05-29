# Widget Quality Obligations

> Load before authoring or reviewing any widget in `packages/ds/`.
> Every box must be checked before marking a widget done.

---

## Token usage

- [ ] Zero hardcoded `Color(0xFF...)` values — every color from `ColorScale`
- [ ] Zero `Colors.*` from Flutter — no `Colors.white`, `Colors.black`, etc.
- [ ] Zero hardcoded font sizes, weights, line heights — use `TypographyScale.*` statics
- [ ] Zero hardcoded spacing or padding values — use `SpacingScale.*`
- [ ] Zero hardcoded border radius — use `RadiusTokens.*`
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
