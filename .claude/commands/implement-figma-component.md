# Skill: implement-figma-component

Implement a Flutter DS component from a Figma node URL.
Invoked as: `/implement-figma-component <figma-url>`

---

## Why this skill exists

Without a strict procedure, these failure modes recur:
1. **Rebuilding what exists** — a DS component is written from scratch when an existing widget already covers it.
2. **Missed text styles** — raw numbers extracted and `TextStyle(...)` assembled inline instead of `TypographyScale.*` statics.
3. **Missed variable bindings** — design values treated as magic numbers instead of traced to Figma token → Dart token.
4. **Premature coding** — widget written before a full token-mapping table exists; wrong tokens discovered after the fact.
5. **Missing quality obligations** — golden tests, accessibility, Code Connect skipped because they have no enforced phase.
6. **Estimated dimensions** — container heights/widths derived from screenshot proportions instead of read from the Figma node data the MCP already returned.
7. **Spacing conflation** — a single `itemSpacing` value applied to all gaps in a tree when different parent frames govern different gaps.
8. **Silent nearest-token approximation** — a value that doesn't exactly match a DS token is rounded to the closest one without flagging it as a gap.
9. **Auto-layout direction guessed from visual** — `Row` or `Column` chosen by looking at the screenshot instead of reading `layoutMode` from the node.
10. **Child sizing assumed fill/hug** — `Expanded` or natural width written based on how it looks, not `layoutSizingHorizontal` / `layoutSizingVertical` per child.
11. **Alignment assumed start/center** — `MainAxisAlignment` and `CrossAxisAlignment` chosen visually instead of read from `primaryAxisAlignItems` / `counterAxisAlignItems`.
12. **Clip behaviour assumed from corner radius** — `ClipRRect` added because `cornerRadius > 0`, even when Figma has `clipsContent: false` and children are allowed to overflow.
13. **Fill type assumed solid** — hex sampled from a gradient's centre point, `Color(hex)` written instead of `LinearGradient` or `RadialGradient`.
14. **Opacity level conflated** — `node.opacity` (layer) and `fills[].opacity` (fill only) are different; applying the wrong one changes which children are affected.
15. **Image fit assumed cover** — `BoxFit.cover` written by default instead of reading `imageScaleMode` (FILL / FIT / CROP / TILE) from the image node.
16. **Stroke weight assumed 1 dp** — `Border.all(color: …)` written without a `width:` argument, defaulting Flutter's 1 dp instead of the Figma-specified stroke weight.
17. **Text alignment assumed left** — `TextAlign.left` written by default instead of reading `textAlignHorizontal` (LEFT / CENTER / RIGHT / JUSTIFIED) from the text node.
18. **Letter spacing assumed zero** — non-zero `letterSpacing` in the Figma style silently dropped.
19. **`maxLines` assumed from sample content** — text shows one line in the screenshot so `maxLines: 1` is written; Figma may intend 2 or unconstrained.
20. **Icon assumed Material** — closest `Icons.*` name chosen visually; Figma node is actually a component instance pointing to a custom icon library.
21. **Only visible state implemented** — the URL shows the default state; hover / pressed / disabled / loading / error states designed elsewhere in the component set are never fetched.
22. **Widget assumed stateless** — `StatelessWidget` written for a component whose variants or interactions require internal state.
23. **Root node assumed to be the whole component** — target node is a child frame inside a larger `COMPONENT_SET`; sibling frames (e.g. title bar, footer) that belong to the same widget are never seen.
24. **Root width assumed fixed** — `_cardWidth = N` written from `absoluteBoundingBox.width` even when `layoutSizingHorizontal: FILL` means the component should fill its container.
25. **Treating a variant system as a snapshot** — the URL frame shows one state; the component has a matrix of variants and states designed in Figma, none of which are fetched or implemented. Every variant-specific token — background color per variant, border per state, element visibility per boolean — is missed.
26. **Nested INSTANCE properties ignored** — icon instances and sub-component instances inside a frame have their own `properties` field with VARIANT options naming exactly which icon or sub-component is used. These are read as visual inspection guesses instead.

This skill enforces the correct order: **classify → check what exists → fetch everything → exhaust the MCP response → map the full variant system → write → test → connect**.

---

## Inputs

- `$FIGMA_URL` — the Figma node URL passed by the user.

---

## Procedure

---

### Phase 0 — Load context (do not skip)

Read these files before doing anything else:

**Foundations:**
- `knowledgebase/foundations/color.md`
- `knowledgebase/foundations/typography.md`
- `knowledgebase/foundations/spacing.md`
- `knowledgebase/foundations/quality.md`
- `knowledgebase/foundations/icons.md`

> **Decisions (`knowledgebase/decisions/`)** are NOT loaded here. They protect
> architectural decisions (why ColorScale is a ThemeExtension, why tokens alias
> rather than hardcode) and belong in token-change or code-review flows — not
> in component implementation. Load them only if a task involves modifying the
> token architecture itself.

**Current token state (know what exists before mapping):**
- `packages/tokens/lib/src/typography_scale.dart`
- `packages/tokens/lib/src/color_scale.dart`
- `packages/tokens/lib/src/spacing_scale.dart`
- `packages/tokens/lib/src/radius_tokens.dart`
- `packages/tokens/lib/src/opacity_tokens.dart`
- `packages/tokens/lib/src/button_tokens.dart`

---

### Phase 0.5 — DS reuse check (do not skip)

Call **both** of these on every new component — they answer different questions:

**`list_components()`** on the ds MCP server — checks our Dart component registry:
1. Does any existing DS widget already implement this, or a close variant?
2. Does the design use sub-components (buttons, chips, inputs) that already exist as DS widgets? Call `get_component(name)` for detail.
3. Does any existing component share layout structure that should be extracted into a shared primitive?

**`mcp__figma__get_code_connect_map`** on the target node URL — checks whether a Code Connect mapping already exists for this node:
- If a mapping is returned with a `snippet` field → that code already represents this component. Do not rebuild it; update the existing one.
- If no mapping is returned → proceed with implementation.

**If either check shows reuse is possible → propose it to the user and wait for confirmation before proceeding.**

