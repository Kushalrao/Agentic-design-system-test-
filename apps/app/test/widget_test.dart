import 'package:flutter_test/flutter_test.dart';
import 'package:app/main.dart';

void main() {
  testWidgets('ScapiaApp renders', (tester) async {
    await tester.pumpWidget(const ScapiaApp());
    expect(find.text('Scapia'), findsOneWidget);
  });
}
