# Skill: review-component

Review a DS component against all quality obligations.

Invoked as: `/review-component <component-name-or-file-path>`

---

## Purpose

Run every obligation from `knowledgebase/foundations/quality.md` against a component and produce a clear pass/fail report. Use before merging any new component or variant.

---

## Procedure

### Phase 0 — Load context

Read:
- `knowledgebase/foundations/quality.md`
- `knowledgebase/foundations/color.md`
- `knowledgebase/foundations/typography.md`
- The component file: `packages/ds/lib/src/components/{category}/{name}.dart`
- The component knowledgebase doc if it exists: `knowledgebase/components/{name}.md`

### Phase 1 — Token usage

Read the component source. Check every line:

- [ ] Any `Color(0xFF...)` literals? → **FAIL**
- [ ] Any `Colors.*` usage? → **FAIL**
- [ ] Any hardcoded font size, weight, or line height numbers? → **FAIL**
- [ ] Any hardcoded spacing values (raw numbers in padding/gap/SizedBox)? → **FAIL**
- [ ] Any hardcoded border radius numbers? → **FAIL**
- [ ] Colors accessed via `Theme.of(context).extension<ColorScale>()!`? → must be the only pattern
- [ ] Any `ColorPrimitives.*` or `Foundation.*` imported directly? → **FAIL**
- [ ] Any `// Gap:` comments? → note each one, flag as unresolved gap

### Phase 2 — Typography

- [ ] Every `Text` widget uses a `TypographyScale.*` static as base?
- [ ] Color applied via `.copyWith(color: ...)` — never baked into the static?
- [ ] No inline `TextStyle(fontSize:..., fontWeight:..., height:...)` construction?

### Phase 3 — API contract

- [ ] Widget constructor has a `///` doc comment?
- [ ] Every public parameter has a `///` doc comment?
- [ ] Variants/states use Dart `enum`, not `String` or `bool` flags?
- [ ] Default values on all optional parameters?
- [ ] No generic parameter names (`data`, `value`, `config`)?

### Phase 4 — Tests

Check `packages/ds/test/components/`:
- [ ] Golden test file exists?
- [ ] Covers every variant × state combination?
- [ ] `dart analyze packages/` is clean?
- [ ] `flutter test packages/tokens/` passes?

### Phase 5 — Widgetbook

Check `packages/ds/widgetbook/lib/components/`:
- [ ] Story file exists?
- [ ] Interactive use case with knobs for all enum values?
- [ ] Edge-case use cases present (long text, empty state, broken image if relevant)?
- [ ] Registered in `packages/ds/widgetbook/lib/main.dart`?

### Phase 6 — Accessibility

- [ ] Interactive elements have `Semantics` labels?
- [ ] Tappable hit targets ≥ 44dp?
- [ ] State not conveyed by color alone — icon or text accompanies every color change?
- [ ] Disabled state uses `contentTertiary` on `backgroundTertiary` only?

### Phase 7 — Code Connect

Check `packages/ds/figma/`:
- [ ] `.figma.js` definition file exists for this component?
- [ ] `figmaNode`, `component`, `source`, `imports`, `example` all populated?

### Phase 8 — Knowledgebase doc

Check `knowledgebase/components/`:
- [ ] Component doc exists?
- [ ] API table complete?
- [ ] Typography mapping table (element → Figma style → Dart static)?
- [ ] Token usage table (property → Figma variable → Dart token)?
- [ ] Token gaps section present if any `// Gap:` comments exist in source?

---

## Output format

Produce a report with:

```
## Review: {ComponentName}

### ✅ Passing
- <item>
- <item>

### ❌ Failing
- <item> — <what needs to be fixed>
- <item> — <what needs to be fixed>

### ⚠️ Gaps
- <gap description> — <current workaround> — <action needed>

### Verdict
READY / NEEDS WORK
```

If `NEEDS WORK`: list the exact changes required before the component can be considered done. Do not suggest "nice to have" improvements — only obligations from `quality.md`.
