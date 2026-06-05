// GENERATED — source of truth: Figma › Seasonal DLS › text styles.
// Text style names match Figma exactly so designers and developers share one vocabulary.
// ignore_for_file: lines_longer_than_80_chars

import 'package:flutter/painting.dart';

import 'foundation.dart';

/// Tier 2 — typography scale.
///
/// ## Usage
/// Prefer the pre-built [TextStyle] constants (e.g. [pMedium], [hdSmall]).
/// They are color-agnostic — apply color at the widget level via [TextStyle.copyWith]:
///
/// ```dart
/// Text(
///   label,
///   style: TypographyScale.pMedium.copyWith(color: colors.contentPrimary),
/// )
/// ```
///
/// The raw numeric constants (`*Size`, `*Weight`, `*Lineheight`) are retained
/// for token-contract tests and edge-cases that require only one dimension.
///
/// ## Families
/// - **P-*** (Paragraph)  — Lexend Deca, Regular (w400). Body copy.
/// - **Shd-*** (Sub-heading) — Lexend Deca, Medium (w500). Prominent body / UI labels.
/// - **Hd-*** (Heading)  — Lexend Deca, SemiBold (w600) or Bold (w700). Structural hierarchy.
/// - **Lb-*** (Label)    — Lexend Deca, Regular (w400). Captions and metadata.
/// - **Pr-*** (Promo)    — GT Ultra Median Trial. Brand / marketing moments.
/// - **Dp-*** (Display)  — GT Flaire Basic Trial. High-impact display.
abstract final class TypographyScale {

  // ════════════════════════════════════════════════════════════════════════════
  // TextStyle constants  (Figma name → camelCase)
  // ════════════════════════════════════════════════════════════════════════════

  // ── P — Paragraph (Lexend Deca, Regular/w400) ─────────────────────────────

  /// 10 / Regular / lh 15  — micro labels, rating counts, score overlays.
  static const TextStyle pExtraSmall = TextStyle(
    fontFamily: Foundation.fontFamilyLexendDeca,
    fontSize:   Foundation.fontSize10,
    fontWeight: FontWeight.w400,
    height:     Foundation.fontLineheight15 / Foundation.fontSize10,
    leadingDistribution: TextLeadingDistribution.even,
    decoration:            TextDecoration.none,
  );

  /// 13 / Regular / lh 21  — metadata, timestamps, fine print.
  static const TextStyle pSmall = TextStyle(
    fontFamily: Foundation.fontFamilyLexendDeca,
    fontSize:   Foundation.fontSize13,
    fontWeight: FontWeight.w400,
    height:     Foundation.fontLineheight21 / Foundation.fontSize13,
    leadingDistribution: TextLeadingDistribution.even,
    decoration:            TextDecoration.none,
  );

  /// 15 / Regular / lh 23  — supporting body text, list subtitles, helper copy.
  static const TextStyle pMedium = TextStyle(
    fontFamily: Foundation.fontFamilyLexendDeca,
    fontSize:   Foundation.fontSize15,
    fontWeight: FontWeight.w400,
    height:     Foundation.fontLineheight23 / Foundation.fontSize15,
    leadingDistribution: TextLeadingDistribution.even,
    decoration:            TextDecoration.none,
  );

  /// 17 / Regular / lh 25  — primary body copy, form values.
  static const TextStyle pLarge = TextStyle(
    fontFamily: Foundation.fontFamilyLexendDeca,
    fontSize:   Foundation.fontSize17,
    fontWeight: FontWeight.w400,
    height:     Foundation.fontLineheight25 / Foundation.fontSize17,
    leadingDistribution: TextLeadingDistribution.even,
    decoration:            TextDecoration.none,
  );

  /// 19 / Regular / lh 29  — slightly elevated body, introductory paragraphs.
  static const TextStyle pExtra = TextStyle(
    fontFamily: Foundation.fontFamilyLexendDeca,
    fontSize:   Foundation.fontSize19,
    fontWeight: FontWeight.w400,
    height:     Foundation.fontLineheight29 / Foundation.fontSize19,
    leadingDistribution: TextLeadingDistribution.even,
    decoration:            TextDecoration.none,
  );

  /// 23 / Regular / lh 35  — large readable prose, pull quotes.
  static const TextStyle pMax = TextStyle(
    fontFamily: Foundation.fontFamilyLexendDeca,
    fontSize:   Foundation.fontSize23,
    fontWeight: FontWeight.w400,
    height:     Foundation.fontLineheight35 / Foundation.fontSize23,
    leadingDistribution: TextLeadingDistribution.even,
    decoration:            TextDecoration.none,
  );

  // ── Shd — Sub-heading (Lexend Deca, Medium/w500) ──────────────────────────

