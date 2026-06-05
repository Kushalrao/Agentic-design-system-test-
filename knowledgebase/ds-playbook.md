# Seasonal DLS — System Playbook

> How the design system is set up, what is done, and what happens end-to-end when a Figma component link is given today.

---

## 1. What we set up in Figma

### 1.1 Code syntax on variables (one-time setup, June 2026)

Every design variable in Figma now has a Dart code syntax annotation registered against it. This is the most important setup step — it makes the Figma MCP server output actual Dart token strings instead of raw hex or dp values.

**How it was done:**
In Figma Desktop → Local Variables → each variable → `···` → Edit → Code syntax → platform: **Android** (the closest platform category to Flutter/Dart in Figma's current UI).

**What was registered (55 variables across 5 collections):**

| Collection | Variables | Example annotation |
|---|---|---|
| `Containers / Spacing` | 17 (0 dp → 115 dp) | `Spacing/15` → `SpacingScale.spaceLg` |
| `Containers / Radius` | 10 (4 dp → 44 dp) | `Radius/20` → `RadiusTokens.r20` |
| `Containers / Opacity` | 11 (0% → 100%) | `Opacity/40` → `OpacityTokens.opacity40` |
| `Color Semantics` | 13 (brand, feedback, surface) | `Surface/Background/Primary` → `colors.backgroundPrimary` |
| `Button` | 4 (orange + black, bg + label) | `Primary/Orange/Background` → `ButtonTokens.primaryOrangeBackground(context)` |

**What was NOT registered (and why):**

| Collection | Reason |
|---|---|
| `Colors` (60 Tier 1 primitives) | Raw hex palette — widgets never reference these directly |
| `Typography` (41 font primitives) | Tier 1 — used internally by TypographyScale, not in widgets |
| `Border/1`, `Border/2`, `Spacing/17`, `size/icon/*` | No Dart token class exists yet — documented as gaps |

**What this changes for agents:**
Before registration, the MCP sent `"15 dp"` and the agent had to call `get_spacing_token(15)`, look it up, and pick `SpacingScale.spaceLg`. Now the MCP sends `"SpacingScale.spaceLg"` directly. The entire Phase 3b/4 token lookup for spacing, radius, opacity, color, and button tokens is replaced by a direct string the agent reads and uses as-is.

### 1.2 Text styles — code syntax not available via UI

Figma's code syntax UI is variables-only. Text styles (P-Small, Hd-Small, etc.) cannot have code syntax registered through the Figma editor. This is a platform limitation.

**How it's handled instead:** Our DS MCP server has a `get_typography_style(figmaName)` tool that maps style names to Dart statics. The agent calls this in Phase 1. The style naming matches exactly: Figma `P-Medium` → `TypographyScale.pMedium`.

### 1.3 Code Connect definition files

Two components have Code Connect files registered (`packages/ds/figma/*.figma.js`). These surface Dart snippets in Figma Dev Mode when a designer or developer inspects a component:

| Component | Figma node | File |
|---|---|---|
| `StaysSrpCard` | Alt Stays › SRP (2608:5110) | `stays_srp_card.figma.js` |
| `StaysPropertyCard` | Alt Stays › Hotel review (2675:5319) | `stays_property_card.figma.js` |

**Current state:** Both snippets are static — they show a representative usage example. Neither Figma component has component properties defined (both are STATIC FRAME classification — see Section 5), so dynamic prop wiring is not yet possible.

Each `.figma.js` file now contains a commented upgrade path showing exactly which `figma.enum()` and `figma.boolean()` calls to add once Figma properties are defined. When properties are added in Figma, the upgrade is a matter of uncommenting and publishing.

---

## 2. What is built in code

### 2.1 Three-tier token architecture (`packages/tokens/`)

The token system mirrors Figma's variable collections exactly. Three tiers, strict rules about which tier is used where.

```
Tier 1 — Primitives (raw values, never used in widget code)
├── color_primitives.dart   60 raw hex colors (6 families × 10 shades)
├── foundation.dart         Font families, sizes, weights, line heights
├── spacing_primitives.dart Raw dp values (0–115 dp)
├── radius_tokens.dart      Named radii: r4 r8 r12 r16 r20 r24 r32 r36 r40 r44 full
└── opacity_tokens.dart     opacity0 → opacity100

Tier 2 — Semantic aliases (what widgets use)
├── color_scale.dart        ColorScale ThemeExtension — 13 semantic fields
├── typography_scale.dart   21 TextStyle statics matching Figma style names exactly
└── spacing_scale.dart      SpacingScale — 17 named gaps (spaceNone → space10xl)

Tier 3 — Component tokens (context-dependent)
└── button_tokens.dart      ButtonTokens — 4 context functions (orange/black × bg/label)
```

**The alias chain mirrors Figma:**
`Figma variable → Tier 1 primitive → Tier 2 semantic → widget code`

For example:
```
Figma: Color Semantics / Surface / Background / Primary
  → ColorPrimitives.neutralGrey000  (#FFFFFF, Tier 1)
  → ColorScale.backgroundPrimary    (Tier 2 — what widgets access)
  → Theme.of(context).extension<ColorScale>()!.backgroundPrimary
```

### 2.2 Components built (`packages/ds/lib/src/components/`)

| Component | File | Figma source | Status |
|---|---|---|---|
| `DsButton` | `button/ds_button.dart` | Seasonal DLS | ✅ Complete |
| `StaysSrpCard` | `stays/stays_srp_card.dart` | Alt Stays SRP (2608:5110) | ✅ Complete |
| `StaysPropertyCard` | `stays/stays_property_card.dart` | Alt Stays Hotel review (2675:5319) | ✅ Complete |

All three are exported from `packages/ds/lib/scapia_ds.dart` — the single import point for the product app.

### 2.3 Golden test suite (`packages/ds/test/`)

Every component has golden tests covering all variants and states. Goldens are generated by Flutter test with system fonts (network images don't load in test) and manually compared against Figma screenshots before being committed.

| Component | Test file | Golden count |
|---|---|---|
| `DsButton` | `button/ds_button_test.dart` | 14 (3 variants × 3 states + edge cases) |
| `StaysPropertyCard` | `stays/stays_property_card_test.dart` | 6 (full spec, no rating, no amenities, no view-all, long name, no overflow) |

### 2.4 Widgetbook catalog (`packages/ds/widgetbook/`)

Interactive component catalog running in Chrome. Every component has:
- **Interactive** use case — all knobs wired to constructor params
- **Fixed spec** use case — exact Figma example
- **Edge cases** — long text, broken image, empty state

Launch: `melos run widgetbook` → opens Chrome.

### 2.5 DS lint scanner (`tools/lint/check_ds_rules.dart`)

Runs in CI (`dart tools/lint/check_ds_rules.dart`). Six rules:

| Rule | What it catches |
|---|---|
| `no_hardcoded_color` | `Color(0xFF...)` literals — must use `ColorScale` |
| `no_flutter_colors` | `Colors.*` — banned entirely |
| `no_tier1_in_widgets` | `ColorPrimitives.*`, `Foundation.*`, `SpacingPrimitives.*` in widget files |
| `no_inline_text_style` | `TextStyle(fontSize: N)` raw assembly — must use `TypographyScale.*` |
| `no_bare_border` | `Border.all(color: ...)` without `width:` — stroke weight must be explicit |
| `no_raw_spacing_literal` | `SizedBox`/`EdgeInsets` with a raw number that matches a `SpacingScale` value |

Lines with `// Gap:` are automatically exempt from spacing rules (documented sub-token values are allowed). Lines with `// ds-lint-ignore: rulename` are exempt from that specific rule.

---

## 3. Skills and files — who accesses what

### 3.1 The MCP servers

Three MCP servers are active in this project. Each has a different role:

**`ds` MCP** — Seasonal DLS knowledge server
- Auto-regenerates its snapshot on startup if source token files have changed
- Tools agents call during component implementation:
  - `list_components()` — reuse check before writing any code
  - `get_component(name)` — full detail on an existing component
  - `check_token(hex)` — is this hex in Tier 2? Returns token + `doNotUseFor`
  - `get_color_guidance(tokenName)` — pairing rules, depth model, interactive states
  - `get_typography_style(figmaName)` — maps Figma style name → `TypographyScale.*` static
  - `get_typography_guidance(figmaName)` — decision table for similar styles
  - `get_spacing_token(valueDp)` — maps dp value → `SpacingScale.*` token
  - `get_spacing_recipe(pattern)` — composition recipe for layout patterns
  - `get_radius_token(valueDp)` — maps dp value → `RadiusTokens.*`

**`figma` MCP** — Figma REST API
- Used when Desktop Bridge is not available
- Key tools:
  - `get_design_context` — full node tree with all properties, text styles, fills (primary design fetch)
  - `get_context_for_code_connect` — component properties and variant structure
  - `get_screenshot` — Figma node screenshot for visual comparison

**`figma-console` MCP** — Figma Desktop Bridge (Southleft)
- Requires Desktop Bridge plugin open in Figma Desktop
- Preferred over REST when available — returns live variable values
- Key tools:
  - `figma_get_text_styles` — all local text styles (Phase 1 source of truth)
  - `figma_get_variables` — all variables with resolved values across all collections

**Hard blocks:** If `figma_get_text_styles` or `figma_get_variables` returns empty, the agent stops and surfaces an error. It does not fall back to estimating values.

### 3.2 The skill (`implement-figma-component`)

Invoked with `/implement-figma-component <figma-url>`. Lives at `.claude/commands/implement-figma-component.md`.

The skill is a multi-phase procedure that enforces the correct order: **classify → fetch everything → exhaust the MCP response → map the full variant system → write → test → connect**. It encodes 26 named failure modes and contains mandatory output tables at each phase that the agent must populate before proceeding to the next.

The skill has two execution paths that branch at Phase 2.5:
- **STATIC FRAME path** — component has no Figma properties defined. Fetches one node. Produces a static Code Connect snippet.
- **COMPONENT WITH PROPERTIES path** — component has Figma properties (VARIANT, BOOLEAN, TEXT). Fetches all meaningful variants. Produces a differential token table. Code Connect snippet documents the upgrade path to `figma.enum`/`figma.boolean` once properties are verified.

**Key files the skill reads:**
- `knowledgebase/foundations/` (color, typography, spacing, quality) — loaded before any node data is fetched
- `packages/tokens/lib/src/` (all 9 token files) — loaded to know what already exists
- `knowledgebase/components/{name}.md` — loaded if the component already exists

**Key files the skill writes:**
- `packages/ds/lib/src/components/{category}/{name}.dart` — the widget
- `packages/ds/lib/scapia_ds.dart` — adds the export
- `packages/ds/widgetbook/lib/components/{name}_story.dart` — Widgetbook story
- `packages/ds/widgetbook/lib/main.dart` — registers the story
- `packages/ds/test/components/{category}/{name}_test.dart` — golden tests
- `packages/ds/figma/{name}.figma.js` — Code Connect definition
- `knowledgebase/components/{name}.md` — knowledgebase doc

### 3.3 The knowledgebase

```
knowledgebase/
├── foundations/
│   ├── color.md         Semantic color intent, pairing rules, depth model, known gaps
│   ├── typography.md    Type hierarchy, when to use each style, DO/DON'T
│   ├── spacing.md       Composition recipes, layout patterns, token selection guidance
│   └── quality.md       Widget authoring checklist — 30+ checks across 7 categories
├── components/
│   ├── ds_button.md         API contract, token usage, gaps
│   ├── stays_srp_card.md    API contract, token usage, gaps, 9 known gaps documented
│   └── stays_property_card.md  API contract, token usage, gaps
└── decisions/
    (ADRs for architectural choices — loaded only when modifying token architecture)
```

The foundation files are loaded at the start of every component build. The component files are loaded if the component already exists. Decision files are not loaded during normal component work.

---

## 4. What happens when a component link is given today

End-to-end walkthrough when you run `/implement-figma-component https://figma.com/design/...?node-id=X-Y`.

### Phase 0 — Load context
Agent reads all four foundation files + all nine token files. Full DS ruleset and complete token picture before any Figma data is fetched.

### Phase 0.5 — Reuse check
Two calls in parallel:
1. `list_components()` on ds MCP → checks Dart component registry
2. `get_code_connect_map` on the node URL → checks for an existing Code Connect mapping with a snippet

If either returns a match, agent proposes reuse instead of rebuilding.

### Phase 1 — Fetch text styles *(hard block if empty)*
Calls `figma_get_text_styles` via Desktop Bridge. If it returns zero styles, execution stops — Desktop Bridge must be open. No fallback, no estimation.

Resolves every style name → `TypographyScale.*` via `get_typography_style()`.

### Phase 2 — Fetch variables *(hard block if empty)*
Calls `figma_get_variables`. If it returns zero variables, execution stops.

Because code syntax is registered on all 55 variables, this table is populated by reading the `codeSyntax` field directly — the MCP emits `SpacingScale.spaceLg` instead of `15 dp`. No `get_spacing_token()` calls needed for registered values.

### Phase 2.5 — Component structure analysis *(classification step — drives everything downstream)*

Calls `get_context_for_code_connect` on the node URL. Three steps:

**Step 2.5A — Root properties → constructor API**
Every entry in root `properties` maps directly to a Dart constructor param: VARIANT → `enum`, BOOLEAN → `bool` or `VoidCallback?`, TEXT → `String`.

**Step 2.5B — Nested INSTANCE traversal → internal implementation choices**
Walks every `descendants` entry. Any `INSTANCE` with non-empty `properties` is recorded separately — these are not constructor params, they are implementation choices inside the widget body. Icon instances with VARIANT options (`arrow-right`, `map-pin`) tell the agent which icon to render at each node. All unresolved options go to the gap batch. Visual guessing is banned.

**Step 2.5C — Classification**
The response produces a typed result that determines which phases run next:

| Classification | Condition | Phase 2.6 | Phase 3 fetches |
|---|---|---|---|
| **STATIC FRAME** | `properties: {}`, no INSTANCE descendants with properties | Skip | URL node only |
| **FRAME WITH NESTED INSTANCES** | `properties: {}` but some INSTANCE descendants have properties | Skip | URL node only, nested instances noted |
| **COMPONENT WITH PROPERTIES** | root `properties` non-empty | Run | All meaningful variants from Phase 2.6 |

Both existing components (`StaysSrpCard`, `StaysPropertyCard`) classify as **STATIC FRAME** — no Figma component properties are defined yet. This is documented in their knowledgebase files under "Figma limitations."

### Phase 2.6 — Variant matrix *(COMPONENT WITH PROPERTIES path only)*

Calls `get_context_for_code_connect` on the **COMPONENT_SET parent** to get the full property × options set — not just the URL frame's properties. Builds two tables:

**Variant matrix** — all properties the component exposes, mapped to Dart types:
| Property | Options | Dart type |
|---|---|---|
| `Variant` | `primary / dark / ghost` | `enum DsXVariant` |
| `State` | `default / disabled / loading` | `bool isDisabled`, `bool isLoading` |

**Variant node ID table** — which combinations exist in Figma and which to fetch in Phase 3:
| Combination | Node ID | Fetch? |
|---|---|---|
| primary / default | 123:456 | ✓ base case |
| primary / disabled | 123:458 | ✓ tokens differ |
| dark / default | 123:462 | ✓ tokens differ |
| dark / disabled | 123:464 | Skip — identical tokens to primary/disabled |

Only variants that introduce visual token differences are fetched. TEXT-only differences are skipped.

### Phase 2.75 — Pre-flight: scope and state completeness
- Lists all designed states (default, disabled, loading, error, empty) — any designed but out of scope documented as a gap
- Decides `StatelessWidget` vs `StatefulWidget`

### Phase 3 — Fetch design context + build node inventory

**STATIC FRAME path:** Calls `get_design_context` once on the URL node. Builds the single-node inventory.

**COMPONENT WITH PROPERTIES path:** Calls `get_design_context` once per variant marked "Fetch" in Phase 2.6. Then builds two inventories:

1. **Single-node inventory** (base variant) — 22-column frame table, per-child sizing, text nodes, image/icon nodes. Every field copied verbatim from MCP JSON — never estimated, never retyped from memory.

2. **Comparative inventory** (Step 3c) — one column per fetched variant, one row per visual property. Every cell from the corresponding `get_design_context` response. Each row then marked:
   - **[S] Structural** — all cells identical across variants → implement once
   - **[D] Differential** — any cell differs → implement conditionally

The node inventory covers: dimensions (`width`, `height` from `absoluteBoundingBox`), layout (`layoutMode`, `layoutSizingH/V`), alignment (`primaryAxisAlign`, `counterAxisAlign`), spacing (`paddingL/R/T/B`, `itemSpacing`), visual (`cornerRadius`, `clipsContent`, `strokeWeight`, `strokeAlign`), fill (`fills[].type` — SOLID vs GRADIENT), opacity (`fills[].opacity` fill-level vs `node.opacity` layer-level), and text properties (`textAlignHorizontal`, `letterSpacing`, `maxLines`, `textTruncation`).

### Phase 3.5 — Layout mapping
Seven lookup tables translate every inventory field to Flutter: `layoutMode` → `Row/Column/Stack`, alignments → `MainAxisAlignment`/`CrossAxisAlignment`, `clipsContent` → whether `ClipRRect` is added, `fills[].type` → `Color`/`LinearGradient`, `imageScaleMode` → `BoxFit`, `strokeWeight`/`strokeAlign` → `Border.all(width: N, ...)`.

Gap ownership table: every gap between siblings traces to its direct parent frame's `itemSpacing`. Two visually similar gaps owned by different parent frames have different values — made explicit before any code is written.

### Phase 4 — Token mapping + gap batch

**Structural table** (from [S] rows) — one row per constant property, one token per row. These go directly into the widget body.

**Differential table** (from [D] rows, COMPONENT WITH PROPERTIES only) — one column per variant, one token per cell, one Dart pattern per row (`switch (variant)`, `if (isDisabled)`, etc.). This table is the direct source for all conditional logic in `build()`.

**Match column applies to every cell:** EXACT (Figma dp = token dp → use token), NEAREST or NONE (raw literal + `// Gap:` comment). Because 55 variables now have code syntax registered, most cells arrive as EXACT from the MCP response.

All NEAREST/NONE cells and unresolved nested instance options collect into a single **gap batch**, presented to the user at the end of Phase 4 before any code is written.

### Phase 5 — Write the component
Pre-checks: widget base class confirmed, root sizing confirmed (no hardcoded width if `layoutSizingH = FILL`).

**All token values must be traceable to a cell in the structural or differential table.** Any value in `build()` that cannot be traced back was assumed — assumptions are removed and added to the tables first.

[S] structural values → implemented once, unconditionally.
[D] differential values → implemented as `switch`/`if` expressions driven by constructor params.

All code follows the tier contract (ColorScale, TypographyScale, SpacingScale, RadiusTokens, OpacityTokens).

### Phase 6 — Validate (4 gates, must all pass)
```
dart analyze packages/               # syntax + type errors
dart tools/lint/check_ds_rules.dart  # 6 DS token rules
flutter test packages/tokens/        # alias chain + tier contract
melos run test:goldens               # regression against existing goldens
```

### Phase 7 — Document
`knowledgebase/components/{name}.md` created with API table, typography map, token usage table, gap decisions.

For COMPONENT WITH PROPERTIES: also includes variant matrix and differential token table.
For STATIC FRAME: includes "Figma limitations" section listing which properties would need to be added to enable dynamic wiring.

### Phase 8 — Golden tests
Golden test list derived from the variant matrix (COMPONENT WITH PROPERTIES) or the designed-states table (STATIC FRAME) — never invented by the agent. Every designed state must have a golden before `--update-goldens` runs. Goldens are visually compared against Figma screenshots, not auto-accepted.

### Phase 9 — Code Connect
`packages/ds/figma/{name}.figma.js` created and published. For COMPONENT WITH PROPERTIES, the file includes a commented upgrade path showing the exact `figma.enum()`/`figma.boolean()` calls to activate once properties are verified in Dev Mode.

---

## 5. Known gaps in the current setup

| Gap | Impact | Plan |
|---|---|---|
| Both existing components are STATIC FRAME (no Figma properties) | No dynamic Code Connect wiring, no variant matrix, no differential table | Add component properties in Figma for each component — then the COMPONENT WITH PROPERTIES path activates automatically |
| `INSTANCE[Icon]` in `StaysSrpCard` has unresolved variant options (`arrow-right`, `map-pin`) | Icon choices were originally guessed as Material icons; now tracked in nested instance table but not fully resolved to DS assets | Create a custom icon resolution guide when the DS icon library is established |
| Text style code syntax not registerable via Figma UI | Typography mapping still requires `get_typography_style()` tool call | Acceptable — naming parity is exact, one extra MCP call |
| `Border/1`, `Border/2` — no Dart token class | Raw `1.0`/`2.0` with gap comments in code | Create `BorderTokens` when a third component uses these |
| `Spacing/17` — no `SpacingScale` token | Falls between `spaceLg` (15) and `spaceXl` (21), documented as NONE gap | Add token if it appears in 3+ components |
| `size/icon/md`, `size/icon/lg` — no Dart token class | Icon sizes hardcoded | Create `IconTokens` when custom icon resolution is built |
| Figma-to-live visual comparison | No automated pixel-diff between Figma frames and running app | Applitools (paid) is the only verified solution; manual review today |
| `get_variable_defs` returns default mode only | Light mode values only; dark mode tokens not surfaced via MCP | Affects future dark mode implementation |

---

## 6. Commands reference

```bash
# Token pipeline
melos run tokens                 # Figma snapshot → Dart token files

# Development
melos run widgetbook             # Launch Widgetbook catalog in Chrome

# Validation
dart analyze packages/ apps/     # Full workspace lint
dart tools/lint/check_ds_rules.dart  # DS token tier rules
flutter test packages/tokens/   # Token alias chain contract
melos run test:goldens           # All golden tests (regression)
flutter test packages/ds/test/components/{dir}/ --update-goldens  # Regenerate goldens

# Code Connect
melos run code-connect:check     # Validate definitions without publishing
melos run code-connect:publish   # Publish to Figma Dev Mode (needs FIGMA_ACCESS_TOKEN)
```
