# Typography

> Hierarchy guide — when to use each type style.
> Load this file before setting any text style in a widget.

---

## Font

Primary font is **Lexend Deca** (`Foundation.fontFamilyLexendDeca`). Two display
fonts are also available for brand moments: `Foundation.fontFamilyGtUltraMedian`
and `Foundation.fontFamilyGtFlaire`.

The font is registered via `ScapiaTheme.light()` on `ThemeData.fontFamily`. Do not
pass `fontFamily` inside individual `TextStyle` calls — it is inherited from the theme.

---

## Style hierarchy

| Style | Size | Weight | Line height | Use when |
|---|---|---|---|---|
| `display` | 47 dp | 700 bold | 63 | Hero statement, full-screen takeover, campaign headline |
| `headingXl` | 41 dp | 700 bold | 55 | Screen-level hero heading |
| `headingLg` | 35 dp | 700 bold | 47 | Page title, primary screen header |
| `headingMd` | 29 dp | 700 bold | 39 | Section heading, modal title |
| `headingSm` | 25 dp | 700 bold | 35 | Card heading, group label, dialog title |
| `titleLg` | 23 dp | 600 semibold | 29 | Sub-section title, collapsible header |
| `titleMd` | 19 dp | 600 semibold | 27 | Button label, prominent CTA, list item title |
| `bodyLg` | 17 dp | 500 medium | 25 | Primary body text, form field value |
| `bodyMd` | 15 dp | 500 medium | 23 | Supporting body text, list item subtitle, helper text |
| `caption` | 13 dp | 400 regular | 21 | Metadata, timestamp, category label, fine print |
| `captionSm` | 12 dp | 400 regular | 19 | Legal copy, overline, reference IDs |

---

## How to build a TextStyle

`TypographyScale` exposes only the numeric constants — assemble them into a
`TextStyle` at the widget level.

```dart
import 'package:scapia_tokens/scapia_tokens.dart';

// Correct — compose from TypographyScale tokens
TextStyle(
  fontSize:   TypographyScale.bodyLgSize,            // 17
  fontWeight: FontWeight.w500,                        // == bodyLgWeight
  height:     TypographyScale.bodyLgLineheight /
              TypographyScale.bodyLgSize,             // Flutter height multiplier
)

// Wrong — hardcoded values
TextStyle(fontSize: 17, fontWeight: FontWeight.w500)
```

> **FontWeight map:** `Foundation.fontWeightRegular` (400) → `FontWeight.w400`,
> `fontWeightMedium` (500) → `FontWeight.w500`, `fontWeightSemibold` (600) →
> `FontWeight.w600`, `fontWeightBold` (700) → `FontWeight.w700`,
> `fontWeightExtrabold` (800) → `FontWeight.w800`, `fontWeightBlack` (900) → `FontWeight.w900`.

> **Line height in Flutter:** Flutter's `TextStyle.height` is a multiplier over
> `fontSize`. Convert: `height = lineheight / fontSize`.
> Example: `titleMd` → `27 / 19 = 1.42`.

---

## Usage rules by style

### `display` / `headingXl` / `headingLg` — impact moments

Large headline styles for hero screens, onboarding, and campaign pages. Use sparingly:
- `display` (47): full-screen takeover or brand splash — one per screen, max.
- `headingXl` (41): opening hero of an important screen.
- `headingLg` (35): the primary heading of a standard screen.

### `headingMd` / `headingSm` — structural hierarchy

- `headingMd` (29): section headings within a scrollable screen or modal.
- `headingSm` (25): card headings, group labels, dialog titles.

### `titleLg` / `titleMd` — interactive and action text

- `titleLg` (23): sub-section or collapsible headers.
- `titleMd` (19): **button labels**, CTAs, prominent interactive text.

### `bodyLg` / `bodyMd` — readable prose

- `bodyLg` (17): primary body copy, form field values — default for most readable text.
- `bodyMd` (15): secondary detail — subtitles, helper text, descriptions.

### `caption` / `captionSm` — metadata

- `caption` (13): timestamps, categories, transaction IDs, short metadata.
- `captionSm` (12): legal text, overlines, reference codes.

---

## Color pairing

Typography tokens carry no color. Always supply color from `ColorScale`:

| Context | Color token |
|---|---|
| Default body text | `contentPrimary` |
| Supporting / secondary text | `contentSecondary` |
| Disabled / placeholder text | `contentTertiary` |
| Text on brand orange or dark navy fill | `backgroundPrimary` (white) |
| Feedback / error message | `feedbackNegative` |
| Feedback / success label | `feedbackPositive` |
| Feedback / warning label | `feedbackWarning` |

---

## DO / DON'T

```dart
// DO — list tile with correct hierarchy
ListTile(
  title: Text(merchantName, style: TextStyle(
    fontSize:   TypographyScale.bodyLgSize,
    fontWeight: FontWeight.w500,
    height:     TypographyScale.bodyLgLineheight / TypographyScale.bodyLgSize,
    color:      colors.contentPrimary,
  )),
  subtitle: Text(dateString, style: TextStyle(
    fontSize:   TypographyScale.captionSize,
    fontWeight: FontWeight.w400,
    height:     TypographyScale.captionLineheight / TypographyScale.captionSize,
    color:      colors.contentSecondary,
  )),
)

// DON'T — mixed hardcoded and token values
ListTile(
  title: Text(merchantName, style: TextStyle(fontSize: 17)),
  subtitle: Text(dateString, style: TextStyle(fontSize: 12, color: Colors.grey)),
)
```
