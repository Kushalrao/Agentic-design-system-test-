# Icons

> Load before using any icon in a widget. Every icon must come from the Seasonal DLS icon library — no `Icons.*` from Material, no guessed SVG names.

---

## The rule in one line

```dart
SvgPicture.asset(ScapiaIcons.hotelsKitchen25px, width: 25, height: 25)
```

Never use `Icons.*` from Flutter. Never guess an icon name from visual appearance. If an icon is not yet in `ScapiaIcons`, it is a gap — add it before writing the widget.

---

## Library facts

| Property | Value |
|---|---|
| Total icons | 17,582 (incl. ~3,222 duplicate names) |
| Sizes | **25px** (default), **19px**, **11px** |
| Format | SVG, flat single-path or multi-path |
| Figma source | [Seasonal DLS › Iconography](https://www.figma.com/design/FNq7xbMPO5wM5mM4EOo2hY/Seasonal-DLS?node-id=391-57) |
| Dart class | `ScapiaIcons` in `packages/ds/lib/src/icons/scapia_icons.dart` |
| Asset location | `packages/ds/assets/icons/{category-slug}/{keyword-slug}_{size}.svg` |

---

## Naming convention — Figma → file → Dart

The Figma component name is preserved exactly through the transformation. No renaming, no abbreviation.

**Transformation rules:**

| Step | Input | Output |
|---|---|---|
| Split on `/` | `Hotels/kitchen/ 25px` | `[Hotels, kitchen, 25px]` |
| Category slug | `Hotels` | `hotels` (lowercase, `, ` → `-`) |
| Keyword slug | `kitchen` | `kitchen` (lowercase, `, ` → `-`, trim) |
| Size | `25px` | `25px` |
| File path | — | `hotels/kitchen_25px.svg` |
| Dart constant | — | `hotelsKitchen25px` (camelCase of path) |

**Examples:**

| Figma component name | File path | Dart constant |
|---|---|---|
| `Hotels/kitchen/ 25px` | `hotels/kitchen_25px.svg` | `ScapiaIcons.hotelsKitchen25px` |
| `Hotels/Swimming, Pool/ 25px` | `hotels/swimming-pool_25px.svg` | `ScapiaIcons.hotelsSwimmingPool25px` |
| `Interface, Essential/WiFi/ 25px` | `interface-essential/wifi_25px.svg` | `ScapiaIcons.interfaceEssentialWifi25px` |
| `Interface, Essential/Arrow, Right/ 25px` | `interface-essential/arrow-right_25px.svg` | `ScapiaIcons.interfaceEssentialArrowRight25px` |
| `Navigation, Maps/Pin, Location, Direction/ 25px` | `navigation-maps/pin-location-direction_25px.svg` | `ScapiaIcons.navigationMapsPinLocationDirection25px` |
| `Navigation, Maps/Pin, Location/ 25px` | `navigation-maps/pin-location_25px.svg` | `ScapiaIcons.navigationMapsPinLocation25px` |
| `User/Users, Friends/ 25px` | `user/users-friends_25px.svg` | `ScapiaIcons.userUsersFriends25px` |
| `Interface, Essential/Star/ 25px` | `interface-essential/star_25px.svg` | `ScapiaIcons.interfaceEssentialStar25px` |

**Size variants follow the same pattern:**

```dart
ScapiaIcons.hotelsKitchen25px  // full size
ScapiaIcons.hotelsKitchen19px  // compact
ScapiaIcons.hotelsKitchen11px  // micro (if it exists in Figma)
```

---

## Asset directory structure

```
packages/ds/
  assets/
    icons/
      arrows-diagrams/
      hotels/
        kitchen_25px.svg
        swimming-pool_25px.svg
        ...
      interface-essential/
        wifi_25px.svg
        arrow-right_25px.svg
        star_25px.svg
        pin-location-circle_25px.svg
        ...
      navigation-maps/
        pin-location_25px.svg
        pin-location-direction_25px.svg
        ...
      user/
        users-friends_25px.svg
        user-profile_25px.svg
        ...
      ... (one folder per Figma category)
  lib/
    src/
      icons/
        scapia_icons.dart    ← all constants, generated or hand-maintained
```

`scapia_icons.dart` structure:
```dart
abstract final class ScapiaIcons {
  static const String hotelsKitchen25px =
      'packages/scapia_ds/assets/icons/hotels/kitchen_25px.svg';
  static const String hotelsSwimmingPool25px =
      'packages/scapia_ds/assets/icons/hotels/swimming-pool_25px.svg';
  // ...
}
```

---

## Duplicate handling

3,222 icon entries in Figma share a name with at least one other entry. When adding an icon that has duplicates, pick the canonical version and record its Figma node ID here:

| Dart constant | Canonical Figma node ID | Notes |
|---|---|---|
| `interfaceEssentialWifi25px` | `410:81506` | First occurrence of exact name |
| — | — | Add rows as icons are added |

---

## Categories available

```
Arrows, Diagrams          Baby, Children, Toys      Basic Shapes
Beauty                    Building, Construction     Business, Products
Cleaning, Housekeeping    Clothes, Accessories       Computers, Devices, Electronics
Content, Edit             Crypto Currency            Cursor, Select, Hand
Delivery                  Design, Tools              Emails
Fast Food, Drink          Files                      Folders
Food                      Fruits, Vegetables         Furniture
Geometric, Abstract       Holidays                   Hotels
Interface, Essential      Internet, Network, Cloud   Kitchen, Cooking
Landmarks, Places         Messages, Chat             Mobile, Devices
Money                     Music, Audio               Navigation, Maps
Outdoor, Park             Payments, Finance          Protection, Security
Restaurant, Cafe          Shopping, Ecommerce        Sport
Support, Help, Question   Technology, Space          Transportation
Travel                    User                       Video, Movies
Weather, Climate
```

---

## How to find an icon

1. Open [Figma Seasonal DLS › Iconography](https://www.figma.com/design/FNq7xbMPO5wM5mM4EOo2hY/Seasonal-DLS?node-id=391-57)
2. Search by keyword (e.g. "kitchen", "pin", "wifi")
3. Pick the 25px variant unless the design spec calls for 19px or 11px
4. If multiple icons match the keyword, pick the one whose full name most closely matches the design intent
5. Record the exact Figma component name → derive the file path and Dart constant using the transformation rules above
6. Export the SVG from Figma, place at the derived file path, add the constant to `ScapiaIcons`

---

## How agents resolve icons (Phase 2.5B)

When `get_context_for_code_connect` returns an `INSTANCE` descendant with `properties`:

1. Read the VARIANT option name (e.g. `arrow-right`, `map-pin`, `kitchen`)
2. Grep `scapia_icons.dart` for the keyword: `grep -i "kitchen" packages/ds/lib/src/icons/scapia_icons.dart | head -10`
3. Pick the constant whose `/// Figma:` comment best matches the design context (category + keywords)
4. Use `SvgPicture.asset(ScapiaIcons.{constant}, width: N, height: N, colorFilter: ColorFilter.mode(colors.X, BlendMode.srcIn))`
5. If grep returns zero results → icon is not in the library. Gap batch: designer must add it to Figma Iconography and re-run `melos run icons:export`
6. **Never** use `Icons.*` from Flutter as a substitute

---

## Current state — all icons pre-exported

All 13,751 unique icons from the Seasonal DLS Iconography page are exported and available. No manual registration required.

- **SVG files**: `packages/ds/assets/icons/{category}/{keywords}_{size}px.svg`
- **Dart constants**: `packages/ds/lib/src/icons/scapia_icons.dart` — 13,751 constants, 50 categories
- **To find an icon**: `grep -i "{keyword}" packages/ds/lib/src/icons/scapia_icons.dart`
- **To refresh** (after new icons added to Figma): `melos run icons:export`

---

## Known unresolved icon references

Icons referenced in existing Figma components whose variant option names don't directly match the Figma library naming convention. These use Material Icons as a temporary placeholder and carry a `// Gap:` comment in code.

| Component | INSTANCE variant option | Closest Figma library icon | Status |
|---|---|---|---|
| `StaysSrpCard` | `arrow-right` | `Interface, Essential/Arrow, Right/ 25px` | Not exported — Material placeholder |
| `StaysSrpCard` | `map-pin` | `Navigation, Maps/Pin, Location, Direction/ 25px` | Not exported — Material placeholder |
| `DsScapiaScore` | `Scapia score/ 11px` | `Scapia score/ 11px` (node 492:901) | ✅ Resolved — `ScapiaIcons.scapiaScoreScapiaScore11px` |

---

## flutter_svg constraints on Flutter web

`flutter_svg` 2.x uses the `vector_graphics` renderer, which reads SVG **presentation attributes** only. It does **not** support CSS inline styles. Violating these constraints causes the entire SVG to render blank — no error, no fallback, just nothing.

| Feature | Status | Fix |
|---|---|---|
| `style="mix-blend-mode:X"` | ❌ Not supported — silent blank render | Remove. Keep `opacity="N"` attribute instead. |
| `style="filter:..."` | ❌ Not supported | Remove. |
| `style="isolation:..."` | ❌ Not supported | Remove. |
| `linearGradient` | ✅ Supported | — |
| `radialGradient` | ✅ Supported | — |
| `clip-path` | ✅ Supported | — |
| `opacity="N"` (attribute) | ✅ Supported | Use this instead of CSS opacity. |

**The `export_icons.py` script automatically strips `style="..."` attributes from every downloaded SVG** via the `sanitize_svg()` function. Icons exported via Desktop Bridge manually must have this applied by hand or via re-running the script.

### Widgetbook asset declaration

The widgetbook is its own Flutter app. It does **not** automatically inherit `scapia_ds` package assets for development rendering. For icons to render in Widgetbook, `packages/ds/widgetbook/pubspec.yaml` must declare:

```yaml
flutter:
  assets:
    - assets/icons/
```

And the icon files must be present in `packages/ds/widgetbook/assets/icons/`. This is a one-time setup — already done.

The production app (`apps/app/`) depends on `scapia_ds` normally and accesses icons via the standard `packages/scapia_ds/assets/icons/...` path — no extra setup needed there.

---

## Flutter usage

```dart
import 'package:flutter_svg/flutter_svg.dart';
import 'package:scapia_ds/scapia_ds.dart';

// Standard usage — always specify explicit size
SvgPicture.asset(
  ScapiaIcons.hotelsKitchen25px,
  width: 25,
  height: 25,
  colorFilter: ColorFilter.mode(colors.contentSecondary, BlendMode.srcIn),
)

// DO NOT
Icon(Icons.kitchen_outlined)          // Material icon — banned in DS widgets
SvgPicture.asset('assets/icons/...')  // Raw string — use ScapiaIcons constant
```

The `colorFilter` approach allows icon color to be driven by `ColorScale` tokens — the SVG itself is monochrome.