---

### Phase 1 — Fetch text styles (ALWAYS first)

**Before fetching the component node**, call `figma_get_text_styles` (figma-console MCP) to get styles from the Figma file.

> ⛔ **Hard block — tool failure check:**
> If the response returns `count: 0` or an error, **stop immediately**. Do not proceed.
> This means the Figma Desktop Bridge plugin is not running or not connected.
> Surface this to the user:
> ```
> BLOCKED: figma_get_text_styles returned no styles.
> Open Figma Desktop → Plugins → Development → Desktop Bridge plugin → ensure it shows "Connected".
> Then re-run this skill from Phase 1.
> ```
> Do not fall back to reading style names from get_design_context — that data is less structured and will produce text style mapping errors.

For each style returned, resolve to a Dart static using the **ds MCP**: `get_typography_style(figmaName)`.

If the ds MCP returns `found: false` for a style → it doesn't exist in `TypographyScale` yet. **Stop and add it** to `TypographyScale` before continuing, then run `melos run ds-mcp:generate` to refresh the snapshot.

---

### Phase 2 — Fetch variables

Call `figma_get_variables` (figma-console MCP) or `figma_browse_tokens`.

> ⛔ **Hard block — tool failure check:**
> If the response returns `total_variables: 0` or an error, **stop immediately**. Do not proceed.
> This means variables could not be resolved — spacing, radius, and color variable paths will be unknown.
> Surface this to the user:
> ```
> BLOCKED: figma_get_variables returned no variables.
> Open Figma Desktop → Plugins → Development → Desktop Bridge plugin → ensure it shows "Connected".
> Then re-run this skill from Phase 2.
> ```
> Do not proceed with unresolved `VariableID:...` strings in the design context — they cannot be traced to dp values without this step.

Build a variable → Dart token lookup:

| Figma variable path | Dart token |
|---|---|
| `Color Semantics/Brand/Primary` | `colors.brandPrimary` |
| `Color Semantics/Surface/Background/Primary` | `colors.backgroundPrimary` |
| `Containers/Spacing/13` | `SpacingScale.spaceMdLg` |
| `Containers/Radius/20` | `RadiusTokens.r20` |
| `Containers/Opacity/40` | `OpacityTokens.opacity40` |
| … | … |

---

### Phase 2.5 — Component structure analysis

Call `mcp__figma__get_context_for_code_connect` with the node URL. One call, three steps.

#### Step 2.5A — Root properties → constructor API

Record every entry in the root `properties` field:

| Figma property | Type | Options | Maps to Dart |
|---|---|---|---|
| e.g. `Variant` | VARIANT | `primary / dark / ghost` | `enum DsXVariant` |
| e.g. `Show Rating` | BOOLEAN | true / false | `VoidCallback?` (interactive) or `bool` (display state) |
| e.g. `Label` | TEXT | — | `String label` (default = Figma value) |

Mapping rules:
- `VARIANT` → Dart `enum`, one case per option. Never a raw `String`.
- `BOOLEAN` → `VoidCallback?` when it drives an interaction; `bool` when it drives visible state (isDisabled, isLoading).
- `TEXT` → `String` param; Figma's current value is the default.
- `INSTANCE_SWAP` → which DS component is slotted in. Add to gap batch: ask which Dart widget maps to each option.

#### Step 2.5B — Nested INSTANCE traversal → internal implementation choices

Walk every entry in `descendants`. For each entry where `type = "INSTANCE"` and `properties` is **non-empty**, record it:

| Descendant key | Instance name | Property | Type | Options |
|---|---|---|---|---|
| e.g. `INSTANCE[Icon]` | Icon | Name | VARIANT | `arrow-right, map-pin` |
| e.g. `INSTANCE[Icon]` | Icon | Size | VARIANT | `16` |

These are **not constructor params** — they are implementation choices inside the widget body:
- **Icon VARIANT options** → which icon to render at this node. All 13,751 Seasonal DLS icons are pre-exported to `packages/ds/assets/icons/` and accessible via `ScapiaIcons`. Resolution process:
  1. Read the option name from Figma (e.g. `arrow-right`, `kitchen`, `map-pin`)
  2. Derive the expected constant using the transformation rules in `knowledgebase/foundations/icons.md`: slugify the option name → camelCase → append size (default `25px`). Example: `arrow-right` → `interfaceEssentialArrowRight25px`
  3. Grep `packages/ds/lib/src/icons/scapia_icons.dart` for constants containing the keyword. Example: `grep -i "arrowright" scapia_icons.dart`
  4. If one clear match → use `SvgPicture.asset(ScapiaIcons.{constant})`. Done.
  5. If multiple matches → pick the one whose Figma comment line most closely matches the design intent. Record the chosen constant in the component's knowledgebase doc.
  6. If zero matches → the icon name doesn't exist in the Seasonal DLS library. Add to gap batch: *"Icon `{option-name}` not found in ScapiaIcons — designer needs to add it to Figma Iconography page and re-run `melos run icons:export`"*
  7. **Never** use `Icons.*` from Flutter as a substitute. Never guess visually.
- **Sub-component VARIANT options** → which variant of the nested DS widget to instantiate.
- **Sub-component BOOLEAN** → conditional rendering of that child.

> **Rule:** Never choose an icon by visual inspection. The VARIANT option name on an INSTANCE descendant is the source of truth. Resolve via `icons.md` first — gap batch only if the icon is not yet registered.

#### Step 2.5C — Classify the node

| Classification | Condition | Phase 2.6? | Phase 3 fetches |
|---|---|---|---|
| **STATIC FRAME** | root `properties: {}` AND no INSTANCE descendants with properties | Skip | URL node only |
| **FRAME WITH NESTED INSTANCES** | root `properties: {}` BUT some INSTANCE descendants have non-empty properties | Skip | URL node only — nested instances noted |
| **COMPONENT WITH PROPERTIES** | root `properties` non-empty | **Run** | All meaningful variants from Phase 2.6 |

> If **STATIC FRAME**: document in `knowledgebase/components/{name}.md` under a "Figma limitations" section — Code Connect dynamic wiring is not possible; the snippet will be static. List what properties would need to be added in Figma to enable it.

