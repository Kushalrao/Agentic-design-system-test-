# Skill: implement-figma-screen

Build a Flutter screen from a Figma node URL using DS foundations directly.
Invoked as: `/implement-figma-screen <figma-url>`

---

## How this differs from `/implement-figma-component`

| | `implement-figma-component` | `implement-figma-screen` |
|---|---|---|
| Output | Reusable DS widget, exported | One-off screen widget in `apps/app/` |
| Nested UI | Every instance → build as DS component first | Existing DS components → consume; missing → build inline with tokens |
| Inventory | Full 22-column table per node | Section-level only |
| Golden tests | Yes — every designed state | No |
| Widgetbook | Yes | No |
| Code Connect | Yes | No |
| Knowledgebase doc | Full API contract | Minimal — route + data deps + components consumed |
| Setup phases (0–2.5) | Per component | Once per screen |
| Token discipline | Identical — EXACT / NEAREST / NONE | Identical |

The token rules are exactly the same. What changes is the output format and the ceremony around it.

---

## Inputs

- `$FIGMA_URL` — URL of the screen frame in Figma.

---

## Procedure

---

### Phase 0 — Load context (same as component skill, do not skip)

Read before anything else:

**Foundations:**
- `knowledgebase/foundations/color.md`
- `knowledgebase/foundations/typography.md`
- `knowledgebase/foundations/spacing.md`
- `knowledgebase/foundations/quality.md`
- `knowledgebase/foundations/icons.md`

**Current token state:**
- `packages/tokens/lib/src/typography_scale.dart`
- `packages/tokens/lib/src/color_scale.dart`
- `packages/tokens/lib/src/spacing_scale.dart`
- `packages/tokens/lib/src/radius_tokens.dart`
- `packages/tokens/lib/src/opacity_tokens.dart`

---

### Phase 0.5 — Component instance scan (run once for the whole screen)

Call `get_context_for_code_connect` on the screen node. Walk every `descendants` entry where `type = "INSTANCE"`.

For each INSTANCE:

| `mainComponentName` | Action |
|---|---|
| Matches a DS widget (`DsButton`, `DsScapiaScore`, `DsStayStars`, etc.) | **Consume** — instantiate that widget in the screen. Do not re-derive its internals. |
| Matches an Iconography entry (`Hotels/kitchen/ 25px`, `Staystars/ 11px`, etc.) | **Resolve** to `ScapiaIcons.*` constant. |
| Any other component name | **Build inline** — use DS tokens directly for that element in this screen. Add a comment `// TODO: could become DsXxx if reused across screens`. |

> The key difference from the component skill: a missing DS component does **not** stop this build. It is built inline with foundations. If the same pattern appears in 2+ screens, extract it as a DS component at that point — not now.

---

### Phase 1 — Fetch text styles (same hard block as component skill)

Call `figma_get_text_styles`. If `count: 0` → stop, reconnect Desktop Bridge.

Resolve each style to `TypographyScale.*`. If `found: false` → follow the **Typography token addition procedure** (same as component skill Phase 1 sub-procedure) before continuing.

---

### Phase 2 — Fetch variables + color cross-check (same as component skill)

Call `figma_get_variables`. If `total_variables: 0` → stop, reconnect Desktop Bridge.

Build variable → Dart token lookup. Run the **Color Semantics cross-check**: for each variable, verify resolved hex matches `color_scale.dart` primitive. Fix any mismatch before Phase 3.

---

### Phase 2.5 — Screen pre-flight

Answer these once before any section work begins:

**Screen dimensions and sizing:**
- Is the root frame a fixed phone size (e.g. 390×844)? → `layoutSizingH = FIXED` on root means the screen fills its Navigator context; do not hardcode width.
- Is the screen scrollable? → wrap body in `SingleChildScrollView` or `ListView`.

**States — which of these exist in the Figma file for this screen?**

| State | Exists? | How represented in code |
|---|---|---|
| Loading / skeleton | — | — |
| Populated / default | — | — |
| Error | — | — |
| Empty / zero data | — | — |

For each state that exists: build it. For each that doesn't: stub it with a TODO comment.

**Data:**
- What data does this screen display? Define a simple Dart type or use a `Map` mock for now. Do not couple the screen to a specific data layer — pass data via constructor or expose a `loadData()` hook.

**Navigation:**
- What navigates TO this screen? (where to define the route)
- What does this screen navigate TO? (what callbacks or `Navigator.push` calls are needed)

**StatefulWidget assessment:**
- Any user interaction that changes display without a callback (scroll position, tab selection, expand/collapse)? → `StatefulWidget`
- All visual changes driven by constructor params? → `StatelessWidget`

---

### Phase 3 — Section decomposition + per-section inventory

**Step 3a — Split the screen into sections (3–7 top-level sections)**

Do not inventory every node. Split the screen into named top-level sections that correspond to visual groupings:

