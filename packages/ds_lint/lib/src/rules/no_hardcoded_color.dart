import 'package:analyzer/dart/ast/ast.dart';
import 'package:analyzer/error/error.dart';
import 'package:analyzer/error/listener.dart';
import 'package:custom_lint_builder/custom_lint_builder.dart';

/// Bans `Color(0xFF...)` literals in widget files.
///
/// Every color must come from ColorScale:
///   `Theme.of(context).extension<ColorScale>()!.fieldName`
///
/// Exceptions (use `// ignore: no_hardcoded_color` with a comment explaining why):
///   - Documented gaps with no Tier 2 token yet, e.g. `Color(0x66000000)` for overlays
class NoHardcodedColor extends DartLintRule {
  const NoHardcodedColor() : super(code: _code);

  static const _code = LintCode(
    name: 'no_hardcoded_color',
    problemMessage:
        'Hardcoded Color() literal — use a ColorScale token instead.\n'
        'Access via: Theme.of(context).extension<ColorScale>()!.fieldName',
    correctionMessage:
        'Replace with the appropriate ColorScale token. '
        'If no token exists, document a gap and ask before proceeding.',
    errorSeverity: ErrorSeverity.ERROR,
  );

  @override
  void run(
    CustomLintResolver resolver,
    ErrorReporter reporter,
    CustomLintContext context,
  ) {
    context.registry.addInstanceCreationExpression((node) {
      // Only flag Color(...) constructor calls
      final element = node.constructorName.staticElement;
      if (element == null) return;
      if (element.enclosingElement.name != 'Color') return;

      // Flag if the first argument is an integer literal (0xFFCCCCCC)
      final args = node.argumentList.arguments;
      if (args.isEmpty) return;
      if (args.first is IntegerLiteral) {
        reporter.reportErrorForNode(_code, node);
      }
    });
  }
}