---

### Phase 2.6 — Variant matrix (runs only when Phase 2.5C = COMPONENT WITH PROPERTIES)

The URL frame is one state. This phase maps the whole system before a single pixel of design context is fetched.

#### Step 2.6A — Fetch the full property set from the COMPONENT_SET

If the URL node lives inside a COMPONENT_SET, call `get_context_for_code_connect` on the **parent COMPONENT_SET node ID** — not just the URL node. This returns the complete property set across all variants, not just the selected one.

Build the **variant matrix** — all properties that define the system:

| Property | Options | Dart type | Notes |
|---|---|---|---|
| `Variant` | `primary / dark / ghost` | `enum DsXVariant` | Drives visual style |
| `State` | `default / disabled / loading` | `bool isDisabled`, `bool isLoading` | Drives behaviour |
| `Icon` | `left / right / none` | `DsXIconPosition?` | `null` = no icon |

#### Step 2.6B — Map each existing combination to its Figma node ID

Not every mathematical product of options is designed. List only combinations that actually exist in Figma. Get their node IDs from the COMPONENT_SET's children (visible in `get_design_context` on the parent node).

| Combination | Figma node ID | Fetch in Phase 3? | Skip reason |
|---|---|---|---|
| primary / default | 123:456 | ✓ | Base case — always fetch |
| primary / disabled | 123:458 | ✓ | Background + label color differ |
| primary / loading | 123:460 | ✓ | Content changes (spinner) |
| dark / default | 123:462 | ✓ | Background + label color differ |
| dark / disabled | 123:464 | Skip | Tokens identical to primary/disabled |
| ghost / default | 123:466 | ✓ | Background removed, border appears |

**Fetch rules:**
- **Always fetch** the base/default variant.
- **Fetch** when: background color changes, text color changes, border appears/disappears, element shows/hides, icon changes.
- **Skip** only when you can prove the visual tokens are identical to an already-fetched variant. When in doubt, fetch.
- **Never fetch** separately for TEXT property differences alone — text content changes without token differences are covered by the text binding.

---

### Phase 2.75 — Pre-flight: scope and state completeness (do not skip)

Before fetching node data, answer these two questions from the component properties in Phase 2.5:

**Scope check — is this the whole component?**
Call `mcp__figma__get_context_for_code_connect` on the target node URL and check the response for a parent `COMPONENT_SET`. If the parent is a `COMPONENT_SET`, call `mcp__figma__get_design_context` on the parent node ID to fetch all sibling variant frames. Never implement only the frame in the URL if sibling frames contain additional designed states.

**State completeness — which states are designed?**
For every component, explicitly list which of these states exist in the component set:

| State | Designed? | In scope for this implementation? |
|---|---|---|
| Default / resting | — | — |
| Pressed / active | — | — |
| Hover | — | — |
| Disabled | — | — |
| Loading | — | — |
| Error | — | — |
| Empty / zero data | — | — |

If a state is designed but not in scope, document it as a known gap in `knowledgebase/components/{component}.md`. Never silently omit a designed state.

**Stateful assessment — `StatelessWidget` or `StatefulWidget`?**
Answer before writing any code:
- Does any parameter change trigger an animation? → `StatefulWidget` + `AnimationController`
- Does any user interaction change display without an external callback? (e.g. expand/collapse, pagination) → `StatefulWidget`
- Do all visual changes flow in from constructor parameters only? → `StatelessWidget` is safe

---

### Phase 3 — Fetch design context + build node inventory

> **Branch — which path runs depends on Phase 2.5C classification:**
>
> **STATIC FRAME / FRAME WITH NESTED INSTANCES:**
> Call `get_design_context` once on the URL node. Build the single-node inventory below. Continue to Phase 3.5.
>
> **COMPONENT WITH PROPERTIES:**
> Call `get_design_context` once for **each combination** marked "Fetch in Phase 3?" in the Phase 2.6 matrix. Build the single-node inventory for the base variant. Then build the comparative inventory (Step 3c). Both are required before Phase 4.

**The MCP response is the source of record. Every numeric property it returns gets a table row. Nothing is estimated afterward.**

#### Step 3a — Build the node inventory table

Walk every node in the response and fill in ALL returned properties.

> **Transcription rule — copy, do not retype:**
> Every numeric value in the table must be copied verbatim from the raw MCP JSON response field — not retyped from memory, not rounded, not summarised.
> The agent's memory of "what it read" is not the source of record. The JSON field is.
> Concretely: if the MCP returns `"itemSpacing": 21`, the table cell must contain `21`. If it returns `"paddingTop": 15`, the table cell must contain `15`. If you are unsure of the value, paste the raw JSON snippet next to the table row rather than guessing.
>
> A transcription error looks like this in practice: MCP returns `"itemSpacing": 21` for the Description Section. Agent reads the whole response, then writes `7` in the table because it just finished reading the Property Info frame which had `itemSpacing: 7`. The number in the table is wrong. The code derived from the table is wrong. The golden passes because the diff is 14 dp at system-font resolution. This is caught only by precise Figma comparison — and only if the reviewer knows to look.
>
> Leave a cell blank only if the MCP genuinely did not return that field. Mark it `?`. Re-fetch before proceeding — never fill a `?` by estimation.

**Frame / container nodes** — one row per node:

| Node name | nodeId | width | height | layoutSizingH | layoutSizingV | layoutMode | paddingL | paddingR | paddingT | paddingB | itemSpacing | primaryAxisAlign | counterAxisAlign | cornerRadius | clipsContent | strokeWeight | strokeAlign | fills[].type | fills[].opacity | node.opacity | effects |
|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|
| *(fill from MCP response)* | | | | | | | | | | | | | | | | | | | | | |