| Section name | Figma frame/node | Background | Layout | Key content |
|---|---|---|---|---|
| e.g. `AppBar` | `489:100` | `backgroundPrimary` | HORIZONTAL | title, back button |
| e.g. `Hero` | `489:200` | image fill | VERTICAL | image, overlay text |
| e.g. `Properties list` | `489:300` | `backgroundSecondary` | VERTICAL | N × `DsPropertyCard` |
| … | | | | |

**Step 3b — Per-section lightweight inventory**

For each section, record only the non-trivial token-bearing properties:

| Property | Figma value | Variable | Dart token | Match |
|---|---|---|---|---|
| Section background | `#FFFFFF` | `Surface/Background/Primary` | `colors.backgroundPrimary` | EXACT |
| Section padding | 21 dp | `Spacing/21` | `SpacingScale.spaceXl` | EXACT |
| Section gap | 15 dp | `Spacing/15` | `SpacingScale.spaceLg` | EXACT |
| Heading style | Hd-Small | — | `TypographyScale.hdSmall` | EXACT |

> **Do not** inventory every child node. Apply the full 22-column inventory only to nodes with non-trivial effects, gradients, or custom sizing. For structural nodes (plain padding/gap containers): read the spacing token from the variable binding and move on.

Token mapping rules are identical to the component skill: EXACT / NEAREST / NONE, gap protocol, batch review before writing.

---

### Phase 4 — Token mapping (per section, same rules)

Same EXACT / NEAREST / NONE discipline. Same gap batch protocol — collect all unknown gaps across all sections, present once before Phase 5.

---

### Phase 5 — Write the screen

**File location:** `apps/app/lib/screens/{screen_name}_screen.dart`

**Pre-checks (same as component skill):**
- Root sizing: FILL → no hardcoded width; screen fills Navigator
- Widget base class: per Phase 2.5 assessment

**Write section by section** — AppBar first, then body sections top to bottom, then bottom bar/CTA if any.

Rules (identical to component skill):
- Every color → `Theme.of(context).extension<ColorScale>()!.fieldName`
- Every text style → `TypographyScale.*` static + `.copyWith(color: ...)`
- Every spacing → `SpacingScale.*` (EXACT) or raw literal with `// Gap:` comment
- Every radius → `RadiusTokens.*`
- Every icon → `ScapiaIcons.*` constant
- No `Colors.*`, no hardcoded hex, no magic numbers

**Inline elements (no DS component):** use token-based widgets directly. Add a `// TODO: could become Ds{Name} if reused` comment so future extraction is easy.

**Existing DS components:** instantiate them directly. Do not re-derive their internals.

---

### Phase 6 — Validate (no goldens)

```bash
dart analyze apps/
dart tools/lint/check_ds_rules.dart
```

Both must pass. The DS lint scanner is the primary token-compliance gate for screens — it catches `Colors.*`, hardcoded hex, and raw spacing values that match tokens.

**Smoke test** (optional but recommended): run the app and navigate to the screen. Confirm it mounts without errors and renders visually close to the Figma frame.

No golden tests. No widgetbook entry.

---

### Phase 7 — Document (minimal)

Add a brief comment block at the top of the screen file:

```dart
/// [ScreenName]
///
/// Route: `/screen-name`
/// Data: {what data this screen displays}
/// Navigates to: {other screens}
/// DS components consumed: DsButton, DsScapiaScore, ...
/// Inline elements to extract later: [list any TODO: Ds* comments]
```

No knowledgebase file needed unless the screen introduces a section pattern used in 2+ screens — in that case, document the pattern in `knowledgebase/patterns/{pattern-name}.md`.

---

## Checklist

**Setup (run once)**
- [ ] All foundations loaded
- [ ] All INSTANCE descendants scanned — existing DS components identified, missing ones flagged as inline
- [ ] `figma_get_text_styles` non-zero (hard block if zero)
- [ ] All text styles resolved; any missing → token addition procedure run
- [ ] `figma_get_variables` non-zero (hard block if zero)
- [ ] Color Semantics cross-check passed
- [ ] Screen states enumerated (loading / populated / error / empty)
- [ ] Data type defined or mocked
- [ ] Navigation routes identified
- [ ] StatelessWidget vs StatefulWidget decided

**Per section**
- [ ] Screen split into named sections (3–7 max)
- [ ] Each section has background, layout, and key content recorded
- [ ] Token mapping complete for each section (EXACT / NEAREST / NONE, no blanks)
- [ ] All unknown gaps collected and batch-reviewed before writing
- [ ] Each section written with token-compliant code

**Output**
- [ ] `dart analyze apps/` → No issues
- [ ] `dart tools/lint/check_ds_rules.dart` → ✅ DS lint passed
- [ ] Screen mounts without errors (smoke test)
- [ ] Route comment block added to screen file
- [ ] Any inline elements marked with `// TODO: could become Ds{Name}` for future extraction
