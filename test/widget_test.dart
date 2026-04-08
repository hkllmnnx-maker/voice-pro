import 'package:flutter_test/flutter_test.dart';
import 'package:voice_pro/main.dart';

void main() {
  testWidgets('VoiceProApp renders splash screen', (WidgetTester tester) async {
    await tester.pumpWidget(const VoiceProApp());
    expect(find.text('صوت برو'), findsOneWidget);
  });
}
