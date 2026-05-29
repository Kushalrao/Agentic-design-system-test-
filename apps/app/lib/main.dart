import 'package:flutter/material.dart';
import 'package:scapia_ds/scapia_ds.dart';

void main() {
  runApp(const ScapiaApp());
}

class ScapiaApp extends StatelessWidget {
  const ScapiaApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Scapia',
      theme: ScapiaTheme.light(),
      darkTheme: ScapiaTheme.dark(),
      home: const Scaffold(
        body: Center(child: Text('Scapia')),
      ),
    );
  }
}
