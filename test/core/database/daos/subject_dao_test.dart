import 'package:drift/native.dart';
import 'package:drift/drift.dart' hide isNotNull;
import 'package:flutter_test/flutter_test.dart';
import 'package:kelasfun/core/database/app_database.dart';

AppDatabase createTestDb() => AppDatabase.forTesting(DatabaseConnection(NativeDatabase.memory()));

void main() {
  late AppDatabase db;

  setUp(() {
    db = createTestDb();
  });

  tearDown(() async {
    await db.close();
  });

  group('SubjectDao', () {
    test('insert and get all subjects', () async {
      await db.subjectDao.insertSubject(name: 'Matematika', code: 'MTK');
      await db.subjectDao.insertSubject(name: 'Bahasa Indonesia', code: 'BIN');
      final subjects = await db.subjectDao.getAllSubjects();
      expect(subjects.length, 2);
    });

    test('get subject by id', () async {
      final id = await db.subjectDao.insertSubject(name: 'Matematika', code: 'MTK');
      final subject = await db.subjectDao.getSubjectById(id);
      expect(subject, isNotNull);
      expect(subject!.name, 'Matematika');
    });

    test('get subject by code', () async {
      await db.subjectDao.insertSubject(name: 'Matematika', code: 'MTK');
      final subject = await db.subjectDao.getSubjectByCode('MTK');
      expect(subject, isNotNull);
      expect(subject!.code, 'MTK');
    });

    test('update subject', () async {
      final id = await db.subjectDao.insertSubject(name: 'Matematika', code: 'MTK');
      final updated = await db.subjectDao.updateSubject(id, name: 'Matematika Wajib');
      expect(updated, true);
      final subject = await db.subjectDao.getSubjectById(id);
      expect(subject!.name, 'Matematika Wajib');
    });

    test('delete subject', () async {
      final id = await db.subjectDao.insertSubject(name: 'Matematika', code: 'MTK');
      await db.subjectDao.deleteSubject(id);
      final subjects = await db.subjectDao.getAllSubjects();
      expect(subjects.length, 0);
    });
  });
}
