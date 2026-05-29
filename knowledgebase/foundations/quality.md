# Widget Quality Obligations

> Load this file before authoring or reviewing any widget in `packages/ds/`.
> Run through every section before marking a widget done.

---

## Token usage

- [ ] Zero hardcoded `Color(0xFF...)` values — every color comes from `ColorScale`
- [ ] Zero hardcoded font sizes, weights, or letter spacing — use `TypographyScale`
- [ ] Zero hardcoded spacing or padding values — use `SpacingScale`
- [ ] Zero hardcoded border radius — use `RadiusTokens`
- [ ] Zero `Colors.*` from Flutter — never `Colors.white`, `Colors.black`, etc.
- [ ] Colors accessed exclusively via `Theme.of(context).extension<ColorScale>()!`
- [ ] Widget references only **Tier 2** tokens (`ColorScale`, `TypographyScale`, `SpacingScale`, `RadiusTokens`)
- [ ] Widget does **not** reference `ColorPrimitives` or `Foundation` directly

## API contract

- [ ] Widget constructor has a `///` doc comment: one line stating what it is + one line on when to reach for it
- [ ] Every public parameter has a `///` doc comment
- [ ] Variants and sizes expressed as Dart `enum`, not raw `String` or `bool` flags
- [ ] Default values declared on every optional parameter
- [ ] No parameter named generically (`data`, `value`, `config`) — names match the concept

## Tests

- [ ] Golden test exists for every variant × state combination
- [ ] Goldens reviewed visually after `flutter test --update-goldens` — not auto-accepted
- [ ] `dart analyze packages/` exits clean — zero issues, zero warnings

## Catalog

- [ ] Widgetbook entry exists in `packages/ds/widgetbook/`
- [ ] Every variant and state is separately navigable in Widgetbook
- [ ] Widgetbook knob covers all enum values, not just the default

## Accessibility

- [ ] Interactive elements have a `Semantics` label (or `Tooltip` for icon-only targets)
- [ ] Tappable hit targets are minimum 44×44pt — wrap in `SizedBox` if the visual is smaller
- [ ] State is never conveyed by color alone — icon or text accompanies color change
- [ ] Disabled state passes contrast check: `textDisabled` on `surfacePrimary` is the only valid pairing for disabled text

## Knowledgebase

- [ ] `knowledgebase/components/{widget}.md` created with the API contract (Step D format)
- [ ] Any cross-cutting constraint not obvious from the API is captured in `knowledgebase/decisions/`

## Trust level (per CLAUDE.md)

| Change type | Required action |
|---|---|
| New widget, new API | Draft PR — requires review |
| New variant on existing widget | Draft PR |
| Token value update, doc fix | Auto — safe |
| Breaking API change | Suggest only — human decision |
