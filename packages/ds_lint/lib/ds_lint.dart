import 'package:custom_lint_builder/custom_lint_builder.dart';

import 'package:ds_lint/src/rules/no_flutter_colors.dart';
import 'package:ds_lint/src/rules/no_hardcoded_color.dart';
import 'package:ds_lint/src/rules/no_inline_text_style.dart';
import 'package:ds_lint/src/rules/no_tier1_in_widgets.dart';

PluginBase createPlugin() => _DsLintPlugin();

class _DsLintPlugin extends PluginBase {
  @override
  List<LintRule> getLintRules(CustomLintConfigs configs) => const [
    NoHardcodedColor(),
    NoFlutterColors(),
    NoTier1InWidgets(),
    NoInlineTextStyle(),
  ];
}
