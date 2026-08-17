import 'package:drift/drift.dart';
import '../app_database.dart';
import '../tables/schedule.dart';

part 'schedule_dao.g.dart';

@DriftAccessor(tables: [Schedules])
class ScheduleDao extends DatabaseAccessor<AppDatabase> with _$ScheduleDaoMixin {
  ScheduleDao(super.db);

  Future<int> insertSchedule({
    required String day,
    required int period,
    required int subjectId,
    required String className,
  }) {
    return into(schedules).insert(SchedulesCompanion.insert(
      day: day,
      period: period,
      subjectId: subjectId,
      className: className,
    ));
  }

  Future<List<Schedule>> getScheduleByClass(String className) {
    return (select(schedules)
      ..where((t) => t.className.equals(className))
      ..orderBy([(t) => OrderingTerm.asc(t.day), (t) => OrderingTerm.asc(t.period)])
    ).get();
  }

  Stream<List<Schedule>> watchScheduleByClass(String className) {
    return (select(schedules)
      ..where((t) => t.className.equals(className))
      ..orderBy([(t) => OrderingTerm.asc(t.day), (t) => OrderingTerm.asc(t.period)])
    ).watch();
  }

  Future<void> deleteScheduleByClassAndDay(String className, String day) {
    return (delete(schedules)
      ..where((t) => t.className.equals(className) & t.day.equals(day))
    ).go();
  }

  Future<void> deleteSchedule(int id) {
    return (delete(schedules)..where((t) => t.id.equals(id))).go();
  }

  Future<Schedule?> getScheduleByClassDayPeriod({
    required String className,
    required String day,
    required int period,
  }) {
    return (select(schedules)
      ..where((t) => 
          t.className.equals(className) & 
          t.day.equals(day) & 
          t.period.equals(period))
    ).getSingleOrNull();
  }

  Future<void> upsertSchedule({
    required String day,
    required int period,
    required int subjectId,
    required String className,
  }) async {
    final existing = await getScheduleByClassDayPeriod(
      className: className,
      day: day,
      period: period,
    );
    
    if (existing != null) {
      // Update existing schedule
      await (update(schedules)..where((t) => t.id.equals(existing.id))).write(
        SchedulesCompanion(subjectId: Value(subjectId)),
      );
    } else {
      // Insert new schedule
      await insertSchedule(
        day: day,
        period: period,
        subjectId: subjectId,
        className: className,
      );
    }
  }
}
