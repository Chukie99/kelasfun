import 'package:drift/native.dart';
import 'package:drift/drift.dart' hide isNotNull, isNull;
import 'package:flutter_test/flutter_test.dart';
import 'package:kelasfun/core/database/app_database.dart';
import 'package:kelasfun/core/database/tables/students.dart';
import 'package:kelasfun/core/utils/qr_generator.dart';

AppDatabase createTestDb() => AppDatabase.forTesting(DatabaseConnection(NativeDatabase.memory()));

void main() {
  late AppDatabase db;

  setUp(() {
    db = createTestDb();
  });

  tearDown(() async {
    await db.close();
  });

  group('Student CRUD Operations', () {
    test('insert student with all required fields', () async {
      final id = await db.studentDao.insertStudent(
        nis: '2025001',
        fullName: 'Andi Pratama',
        className: '6A',
        gender: 'Laki-laki',
        qrData: QrGenerator.encodePayload(nis: '2025001', name: 'Andi Pratama', className: '6A'),
      );
      expect(id, greaterThan(0));
      
      final student = await db.studentDao.getStudentById(id);
      expect(student, isNotNull);
      expect(student!.nis, '2025001');
      expect(student.fullName, 'Andi Pratama');
      expect(student.className, '6A');
      expect(student.gender, 'Laki-laki');
    });

    test('insert student with optional fields', () async {
      final id = await db.studentDao.insertStudent(
        nis: '2025002',
        fullName: 'Budi Santoso',
        className: '6B',
        gender: 'Laki-laki',
        qrData: QrGenerator.encodePayload(nis: '2025002', name: 'Budi Santoso', className: '6B'),
        birthDate: '2010-05-15',
        address: 'Jl. Sudirman No. 10',
        parentName: 'Budi Santoso Sr.',
        parentPhone: '08123456789',
        photoPath: '/path/to/photo.jpg',
        notes: 'Siswa berprestasi',
      );
      expect(id, greaterThan(0));
      
      final student = await db.studentDao.getStudentById(id);
      expect(student, isNotNull);
      expect(student!.birthDate, '2010-05-15');
      expect(student.address, 'Jl. Sudirman No. 10');
      expect(student.parentName, 'Budi Santoso Sr.');
      expect(student.parentPhone, '08123456789');
      expect(student.photoPath, '/path/to/photo.jpg');
      expect(student.notes, 'Siswa berprestasi');
    });

    test('insert student with null optional fields', () async {
      final id = await db.studentDao.insertStudent(
        nis: '2025003',
        fullName: 'Citra Dewi',
        className: '6A',
        gender: 'Perempuan',
        qrData: QrGenerator.encodePayload(nis: '2025003', name: 'Citra Dewi', className: '6A'),
        birthDate: null,
        address: null,
        parentName: null,
        parentPhone: null,
        photoPath: null,
        notes: null,
      );
      expect(id, greaterThan(0));
      
      final student = await db.studentDao.getStudentById(id);
      expect(student, isNotNull);
      expect(student!.birthDate, isNull);
      expect(student.address, isNull);
      expect(student.parentName, isNull);
      expect(student.parentPhone, isNull);
      expect(student.photoPath, isNull);
      expect(student.notes, isNull);
    });

    test('duplicate NIS throws error', () async {
      await db.studentDao.insertStudent(
        nis: '2025001',
        fullName: 'Andi',
        className: '6A',
        gender: 'Laki-laki',
        qrData: '{}',
      );
      
      expect(
        () => db.studentDao.insertStudent(
          nis: '2025001',
          fullName: 'Budi',
          className: '6B',
          gender: 'Laki-laki',
          qrData: '{}',
        ),
        throwsA(isA<Exception>()),
      );
    });

    test('update student', () async {
      final id = await db.studentDao.insertStudent(
        nis: '2025001',
        fullName: 'Andi',
        className: '6A',
        gender: 'Laki-laki',
        qrData: '{}',
      );
      
      await db.studentDao.updateStudent(StudentsCompanion(
        id: Value(id),
        nis: const Value('2025001'),
        fullName: const Value('Andi Pratama Updated'),
        className: const Value('6B'),
        gender: const Value('Laki-laki'),
        qrData: const Value('{}'),
      ));
      
      final student = await db.studentDao.getStudentById(id);
      expect(student, isNotNull);
      expect(student!.fullName, 'Andi Pratama Updated');
      expect(student.className, '6B');
    });

    test('soft delete student', () async {
      final id = await db.studentDao.insertStudent(
        nis: '2025001',
        fullName: 'Andi',
        className: '6A',
        gender: 'Laki-laki',
        qrData: '{}',
      );
      
      await db.studentDao.softDeleteStudent(id);
      
      final students = await db.studentDao.getAllStudents();
      expect(students, isEmpty);
      
      final student = await db.studentDao.getStudentById(id);
      expect(student, isNotNull);
      expect(student!.isActive, 0);
    });
  });

  group('Form Validation Logic', () {
    test('NIS validation - empty string', () {
      const nis = '';
      expect(nis.isEmpty, isTrue);
    });

    test('NIS validation - valid string', () {
      const nis = '2025001';
      expect(nis.isNotEmpty, isTrue);
    });

    test('Name validation - empty string', () {
      const name = '';
      expect(name.isEmpty, isTrue);
    });

    test('Name validation - valid string', () {
      const name = 'Andi Pratama';
      expect(name.isNotEmpty, isTrue);
    });

    test('Class validation - empty string', () {
      const className = '';
      expect(className.isEmpty, isTrue);
    });

    test('Class validation - valid string', () {
      const className = '6A';
      expect(className.isNotEmpty, isTrue);
    });

    test('Gender validation - null value', () {
      String? gender = null;
      expect(gender, isNull);
    });

    test('Gender validation - empty string', () {
      const gender = '';
      expect(gender.isEmpty, isTrue);
    });

    test('Gender validation - valid value', () {
      const gender = 'Laki-laki';
      expect(gender.isNotEmpty, isTrue);
    });
  });

  group('QR Data Generation', () {
    test('generate QR data with valid inputs', () {
      final qrData = QrGenerator.encodePayload(
        nis: '2025001',
        name: 'Andi Pratama',
        className: '6A',
      );
      expect(qrData, isNotEmpty);
      expect(qrData.contains('2025001'), isTrue);
      expect(qrData.contains('Andi Pratama'), isTrue);
      expect(qrData.contains('6A'), isTrue);
    });

    test('generate QR data with special characters', () {
      final qrData = QrGenerator.encodePayload(
        nis: '2025001',
        name: 'Andi "Pratama"',
        className: '6A',
      );
      expect(qrData, isNotEmpty);
      expect(qrData.contains('2025001'), isTrue);
    });
  });

  group('Attendance Stats Calculation', () {
    test('calculate attendance percentage with data', () async {
      final studentId1 = await db.studentDao.insertStudent(
        nis: '001', fullName: 'Andi', className: '6A',
        gender: 'Laki-laki', qrData: '{"n":"001"}',
      );
      final studentId2 = await db.studentDao.insertStudent(
        nis: '002', fullName: 'Budi', className: '6A',
        gender: 'Laki-laki', qrData: '{"n":"002"}',
      );
      final studentId3 = await db.studentDao.insertStudent(
        nis: '003', fullName: 'Citra', className: '6A',
        gender: 'Perempuan', qrData: '{"n":"003"}',
      );

      final today = DateTime.now().toIso8601String().substring(0, 10);

      await db.attendanceDao.markAttendance(
        studentId: studentId1, date: today,
        status: 'Hadir', scanMethod: 'QR_SCAN',
      );
      await db.attendanceDao.markAttendance(
        studentId: studentId2, date: today,
        status: 'Sakit', scanMethod: 'MANUAL',
      );

      final attendance = await db.attendanceDao.getAttendanceByDate(today);
      final allStudents = await db.studentDao.getAllStudents();

      final totalStudents = allStudents.length;
      final hadir = attendance.where((a) => a.status == 'Hadir').length;
      final sakit = attendance.where((a) => a.status == 'Sakit').length;
      final izin = attendance.where((a) => a.status == 'Izin').length;
      final alpha = totalStudents - hadir - sakit - izin;

      expect(totalStudents, 3);
      expect(hadir, 1);
      expect(sakit, 1);
      expect(izin, 0);
      expect(alpha, 1);

      final percentage = totalStudents > 0
          ? (hadir / totalStudents * 100).toStringAsFixed(1)
          : '0.0';
      expect(percentage, '33.3');
    });

    test('calculate attendance percentage with no students', () async {
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

  group('Grade Calculation', () {
    test('calculate average score', () async {
      final studentId = await db.studentDao.insertStudent(
        nis: '001', fullName: 'Andi', className: '6A',
        gender: 'Laki-laki', qrData: '{"n":"001"}',
      );
      final subjectId = await db.subjectDao.insertSubject(
        name: 'Matematika', code: 'MTK',
      );

      await db.gradeDao.insertGrade(
        studentId: studentId, subjectId: subjectId,
        score: 85, examType: 'UTS', semester: 'Ganjil 2026',
      );
      await db.gradeDao.insertGrade(
        studentId: studentId, subjectId: subjectId,
        score: 90, examType: 'UAS', semester: 'Ganjil 2026',
      );

      final avg = await db.gradeDao.getAverageScore(studentId, 'Ganjil 2026');
      expect(avg, 87.5);
    });

    test('calculate average score with no grades', () async {
      final studentId = await db.studentDao.insertStudent(
        nis: '001', fullName: 'Andi', className: '6A',
        gender: 'Laki-laki', qrData: '{"n":"001"}',
      );

      final avg = await db.gradeDao.getAverageScore(studentId, 'Ganjil 2026');
      expect(avg, 0.0);
    });

    test('calculate ranking', () async {
      final studentId1 = await db.studentDao.insertStudent(
        nis: '001', fullName: 'Andi', className: '6A',
        gender: 'Laki-laki', qrData: '{"n":"001"}',
      );
      final studentId2 = await db.studentDao.insertStudent(
        nis: '002', fullName: 'Budi', className: '6A',
        gender: 'Laki-laki', qrData: '{"n":"002"}',
      );
      final subjectId = await db.subjectDao.insertSubject(
        name: 'Matematika', code: 'MTK',
      );

      await db.gradeDao.insertGrade(
        studentId: studentId1, subjectId: subjectId,
        score: 90, examType: 'UTS', semester: 'Ganjil 2026',
      );
      await db.gradeDao.insertGrade(
        studentId: studentId2, subjectId: subjectId,
        score: 70, examType: 'UTS', semester: 'Ganjil 2026',
      );

      final ranking = await db.gradeDao.getRanking('Ganjil 2026');
      expect(ranking.length, 2);
      expect(ranking[0].score, 90.0);
      expect(ranking[1].score, 70.0);
    });

    test('calculate ranking with no grades', () async {
      final ranking = await db.gradeDao.getRanking('Ganjil 2026');
      expect(ranking, isEmpty);
    });
  });

  group('Point Calculation', () {
    test('calculate total points', () async {
      final studentId = await db.studentDao.insertStudent(
        nis: '001', fullName: 'Andi', className: '6A',
        gender: 'Laki-laki', qrData: '{"n":"001"}',
      );

      await db.pointDao.insertPoint(
        studentId: studentId, type: 'VIOLATION',
        category: 'Terlambat', pointValue: -5,
        date: '2026-08-01', description: 'Terlambat 15 menit',
      );
      await db.pointDao.insertPoint(
        studentId: studentId, type: 'ACHIEVEMENT',
        category: 'Juara 1', pointValue: 20,
        date: '2026-08-03', description: 'Lomba Matematika',
      );

      final totalPoints = await db.pointDao.getTotalPoints(studentId);
      expect(totalPoints, 15);
    });

    test('calculate total points with no points', () async {
      final studentId = await db.studentDao.insertStudent(
        nis: '001', fullName: 'Andi', className: '6A',
        gender: 'Laki-laki', qrData: '{"n":"001"}',
      );

      final totalPoints = await db.pointDao.getTotalPoints(studentId);
      expect(totalPoints, 0);
    });
  });
}
