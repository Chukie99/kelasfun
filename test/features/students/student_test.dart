import 'package:drift/native.dart';
import 'package:drift/drift.dart' hide Column;
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:kelasfun/core/database/app_database.dart';
import 'package:kelasfun/features/students/student_list_screen.dart';

AppDatabase createTestDb() => AppDatabase.forTesting(DatabaseConnection(NativeDatabase.memory()));

void main() {
  testWidgets('StudentListScreen shows empty state', (tester) async {
    final db = createTestDb();
    await tester.pumpWidget(MaterialApp(
      home: Provider<AppDatabase>.value(
        value: db,
        child: const StudentListScreen(),
      ),
    ));
    await tester.pump();
    expect(find.text('Belum ada siswa'), findsOneWidget);
    await db.close();
  });
}
