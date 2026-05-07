import 'package:flutter_test/flutter_test.dart';
import 'package:temposet/main.dart';

void main() {
  testWidgets('App starts without crashing', (WidgetTester tester) async {
    await tester.pumpWidget(const TempoSetApp());
    expect(find.text('Metronome'), findsWidgets);
  });
}