  /// 15 / Medium / lh 23  — prominent UI label, list item title, chip text.
  static const TextStyle shdSmall = TextStyle(
    fontFamily: Foundation.fontFamilyLexendDeca,
    fontSize:   Foundation.fontSize15,
    fontWeight: FontWeight.w500,
    height:     Foundation.fontLineheight23 / Foundation.fontSize15,
    leadingDistribution: TextLeadingDistribution.even,
    decoration:            TextDecoration.none,
  );

  /// 17 / Medium / lh 23  — tab label, card sub-title, section label.
  static const TextStyle shdMedium = TextStyle(
    fontFamily: Foundation.fontFamilyLexendDeca,
    fontSize:   Foundation.fontSize17,
    fontWeight: FontWeight.w500,
    height:     Foundation.fontLineheight23 / Foundation.fontSize17,
    leadingDistribution: TextLeadingDistribution.even,
    decoration:            TextDecoration.none,
  );

  // ── Hd — Heading (Lexend Deca, SemiBold w600 or Bold w700) ────────────────

  /// 17 / SemiBold / lh 23  — compact heading, inline action text.
  static const TextStyle hdSmall = TextStyle(
    fontFamily: Foundation.fontFamilyLexendDeca,
    fontSize:   Foundation.fontSize17,
    fontWeight: FontWeight.w600,
    height:     Foundation.fontLineheight23 / Foundation.fontSize17,
    leadingDistribution: TextLeadingDistribution.even,
    decoration:            TextDecoration.none,
  );

  /// 19 / SemiBold / lh 27  — button label, prominent CTA, list item heading.
  static const TextStyle hdMedium = TextStyle(
    fontFamily: Foundation.fontFamilyLexendDeca,
    fontSize:   Foundation.fontSize19,
    fontWeight: FontWeight.w600,
    height:     Foundation.fontLineheight27 / Foundation.fontSize19,
    leadingDistribution: TextLeadingDistribution.even,
    decoration:            TextDecoration.none,
  );

  /// 23 / Bold / lh 35  — sub-section title, collapsible header.
  static const TextStyle hdLarge = TextStyle(
    fontFamily: Foundation.fontFamilyLexendDeca,
    fontSize:   Foundation.fontSize23,
    fontWeight: FontWeight.w700,
    height:     Foundation.fontLineheight35 / Foundation.fontSize23,
    leadingDistribution: TextLeadingDistribution.even,
    decoration:            TextDecoration.none,
  );

  /// 27 / Bold / lh 39  — section heading, modal title.
  static const TextStyle hdExtra = TextStyle(
    fontFamily: Foundation.fontFamilyLexendDeca,
    fontSize:   Foundation.fontSize27,
    fontWeight: FontWeight.w700,
    height:     Foundation.fontLineheight39 / Foundation.fontSize27,
    leadingDistribution: TextLeadingDistribution.even,
    decoration:            TextDecoration.none,
  );

  /// 35 / Bold / lh 47  — page title, primary screen header.
  static const TextStyle hdMax = TextStyle(
    fontFamily: Foundation.fontFamilyLexendDeca,
    fontSize:   Foundation.fontSize35,
    fontWeight: FontWeight.w700,
    height:     Foundation.fontLineheight47 / Foundation.fontSize35,
    leadingDistribution: TextLeadingDistribution.even,
    decoration:            TextDecoration.none,
  );

  /// 41 / Bold / lh 55  — screen-level hero heading.
  static const TextStyle hdRare = TextStyle(
    fontFamily: Foundation.fontFamilyLexendDeca,
    fontSize:   Foundation.fontSize41,
    fontWeight: FontWeight.w700,
    height:     Foundation.fontLineheight55 / Foundation.fontSize41,
    leadingDistribution: TextLeadingDistribution.even,
    decoration:            TextDecoration.none,
  );

  // ── Lb — Label (Lexend Deca, Regular/w400) ────────────────────────────────

  /// 12 / Regular / lh 19  — legal copy, overlines, reference codes.
  static const TextStyle lbSmall = TextStyle(
    fontFamily: Foundation.fontFamilyLexendDeca,
    fontSize:   Foundation.fontSize12,
    fontWeight: FontWeight.w400,
    height:     Foundation.fontLineheight19 / Foundation.fontSize12,
    leadingDistribution: TextLeadingDistribution.even,
    decoration:            TextDecoration.none,
  );

  /// 13 / Regular / lh 21  — category label, transaction ID, short metadata.
  static const TextStyle lbRegular = TextStyle(
    fontFamily: Foundation.fontFamilyLexendDeca,
    fontSize:   Foundation.fontSize13,
    fontWeight: FontWeight.w400,
    height:     Foundation.fontLineheight21 / Foundation.fontSize13,
    leadingDistribution: TextLeadingDistribution.even,
    decoration:            TextDecoration.none,
  );