Column legend:
- `layoutSizingH / V` — FIXED / FILL / HUG (per node, from MCP — not inferred from visual)
- `layoutMode` — HORIZONTAL / VERTICAL / NONE (NONE = absolute positioning, not auto-layout)
- `primaryAxisAlign` — MIN / CENTER / MAX / SPACE_BETWEEN → maps to `MainAxisAlignment`
- `counterAxisAlign` — MIN / CENTER / MAX / BASELINE → maps to `CrossAxisAlignment`
- `clipsContent` — true / false; only add `ClipRRect` when this is `true`
- `strokeWeight` — exact dp value; write `Border.all(width: N)` not `Border.all()`
- `strokeAlign` — INSIDE / CENTER / OUTSIDE (affects layout box)
- `fills[].type` — SOLID / GRADIENT_LINEAR / GRADIENT_RADIAL / IMAGE; never sample hex from a gradient
- `fills[].opacity` — fill-level opacity; different from `node.opacity`; applies only to the fill, not children
- `node.opacity` — layer-level opacity; applies to the node and all its children

> **Rule:** `width` and `height` must come from `absoluteBoundingBox` or explicit size fields in the MCP response — never from arithmetic on other nodes or from measuring the screenshot. If the MCP didn't return a field, mark it `?` and re-fetch before proceeding.

**Per-child sizing** — for each child within an auto-layout frame, record the child's own sizing mode (not the parent's):

| Child name | Parent frame | Child layoutSizingH | Child layoutSizingV | Flutter equivalent |
|---|---|---|---|---|
| *(fill from MCP response)* | | | | e.g. `Expanded` / `SizedBox(w,h)` / natural |

> **Rule:** `Expanded` is only correct when `layoutSizingH = FILL` on that child. Never add `Expanded` because a child *looks* like it fills the row.

**Text nodes** — one row per node:

| Node name | nodeId | characters | textStyle.name | fill color / variable | fills[].type | textAlignHorizontal | letterSpacing | maxLines | textTruncation |
|---|---|---|---|---|---|---|---|---|---|
| *(fill from MCP response)* | | | | | | | | | |

Column legend:
- `fills[].type` — text fills can be gradients; if GRADIENT, check_token(hex) is not sufficient
- `textAlignHorizontal` — LEFT / CENTER / RIGHT / JUSTIFIED; never default to left
- `letterSpacing` — if non-zero, must be passed to `.copyWith(letterSpacing: N)`
- `maxLines` — from `textAutoResize` + line count in design; never infer from sample content length
- `textTruncation` — DISABLED / ENDING; maps to `overflow: TextOverflow.ellipsis` only when ENDING

**Image / media / icon nodes** — one row per node:

| Node name | nodeId | width | height | imageScaleMode | isComponentInstance | componentName |
|---|---|---|---|---|---|---|
| *(fill from MCP response)* | | | | | | |

Column legend:
- `imageScaleMode` — FILL → `BoxFit.cover`; FIT → `BoxFit.contain`; CROP → `BoxFit.cover` + alignment; TILE → pattern shader
- `isComponentInstance` — if true, this is a custom icon from a library, not a Material icon; fetch the component to identify the correct asset
- `componentName` — the referenced Figma component name; use this to find the DS icon or SVG asset

#### Step 3b — Resolve each inventory row to DS tokens

For each row in the frame inventory:
- `paddingLeft/Right/Top/Bottom`, `itemSpacing` → call `get_spacing_token(valueDp)` on ds MCP
- `cornerRadius` → call `get_radius_token(valueDp)` on ds MCP
- `fills[].boundVariables.color` → call `check_token(hex)` on ds MCP
- `opacity` → `OpacityTokens.*`
- `effects` → carry forward to Phase 3.6

For each row in the text inventory:
- `textStyle.name` → must appear in the Phase 1 table. If not → stop and add the style.
- `fills[].type` → if GRADIENT, do not call `check_token`. Record as a gap and ask the user.
- `fill color` → call `check_token(hex)` on ds MCP (only when `fills[].type = SOLID`)
- `textAlignHorizontal` → map to `TextAlign`: LEFT → `.left`, CENTER → `.center`, RIGHT → `.right`, JUSTIFIED → `.justify`. Never default to `.left` without reading this field.
- `letterSpacing` → if non-zero, add `.copyWith(letterSpacing: N)`. If zero, omit.
- `maxLines` → write `maxLines: N` when the Figma node has a fixed line cap. Do not infer from the sample content length.
- `textTruncation` → ENDING → `overflow: TextOverflow.ellipsis`. DISABLED → no overflow param.

For each row in the image/icon inventory:
- `isComponentInstance = true` → do not guess a Material icon. Add this to the **unknown gap batch** with the `componentName` and ask the user which DS asset or `Icons.*` to use. Custom icon resolution is deferred to the batch review at the end of Phase 4.
- `imageScaleMode` → apply the BoxFit mapping from Step 3.5a. Never default to `BoxFit.cover` without reading this field.

❌ **Never** read `fontSize`, `fontWeight`, or `lineHeightPx` from node data to assemble a `TextStyle`. Always use the named style from Phase 1.

#### Step 3c — Comparative inventory (COMPONENT WITH PROPERTIES path only)

After all Phase 2.6 variants have been fetched, build this table. One row per visual property. One column per fetched variant. Every cell copied verbatim from the `get_design_context` response for that variant — never filled by interpolation.

| Property | base (e.g. primary/default) | variant-2 | variant-3 | … |
|---|---|---|---|---|
| Background color | `brandPrimary` | `brandDark` | transparent (gap) | |
| Label color | `backgroundPrimary` | `backgroundPrimary` | `contentPrimary` | |
| Border | none | none | `borderOpaque` | |
| Radius | `r20` | `r20` | `r20` | |
| Height | 48 dp | 48 dp | 48 dp | |
| node.opacity (disabled state) | 1.0 | 0.4 → `opacity40` | 0.4 → `opacity40` | |

**After filling every cell, mark each row:**
- **[S] Structural** — all cells in this row are identical. Implement once, no conditional.
- **[D] Differential** — at least one cell differs. Implement conditionally from a `switch` or `if`.

Every [D] row goes directly into the Phase 4 differential table. Every [S] row goes into the Phase 4 structural table. No row is left unclassified.

For any token lookup that returns `found: false` → **stop and ask the user**.

---

### Phase 3.5 — Map Figma layout structure to Flutter

