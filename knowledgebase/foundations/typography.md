# Typography

> Load before setting any text style in a widget.

---

## The rule in one line

```dart
// Every text in the DS looks like this — no exceptions
Text(label, style: TypographyScale.pMedium.copyWith(color: colors.contentPrimary))
```

Never assemble `TextStyle(fontSize:..., fontWeight:..., height:...)` from raw numbers. Always start from a named static.

---

## Font families

| Family | Token | Use when |
|---|---|---|
| **Lexend Deca** | `Foundation.fontFamilyLexendDeca` | Everything — UI, body, headings. Default via theme. |
| **GT Ultra Median** | `Foundation.fontFamilyGtUltraMedian` | Promo moments — campaign headlines, feature announcements |
| **GT Flaire** | `Foundation.fontFamilyGtFlaire` | High-impact display — hero takeovers, brand splash screens |

Lexend Deca is set on `ThemeData.fontFamily` in `ScapiaTheme.light()`. Do not pass it on individual `TextStyle` calls — it inherits. GT Ultra Median and GT Flaire must be set explicitly via the `Pr-*` and `Dp-*` statics (they include `fontFamily`).

---

## Style catalogue

Names match Figma text style names exactly. When the designer says "use P-Medium", you use `TypographyScale.pMedium`.

### P — Paragraph (Lexend Deca / Regular / w400)
Body copy. Reading-optimised. No emphasis.

| Static | Size | lh | Use when |
|---|---|---|---|
| `TypographyScale.pSmall` | 13 | 21 | Metadata, timestamps, transaction IDs, fine print |
| `TypographyScale.pMedium` | 15 | 23 | Supporting body — subtitles, helper text, card descriptions |
| `TypographyScale.pLarge` | 17 | 25 | Primary body copy, form field values |
| `TypographyScale.pExtra` | 19 | 29 | Elevated body — introductory paragraphs, featured descriptions |
| `TypographyScale.pMax` | 23 | 35 | Large prose, pull quotes |

### Shd — Sub-heading (Lexend Deca / Medium / w500)
Prominent labels. Not a heading, not plain body. Use for UI control labels and list item titles.

| Static | Size | lh | Use when |
|---|---|---|---|
| `TypographyScale.shdSmall` | 15 | 23 | List item title, chip text, tab label |
| `TypographyScale.shdMedium` | 17 | 23 | Card sub-title, section label, prominent list title |

### Hd — Heading (Lexend Deca / SemiBold–Bold)
Structural hierarchy. One heading level per section — do not stack two heading levels adjacent.

| Static | Size | Weight | lh | Use when |
|---|---|---|---|---|
| `TypographyScale.hdSmall` | 17 | 600 | 23 | Compact heading, inline action label |
| `TypographyScale.hdMedium` | 19 | 600 | 27 | **Button labels**, prominent CTAs, list item heading |
| `TypographyScale.hdLarge` | 23 | 700 | 35 | Sub-section title, collapsible header |
| `TypographyScale.hdExtra` | 27 | 700 | 39 | Section heading, modal title |
| `TypographyScale.hdMax` | 35 | 700 | 47 | Page title, primary screen header |
| `TypographyScale.hdRare` | 41 | 700 | 55 | Screen-level hero heading |

### Lb — Label (Lexend Deca / Regular / w400)
Compact metadata. Tighter than P-Small. Use for captions, overlines, reference codes.

| Static | Size | lh | Use when |
|---|---|---|---|
| `TypographyScale.lbSmall` | 12 | 19 | Legal copy, overline, reference IDs |
| `TypographyScale.lbRegular` | 13 | 21 | Category label, timestamps, short metadata |

### Pr — Promo (GT Ultra Median / Regular / w400)
Brand/marketing moments only. Never use for UI chrome.

