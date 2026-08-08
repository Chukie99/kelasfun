import 'package:drift/native.dart';
import 'package:drift/drift.dart' hide isNotNull;
import 'package:flutter_test/flutter_test.dart';
import 'package:kelasfun/core/database/app_database.dart';
import 'package:kelasfun/core/database/tables/students.dart';

AppDatabase createTestDb() => AppDatabase.forTesting(DatabaseConnection(NativeDatabase.memory()));

void main() {
  late AppDatabase db;

  setUp(() {
    db = createTestDb();
  });

  tearDown(() async {
    await db.close();
  });

  group('StudentDao', () {
    test('insert student returns id', () async {
      final id = await db.into(db.students).insert(
        StudentsCompanion.insert(
          nis: '2025001',
          fullName: 'Andi Pratama',
          className: '6A',
          gender: 'Laki-laki',
          qrData: '{"n":"2025001","nama":"Andi Pratama","k":"6A"}',
        ),
      );
      expect(id, greaterThan(0));
    });

    test('get all students returns list', () async {
      await db.into(db.students).insert(
        StudentsCompanion.insert(
          nis: '2025001', fullName: 'Andi', className: '6A',
          gender: 'Laki-laki', qrData: '{}',
        ),
      );
      final students = await (db.select(db.students)).get();
      expect(students.length, 1);
    });

    test('get student by nis', () async {
      await db.into(db.students).insert(
        StudentsCompanion.insert(
          nis: '2025001', fullName: 'Andi', className: '6A',
          gender: 'Laki-laki', qrData: '{}',
        ),
      );
      final student = await (db.select(db.students)
        ..where((t) => t.nis.equals('2025001'))).getSingleOrNull();
      expect(student, isNotNull);
      expect(student!.nis, '2025001');
    });

    test('delete student', () async {
      final id = await db.into(db.students).insert(
        StudentsCompanion.insert(
          nis: '2025001', fullName: 'Andi', className: '6A',
          gender: 'Laki-laki', qrData: '{}',
        ),
      );
      await (db.delete(db.students)..where((t) => t.id.equals(id))).go();
      final students = await (db.select(db.students)).get();
      expect(students.length, 0);
    });
  });

  group('AttendanceDao', () {
    test('mark attendance inserts record', () async {
      await db.into(db.students).insert(
        StudentsCompanion.insert(
          nis: '2025001', fullName: 'Andi', className: '6A',
          gender: 'Laki-laki', qrData: '{}',
        ),
      );
      await db.attendanceDao.markAttendance(
        studentId: 1, date: '2025-08-08',
        status: 'Hadir', scanMethod: 'QR_SCAN',
      );
      final records = await db.attendanceDao.getAttendanceByDate('2025-08-08');
      expect(records.length, 1);
    });

    test('duplicate student+date updates instead of insert', () async {
      await db.into(db.students).insert(
        StudentsCompanion.insert(
          nis: '2025001', fullName: 'Andi', className: '6A',
          gender: 'Laki-laki', qrData: '{}',
        ),
      );
      await db.attendanceDao.markAttendance(
        studentId: 1, date: '2025-08-08',
        status: 'Hadir', scanMethod: 'QR_SCAN',
      );
      await db.attendanceDao.markAttendance(
        studentId: 1, date: '2025-08-08',
        status: 'Izin', scanMethod: 'MANUAL',
      );
      final records = await db.attendanceDao.getAttendanceByDate('2025-08-08');
      expect(records.length, 1);
      expect(records.first.status, 'Izin');
    });
  });
}
