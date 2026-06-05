#!/usr/bin/env dart
// DS Lint — token tier contract checker
//
// Scans widget files for Seasonal DLS rule violations.
// Exits 1 if violations found — use in CI.
//
// Usage:
//   dart tools/lint/check_ds_rules.dart
//   melos run lint:ds-rules
//
// Rules:
//   no_hardcoded_color       — Color(0xFF...) literals banned; use ColorScale
//   no_flutter_colors        — Colors.* from Flutter banned; use ColorScale
//   no_tier1_in_widgets      — ColorPrimitives/Foundation/SpacingPrimitives banned
//   no_inline_text_style     — TextStyle(fontSize: n) inline assembly banned
//   no_bare_border           — Border.all(color:) without explicit width: banned
//   no_raw_spacing_literal   — SizedBox/EdgeInsets with raw number matching a SpacingScale value
//
// Ignore a specific line with:
//   // ds-lint-ignore: no_hardcoded_color

import 'dart:io';

// ─── Rule definitions ─────────────────────────────────────────────────────────

class Rule {
  const Rule({
    required this.name,
    required this.pattern,
    required this.message,
    required this.fix,
    this.exemptFiles = const {},
    this.gapExempt   = false,
  });

  final String          name;
  final RegExp          pattern;
  final String          message;
  final String          fix;
  final Set<String>     exemptFiles;
  /// When true, lines containing '// Gap:' are exempt from this rule.
  /// Used for spacing rules where documented sub-token raw literals are allowed.
  final bool            gapExempt;
}

final _rules = [
  Rule(
    name:    'no_hardcoded_color',
    pattern: RegExp(r'Color\s*\(\s*0x[0-9A-Fa-f]+'),
    message: 'Hardcoded Color() literal',
    fix:     'Use a ColorScale token: colors.fieldName\n'
             '  Access via: Theme.of(context).extension<ColorScale>()!.fieldName',
  ),
  Rule(
    name:    'no_flutter_colors',
    pattern: RegExp(r'\bColors\.(?!transparent\b)'),  // transparent has nuance, warn not error
    message: 'Flutter Colors.* is banned',
    fix:     'Use a ColorScale token instead.\n'
             '  colors.backgroundPrimary instead of Colors.white\n'
             '  colors.contentPrimary    instead of Colors.black',
  ),
  Rule(
    name:    'no_flutter_colors_transparent',
    pattern: RegExp(r'\bColors\.transparent\b'),
    message: 'Colors.transparent — prefer a ColorScale token or explicit Color(0x00000000)',
    fix:     'Document why no ColorScale token exists, then use Color(0x00000000) with a // Gap: comment',
  ),
  Rule(
    name:    'no_tier1_in_widgets',
    pattern: RegExp(r'\b(ColorPrimitives|Foundation|SpacingPrimitives)\.'),
    message: 'Direct Tier 1 token reference',
    fix:     'Use Tier 2 tokens: ColorScale, TypographyScale, SpacingScale.\n'
             '  Tier 1 classes are internal implementation — never reference in widget code.',
    exemptFiles: {
      'color_scale.dart',
      'typography_scale.dart',
      'spacing_scale.dart',
      'button_tokens.dart',
      'tokens_test.dart',
    },
  ),
  Rule(
    name:    'no_inline_text_style',
    // Catches TextStyle( with a raw number as fontSize or height argument
    pattern: RegExp(r'TextStyle\s*\([^)]*(?:fontSize|height)\s*:\s*[\d]'),
    message: 'Inline TextStyle() with raw number',
    fix:     'Use a TypographyScale static:\n'
             '  TypographyScale.pMedium.copyWith(color: colors.contentPrimary)',
    exemptFiles: {
      'typography_scale.dart',
    },
  ),
  Rule(
    // Catches Border.all( where the first named argument is color: without width: preceding it.
    // Per DS rules, strokeWeight must always be read from the Figma node and written explicitly.
    // Flutter's default width of 1.0 is not a token match — it is a silent assumption.
    // Fix: Border.all(width: N, color: ...) where N comes from the Figma strokeWeight field.
    name:    'no_bare_border',
    pattern: RegExp(r'Border\.all\s*\(\s*color\s*:'),
    message: 'Border.all() with no explicit width: — Flutter defaults to 1.0 dp, which may not match the Figma strokeWeight',
    fix:     'Read strokeWeight from the Figma node inventory and write:\n'
             '  Border.all(width: N, color: colors.fieldName)\n'
             'If the Figma strokeWeight is 1.0 and that is intentional, write it explicitly and add a // Gap: comment.',
  ),
  Rule(
    // Catches SizedBox or EdgeInsets using a raw number that exactly matches a SpacingScale
    // token value. These must use the token — using the raw number bypasses the tier contract
    // and makes future token renames invisible to this widget.
    //
    // SpacingScale values (excluding 0 and 2 which are commonly used as raw layout adjustments):
    //   5→spaceXs  7→spaceSm  9→spaceMd  13→spaceMdLg  15→spaceLg  21→spaceXl
    //   25→space2xl  29→space3xl  35→space4xl  39→space5xl  47→space6xl  65→space7xl
    //   75→space8xl  95→space9xl  115→space10xl
    //
    // Exempt: lines with a '// Gap:' comment (documented sub-token values are allowed as raw literals).
    name:    'no_raw_spacing_literal',
    pattern: RegExp(
      r'(?:SizedBox\s*\([^)]*(?:width|height)|EdgeInsets\.(?:all|symmetric|only|fromLTRB))\s*[(:,]\s*'
      r'(?:5|7|9|13|15|21|25|29|35|39|47|65|75|95|115)(?:\.0)?\s*[,\):]',
    ),
    message: 'Raw spacing literal matches a SpacingScale token value',
    fix:     'Use the SpacingScale token:\n'
             '  5→spaceXs  7→spaceSm  9→spaceMd  13→spaceMdLg  15→spaceLg  21→spaceXl\n'
             '  25→space2xl  29→space3xl  35→space4xl  39→space5xl  47→space6xl  65→space7xl\n'
             '  75→space8xl  95→space9xl  115→space10xl\n'
             'If this is a documented gap (no token exists), add a // Gap: comment to suppress.',
    gapExempt: true,
  ),
];

