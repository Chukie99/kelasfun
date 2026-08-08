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

part 'app_database.g.dart';

@DriftDatabase(tables: [
  Students,
  Attendance,
  Subjects,
  Grades,
  Points,
  Settings,
])
class AppDatabase extends _$AppDatabase {
  AppDatabase() : super(_openConnection());

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
