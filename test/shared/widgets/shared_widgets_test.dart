import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kelasfun/shared/widgets/app_card.dart';
import 'package:kelasfun/shared/widgets/app_button.dart';
import 'package:kelasfun/shared/widgets/app_text_field.dart';

void main() {
  group('AppCard', () {
    testWidgets('renders child content', (tester) async {
      await tester.pumpWidget(MaterialApp(
        home: Scaffold(body: AppCard(child: Text('Test'))),
      ));
      expect(find.text('Test'), findsOneWidget);
    });
  });

  group('AppButton', () {
    testWidgets('renders with label', (tester) async {
      await tester.pumpWidget(MaterialApp(
        home: Scaffold(body: AppButton(label: 'Submit', onPressed: () {})),
      ));
      expect(find.text('Submit'), findsOneWidget);
    });
  });

  group('AppTextField', () {
    testWidgets('renders with label', (tester) async {
      await tester.pumpWidget(MaterialApp(
        home: Scaffold(body: AppTextField(label: 'Name', onChanged: (_) {})),
      ));
      expect(find.text('Name'), findsOneWidget);
    });
  });
}
