import 'package:drift/native.dart';
import 'package:drift/drift.dart' hide isNotNull;
import 'package:flutter_test/flutter_test.dart';
import 'package:kelasfun/core/database/app_database.dart';
import 'package:kelasfun/core/database/tables/students.dart';
import 'package:kelasfun/core/database/tables/subjects.dart';

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
    await db.into(db.subjects).insert(
      SubjectsCompanion.insert(name: 'Matematika', code: 'MTK'),
    );
  });

  tearDown(() async {
    await db.close();
  });

  group('GradeDao', () {
    test('insert grade', () async {
      await db.gradeDao.insertGrade(
        studentId: 1, subjectId: 1, score: 85.0,
        examType: 'UTS', semester: 'Ganjil 2025/2026',
      );
      final grades = await db.gradeDao.getGradesByStudent(1);
      expect(grades.length, 1);
      expect(grades.first.score, 85.0);
    });

    test('get average score by student', () async {
      await db.gradeDao.insertGrade(
        studentId: 1, subjectId: 1, score: 80.0,
        examType: 'UTS', semester: 'Ganjil 2025/2026',
      );
      await db.gradeDao.insertGrade(
        studentId: 1, subjectId: 1, score: 90.0,
        examType: 'UAS', semester: 'Ganjil 2025/2026',
      );
      final avg = await db.gradeDao.getAverageScore(1, 'Ganjil 2025/2026');
      expect(avg, 85.0);
    });

    test('duplicate grade updates instead of insert', () async {
      await db.gradeDao.insertGrade(
        studentId: 1, subjectId: 1, score: 80.0,
        examType: 'UTS', semester: 'Ganjil 2025/2026',
      );
      await db.gradeDao.insertGrade(
        studentId: 1, subjectId: 1, score: 90.0,
        examType: 'UTS', semester: 'Ganjil 2025/2026',
      );
      final grades = await db.gradeDao.getGradesByStudent(1);
      expect(grades.length, 1);
      expect(grades.first.score, 90.0);
    });

    test('get grades by student and semester', () async {
      await db.gradeDao.insertGrade(
        studentId: 1, subjectId: 1, score: 85.0,
        examType: 'UTS', semester: 'Ganjil 2025/2026',
      );
      await db.gradeDao.insertGrade(
        studentId: 1, subjectId: 1, score: 85.0,
        examType: 'UTS', semester: 'Genap 2025/2026',
      );
      final grades = await db.gradeDao.getGradesByStudentSemester(1, 'Ganjil 2025/2026');
      expect(grades.length, 1);
    });

    test('delete grade', () async {
      await db.gradeDao.insertGrade(
        studentId: 1, subjectId: 1, score: 85.0,
        examType: 'UTS', semester: 'Ganjil 2025/2026',
      );
      final grades = await db.gradeDao.getGradesByStudent(1);
      await db.gradeDao.deleteGrade(grades.first.id);
      final remaining = await db.gradeDao.getGradesByStudent(1);
      expect(remaining.length, 0);
    });
  });
}
