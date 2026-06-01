import 'package:analyzer/error/error.dart';
import 'package:analyzer/error/listener.dart';
import 'package:custom_lint_builder/custom_lint_builder.dart';

/// Bans `Colors.*` from Flutter's material library.
///
/// `Colors.white`, `Colors.black`, `Colors.transparent`, etc. are all banned.
/// Use ColorScale tokens exclusively:
///   `colors.backgroundPrimary` instead of `Colors.white`
///   `colors.contentPrimary`    instead of `Colors.black`
class NoFlutterColors extends DartLintRule {
  const NoFlutterColors() : super(code: _code);

  static const _code = LintCode(
    name: 'no_flutter_colors',
    problemMessage:
        'Flutter Colors.* is banned — use a ColorScale token instead.\n'
        'e.g. colors.backgroundPrimary instead of Colors.white',
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

      // Resolve the prefix to ensure it's the Flutter Colors class (not a local var)
      final library = element.library?.identifier ?? '';
      if (element.name == 'Colors' && library.contains('flutter')) {
        reporter.reportErrorForNode(_code, node);
      }
    });
  }
}
