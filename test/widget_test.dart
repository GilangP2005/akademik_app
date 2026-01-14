import 'package:flutter_test/flutter_test.dart';
import 'package:akademik_app/main.dart';

void main() {
  testWidgets('App build test', (WidgetTester tester) async {
    await tester.pumpWidget(const AkademikApp());
    expect(find.byType(AkademikApp), findsOneWidget);
  });
}
