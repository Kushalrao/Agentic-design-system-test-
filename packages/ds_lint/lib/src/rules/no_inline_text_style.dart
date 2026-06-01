import 'package:analyzer/dart/ast/ast.dart';
import 'package:analyzer/error/error.dart';
import 'package:analyzer/error/listener.dart';
import 'package:custom_lint_builder/custom_lint_builder.dart';

/// Bans inline `TextStyle(...)` construction in widget code.
///
/// Every text style must start from a TypographyScale static:
///   ✅ TypographyScale.pMedium.copyWith(color: colors.contentPrimary)
///   ❌ TextStyle(fontSize: 15, fontWeight: FontWeight.w400, height: 1.53)
///
/// Inline construction bypasses:
///   - The `leadingDistribution: TextLeadingDistribution.even` setting
///     (required to match Figma line height distribution)
///   - The `decoration: TextDecoration.none` setting
///     (prevents browser default underlines in Flutter web)
///   - Figma-name traceability (which style does this correspond to?)
///
/// Exempt: the TypographyScale file itself, and `.copyWith()` calls
/// (those start from a named static — this rule only flags `new TextStyle(...)`).
class NoInlineTextStyle extends DartLintRule {
  const NoInlineTextStyle() : super(code: _code);

  static const _code = LintCode(
    name: 'no_inline_text_style',
    problemMessage:
        'Inline TextStyle() construction — use a TypographyScale static instead.\n'
        'e.g. TypographyScale.pMedium.copyWith(color: colors.contentPrimary)',
    correctionMessage:
        'Pick the matching Figma text style name from TypographyScale '
        'and use .copyWith(color: ...) to apply color.',
    errorSeverity: ErrorSeverity.ERROR,
  );

  // Files exempt from this rule (the token definitions themselves)
  static const _exemptPaths = {
    'typography_scale.dart',
  };

  @override
  void run(
    CustomLintResolver resolver,
    ErrorReporter reporter,
    CustomLintContext context,
  ) {
    // Skip exempt files
    final filePath = resolver.path;
    if (_exemptPaths.any(filePath.endsWith)) return;

    context.registry.addInstanceCreationExpression((node) {
      final element = node.constructorName.staticElement;
      if (element == null) return;

      // Only flag TextStyle constructor calls (not .copyWith which is a method)
      if (element.enclosingElement.name != 'TextStyle') return;

      // Check if any argument contains a raw literal number for fontSize or height
      // This catches the most egregious cases while allowing token references
      for (final arg in node.argumentList.arguments) {
        if (arg is! NamedExpression) continue;
        final name = arg.name.label.name;
        if (name != 'fontSize' && name != 'height' && name != 'fontWeight') continue;

        final value = arg.expression;
        if (value is IntegerLiteral || value is DoubleLiteral) {
          reporter.reportErrorForNode(_code, node);
          return;
        }
      }
    });
  }
}
