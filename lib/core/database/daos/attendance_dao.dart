import 'package:drift/drift.dart';
import '../app_database.dart';
import '../tables/attendance.dart';

part 'attendance_dao.g.dart';

@DriftAccessor(tables: [Attendance])
class AttendanceDao extends DatabaseAccessor<AppDatabase> with _$AttendanceDaoMixin {
  AttendanceDao(super.db);

  Future<void> markAttendance({
    required int studentId,
    required String date,
    required String status,
    required String scanMethod,
  }) async {
    final existing = await (select(attendance)
      ..where((t) => t.studentId.equals(studentId) & t.date.equals(date))
    ).getSingleOrNull();

    if (existing != null) {
      await (update(attendance)..where((t) => t.id.equals(existing.id)))
        .write(AttendanceCompanion(
          status: Value(status),
          scanMethod: Value(scanMethod),
        ));
    } else {
      await into(attendance).insert(AttendanceCompanion.insert(
        studentId: studentId,
        date: date,
        status: status,
        scanMethod: scanMethod,
      ));
    }
  }

  Future<List<AttendanceData>> getAttendanceByDate(String date) {
    return (select(attendance)..where((t) => t.date.equals(date))).get();
  }

  Stream<List<AttendanceData>> watchAttendanceByDate(String date) {
    return (select(attendance)..where((t) => t.date.equals(date))).watch();
  }

  Future<List<AttendanceData>> getAttendanceByStudent({
    required int studentId,
    required String startDate,
    required String endDate,
  }) {
    return (select(attendance)
      ..where((t) =>
          t.studentId.equals(studentId) &
          t.date.isBiggerOrEqualValue(startDate) &
          t.date.isSmallerOrEqualValue(endDate))
    ).get();
  }

  Future<List<AttendanceData>> getUnsyncedAttendance() {
    return (select(attendance)
      ..where((t) => t.synced.equals('false'))
    ).get();
  }

  Future<void> markSynced(int id) {
    return (update(attendance)..where((t) => t.id.equals(id)))
        .write(const AttendanceCompanion(synced: Value('true')));
  }
}
