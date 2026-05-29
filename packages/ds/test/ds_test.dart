import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:scapia_ds/scapia_ds.dart';

void main() {
  test('ScapiaTheme.light returns a ThemeData', () {
    expect(ScapiaTheme.light(), isA<ThemeData>());
  });
}