  // ── Pr — Promo (GT Ultra Median Trial) ───────────────────────────────────

  /// 47 / Regular / lh 63  — hero statement, campaign headline.
  static const TextStyle prMax = TextStyle(
    fontFamily: Foundation.fontFamilyGtUltraMedian,
    fontSize:   Foundation.fontSize47,
    fontWeight: FontWeight.w400,
    height:     Foundation.fontLineheight63 / Foundation.fontSize47,
    leadingDistribution: TextLeadingDistribution.even,
    decoration:            TextDecoration.none,
  );

  /// 35 / Regular / lh 47  — prominent promo heading.
  static const TextStyle prExtra = TextStyle(
    fontFamily: Foundation.fontFamilyGtUltraMedian,
    fontSize:   Foundation.fontSize35,
    fontWeight: FontWeight.w400,
    height:     Foundation.fontLineheight47 / Foundation.fontSize35,
    leadingDistribution: TextLeadingDistribution.even,
    decoration:            TextDecoration.none,
  );

  /// 29 / Regular / lh 43  — promo sub-heading.
  static const TextStyle prBase = TextStyle(
    fontFamily: Foundation.fontFamilyGtUltraMedian,
    fontSize:   Foundation.fontSize29,
    fontWeight: FontWeight.w400,
    height:     Foundation.fontLineheight43 / Foundation.fontSize29,
    leadingDistribution: TextLeadingDistribution.even,
    decoration:            TextDecoration.none,
  );

  // ── Dp — Display (GT Flaire Basic Trial) ─────────────────────────────────

  /// 47 / Bold / lh 63  — full-screen takeover, brand splash.
  static const TextStyle dpMax = TextStyle(
    fontFamily: Foundation.fontFamilyGtFlaire,
    fontSize:   Foundation.fontSize47,
    fontWeight: FontWeight.w700,
    height:     Foundation.fontLineheight63 / Foundation.fontSize47,
    leadingDistribution: TextLeadingDistribution.even,
    decoration:            TextDecoration.none,
  );

  /// 35 / Bold / lh 47  — high-impact display heading.
  static const TextStyle dpExtra = TextStyle(
    fontFamily: Foundation.fontFamilyGtFlaire,
    fontSize:   Foundation.fontSize35,
    fontWeight: FontWeight.w700,
    height:     Foundation.fontLineheight47 / Foundation.fontSize35,
    leadingDistribution: TextLeadingDistribution.even,
    decoration:            TextDecoration.none,
  );

  /// 29 / Medium / lh 43  — display sub-heading.
  static const TextStyle dpBase = TextStyle(
    fontFamily: Foundation.fontFamilyGtFlaire,
    fontSize:   Foundation.fontSize29,
    fontWeight: FontWeight.w500,
    height:     Foundation.fontLineheight43 / Foundation.fontSize29,
    leadingDistribution: TextLeadingDistribution.even,
    decoration:            TextDecoration.none,
  );

  // ════════════════════════════════════════════════════════════════════════════
  // Raw numeric tokens  (Figma → Foundation alias chain)
  // Use for token-contract tests only. In widgets, prefer the TextStyle statics above.
  // ════════════════════════════════════════════════════════════════════════════

  // ── Paragraph ────────────────────────────────────────────────────────────
  static const double pExtraSmallSize       = Foundation.fontSize10;
  static const double pExtraSmallWeight     = Foundation.fontWeightRegular;  // 400
  static const double pExtraSmallLineheight = Foundation.fontLineheight15;

  static const double pSmallSize       = Foundation.fontSize13;
  static const double pSmallWeight     = Foundation.fontWeightRegular;   // 400
  static const double pSmallLineheight = Foundation.fontLineheight21;

  static const double pMediumSize       = Foundation.fontSize15;
  static const double pMediumWeight     = Foundation.fontWeightRegular;  // 400
  static const double pMediumLineheight = Foundation.fontLineheight23;

  static const double pLargeSize       = Foundation.fontSize17;
  static const double pLargeWeight     = Foundation.fontWeightRegular;   // 400
  static const double pLargeLineheight = Foundation.fontLineheight25;

  static const double pExtraSize       = Foundation.fontSize19;
  static const double pExtraWeight     = Foundation.fontWeightRegular;   // 400
  static const double pExtraLineheight = Foundation.fontLineheight29;

  static const double pMaxSize       = Foundation.fontSize23;
  static const double pMaxWeight     = Foundation.fontWeightRegular;     // 400
  static const double pMaxLineheight = Foundation.fontLineheight35;

