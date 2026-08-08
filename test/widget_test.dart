import 'package:flutter_test/flutter_test.dart';
import 'package:kelasfun/app.dart';

void main() {
  testWidgets('App renders home screen', (WidgetTester tester) async {
    await tester.pumpWidget(const KelasFunApp());
    expect(find.text('kelasFun'), findsOneWidget);
  });
}
