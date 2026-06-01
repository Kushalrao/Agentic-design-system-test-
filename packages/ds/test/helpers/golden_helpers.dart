import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:scapia_ds/scapia_ds.dart';

/// Load all DS fonts before golden tests run.
/// Call this in [setUpAll] for every golden test file.
///
/// Reads font files directly from disk so they work regardless of how
/// `flutter test` is invoked (from repo root or from within the package).
Future<void> loadDsFonts() async {
  // Resolve font directory relative to this test file's package root.
  // Works whether flutter test is run from the repo root or the package.
  final packageRoot = _findPackageRoot();
  final fontsDir    = '$packageRoot/assets/fonts';

  Future<ByteData> read(String name) async {
    final bytes = await File('$fontsDir/$name').readAsBytes();
    return ByteData.sublistView(bytes);
  }

  final loader = FontLoader('Lexend Deca')
    ..addFont(read('LexendDeca-Regular.ttf'))
    ..addFont(read('LexendDeca-Medium.ttf'))
    ..addFont(read('LexendDeca-SemiBold.ttf'))
    ..addFont(read('LexendDeca-Bold.ttf'));
  await loader.load();
}

/// Resolve the scapia_ds package root directory.
/// Works whether flutter test is run from the repo root or the package root.
String _findPackageRoot() {
  final cwd = Directory.current.path;
  // Case 1: running from packages/ds/ directly
  if (File('$cwd/pubspec.yaml').existsSync() &&
      File('$cwd/pubspec.yaml').readAsStringSync().contains('name: scapia_ds')) {
    return cwd;
  }
  // Case 2: running from the repo root (melos run test or flutter test packages/ds/)
  final fromRoot = '$cwd/packages/ds';
  if (Directory(fromRoot).existsSync()) return fromRoot;

  throw StateError(
    'Could not find scapia_ds package root. '
    'Run tests from the repo root or from packages/ds/.',
  );
}

/// Wrap a widget in ScapiaTheme for golden rendering.
/// Uses a fixed 390dp wide screen (standard mobile width).
Widget dsGoldenWrapper(Widget child, {double width = 390}) {
  return MaterialApp(
    theme: ScapiaTheme.light(),
    debugShowCheckedModeBanner: false,
    home: Scaffold(
      backgroundColor: Colors.white,
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Center(child: child),
      ),
    ),
  );
}

/// Pump a widget, wait for all animations and images, then match golden.
Future<void> expectGolden(
  WidgetTester tester,
  Widget widget,
  String goldenFile,
) async {
  await tester.pumpWidget(dsGoldenWrapper(widget));
  await tester.pump(); // trigger first frame
  await tester.pump(const Duration(milliseconds: 100)); // settle
  await expectLater(
    find.byType(MaterialApp),
    matchesGoldenFile(goldenFile),
  );
}
