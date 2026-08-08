import 'dart:convert';
import 'dart:io';
import 'package:drift/native.dart';
import 'package:drift/drift.dart' hide isNotNull;
import 'package:flutter_test/flutter_test.dart';
import 'package:kelasfun/core/database/app_database.dart';
import 'package:kelasfun/core/sync/sync_config.dart';
import 'package:kelasfun/core/utils/pdf_generator.dart';

void main() {
  late AppDatabase db;

  setUp(() {
    db = AppDatabase.forTesting(DatabaseConnection(NativeDatabase.memory()));
  });

  tearDown(() async {
    await db.close();
  });

  group('Sync Config', () {
    test('creates from json', () {
      final config = SyncConfig.fromJson({
        'serverUrl': 'http://192.168.1.100:8080',
        'apiKey': 'test-key-123',
      });

      expect(config.serverUrl, 'http://192.168.1.100:8080');
      expect(config.apiKey, 'test-key-123');
    });

    test('serializes to json', () {
      final config = SyncConfig(
        serverUrl: 'http://192.168.1.100:8080',
        apiKey: 'test-key-123',
      );

      final json = config.toJson();
      expect(json['serverUrl'], 'http://192.168.1.100:8080');
      expect(json['apiKey'], 'test-key-123');
    });
  });

  group('PDF Generator', () {
    test('generate biodata PDF with school name', () async {
      final pdf = await PdfGenerator.generateBiodata(
        nis: '001',
        fullName: 'Andi Pratama',
        className: '6A',
        gender: 'Laki-laki',
        birthDate: '2015-05-15',
        address: 'Jl. Merdeka No. 10',
        parentName: 'Budi Pratama',
        parentPhone: '08123456789',
        schoolName: 'SDN 01 Jakarta',
      );

      expect(pdf, isNotNull);
      expect(pdf!.isNotEmpty, true);
    });

    test('generate KTP student cards', () async {
      final students = [
        {'nis': '001', 'name': 'Andi', 'class': '6A'},
        {'nis': '002', 'name': 'Budi', 'class': '6A'},
      ];

      final pdf = await PdfGenerator.generateStudentCards(
        students: students,
        schoolName: 'SDN 01 Jakarta',
      );

      expect(pdf, isNotNull);
      expect(pdf!.isNotEmpty, true);
    });

    test('generate report card', () async {
      final grades = [
        {
          'subject': 'Matematika',
          'uts': 85,
          'uas': 90,
          'tugas': 88,
          'average': 87.7,
        },
      ];

      final pdf = await PdfGenerator.generateReportCard(
        studentName: 'Andi Pratama',
        nis: '001',
        className: '6A',
        semester: 'Ganjil 2026',
        grades: grades,
        totalViolationPoints: 10,
        totalAchievementPoints: 20,
        rank: 1,
        totalStudents: 30,
        schoolName: 'SDN 01 Jakarta',
      );

      expect(pdf, isNotNull);
      expect(pdf!.isNotEmpty, true);
    });
  });

  group('Database Operations', () {
    test('insert and retrieve student', () async {
      final id = await db.studentDao.insertStudent(
        nis: '001', fullName: 'Andi', className: '6A',
        gender: 'Laki-laki', qrData: '{"n":"001","nama":"Andi","k":"6A"}',
        birthDate: '2015-05-15',
        address: 'Jl. Merdeka No. 10',
        parentName: 'Budi Pratama',
        parentPhone: '08123456789',
      );

      final student = await db.studentDao.getStudentById(id);

      expect(student, isNotNull);
      expect(student!.nis, '001');
      expect(student.fullName, 'Andi');
      expect(student.birthDate, '2015-05-15');
      expect(student.address, 'Jl. Merdeka No. 10');
      expect(student.parentName, 'Budi Pratama');
      expect(student.parentPhone, '08123456789');
    });

    test('insert and retrieve attendance', () async {
      final studentId = await db.studentDao.insertStudent(
        nis: '001', fullName: 'Andi', className: '6A',
        gender: 'Laki-laki', qrData: '{"n":"001","nama":"Andi","k":"6A"}',
      );

      final today = DateTime.now().toIso8601String().substring(0, 10);

      await db.attendanceDao.markAttendance(
        studentId: studentId, date: today,
        status: 'hadir', scanMethod: 'QR_SCAN',
      );

      final attendance = await db.attendanceDao.getAttendanceByDate(today);

      expect(attendance.length, 1);
      expect(attendance.first.status, 'hadir');
      expect(attendance.first.scanMethod, 'QR_SCAN');
    });

    test('settings CRUD', () async {
      await db.settingsDao.setSetting('school_name', 'SDN 01 Jakarta');
      await db.settingsDao.setSetting('school_address', 'Jl. Merdeka No. 10');

      final name = await db.settingsDao.getSetting('school_name');
      final address = await db.settingsDao.getSetting('school_address');

      expect(name, 'SDN 01 Jakarta');
      expect(address, 'Jl. Merdeka No. 10');

      // Update
      await db.settingsDao.setSetting('school_name', 'SDN 02 Jakarta');
      final updatedName = await db.settingsDao.getSetting('school_name');
      expect(updatedName, 'SDN 02 Jakarta');
    });

    test('set school profile', () async {
      await db.settingsDao.setSchoolProfile(
        name: 'SDN 01 Jakarta',
        address: 'Jl. Merdeka No. 10',
        city: 'Jakarta Pusat',
        province: 'DKI Jakarta',
        phone: '021-1234567',
        email: 'sdn01@email.com',
      );

      final settings = await db.settingsDao.getAllSettings();

      expect(settings['school_name'], 'SDN 01 Jakarta');
      expect(settings['school_address'], 'Jl. Merdeka No. 10');
      expect(settings['school_city'], 'Jakarta Pusat');
      expect(settings['school_province'], 'DKI Jakarta');
      expect(settings['school_phone'], '021-1234567');
      expect(settings['school_email'], 'sdn01@email.com');
    });
  });

  group('Grade Operations', () {
    test('upsert grade on duplicate', () async {
      final studentId = await db.studentDao.insertStudent(
        nis: '001', fullName: 'Andi', className: '6A',
        gender: 'Laki-laki', qrData: '{"n":"001","nama":"Andi","k":"6A"}',
      );
      final subjectId = await db.subjectDao.insertSubject(
        name: 'Matematika', code: 'MTK',
      );

      // First insert
      await db.gradeDao.insertGrade(
        studentId: studentId, subjectId: subjectId,
        score: 85, examType: 'UTS', semester: 'Ganjil 2026',
      );

      // Second insert (should update)
      await db.gradeDao.insertGrade(
        studentId: studentId, subjectId: subjectId,
        score: 90, examType: 'UTS', semester: 'Ganjil 2026',
      );

      final grades = await db.gradeDao.getGradesByStudent(studentId);
      expect(grades.length, 1);
      expect(grades.first.score, 90.0);
    });
  });

  group('Point Operations', () {
    test('insert and delete point', () async {
      final studentId = await db.studentDao.insertStudent(
        nis: '001', fullName: 'Andi', className: '6A',
        gender: 'Laki-laki', qrData: '{"n":"001","nama":"Andi","k":"6A"}',
      );

      final pointId = await db.pointDao.insertPoint(
        studentId: studentId, type: 'VIOLATION',
        category: 'Terlambat', pointValue: -5,
        date: '2026-08-01',
      );

      final points = await db.pointDao.getPointsByStudent(studentId);
      expect(points.length, 1);

      await db.pointDao.deletePoint(pointId);

      final pointsAfterDelete = await db.pointDao.getPointsByStudent(studentId);
      expect(pointsAfterDelete.length, 0);
    });
  });
}
