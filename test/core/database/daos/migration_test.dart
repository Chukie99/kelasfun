import 'dart:io';
import 'package:drift/drift.dart' hide isNotNull;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kelasfun/core/database/app_database.dart';
import 'package:sqlite3/sqlite3.dart';

const oldStudentsSchema = '''
CREATE TABLE students (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  nis TEXT NOT NULL UNIQUE,
  full_name TEXT NOT NULL,
  class_name TEXT NOT NULL,
  gender TEXT NOT NULL,
  birth_date TEXT,
  address TEXT,
  parent_name TEXT,
  parent_phone TEXT,
  photo_path TEXT,
  qr_data TEXT NOT NULL UNIQUE,
  created_at INTEGER NOT NULL DEFAULT (strftime('%s','now') * 1000),
  updated_at INTEGER NOT NULL DEFAULT (strftime('%s','now') * 1000)
);
''';

// v2 schema as it exists on devices installed before the photo upload feature:
// students has is_active + notes but NO photo_path; attendance has NO
// description; the schedule table does not exist at all.
const v2StudentsSchema = '''
CREATE TABLE students (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  nis TEXT NOT NULL UNIQUE,
  full_name TEXT NOT NULL,
  class_name TEXT NOT NULL,
  gender TEXT NOT NULL,
  birth_date TEXT,
  address TEXT,
  parent_name TEXT,
  parent_phone TEXT,
  qr_data TEXT NOT NULL UNIQUE,
  is_active INTEGER NOT NULL DEFAULT 1,
  notes TEXT,
  created_at INTEGER NOT NULL DEFAULT (strftime('%s','now') * 1000),
  updated_at INTEGER NOT NULL DEFAULT (strftime('%s','now') * 1000)
);
''';

const v2AttendanceSchema = '''
CREATE TABLE attendance (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  student_id INTEGER NOT NULL REFERENCES students(id),
  date TEXT NOT NULL,
  status TEXT NOT NULL,
  scan_method TEXT NOT NULL,
  scanned_at INTEGER NOT NULL DEFAULT (strftime('%s','now') * 1000),
  synced TEXT NOT NULL DEFAULT 'false'
);
''';

DatabaseConnection _openOldDb(String path, List<String> schemas,
    {int version = 1}) {
  final file = File(path);
  if (file.existsSync()) file.deleteSync();

  final oldDb = sqlite3.open(file.path);
  for (final schema in schemas) {
    oldDb.execute(schema);
  }
  oldDb.execute('PRAGMA user_version = $version;');
  oldDb.dispose();

  return DatabaseConnection(NativeDatabase(file));
}

Future<List<String>> _tableColumns(AppDatabase db, String table) async {
  final rows = await db.customSelect('PRAGMA table_info($table)').get();
  return rows.map((r) => r.data['name'] as String).toList();
}

void main() {
  test('database from schema v1 is migrated and can store notes', () async {
    final file = File('${Directory.systemTemp.path}/kelasfun_migration_test.db');

    final db = AppDatabase.forTesting(_openOldDb(file.path, [oldStudentsSchema]));

    await db.into(db.students).insert(
      StudentsCompanion.insert(
        nis: '2025001',
        fullName: 'Andi Pratama',
        className: '6A',
        gender: 'Laki-laki',
        qrData: '{"n":"2025001"}',
        notes: const Value('Catatan rapor'),
      ),
    );

    final student = await (db.select(db.students)
      ..where((t) => t.nis.equals('2025001'))).getSingleOrNull();

    expect(student, isNotNull);
    expect(student!.notes, 'Catatan rapor');

    await db.close();
    file.deleteSync();
  });

  test(
      'v2 database is migrated to add photo_path, description and schedule '
      'table, and can insert a student with photo', () async {
    final file = File('${Directory.systemTemp.path}/kelasfun_migration_v2.db');

    final db = AppDatabase.forTesting(_openOldDb(
      file.path,
      [v2StudentsSchema, v2AttendanceSchema],
      version: 2,
    ));

    // The migration must have added the columns before app code uses them.
    final studentsCols = await _tableColumns(db, 'students');
    expect(studentsCols, contains('photo_path'));

    final attendanceCols = await _tableColumns(db, 'attendance');
    expect(attendanceCols, contains('description'));

    final tables = await db.customSelect(
      "SELECT name FROM sqlite_master WHERE type='table' AND name='schedules'",
    ).get();
    expect(tables, hasLength(1));

    // The exact INSERT that previously threw
    // "table students has no column named photo_path".
    await db.into(db.students).insert(
      StudentsCompanion.insert(
        nis: '2025006',
        fullName: 'Budi Santoso',
        className: '6B',
        gender: 'Laki-laki',
        qrData: '{"n":"2025006"}',
        photoPath: const Value('/photos/2025006.jpg'),
      ),
    );

    final student = await (db.select(db.students)
      ..where((t) => t.nis.equals('2025006'))).getSingleOrNull();
    expect(student!.photoPath, '/photos/2025006.jpg');

    await db.close();
    file.deleteSync();
  });
}