// ─── Scan target directories ───────────────────────────────────────────────────

const _scanDirs = [
  'packages/ds/lib/src/components',
  'apps/app/lib',
];

const _ignoreDirective = 'ds-lint-ignore';

// ─── Main ─────────────────────────────────────────────────────────────────────

void main() {
  final root = _findRepoRoot();
  var totalViolations = 0;

  for (final dir in _scanDirs) {
    final target = Directory('$root/$dir');
    if (!target.existsSync()) continue;

    final files = target
        .listSync(recursive: true)
        .whereType<File>()
        .where((f) => f.path.endsWith('.dart'));

    for (final file in files) {
      final violations = _scanFile(file);
      if (violations.isNotEmpty) {
        for (final v in violations) {
          stderr.writeln(v);
        }
        totalViolations += violations.length;
      }
    }
  }

  if (totalViolations == 0) {
    stdout.writeln('✅  DS lint passed — no token violations found.');
    exit(0);
  } else {
    stderr.writeln('\n❌  $totalViolations violation(s) found. Fix before merging.');
    exit(1);
  }
}

List<String> _scanFile(File file) {
  final lines    = file.readAsLinesSync();
  final fileName = file.uri.pathSegments.last;
  final relPath  = _relativePath(file.path);
  final results  = <String>[];

  for (var i = 0; i < lines.length; i++) {
    final line       = lines[i];
    final lineNum    = i + 1;

    // Skip pure comment lines — violations in comments are documentation, not code
    final trimmed = line.trim();
    if (trimmed.startsWith('//') || trimmed.startsWith('*') || trimmed.startsWith('/*')) continue;

    // Check for per-line ignore directive
    final ignoredRules = _parseIgnore(line);

    for (final rule in _rules) {
      if (rule.exemptFiles.contains(fileName)) continue;
      if (ignoredRules.contains(rule.name) || ignoredRules.contains('all')) continue;
      if (rule.gapExempt && line.contains('// Gap:')) continue;
      if (!rule.pattern.hasMatch(line)) continue;

      results.add(
        '$relPath:$lineNum  [${rule.name}]\n'
        '  ${line.trim()}\n'
        '  → ${rule.message}\n'
        '  Fix: ${rule.fix}\n',
      );
    }
  }

  return results;
}

Set<String> _parseIgnore(String line) {
  final idx = line.indexOf(_ignoreDirective);
  if (idx == -1) return const {};
  var rest = line.substring(idx + _ignoreDirective.length).trim();
  // Strip leading colon: "ds-lint-ignore: rule1" → "rule1"
  if (rest.startsWith(':')) rest = rest.substring(1).trim();
  if (rest.isEmpty) return {'all'};
  // Strip trailing explanation comment: "rule1 — reason" → "rule1"
  rest = rest.split(' — ').first.split(' //').first.trim();
  return rest.split(',').map((s) => s.trim()).toSet();
}

String _findRepoRoot() {
  var dir = Directory.current;
  while (!File('${dir.path}/melos.yaml').existsSync()) {
    final parent = dir.parent;
    if (parent.path == dir.path) {
      stderr.writeln('Could not find repo root (melos.yaml not found).');
      exit(1);
    }
    dir = parent;
  }
  return dir.path;
}

String _relativePath(String absolute) {
  final root = _findRepoRoot();
  return absolute.startsWith(root)
      ? absolute.substring(root.length + 1)
      : absolute;
}
