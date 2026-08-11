import 'package:drift/native.dart';
import 'package:drift/drift.dart' hide isNotNull, isNull;
import 'package:sqlite3/sqlite3.dart' show SqliteException;
import 'package:flutter_test/flutter_test.dart';
import 'package:kelasfun/core/database/app_database.dart';
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

  group('Student Save Integration - Production Flow', () {
    test('insertStudent with exact form data like user fills', () async {
      final nis = '12345';
      final name = 'Budi Santoso';
      final className = '1A';
      final gender = 'Laki-laki';
      final qrData = QrGenerator.encodePayload(
        nis: nis,
        name: name,
        className: className,
      );

      expect(qrData, isNotEmpty);
      expect(qrData, '{"n":"12345","nama":"Budi Santoso","k":"1A"}');

      final id = await db.studentDao.insertStudent(
        nis: nis,
        fullName: name,
        className: className,
        gender: gender,
        qrData: qrData,
        birthDate: null,
        address: null,
        parentName: null,
        parentPhone: null,
        photoPath: null,
        notes: null,
      );

      expect(id, greaterThan(0));

      final student = await db.studentDao.getStudentByNis(nis);
      expect(student, isNotNull);
      expect(student!.fullName, name);
      expect(student.className, className);
      expect(student.gender, gender);
      expect(student.qrData, qrData);
    });

    test('insertStudent with ALL optional fields filled', () async {
      final nis = '99999';
      final name = 'Andi Wijaya';
      final className = '2B';
      final gender = 'Perempuan';
      final qrData = QrGenerator.encodePayload(
        nis: nis,
        name: name,
        className: className,
      );

      final id = await db.studentDao.insertStudent(
        nis: nis,
        fullName: name,
        className: className,
        gender: gender,
        qrData: qrData,
        birthDate: '2010-05-15',
        address: 'Jl. Merdeka No. 10',
        parentName: 'Parent Name',
        parentPhone: '08123456789',
        photoPath: '/some/path/photo.jpg',
        notes: 'Test notes',
      );

      expect(id, greaterThan(0));

      final student = await db.studentDao.getStudentByNis(nis);
      expect(student, isNotNull);
      expect(student!.birthDate, '2010-05-15');
      expect(student.address, 'Jl. Merdeka No. 10');
      expect(student.parentName, 'Parent Name');
      expect(student.parentPhone, '08123456789');
      expect(student.photoPath, '/some/path/photo.jpg');
      expect(student.notes, 'Test notes');
    });

    test('insertStudent then insert ANOTHER student (no qrData collision)', () async {
      final student1 = await db.studentDao.insertStudent(
        nis: '001',
        fullName: 'Student One',
        className: '1A',
        gender: 'Laki-laki',
        qrData: QrGenerator.encodePayload(nis: '001', name: 'Student One', className: '1A'),
      );
      expect(student1, greaterThan(0));

      final student2 = await db.studentDao.insertStudent(
        nis: '002',
        fullName: 'Student Two',
        className: '1B',
        gender: 'Perempuan',
        qrData: QrGenerator.encodePayload(nis: '002', name: 'Student Two', className: '1B'),
      );
      expect(student2, greaterThan(0));

      final all = await db.studentDao.getAllStudents();
      expect(all.length, 2);
    });

    test('insertStudent duplicate NIS throws SqliteException', () async {
      await db.studentDao.insertStudent(
        nis: 'DUP01',
        fullName: 'First',
        className: '1A',
        gender: 'Laki-laki',
        qrData: QrGenerator.encodePayload(nis: 'DUP01', name: 'First', className: '1A'),
      );

      expect(
        () => db.studentDao.insertStudent(
          nis: 'DUP01',
          fullName: 'Second',
          className: '1A',
          gender: 'Laki-laki',
          qrData: QrGenerator.encodePayload(nis: 'DUP01', name: 'Second', className: '1A'),
        ),
        throwsA(isA<SqliteException>()),
      );
    });

    test('updateStudent works correctly', () async {
      final id = await db.studentDao.insertStudent(
        nis: 'UPD01',
        fullName: 'Original Name',
        className: '1A',
        gender: 'Laki-laki',
        qrData: QrGenerator.encodePayload(nis: 'UPD01', name: 'Original Name', className: '1A'),
      );

      await db.studentDao.updateStudent(StudentsCompanion(
        id: Value(id),
        nis: const Value('UPD01'),
        fullName: const Value('Updated Name'),
        className: const Value('2B'),
        gender: const Value('Perempuan'),
        qrData: Value(QrGenerator.encodePayload(nis: 'UPD01', name: 'Updated Name', className: '2B')),
      ));

      final student = await db.studentDao.getStudentByNis('UPD01');
      expect(student, isNotNull);
      expect(student!.fullName, 'Updated Name');
      expect(student.className, '2B');
      expect(student.gender, 'Perempuan');
    });
  });
}
