# Skill: ds

The **Design System Worker** — entry point for all DS maintenance tasks.

Invoked as: `/ds <task>`

---

## Who this skill is for

This skill is for **DS team members working on the design system itself** — tokens, foundations, architecture. It is NOT for product engineers building product UI with the DS. If you're implementing a product component, use `/implement-figma-component` instead.

---

## What it handles

Describe what you need to do. The skill routes to the right sub-procedure:

| Task | Sub-procedure |
|---|---|
| Add a new token (color, spacing, typography, radius, opacity) | → [Add Token](#add-token) |
| Resolve a documented gap in the DS | → [Resolve Gap](#resolve-gap) |
| Sync all tokens from Figma after a Figma variable change | → [Sync Tokens](#sync-tokens) |

---

## Context (always load first)

Before any sub-procedure, read:
- `knowledgebase/decisions/001-two-tier-token-architecture.md`
- `knowledgebase/decisions/002-color-scale-as-theme-extension.md`
- The relevant foundation file for the token type being changed

These are the ADRs that protect the architecture. DS maintenance tasks are exactly the context they were written for.

---

---

## Sub-procedure: Add Token

### When to use
A designer has added a new variable in Figma, or a token gap has been formally decided to become a real token.

### Phase 1 — Identify tier and type

Answer these before touching any file:

1. **Tier 1 or Tier 2?**
   - Tier 1: raw value (a new primitive color, a new spacing step, a new font size) — goes in `ColorPrimitives`, `Foundation`, `SpacingPrimitives`, `RadiusTokens`, or `OpacityTokens`
   - Tier 2: semantic alias (a new intent, e.g. `surfaceOverlay`) — references a Tier 1 value, goes in `ColorScale`, `TypographyScale`, or `SpacingScale`
   - Never skip Tier 1 to create a hardcoded Tier 2 value

2. **What type?** Color / Spacing / Typography / Radius / Opacity

3. **Does this resolve a documented gap?** Check `knowledgebase/foundations/color.md` (gap registry) and component docs before adding a brand new token — the value may already be needed elsewhere.

### Phase 2 — Add to Figma

Open Figma Desktop with the Desktop Bridge plugin running.

- Add the variable to the correct collection and tier in Seasonal DLS
- For Tier 2: make it an alias of the Tier 1 variable — never a hardcoded value
- Name it using the existing naming convention:
  - Colors: `Color Semantics / Group / Name`
  - Spacing: `Containers / Spacing / Value`
  - Radius: `Containers / Radius / Value`

### Phase 3 — Sync to Dart

```bash
melos run tokens
dart analyze packages/
flutter test packages/tokens/
```

All three must pass before continuing. If the pipeline doesn't pick up the new variable, add it manually to the correct Dart file following the existing pattern.

### Phase 4 — Update the Dart token file

For **Tier 1**: add the constant to the appropriate class (`ColorPrimitives`, `Foundation`, etc.)

For **Tier 2 color** (`ColorScale`):
- Add the field to the class
- Add to the `light` static constant referencing the Tier 1 primitive
- Add to `copyWith` and `lerp`

For **Tier 2 typography** (`TypographyScale`):
- Add both the raw numeric constants AND a pre-built `TextStyle` static
- The `TextStyle` static must include `leadingDistribution: TextLeadingDistribution.even` and `decoration: TextDecoration.none`
- Name the static to match the Figma text style name

For **Tier 2 spacing** (`SpacingScale`):
- Add the semantic alias referencing the `SpacingPrimitives` constant

### Phase 5 — Update tests

Open `packages/tokens/test/tokens_test.dart`. Add a test asserting:
- The new Tier 1 value is non-zero / non-empty
- The new Tier 2 alias resolves to the correct Tier 1 value

Run `flutter test packages/tokens/` — all tests must pass.

### Phase 6 — Update knowledgebase

Update the relevant foundation file:
- New color token → add to the correct group table in `knowledgebase/foundations/color.md` with intent description
- If resolving a gap → remove from the gap registry and add to the appropriate token group
- New spacing step → add to the scale table in `knowledgebase/foundations/spacing.md`
- New text style → add to the catalogue in `knowledgebase/foundations/typography.md`

### Phase 7 — Check component gaps

Search `packages/ds/` for any `// Gap:` comments referencing the value you just added. Update those call sites to use the new token and remove the gap comments.

---

---

## Sub-procedure: Resolve Gap

### When to use
A `// Gap:` comment exists in a component, the gap has been formally reviewed, and the decision is to add a real token (not just keep the workaround).

**Run [Add Token](#add-token) first to create the token, then:**

1. Find all `// Gap:` comments referencing this value across `packages/ds/`
2. Replace each workaround with the new token
3. Remove the `// Gap:` comment
4. Update `knowledgebase/components/{component}.md` — remove from gaps section, add to token usage table
5. Remove from gap registry in `knowledgebase/foundations/color.md`
6. Run `dart analyze packages/` and `flutter test packages/tokens/`

---

---

## Sub-procedure: Sync Tokens

### When to use
A designer has changed variable values or names in Figma Seasonal DLS, and the Dart token files need to reflect those changes.

1. Open Figma Desktop + Desktop Bridge plugin
2. Verify the changes in the Figma variables panel
3. Run the pipeline:
   ```bash
   melos run tokens
   dart analyze packages/
   flutter test packages/tokens/
   ```
4. If token names changed: search `packages/ds/` for any usages of old names, update them
5. Update affected knowledgebase foundation files with new values
6. If any component docs reference the old values, update them
7. Commit with: `chore: sync tokens from Figma — <brief description of what changed>`