#### Step 3.5a — Auto-layout and sizing equivalents

For every frame in the node inventory, map every layout field to its Flutter equivalent:

**Layout direction** — from `layoutMode`:

| Figma layoutMode | Flutter equivalent |
|---|---|
| HORIZONTAL | `Row` |
| VERTICAL | `Column` |
| NONE | `Stack` (absolute positioning) |

**Root-level sizing** — from root node's `layoutSizingH`:

| Root layoutSizingH | Flutter equivalent | Rule |
|---|---|---|
| FIXED | `SizedBox(width: N)` | Hardcode width constant |
| FILL | no width constraint | Never hardcode `_cardWidth`; let parent constrain |
| HUG | `mainAxisSize: MainAxisSize.min` | Shrink-wraps content |

**Per-child sizing** — from each child's `layoutSizingH` / `layoutSizingV`:

| Child layoutSizingH | Inside a Row | Inside a Column |
|---|---|---|
| FILL | `Expanded(child: …)` | `SizedBox(width: double.infinity, …)` |
| FIXED | `SizedBox(width: N, …)` | `SizedBox(width: N, …)` |
| HUG | natural / `mainAxisSize: min` | natural / `mainAxisSize: min` |

**Alignment** — from `primaryAxisAlignItems` and `counterAxisAlignItems`:

| Figma primaryAxisAlignItems | Flutter MainAxisAlignment |
|---|---|
| MIN | `MainAxisAlignment.start` |
| CENTER | `MainAxisAlignment.center` |
| MAX | `MainAxisAlignment.end` |
| SPACE_BETWEEN | `MainAxisAlignment.spaceBetween` |

| Figma counterAxisAlignItems | Flutter CrossAxisAlignment |
|---|---|
| MIN | `CrossAxisAlignment.start` |
| CENTER | `CrossAxisAlignment.center` |
| MAX | `CrossAxisAlignment.end` |
| BASELINE | `CrossAxisAlignment.baseline` |

**Clip behaviour** — from `clipsContent`:

| Figma clipsContent | Flutter |
|---|---|
| true | Wrap with `ClipRRect(borderRadius: …)` |
| false | No clip — even if `cornerRadius > 0`, children are allowed to overflow |

**Fill type** — from `fills[].type`:

| Figma fills[].type | Flutter |
|---|---|
| SOLID | `color: colors.someToken` (use check_token on the hex) |
| GRADIENT_LINEAR | `gradient: LinearGradient(colors: […], stops: […])` — do not call check_token on a sampled hex |
| GRADIENT_RADIAL | `gradient: RadialGradient(…)` |
| IMAGE | `DecorationImage` with `imageScaleMode` (see below) |

**Image fit** — from `imageScaleMode`:

| Figma imageScaleMode | Flutter BoxFit |
|---|---|
| FILL | `BoxFit.cover` |
| FIT | `BoxFit.contain` |
| CROP | `BoxFit.cover` (+ `alignment` if crop position is non-centre) |
| TILE | `ImageRepeat.repeat` / custom shader |

**Stroke** — from `strokeWeight` and `strokeAlign`:

| Figma strokeAlign | Flutter Border note |
|---|---|
| INSIDE | `Border.all(width: N)` inside `BoxDecoration` — shrinks content area by N dp |
| CENTER | `Border.all(width: N)` — standard Flutter behaviour |
| OUTSIDE | Use `BoxShadow` with `spreadRadius: N, blurRadius: 0` as an approximation |

> **Rule:** Never write `Border.all(color: …)` without an explicit `width: strokeWeight`. Flutter's default `width: 1.0` is not a token match — it is a silent assumption.

#### Step 3.5b — Gap ownership table (do not skip)

For **every gap between sibling elements** in the layout, record which parent frame owns it and what that frame's `itemSpacing` value is. A gap's value is always owned by its **direct parent** — never inherited from an ancestor or assumed from a sibling frame.

| Gap (between A and B) | Direct parent frame | Parent itemSpacing (dp) | DS token |
|---|---|---|---|
| e.g. Property Title → Location row | Property Info frame | 7 dp | `SpacingScale.spaceSm` |
| e.g. Property Info → Amenities Section | Description Section frame | 21 dp | `SpacingScale.spaceXl` |
| e.g. Amenities Section → View All | Description Section frame | 21 dp | `SpacingScale.spaceXl` |

> **Rule:** Two gaps that look visually similar may be governed by different parent frames with different `itemSpacing` values. Never assume that one frame's `itemSpacing` applies to gaps in a different frame. Trace every gap to its owning parent row in the inventory table from Step 3a.

Build the full widget tree skeleton from these two tables before writing any Dart.

---

### Phase 3.6 — Map Figma effects

For every effect found in the node inventory, record and resolve:

| Effect type | Figma value | Flutter equivalent | Token |
|---|---|---|---|
| `layerBlur` | sigma: 8 | `ImageFilter.blur(sigmaX: 8, sigmaY: 8)` | — (no token) |
| `backdropBlur` | sigma: N | `BackdropFilter` + `ImageFilter.blur(sigmaX: N, sigmaY: N)` | — (use exact Figma value) |
| `dropShadow` | color, offset, blur | `BoxDecoration(boxShadow: [...])` | Gap — ask user |
| `innerShadow` | color, offset, blur | No direct Flutter equivalent | Gap — ask user |
| `opacity` | 0.4 | `Opacity` widget or `.withAlpha()` | `OpacityTokens.*` |

> **Rule:** Blur sigma values must come from the `effects` field in the node inventory — never visually estimated. Figma's blur radius maps 1:1 to Flutter's `ImageFilter.blur` sigma.

**If a shadow or effect has no token mapping — stop and ask the user what to use before continuing.**

---

### Phase 4 — Build the token mapping table

Before writing a single line of Dart, produce this table in full. Every row must reference a specific node from the Phase 3 inventory — no rows may be added by estimation.

