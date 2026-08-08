import 'package:drift/native.dart';
import 'package:drift/drift.dart' hide Column;
import 'package:flutter_test/flutter_test.dart';
import 'package:kelasfun/app.dart';
import 'package:kelasfun/core/database/app_database.dart';

AppDatabase createTestDb() => AppDatabase.forTesting(DatabaseConnection(NativeDatabase.memory()));

void main() {
  testWidgets('App renders home screen', (WidgetTester tester) async {
    final db = createTestDb();
    await tester.pumpWidget(KelasFunApp(database: db));
    await tester.pump();
    expect(find.text('Presensi'), findsOneWidget);
    await db.close();
  });
}
