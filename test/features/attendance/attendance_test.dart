import 'package:drift/native.dart';
import 'package:drift/drift.dart' hide Column;
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:kelasfun/core/database/app_database.dart';
import 'package:kelasfun/features/attendance/attendance_screen.dart';

AppDatabase createTestDb() => AppDatabase.forTesting(DatabaseConnection(NativeDatabase.memory()));

void main() {
  testWidgets('AttendanceScreen shows presensi title', (tester) async {
    await tester.runAsync(() async {
      final db = createTestDb();
      await tester.pumpWidget(MaterialApp(
        home: Provider<AppDatabase>.value(
          value: db,
          child: const AttendanceScreen(),
        ),
      ));
      await tester.pump();
      expect(find.textContaining('Presensi'), findsWidgets);
      await tester.pumpWidget(const SizedBox());
      await tester.pump();
      await db.close();
    });
  });
}
