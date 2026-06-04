import 'package:flutter_test/flutter_test.dart';
import 'package:medico_app/main.dart';

void main() {
  testWidgets('Smoke test', (WidgetTester tester) async {
    await tester.pumpWidget(const MedicoApp());
    expect(find.byType(MedicoApp), findsOneWidget);
  });
}
