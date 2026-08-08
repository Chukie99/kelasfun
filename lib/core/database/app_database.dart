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
import 'daos/student_dao.dart';
import 'daos/attendance_dao.dart';
import 'daos/subject_dao.dart';
import 'daos/grade_dao.dart';
import 'daos/point_dao.dart';
import 'daos/settings_dao.dart';

part 'app_database.g.dart';

@DriftDatabase(tables: [
  Students,
  Attendance,
  Subjects,
  Grades,
  Points,
  Settings,
], daos: [
  StudentDao,
  AttendanceDao,
  SubjectDao,
  GradeDao,
  PointDao,
  SettingsDao,
])
class AppDatabase extends _$AppDatabase {
  AppDatabase([DatabaseConnection? connection]) : super(connection ?? _openConnection());

  AppDatabase.forTesting(DatabaseConnection connection) : super(connection);

  @override
  int get schemaVersion => 1;

  @override
  MigrationStrategy get migration {
    return MigrationStrategy(
      onCreate: (m) async {
        await m.createAll();
      },
    );
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