| Widget property | Figma node | Figma value | Figma variable / style | Dart token | Token dp | Match | Action |
|---|---|---|---|---|---|---|---|
| Hotel name text style | `Text/hotel-name` | P-Medium | P-Medium | `TypographyScale.pMedium` | — | EXACT | ✓ |
| Card bg | `Frame/card` | `#FFFFFF` | `BG/Primary` | `colors.backgroundPrimary` | — | EXACT | ✓ |
| Card radius | `Frame/card` | 20 dp | `Containers/Radius/20` | `RadiusTokens.r20` | 20 dp | EXACT | ✓ |
| Card padding | `Frame/card` | 15 dp | `Containers/Spacing/15` | `SpacingScale.spaceLg` | 15 dp | EXACT | ✓ |
| Chip gap | `Amenities frame` | 4 dp | — | — | — | NONE | raw `4` + gap comment |
| Pill left offset | `Rating pill` | 11 dp | — | — | — | NONE | raw `11` + gap comment |

#### Match column rules — enforced, no exceptions

| Match value | Meaning | Required action |
|---|---|---|
| **EXACT** | Figma dp = DS token dp | Proceed. Use the token. |
| **NEAREST** | Closest token exists but dp differs | Do NOT silently use nearest. Use a raw literal. Add `// Gap: Figma N dp, no token match` comment. Notify user. |
| **NONE** | No token anywhere near the value | Raw literal. Gap comment. Notify user. |

> **The single rule that prevents failure mode 8:** if the Figma value is `4 dp` and the closest token is `spaceXs = 5 dp`, the match is NEAREST, not EXACT. Write `SizedBox(width: 4)` with a gap comment — never silently write `SizedBox(width: SpacingScale.spaceXs)`.

#### Differential table (COMPONENT WITH PROPERTIES path only)

Built directly from the [D] rows in the Phase 3c comparative inventory. One column per Figma variant, using the Dart enum value as the column header.

| Property | `DsXVariant.primary` | `DsXVariant.dark` | `DsXVariant.ghost` | Dart pattern |
|---|---|---|---|---|
| Background | `colors.brandPrimary` | `colors.brandDark` | gap — batch | `switch (variant)` |
| Label color | `colors.backgroundPrimary` | `colors.backgroundPrimary` | `colors.contentPrimary` | `switch (variant)` |
| Border | none | none | `Border.all(width:1, color: colors.borderOpaque)` | `if (variant == ghost)` |
| Opacity (disabled) | `OpacityTokens.opacity40` | `OpacityTokens.opacity40` | — | `if (isDisabled) Opacity(...)` |

**Dart pattern column — four options, pick the clearest:**
- `switch (variant)` — token differs across enum cases → full switch expression
- `if (boolParam)` — token differs on a BOOLEAN param → if / ternary
- `if (variant == X)` — token applies in one case only, absent in all others
- `Map<Variant, Token>` — many cases, same structure → consider a lookup map for readability

The Match column (EXACT / NEAREST / NONE) still applies per cell. NEAREST or NONE goes to the gap batch. No cell is left blank — a blank means the variant was not fetched, which is a Phase 2.6 error to fix.

#### Token lookup protocol

For every color in the design:
1. Call `check_token(hex)` — get the token + `doNotUseFor`
2. If `doNotUseFor` is set → call `get_color_guidance(tokenName)` and check the depth model and pairing rules against the current context. If `doNotUseFor` applies → stop and ask the user.

For every spacing value in the design:
1. Call `get_spacing_token(dp)` — get the token value
2. Confirm the returned token dp **exactly equals** the Figma dp. If not → Match = NEAREST, use raw literal.
3. If deciding BETWEEN two adjacent tokens → call `get_spacing_recipe(pattern)` to understand which token the pattern calls for.

For every typography style:
1. Call `get_typography_style(figmaName)` — get the Dart static
2. If choosing between visually similar styles (same size, different weight) → call `get_typography_guidance(figmaName)` to see the decision table.

#### Gap protocol

Gaps come in two kinds. Handle them differently:

**Known documented gap** — the gap already appears in `knowledgebase/foundations/color.md` (Known gaps section) or in a prior component's `knowledgebase/components/*.md` Token gaps section, with an established workaround.
→ Apply the documented workaround automatically. Add a `// Gap: <description>; using <token> per <doc reference>.` comment. Add it to the batch review list (see below). Do not block.

**Unknown gap** — no workaround is on record anywhere in the knowledgebase.
→ Add it to the batch review list and mark it `UNKNOWN`. Continue building the rest of the table. Do not proceed to Phase 5 until all UNKNOWN gaps are resolved.

**Batch review — present all gaps together at the end of Phase 4:**
Once the full token mapping table is complete, surface every gap in a single message:
```
GAP REVIEW — resolve before Phase 5

Known gaps (workaround applied, confirm or override):
  • [node] fills: #FFF2EC → ColorPrimitives.primaryScapia000 (Tier 1) per stays_srp_card.md

Unknown gaps (need your decision):
  • [node] itemSpacing: 4 dp — no SpacingScale token. Raw literal 4 or different layout intent?
  • [node] textColor: #3B82F6 — not in ColorScale. What token should this use?
```
Wait for user response before writing any code. Once resolved, record decisions in `knowledgebase/components/{component}.md` under "Token gaps".

---

### Phase 5 — Write the component

Only start coding once Phase 4 is complete and every row has an Action.

**Pre-check: widgetbook asset declaration (first time a component uses `ScapiaIcons.*`)**
If this is the first component in the current session that calls `SvgPicture.asset(ScapiaIcons.xxx)`, verify `packages/ds/widgetbook/pubspec.yaml` has `assets: - assets/icons/` in its `flutter:` section. The widgetbook is its own Flutter app and does NOT automatically inherit `scapia_ds` package assets for development rendering — it needs the icons declared in its own pubspec. This is a one-time check; skip it if already declared.

**Pre-check: all token values come from tables, not from visual memory**

For COMPONENT WITH PROPERTIES:
- All [S] structural token values → implement once, unconditionally. Source: Phase 4 structural table.
- All [D] differential token values → implement conditionally. Source: Phase 4 differential table.
- The widget body must be derivable from these two tables alone. If any token value in the code cannot be traced back to a table cell, it was assumed — remove it and add it to the tables first.

