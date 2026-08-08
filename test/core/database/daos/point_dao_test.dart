import 'package:drift/native.dart';
import 'package:drift/drift.dart' hide isNotNull;
import 'package:flutter_test/flutter_test.dart';
import 'package:kelasfun/core/database/app_database.dart';
import 'package:kelasfun/core/database/tables/students.dart';

AppDatabase createTestDb() => AppDatabase.forTesting(DatabaseConnection(NativeDatabase.memory()));

void main() {
  late AppDatabase db;

  setUp(() async {
    db = createTestDb();
    await db.into(db.students).insert(
      StudentsCompanion.insert(
        nis: '2025001', fullName: 'Andi', className: '6A',
        gender: 'Laki-laki', qrData: '{}',
      ),
    );
  });

  tearDown(() async {
    await db.close();
  });

  group('PointDao', () {
    test('insert point', () async {
      await db.pointDao.insertPoint(
        studentId: 1, type: 'VIOLATION', category: 'Terlambat',
        pointValue: -5, date: '2025-08-08',
      );
      final points = await db.pointDao.getPointsByStudent(1);
      expect(points.length, 1);
      expect(points.first.pointValue, -5);
    });

    test('get total points by student', () async {
      await db.pointDao.insertPoint(
        studentId: 1, type: 'VIOLATION', category: 'Terlambat',
        pointValue: -5, date: '2025-08-08',
      );
      await db.pointDao.insertPoint(
        studentId: 1, type: 'ACHIEVEMENT', category: 'Juara Olimpiade',
        pointValue: 10, date: '2025-08-08',
      );
      final total = await db.pointDao.getTotalPoints(1);
      expect(total, 5);
    });

    test('get points by date', () async {
      await db.pointDao.insertPoint(
        studentId: 1, type: 'VIOLATION', category: 'Terlambat',
        pointValue: -5, date: '2025-08-08',
      );
      await db.pointDao.insertPoint(
        studentId: 1, type: 'VIOLATION', category: 'Terlambat',
        pointValue: -5, date: '2025-08-09',
      );
      final points = await db.pointDao.getPointsByDate('2025-08-08');
      expect(points.length, 1);
    });

    test('get all total points', () async {
      await db.into(db.students).insert(
        StudentsCompanion.insert(
          nis: '2025002', fullName: 'Budi', className: '6A',
          gender: 'Laki-laki', qrData: '{"n":"2025002"}',
        ),
      );
      await db.pointDao.insertPoint(
        studentId: 1, type: 'VIOLATION', category: 'Terlambat',
        pointValue: -5, date: '2025-08-08',
      );
      await db.pointDao.insertPoint(
        studentId: 2, type: 'ACHIEVEMENT', category: 'Juara',
        pointValue: 10, date: '2025-08-08',
      );
      final totals = await db.pointDao.getAllTotalPoints();
      expect(totals.length, 2);
      expect(totals[1], -5);
      expect(totals[2], 10);
    });

    test('delete point', () async {
      await db.pointDao.insertPoint(
        studentId: 1, type: 'VIOLATION', category: 'Terlambat',
        pointValue: -5, date: '2025-08-08',
      );
      final points = await db.pointDao.getPointsByStudent(1);
      await db.pointDao.deletePoint(points.first.id);
      final remaining = await db.pointDao.getPointsByStudent(1);
      expect(remaining.length, 0);
    });
  });
}
