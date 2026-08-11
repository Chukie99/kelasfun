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

void main() {
  test('database from schema v1 is migrated and can store notes', () async {
    final file = File('${Directory.systemTemp.path}/kelasfun_migration_test.db');
    if (file.existsSync()) file.deleteSync();

    final oldDb = sqlite3.open(file.path);
    oldDb.execute(oldStudentsSchema);
    oldDb.execute('PRAGMA user_version = 1;');
    oldDb.dispose();

    final db = AppDatabase.forTesting(
      DatabaseConnection(NativeDatabase(file)),
    );

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
}