  // ── Sub-heading ──────────────────────────────────────────────────────────
  static const double shdSmallSize       = Foundation.fontSize15;
  static const double shdSmallWeight     = Foundation.fontWeightMedium;  // 500
  static const double shdSmallLineheight = Foundation.fontLineheight23;

  static const double shdMediumSize       = Foundation.fontSize17;
  static const double shdMediumWeight     = Foundation.fontWeightMedium; // 500
  static const double shdMediumLineheight = Foundation.fontLineheight23;

  // ── Heading ───────────────────────────────────────────────────────────────
  static const double hdSmallSize       = Foundation.fontSize17;
  static const double hdSmallWeight     = Foundation.fontWeightSemibold; // 600
  static const double hdSmallLineheight = Foundation.fontLineheight23;

  static const double hdMediumSize       = Foundation.fontSize19;
  static const double hdMediumWeight     = Foundation.fontWeightSemibold; // 600
  static const double hdMediumLineheight = Foundation.fontLineheight27;

  static const double hdLargeSize       = Foundation.fontSize23;
  static const double hdLargeWeight     = Foundation.fontWeightBold;     // 700
  static const double hdLargeLineheight = Foundation.fontLineheight35;

  static const double hdExtraSize       = Foundation.fontSize27;
  static const double hdExtraWeight     = Foundation.fontWeightBold;     // 700
  static const double hdExtraLineheight = Foundation.fontLineheight39;

  static const double hdMaxSize       = Foundation.fontSize35;
  static const double hdMaxWeight     = Foundation.fontWeightBold;       // 700
  static const double hdMaxLineheight = Foundation.fontLineheight47;

  static const double hdRareSize       = Foundation.fontSize41;
  static const double hdRareWeight     = Foundation.fontWeightBold;      // 700
  static const double hdRareLineheight = Foundation.fontLineheight55;

  // ── Label ─────────────────────────────────────────────────────────────────
  static const double lbSmallSize       = Foundation.fontSize12;
  static const double lbSmallWeight     = Foundation.fontWeightRegular;  // 400
  static const double lbSmallLineheight = Foundation.fontLineheight19;

  static const double lbRegularSize       = Foundation.fontSize13;
  static const double lbRegularWeight     = Foundation.fontWeightRegular; // 400
  static const double lbRegularLineheight = Foundation.fontLineheight21;

  // ─────────────────────────────────────────────────────────────────────────
  // Deprecated aliases — kept for backward compat, will be removed in v2.
  // Use the Figma-named constants above instead.
  // ─────────────────────────────────────────────────────────────────────────

  @Deprecated('Use hdMedium or hdMediumSize')
  static const double titleMdSize       = Foundation.fontSize19;
  @Deprecated('Use hdMedium or hdMediumWeight')
  static const double titleMdWeight     = Foundation.fontWeightSemibold;
  @Deprecated('Use hdMedium or hdMediumLineheight')
  static const double titleMdLineheight = Foundation.fontLineheight27;

  @Deprecated('Use pSmall or pSmallSize')
  static const double captionSize       = Foundation.fontSize13;
  @Deprecated('Use pSmall or pSmallWeight')
  static const double captionWeight     = Foundation.fontWeightRegular;
  @Deprecated('Use pSmall or pSmallLineheight')
  static const double captionLineheight = Foundation.fontLineheight21;

  @Deprecated('Use lbSmall or lbSmallSize')
  static const double captionSmSize       = Foundation.fontSize12;
  @Deprecated('Use lbSmall or lbSmallWeight')
  static const double captionSmWeight     = Foundation.fontWeightRegular;
  @Deprecated('Use lbSmall or lbSmallLineheight')
  static const double captionSmLineheight = Foundation.fontLineheight19;

  @Deprecated('Use pMedium or pMediumSize')
  static const double bodyMdSize       = Foundation.fontSize15;
  @Deprecated('Use pMedium or pMediumWeight')
  static const double bodyMdWeight     = Foundation.fontWeightRegular; // fixed: was Medium/500, Figma is Regular/400
  @Deprecated('Use pMedium or pMediumLineheight')
  static const double bodyMdLineheight = Foundation.fontLineheight23;

  @Deprecated('Use pLarge or pLargeSize')
  static const double bodyLgSize       = Foundation.fontSize17;
  @Deprecated('Use pLarge or pLargeWeight')
  static const double bodyLgWeight     = Foundation.fontWeightRegular; // fixed: was Medium/500, Figma is Regular/400
  @Deprecated('Use pLarge or pLargeLineheight')
  static const double bodyLgLineheight = Foundation.fontLineheight25;
}