**Pre-check: confirm widget base class** (from Phase 2.75 stateful assessment):
- If `StatefulWidget` is needed → set it up first; changing base class later breaks the API.
- If `StatelessWidget` → confirm no internal toggle, selection, or animation is silently swallowed.

**Pre-check: confirm root sizing** (from `layoutSizingH` in inventory):
- FILL → no `_cardWidth` constant; let parent constrain. Use `double.infinity` or omit width.
- FIXED → hardcode the constant with a comment citing the Figma node name and value.

Rules (enforced by `knowledgebase/foundations/quality.md`):
- Every text style → `TypographyScale.*` static + `.copyWith(color: ...)`
- Every color → `Theme.of(context).extension<ColorScale>()!.fieldName`
- Every spacing → `SpacingScale.*` (EXACT match only) or raw literal with gap comment
- Every radius → `RadiusTokens.*`
- Every opacity → `OpacityTokens.*`
- No `Colors.*`, no hardcoded hex, no magic numbers
- No assembling `TextStyle(fontSize:..., fontWeight:..., height:...)` from scratch
- Interactive elements must have `Semantics` labels
- Tappable targets must be ≥ 44dp — wrap in `SizedBox` if visual is smaller
- State must never be conveyed by color alone — pair with icon or text

Component location:
- Widget: `packages/ds/lib/src/components/{category}/{ds_name}.dart`
- Export: add to `packages/ds/lib/scapia_ds.dart`
- Story: `packages/ds/widgetbook/lib/components/{name}_story.dart`
- Register: add to `packages/ds/widgetbook/lib/main.dart`

---

### Phase 6 — Validate

Run in this order — each gate must pass before the next:

```bash
# 1. Syntax + type errors first — if this fails, nothing else can run
dart analyze packages/

# 2. DS token tier violations — catches what dart analyze can't
dart tools/lint/check_ds_rules.dart

# 3. Token alias chain contract
flutter test packages/tokens/

# 4. Regression check — did this component break any existing golden?
#    (New component has no goldens yet — this only checks existing ones)
melos run test:goldens
```

All four must exit cleanly before proceeding. If `melos run test:goldens` fails, you changed something that broke an existing component's visual output — fix that before moving on.

---

### Phase 7 — Document

Create or update `knowledgebase/components/{component}.md` with:
- API table (all constructor params, derived from Phase 2.5A root properties)
- Typography table: each text element → Figma style → Dart static
- Token usage table: each visual property → Figma variable → Dart token
- Token gaps section (decisions made + comments)
- Widgetbook use-cases list

**If COMPONENT WITH PROPERTIES — also add:**
- **Variant matrix** (from Phase 2.6): all Figma properties × options × Dart types in one table
- **Differential token table** (from Phase 4): per-variant token values for all [D] properties, with Dart pattern noted

**If STATIC FRAME — also add:**
- **Figma limitations** section: "This component has no Figma component properties defined. Code Connect dynamic wiring is not possible. The Dev Mode snippet is static. Properties that would need to be added in Figma to enable dynamic wiring: `[list them]`."

---

### Phase 8 — Golden tests + visual verification

1. Create `packages/ds/test/components/{category}/{ds_name}_test.dart`

2. **Cross-check against the Phase 2.75 state table before writing a single test:**
   For every row marked "Designed: Yes" in the state completeness table, there must be a corresponding `testWidgets` golden. If a designed state has no test, the regression suite can never catch a regression on it.

   | State | Designed? | Golden test exists? |
   |---|---|---|
   | Default | Yes | `{name}_default.png` |
   | Disabled | Yes | `{name}_disabled.png` |
   | … | … | … |

   Any designed state with no golden → add the test before running `--update-goldens`.

3. Run:
   ```bash
   flutter test packages/ds/test/components/{category}/ --update-goldens
   ```

4. Open each generated golden PNG and **visually compare against the Figma node screenshot** from Phase 3.
   Focus specifically on: spacing between sections, container heights, chip padding, text size/alignment.
   These are the properties golden tests at system-font resolution are most likely to pass incorrectly.

5. If layout, spacing, or color differs → fix before proceeding.

Do not auto-accept goldens without visual review.

---

### Phase 9 — Code Connect

1. Create `packages/ds/figma/{ds_name}.figma.js` using the definition format from `stays_srp_card.figma.js` as reference.
2. Fill in `figmaNode`, `component`, `source`, `imports`, and `example` (representative Dart constructor call).
3. **If COMPONENT WITH PROPERTIES:** Add a comment block documenting the upgrade path to dynamic wiring:
   ```js
   // UPGRADE PATH — wire once Figma properties are confirmed in Dev Mode:
   // props: {
   //   variant: figma.enum('Variant', { 'primary': 'DsXVariant.primary', 'dark': 'DsXVariant.dark' }),
   //   isDisabled: figma.boolean('State', { 'disabled': true, 'default': false }),
   // },
   // example: ({ variant, isDisabled }) => `DsX(variant: ${variant}, onPressed: ${isDisabled ? 'null' : '() {}'})`
   ```
   Do not publish a broken dynamic snippet — document the intent and publish the working static one.
4. Publish:
   ```bash
   melos run code-connect:publish
   ```
5. Open Figma Dev Mode and confirm the snippet renders without error.

---

## Checklist (tick every box before marking done)

**Fetch phases**
- [ ] DS reuse check completed — existing widgets checked, reuse confirmed or ruled out
- [ ] `figma_get_text_styles` called — confirmed non-zero styles returned (hard block if zero)
- [ ] `figma_get_variables` called — confirmed non-zero variables returned (hard block if zero)
- [ ] Figma component properties extracted and mapped to Dart constructor params
- [ ] `get_design_context` called — full response processed (not skimmed)

**Component structure (Phase 2.5)**
- [ ] `get_context_for_code_connect` called — root `properties` read
- [ ] All INSTANCE descendants with non-empty `properties` walked and recorded (Step 2.5B)
- [ ] Node classified: STATIC FRAME / FRAME WITH NESTED INSTANCES / COMPONENT WITH PROPERTIES (Step 2.5C)
- [ ] If STATIC FRAME: Figma limitations documented in knowledgebase — no dynamic wiring possible
- [ ] Nested INSTANCE variant options either resolved to a Dart asset or added to gap batch — no visual guessing

