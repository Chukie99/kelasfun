import 'package:drift/native.dart';
import 'package:drift/drift.dart' hide isNotNull;
import 'package:flutter_test/flutter_test.dart';
import 'package:kelasfun/core/database/app_database.dart';

void main() {
  late AppDatabase db;

  setUp(() {
    db = AppDatabase.forTesting(DatabaseConnection(NativeDatabase.memory()));
  });

  tearDown(() async {
    await db.close();
  });

  group('Ranking Calculation', () {
    test('average score calculation', () async {
      // Insert students
      final studentId1 = await db.studentDao.insertStudent(
        nis: '001', fullName: 'Andi', className: '6A',
        gender: 'Laki-laki', qrData: '{"n":"001","nama":"Andi","k":"6A"}',
      );
      final studentId2 = await db.studentDao.insertStudent(
        nis: '002', fullName: 'Budi', className: '6A',
        gender: 'Laki-laki', qrData: '{"n":"002","nama":"Budi","k":"6A"}',
      );

      // Insert subjects
      final subjectId = await db.subjectDao.insertSubject(
        name: 'Matematika', code: 'MTK',
      );

      // Insert grades
      await db.gradeDao.insertGrade(
        studentId: studentId1, subjectId: subjectId,
        score: 85, examType: 'UTS', semester: 'Ganjil 2026',
      );
      await db.gradeDao.insertGrade(
        studentId: studentId1, subjectId: subjectId,
        score: 90, examType: 'UAS', semester: 'Ganjil 2026',
      );
      await db.gradeDao.insertGrade(
        studentId: studentId2, subjectId: subjectId,
        score: 75, examType: 'UTS', semester: 'Ganjil 2026',
      );
      await db.gradeDao.insertGrade(
        studentId: studentId2, subjectId: subjectId,
        score: 80, examType: 'UAS', semester: 'Ganjil 2026',
      );

      // Test average calculation
      final avg1 = await db.gradeDao.getAverageScore(studentId1, 'Ganjil 2026');
      final avg2 = await db.gradeDao.getAverageScore(studentId2, 'Ganjil 2026');

      expect(avg1, 87.5); // (85 + 90) / 2
      expect(avg2, 77.5); // (75 + 80) / 2
    });

    test('ranking order by average', () async {
      final studentId1 = await db.studentDao.insertStudent(
        nis: '001', fullName: 'Andi', className: '6A',
        gender: 'Laki-laki', qrData: '{"n":"001","nama":"Andi","k":"6A"}',
      );
      final studentId2 = await db.studentDao.insertStudent(
        nis: '002', fullName: 'Budi', className: '6A',
        gender: 'Laki-laki', qrData: '{"n":"002","nama":"Budi","k":"6A"}',
      );
      final studentId3 = await db.studentDao.insertStudent(
        nis: '003', fullName: 'Citra', className: '6A',
        gender: 'Perempuan', qrData: '{"n":"003","nama":"Citra","k":"6A"}',
      );

      final subjectId = await db.subjectDao.insertSubject(
        name: 'Matematika', code: 'MTK',
      );

      // Andi: avg 90
      await db.gradeDao.insertGrade(
        studentId: studentId1, subjectId: subjectId,
        score: 90, examType: 'UTS', semester: 'Ganjil 2026',
      );
      // Budi: avg 70
      await db.gradeDao.insertGrade(
        studentId: studentId2, subjectId: subjectId,
        score: 70, examType: 'UTS', semester: 'Ganjil 2026',
      );
      // Citra: avg 80
      await db.gradeDao.insertGrade(
        studentId: studentId3, subjectId: subjectId,
        score: 80, examType: 'UTS', semester: 'Ganjil 2026',
      );

      final ranking = await db.gradeDao.getRanking('Ganjil 2026');

      expect(ranking.length, 3);
      expect(ranking[0].score, 90.0); // Andi
      expect(ranking[1].score, 80.0); // Citra
      expect(ranking[2].score, 70.0); // Budi
    });
  });

  group('Attendance Percentage', () {
    test('calculate attendance stats', () async {
      final studentId1 = await db.studentDao.insertStudent(
        nis: '001', fullName: 'Andi', className: '6A',
        gender: 'Laki-laki', qrData: '{"n":"001","nama":"Andi","k":"6A"}',
      );
      final studentId2 = await db.studentDao.insertStudent(
        nis: '002', fullName: 'Budi', className: '6A',
        gender: 'Laki-laki', qrData: '{"n":"002","nama":"Budi","k":"6A"}',
      );
      final studentId3 = await db.studentDao.insertStudent(
        nis: '003', fullName: 'Citra', className: '6A',
        gender: 'Perempuan', qrData: '{"n":"003","nama":"Citra","k":"6A"}',
      );

      final today = DateTime.now().toIso8601String().substring(0, 10);

      // Mark attendance
      await db.attendanceDao.markAttendance(
        studentId: studentId1, date: today,
        status: 'hadir', scanMethod: 'QR_SCAN',
      );
      await db.attendanceDao.markAttendance(
        studentId: studentId2, date: today,
        status: 'sakit', scanMethod: 'MANUAL',
      );
      // studentId3 = alpha (no attendance)

      final attendance = await db.attendanceDao.getAttendanceByDate(today);
      final allStudents = await db.studentDao.getAllStudents();

      final totalStudents = allStudents.length;
      final hadir = attendance.where((a) => a.status == 'hadir').length;
      final sakit = attendance.where((a) => a.status == 'sakit').length;
      final izin = attendance.where((a) => a.status == 'izin').length;
      final alpha = totalStudents - hadir - sakit - izin;

      expect(totalStudents, 3);
      expect(hadir, 1);
      expect(sakit, 1);
      expect(izin, 0);
      expect(alpha, 1);

      final percentage = (hadir / totalStudents * 100).toStringAsFixed(1);
      expect(percentage, '33.3');
    });
  });

  group('Point Accumulation', () {
    test('total points by student', () async {
      final studentId = await db.studentDao.insertStudent(
        nis: '001', fullName: 'Andi', className: '6A',
        gender: 'Laki-laki', qrData: '{"n":"001","nama":"Andi","k":"6A"}',
      );

      // Insert points
      await db.pointDao.insertPoint(
        studentId: studentId, type: 'VIOLATION',
        category: 'Terlambat', pointValue: -5,
        date: '2026-08-01', description: 'Terlambat 15 menit',
      );
      await db.pointDao.insertPoint(
        studentId: studentId, type: 'VIOLATION',
        category: 'Tidak Pakai Seragam', pointValue: -10,
        date: '2026-08-02', description: '',
      );
      await db.pointDao.insertPoint(
        studentId: studentId, type: 'ACHIEVEMENT',
        category: 'Juara 1', pointValue: 20,
        date: '2026-08-03', description: 'Lomba Matematika',
      );

      final totalPoints = await db.pointDao.getTotalPoints(studentId);

      expect(totalPoints, 5); // -5 + -10 + 20 = 5
    });

    test('all total points', () async {
      final studentId1 = await db.studentDao.insertStudent(
        nis: '001', fullName: 'Andi', className: '6A',
        gender: 'Laki-laki', qrData: '{"n":"001","nama":"Andi","k":"6A"}',
      );
      final studentId2 = await db.studentDao.insertStudent(
        nis: '002', fullName: 'Budi', className: '6A',
        gender: 'Laki-laki', qrData: '{"n":"002","nama":"Budi","k":"6A"}',
      );

      await db.pointDao.insertPoint(
        studentId: studentId1, type: 'ACHIEVEMENT',
        category: 'Juara', pointValue: 15,
        date: '2026-08-01',
      );
      await db.pointDao.insertPoint(
        studentId: studentId2, type: 'VIOLATION',
        category: 'Terlambat', pointValue: -5,
        date: '2026-08-01',
      );

      final allPoints = await db.pointDao.getAllTotalPoints();

      expect(allPoints[studentId1], 15);
      expect(allPoints[studentId2], -5);
    });
  });

  group('Division by Zero / Empty Data', () {
    test('ranking with no students returns empty list', () async {
      final ranking = await db.gradeDao.getRanking('Ganjil 2026');
      expect(ranking, isEmpty);
    });

    test('average score with no grades returns 0', () async {
      final studentId = await db.studentDao.insertStudent(
        nis: '001', fullName: 'Andi', className: '6A',
        gender: 'Laki-laki', qrData: '{"n":"001"}',
      );
      final avg = await db.gradeDao.getAverageScore(studentId, 'Ganjil 2026');
      expect(avg, 0.0);
    });

    test('attendance percentage with no students returns 0', () async {
      final today = DateTime.now().toIso8601String().substring(0, 10);
      final attendance = await db.attendanceDao.getAttendanceByDate(today);
      final allStudents = await db.studentDao.getAllStudents();
      final totalStudents = allStudents.length;
      final percentage = totalStudents > 0
          ? (attendance.length / totalStudents * 100).toStringAsFixed(1)
          : '0.0';
      expect(percentage, '0.0');
    });
  });

  group('Attendance Dedup', () {
    test('duplicate student+date updates instead of insert', () async {
      final studentId = await db.studentDao.insertStudent(
        nis: '001', fullName: 'Andi', className: '6A',
        gender: 'Laki-laki', qrData: '{"n":"001","nama":"Andi","k":"6A"}',
      );

      final today = DateTime.now().toIso8601String().substring(0, 10);

      // First mark
      await db.attendanceDao.markAttendance(
        studentId: studentId, date: today,
        status: 'hadir', scanMethod: 'QR_SCAN',
      );

      // Second mark (should update, not insert)
      await db.attendanceDao.markAttendance(
        studentId: studentId, date: today,
        status: 'izin', scanMethod: 'MANUAL',
      );

      final attendance = await db.attendanceDao.getAttendanceByDate(today);
      expect(attendance.length, 1);
      expect(attendance.first.status, 'izin');
    });
  });
}
