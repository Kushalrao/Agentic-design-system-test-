# ADR 002 — ColorScale as ThemeExtension, not abstract final class

**Status:** Accepted  
**Date:** 2026-05-24  
**Updated:** 2026-05-29 — updated token names to Seasonal DLS

---

## Context

Tier 2 semantic tokens split into two forms at implementation time:
- `TypographyScale` and `SpacingScale` are `abstract final class` with static consts.
- `ColorScale` is a `ThemeExtension<ColorScale>` instantiated at runtime.

This asymmetry is intentional and warrants its own decision record.

---

## Decision

`ColorScale` is a Flutter `ThemeExtension<ColorScale>` registered on `ThemeData`.
It is accessed exclusively via:

```dart
final colors = Theme.of(context).extension<ColorScale>()!;
```

Typography and spacing tokens are `abstract final class` and accessed as static constants.

---

## Rationale

**Colors are theme-variable; spacing and typography are not.**

Spacing and typography do not change between light mode, dark mode, or a seasonal
sub-theme. `SpacingScale.spaceMd` is 9 dp regardless of theme. An `abstract final
class` with static consts is the simplest structure that cannot be instantiated
incorrectly.

Colors *do* change between themes. `backgroundPrimary` is white in light mode and
a dark neutral in dark mode. If `ColorScale` were a static class, switching themes
would require injecting a `ThemeMode` parameter into every widget tree or running
a global state mutation — both fragile.

`ThemeExtension<T>` is Flutter's built-in mechanism for exactly this: attaching
additional typed data to `ThemeData` that propagates via `Theme.of(context)`.
The `copyWith` and `lerp` methods enable smooth animated theme transitions as a
side effect, at no extra implementation cost.

**Future-proofing for dark mode and seasonal themes.**

When a dark mode is added, only two things change:
1. Add `static const dark = ColorScale(backgroundPrimary: ColorPrimitives.neutralGrey900, ...)` to `color_scale.dart`.
2. Swap the extension in `ScapiaTheme.dark()`.

Zero widget changes needed. The same applies to a seasonal theme (e.g. Diwali,
Summer) — swap the extension, not the widgets.

---

## Rejected alternatives

**Static ColorScale class** — Cannot be swapped at runtime without touching every
widget. Dark mode would require either prop-drilling a `ThemeMode` flag or a
separate global reactive state system.

**InheritedWidget / Provider** — More explicit than `ThemeExtension` but requires
additional boilerplate and does not integrate cleanly with `AnimatedTheme` /
`ThemeData.lerp`.

**Multiple separate static classes (LightColors, DarkColors)** — Forces widgets
to know which class to import. Defeats the point of semantic abstraction.

---

## Consequences

- Widget authors call `Theme.of(context).extension<ColorScale>()!` — the `!` is
  intentional. If `ColorScale` is not registered, the app should fail loudly rather
  than silently painting with wrong/missing colors. The extension must be present in
  every `ThemeData` used in the app and in tests.
- Golden tests must wrap widgets in a `MaterialApp` (or equivalent) that registers
  `ColorScale.light` — a bare `Widget` render will throw.
- The `lerp` method on `ColorScale` enables `AnimatedTheme` transitions. It is
  generated boilerplate — do not optimize it away.
- `Tier 3` component tokens (`ButtonTokens`) also depend on `ColorScale` via
  `BuildContext` — they must be called within the widget tree, not at class level.
