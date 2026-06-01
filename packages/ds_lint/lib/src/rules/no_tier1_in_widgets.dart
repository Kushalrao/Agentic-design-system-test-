import 'package:analyzer/error/error.dart';
import 'package:analyzer/error/listener.dart';
import 'package:custom_lint_builder/custom_lint_builder.dart';

/// Bans direct Tier 1 token references in widget code.
///
/// Tier 1 classes are internal implementation details — the alias chain
/// from Figma to Dart is:
///   Tier 1 (primitives) → Tier 2 (semantic aliases) → Tier 3 (component tokens)
///
/// Widgets must only consume Tier 2 or Tier 3:
///   ✅ colors.brandPrimary               (ColorScale — Tier 2)
///   ✅ SpacingScale.spaceMd              (SpacingScale — Tier 2)
///   ✅ TypographyScale.pMedium           (TypographyScale — Tier 2)
///   ❌ ColorPrimitives.primaryScapia800  (Tier 1 — banned in widgets)
///   ❌ Foundation.fontSize15             (Tier 1 — banned in widgets)
///   ❌ SpacingPrimitives.spacing9        (Tier 1 — banned in widgets)
const _tier1Classes = {
  'ColorPrimitives',
  'Foundation',
  'SpacingPrimitives',
};

class NoTier1InWidgets extends DartLintRule {
  const NoTier1InWidgets() : super(code: _code);

  static const _code = LintCode(
    name: 'no_tier1_in_widgets',
    problemMessage:
        'Direct Tier 1 token reference — use Tier 2 tokens instead.\n'
        'ColorPrimitives/Foundation/SpacingPrimitives are banned in widget code.',
    correctionMessage:
        'Use ColorScale, TypographyScale, or SpacingScale '
        '(Tier 2) — never the raw primitive classes.',
    errorSeverity: ErrorSeverity.ERROR,
  );

  @override
  void run(
    CustomLintResolver resolver,
    ErrorReporter reporter,
    CustomLintContext context,
  ) {
    context.registry.addPrefixedIdentifier((node) {
      final element = node.prefix.staticElement;
      if (element == null) return;
      if (_tier1Classes.contains(element.name)) {
        reporter.reportErrorForNode(_code, node);
      }
    });
  }
}
