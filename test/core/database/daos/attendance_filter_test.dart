import 'package:drift/native.dart';
import 'package:drift/drift.dart' hide isNotNull, isNull;
import 'package:flutter_test/flutter_test.dart';
import 'package:kelasfun/core/database/app_database.dart';
import 'package:kelasfun/core/utils/photo_helper.dart';

void main() {
  late AppDatabase db;

  setUp(() {
    db = AppDatabase.forTesting(DatabaseConnection(NativeDatabase.memory()));
  });

  tearDown(() async {
    await db.close();
  });

  group('Photo Helper', () {
    test('getInitials returns first letter for single name', () {
      expect(PhotoHelper.getInitials('Andi'), 'A');
    });

    test('getInitials returns first and last initials for multiple names', () {
      expect(PhotoHelper.getInitials('Andi Pratama'), 'AP');
    });

    test('getInitials handles extra spaces', () {
      expect(PhotoHelper.getInitials('  Andi  Pratama  '), 'AP');
    });

    test('getInitials returns ? for empty string', () {
      expect(PhotoHelper.getInitials(''), '?');
    });
  });

  group('Attendance Filter Logic', () {
    test('filter students by attendance status', () async {
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

      // Mark attendance for Andi (Hadir) and Budi (Sakit)
      await db.attendanceDao.markAttendance(
        studentId: studentId1, date: today,
        status: 'Hadir', scanMethod: 'QR_SCAN',
      );
      await db.attendanceDao.markAttendance(
        studentId: studentId2, date: today,
        status: 'Sakit', scanMethod: 'MANUAL',
      );
      // Citra = Belum Absen

      final allStudents = await db.studentDao.getAllStudents();
      final attendances = await db.attendanceDao.getAttendanceByDate(today);
      final attendanceMap = {for (final a in attendances) a.studentId: a};

      // Semua
      expect(allStudents.length, 3);

      // Hadir
      final hadir = allStudents.where((s) => attendanceMap[s.id]?.status == 'Hadir').toList();
      expect(hadir.length, 1);
      expect(hadir.first.fullName, 'Andi');

      // Sakit
      final sakit = allStudents.where((s) => attendanceMap[s.id]?.status == 'Sakit').toList();
      expect(sakit.length, 1);
      expect(sakit.first.fullName, 'Budi');

      // Belum Absen
      final belumAbsen = allStudents.where((s) => !attendanceMap.containsKey(s.id)).toList();
      expect(belumAbsen.length, 1);
      expect(belumAbsen.first.fullName, 'Citra');
    });

    test('attendance with description', () async {
      final studentId = await db.studentDao.insertStudent(
        nis: '001', fullName: 'Andi', className: '6A',
        gender: 'Laki-laki', qrData: '{"n":"001"}',
      );

      final today = DateTime.now().toIso8601String().substring(0, 10);

      await db.attendanceDao.markAttendance(
        studentId: studentId, date: today,
        status: 'Sakit', scanMethod: 'MANUAL',
        description: 'Sakit demam',
      );

      final attendance = await db.attendanceDao.getAttendanceByDate(today);
      expect(attendance.length, 1);
      expect(attendance.first.status, 'Sakit');
      expect(attendance.first.description, 'Sakit demam');
    });

    test('reset attendance removes record', () async {
      final studentId = await db.studentDao.insertStudent(
        nis: '001', fullName: 'Andi', className: '6A',
        gender: 'Laki-laki', qrData: '{"n":"001"}',
      );

      final today = DateTime.now().toIso8601String().substring(0, 10);

      await db.attendanceDao.markAttendance(
        studentId: studentId, date: today,
        status: 'Alpa', scanMethod: 'MANUAL',
      );

      var attendance = await db.attendanceDao.getAttendanceByDate(today);
      expect(attendance.length, 1);

      await db.attendanceDao.resetAttendance(studentId, today);

      attendance = await db.attendanceDao.getAttendanceByDate(today);
      expect(attendance.length, 0);
    });

    test('update attendance status', () async {
      final studentId = await db.studentDao.insertStudent(
        nis: '001', fullName: 'Andi', className: '6A',
        gender: 'Laki-laki', qrData: '{"n":"001"}',
      );

      final today = DateTime.now().toIso8601String().substring(0, 10);

      await db.attendanceDao.markAttendance(
        studentId: studentId, date: today,
        status: 'Alpa', scanMethod: 'MANUAL',
      );

      // Update to Sakit
      await db.attendanceDao.markAttendance(
        studentId: studentId, date: today,
        status: 'Sakit', scanMethod: 'MANUAL',
        description: 'Sakit perut',
      );

      final attendance = await db.attendanceDao.getAttendanceByDate(today);
      expect(attendance.length, 1);
      expect(attendance.first.status, 'Sakit');
      expect(attendance.first.description, 'Sakit perut');
    });
  });

  group('Student with Photo', () {
    test('insert student with photoPath', () async {
      final id = await db.studentDao.insertStudent(
        nis: '001', fullName: 'Andi', className: '6A',
        gender: 'Laki-laki', qrData: '{"n":"001"}',
        photoPath: '/path/to/photo.jpg',
      );

      final student = await db.studentDao.getStudentById(id);
      expect(student, isNotNull);
      expect(student!.photoPath, '/path/to/photo.jpg');
    });

    test('student without photo has null photoPath', () async {
      final id = await db.studentDao.insertStudent(
        nis: '001', fullName: 'Andi', className: '6A',
        gender: 'Laki-laki', qrData: '{"n":"001"}',
      );

      final student = await db.studentDao.getStudentById(id);
      expect(student, isNotNull);
      expect(student!.photoPath, isNull);
    });

    test('update student photoPath', () async {
      final id = await db.studentDao.insertStudent(
        nis: '001', fullName: 'Andi', className: '6A',
        gender: 'Laki-laki', qrData: '{"n":"001"}',
      );

      final student = await db.studentDao.getStudentById(id);
      expect(student!.photoPath, isNull);

      await db.studentDao.updateStudent(StudentsCompanion(
        id: Value(id),
        nis: Value(student.nis),
        fullName: Value(student.fullName),
        className: Value(student.className),
        gender: Value(student.gender),
        qrData: Value(student.qrData),
        photoPath: const Value('/path/to/new_photo.jpg'),
      ));

      final result = await db.studentDao.getStudentById(id);
      expect(result!.photoPath, '/path/to/new_photo.jpg');
    });
  });
}
