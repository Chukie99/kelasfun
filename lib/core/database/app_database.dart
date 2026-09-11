import 'dart:io';
import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;

import 'tables/students.dart';
import 'tables/attendance.dart';
import 'tables/subjects.dart';
import 'tables/grades.dart';
import 'tables/points.dart';
import 'tables/settings.dart';
import 'tables/schedule.dart';
import 'daos/student_dao.dart';
import 'daos/attendance_dao.dart';
import 'daos/subject_dao.dart';
import 'daos/grade_dao.dart';
import 'daos/point_dao.dart';
import 'daos/settings_dao.dart';
import 'daos/schedule_dao.dart';

part 'app_database.g.dart';

@DriftDatabase(tables: [
  Students,
  Attendance,
  Subjects,
  Grades,
  Points,
  Settings,
  Schedules,
], daos: [
  StudentDao,
  AttendanceDao,
  SubjectDao,
  GradeDao,
  PointDao,
  SettingsDao,
  ScheduleDao,
])
class AppDatabase extends _$AppDatabase {
  AppDatabase([DatabaseConnection? connection]) : super(connection ?? _openConnection());

  AppDatabase.forTesting(DatabaseConnection connection) : super(connection);

  @override
  int get schemaVersion => 3;

  @override
  MigrationStrategy get migration {
    return MigrationStrategy(
      onCreate: (m) async { await m.createAll(); },
      beforeOpen: (details) async {
        await customStatement('PRAGMA foreign_keys = ON');
        await customStatement('PRAGMA journal_mode = WAL');
      },
      onUpgrade: (m, from, to) async {
        // Each step isolated — fail one does not block others, but logged
        if (from < 2) {
          try { await _ensureColumn(m, students, students.isActive); await _ensureColumn(m, students, students.notes); } catch(e){
            print('[DB] v2 migration failed: $e');
          }
        }
        if (from < 3) {
          try { await _ensureColumn(m, students, students.photoPath); } catch(e){ print('[DB] v3 photoPath failed: $e'); }
          try { await _ensureColumn(m, attendance, attendance.description); } catch(e){ print('[DB] v3 description failed: $e'); }
          try { await m.createTable(schedules); } catch(e){ print('[DB] v3 schedules failed: $e'); }
        }
      },
    );
  }

  Future<void> _ensureColumn(
    Migrator m,
    TableInfo table,
    GeneratedColumn column,
  ) async {
    final info = await m.database.customSelect(
      'PRAGMA table_info(${table.actualTableName})',
    ).get();
    if (info.isEmpty) return; // table doesn't exist; nothing to alter
    final exists = info.any((row) => row.data['name'] == column.name);
    if (!exists) {
      await m.addColumn(table, column);
    }
  }

  Future<String> getDatabasePath() async {
    final dbFolder = await getApplicationDocumentsDirectory();
    return p.join(dbFolder.path, 'kelasFun', 'kelasfun.db');
  }
}

LazyDatabase _openConnection() {
  return LazyDatabase(() async {
    final dbFolder = await getApplicationDocumentsDirectory();
    final file = File(p.join(dbFolder.path, 'kelasFun', 'kelasfun.db'));

    if (!file.existsSync()) {
      file.parent.createSync(recursive: true);
    }

    return NativeDatabase(file);
  });
}