**Variant matrix (Phase 2.6 — only when COMPONENT WITH PROPERTIES)**
- [ ] COMPONENT_SET parent fetched — full property × options set retrieved
- [ ] All existing variant combinations listed with Figma node IDs
- [ ] Each combination marked: Fetch in Phase 3 or Skip (with reason)
- [ ] Phase 3 called once per "Fetch" combination — not just the URL node
- [ ] Comparative inventory (Step 3c) built — every cell verbatim from MCP, every row marked [S] or [D]
- [ ] Differential table built in Phase 4 — every [D] property has a token per variant and a Dart pattern
- [ ] Golden test list derived from variant matrix — one golden per designed variant, not invented

**Scope and state (Phase 2.75)**
- [ ] Parent node checked — if COMPONENT_SET, all sibling frames fetched and reviewed
- [ ] All designed states listed (default / pressed / disabled / loading / error / empty)
- [ ] In-scope states confirmed with user; out-of-scope states documented as known gaps
- [ ] StatelessWidget vs StatefulWidget decision made explicitly before writing any code

**Node inventory (Phase 3a) — every MCP-returned field has a table cell**
- [ ] Frame inventory complete — all columns filled from MCP: width, height, layoutSizingH, layoutSizingV, layoutMode, paddingL/R/T/B, itemSpacing, primaryAxisAlign, counterAxisAlign, cornerRadius, clipsContent, strokeWeight, strokeAlign, fills[].type, fills[].opacity, node.opacity, effects
- [ ] Per-child sizing table complete — every child's layoutSizingH and layoutSizingV recorded; `Expanded` used only when child layoutSizingH = FILL
- [ ] Text inventory complete — all columns filled: textStyle.name, fill type, textAlignHorizontal, letterSpacing, maxLines, textTruncation
- [ ] Image/icon inventory complete — imageScaleMode, isComponentInstance, componentName recorded for every image/icon node
- [ ] Zero cells filled by screenshot estimation or arithmetic — only MCP-returned values

**Layout mapping (Phase 3.5) — every inventory field has a Flutter equivalent**
- [ ] layoutMode → Row / Column / Stack (not guessed from visual)
- [ ] Root layoutSizingH checked — no hardcoded width constant if FILL
- [ ] All MainAxisAlignment values read from primaryAxisAlignItems — not assumed from visual centering
- [ ] All CrossAxisAlignment values read from counterAxisAlignItems
- [ ] clipsContent checked — ClipRRect added only when true
- [ ] fills[].type checked — LinearGradient / RadialGradient used when not SOLID; check_token never called on a gradient-sampled hex
- [ ] imageScaleMode → BoxFit mapping applied; BoxFit.cover not defaulted without reading the field
- [ ] strokeWeight read and written as explicit `width:` on every Border — no bare `Border.all(color:)`
- [ ] textAlignHorizontal → TextAlign applied; never defaulted to left
- [ ] letterSpacing applied via `.copyWith` when non-zero
- [ ] maxLines and textTruncation mapped to overflow params — not inferred from sample content
- [ ] Component instance icons resolved to DS assets or flagged as gap — no guessed Material icons

**Gap ownership (Phase 3.5b) — every sibling gap traced to its direct parent**
- [ ] Gap ownership table built: each gap lists its direct parent frame and that frame's itemSpacing
- [ ] No gap assumed to inherit from an ancestor or sibling frame
- [ ] Auto-layout structure and gap ownership verified before any Flutter tree is drafted

**Effects (Phase 3.6)**
- [ ] All blur, shadow, and opacity effects read from node inventory — not estimated visually
- [ ] Blur sigma values match Figma exactly (1:1 mapping to `ImageFilter.blur`)
- [ ] fills[].opacity vs node.opacity correctly applied — fill opacity affects fill only, node opacity affects children too

**Token mapping (Phase 4) — every row has a Match column**
- [ ] Every text node has a named style (not raw numbers)
- [ ] Every fill/stroke has a variable binding traced to a Dart token
- [ ] Every spacing value has Match = EXACT, NEAREST, or NONE — no blank Match cells
- [ ] Every radius traced to `RadiusTokens.*`
- [ ] Every opacity traced to `OpacityTokens.*`
- [ ] Token mapping table written out before coding started
- [ ] All NEAREST and NONE matches use raw literals + gap comments — no silent rounding to nearest token
- [ ] Known documented gaps applied with workaround automatically — no re-asking the user for already-decided gaps
- [ ] All unknown gaps collected into a single batch review message and presented to user before Phase 5
- [ ] User has responded to the gap batch — no unknown gaps remain open

**Code**
- [ ] No `Colors.*`, hardcoded hex, or magic numbers (except documented NEAREST/NONE gaps with comments)
- [ ] All text styles use `TypographyScale.*` statics + `.copyWith(color: ...)`
- [ ] All interactive elements have `Semantics` labels
- [ ] All tappable targets ≥ 44dp

**Quality**
- [ ] `dart analyze packages/` → No issues found
- [ ] `dart tools/lint/check_ds_rules.dart` → ✅ DS lint passed
- [ ] `flutter test packages/tokens/` → All tests passed
- [ ] `melos run test:goldens` → All existing goldens pass (regression check)
- [ ] Golden tests written for the new component (every variant × state)
- [ ] State completeness cross-checked: every "Designed: Yes" row from Phase 2.75 has a corresponding golden test
- [ ] New goldens visually compared against Figma screenshot — not auto-accepted
- [ ] If component uses `ScapiaIcons.*`: verified icon renders visibly in Widgetbook (golden tests cannot catch SVG load failures)

**Catalog & connect**
- [ ] Widgetbook story added with Interactive + edge-case use-cases
- [ ] `knowledgebase/components/{component}.md` created/updated
- [ ] `packages/ds/figma/{component}.figma.js` created
- [ ] `melos run code-connect:publish` run — snippet renders in Figma Dev Mode