| Static | Size | lh | Use when |
|---|---|---|---|
| `TypographyScale.prMax` | 47 | 63 | Hero statement, campaign headline |
| `TypographyScale.prExtra` | 35 | 47 | Prominent promo heading |
| `TypographyScale.prBase` | 29 | 43 | Promo sub-heading |

### Dp — Display (GT Flaire / Bold–Medium)
Highest-impact moments. One per screen, maximum.

| Static | Size | Weight | lh | Use when |
|---|---|---|---|---|
| `TypographyScale.dpMax` | 47 | 700 | 63 | Full-screen takeover, brand splash |
| `TypographyScale.dpExtra` | 35 | 700 | 47 | High-impact display heading |
| `TypographyScale.dpBase` | 29 | 500 | 43 | Display sub-heading |

---

## Choosing between similar styles

**P-Medium vs Shd-Small** — both are 15px/lh23, different weight:
- Use `pMedium` (w400) for reading — descriptions, helper text, subtitles
- Use `shdSmall` (w500) for scanning — list item titles, labels the user acts on

**P-Large vs Shd-Medium vs Hd-Small** — all near 17px, three weights:
- `pLarge` (w400): body copy, form values — the user reads it
- `shdMedium` (w500): prominent label — the user scans it
- `hdSmall` (w600): compact heading — the user orients by it

**Hd-Medium vs Hd-Large** — button labels vs. collapsible headers:
- `hdMedium` (19/600): interactive — any tappable label
- `hdLarge` (23/700): structural — section breaks, collapsible group headers

**When to reach for Lb-* vs P-Small** — both 12–13px:
- `lbRegular` / `lbSmall`: metadata that annotates other content (timestamps, IDs, overlines)
- `pSmall`: reading copy that happens to be small (fine print, terms, helper paragraphs)

---

## Color pairing

Typography statics carry no color. Always supply it via `.copyWith(color: ...)`.

| Context | Token |
|---|---|
| Default body / heading | `colors.contentPrimary` |
| Supporting / secondary | `colors.contentSecondary` |
| Disabled / placeholder | `colors.contentTertiary` |
| On brand orange (`brandPrimary`) fill | `colors.backgroundPrimary` |
| On dark navy (`brandDark`) fill | `colors.backgroundPrimary` |
| Error / destructive message | `colors.feedbackNegative` |
| Success label | `colors.feedbackPositive` |
| Warning / caution label | `colors.feedbackWarning` |

---

## Flutter implementation notes

**Line height** — `TextStyle.height` is a multiplier, not pixels. Each static computes it correctly (`lh / size`). Do not recompute it.

**Leading distribution** — every static sets `leadingDistribution: TextLeadingDistribution.even` to match Figma's CSS-style half-leading. Without this, text sits lower than the design.

**Text decoration** — every static sets `decoration: TextDecoration.none` to prevent browser default underlines on Flutter web.

**These three properties are already baked in.** You do not need to set them manually. `.copyWith()` preserves them unless you explicitly override.

---

## DO / DON'T

```dart
// DO — named static + color via copyWith
Text(
  hotelName,
  style: TypographyScale.pMedium.copyWith(color: colors.contentPrimary),
)

// DO — button label
Text(
  'Book now',
  style: TypographyScale.hdMedium.copyWith(color: colors.backgroundPrimary),
)

// DON'T — inline assembly from raw numbers
Text(
  hotelName,
  style: TextStyle(fontSize: 15, fontWeight: FontWeight.w400, height: 1.53),
)

// DON'T — hardcoded font family on a Lexend Deca element
Text(
  label,
  style: TextStyle(fontFamily: 'Lexend Deca', fontSize: 15),
)
```

---

## What NOT to use

- Mixing `Pr-*` or `Dp-*` styles inside UI chrome — these are brand-moment only.
- Two heading levels in the same visual group — creates ambiguous hierarchy.
- `Hd-*` styles for body copy — weight implies interaction or structure; misuse breaks the user's scanning pattern.
