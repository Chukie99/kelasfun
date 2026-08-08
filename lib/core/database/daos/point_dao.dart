import 'package:drift/drift.dart';
import '../app_database.dart';
import '../tables/points.dart';

part 'point_dao.g.dart';

@DriftAccessor(tables: [Points])
class PointDao extends DatabaseAccessor<AppDatabase> with _$PointDaoMixin {
  PointDao(super.db);

  Future<int> insertPoint({
    required int studentId,
    required String type,
    required String category,
    required int pointValue,
    required String date,
    String? description,
  }) {
    return into(points).insert(PointsCompanion.insert(
      studentId: studentId,
      type: type,
      category: category,
      pointValue: pointValue,
      date: date,
      description: Value.absentIfNull(description),
    ));
  }

  Future<List<Point>> getPointsByStudent(int studentId) {
    return (select(points)..where((t) => t.studentId.equals(studentId))).get();
  }

  Future<List<Point>> getPointsByDate(String date) {
    return (select(points)..where((t) => t.date.equals(date))).get();
  }

  Future<List<Point>> getPointsByStudentAndDate(int studentId, String date) {
    return (select(points)
      ..where((t) => t.studentId.equals(studentId) & t.date.equals(date))
    ).get();
  }

  Future<int> getTotalPoints(int studentId) async {
    final studentPoints = await getPointsByStudent(studentId);
    return studentPoints.fold<int>(0, (sum, p) => sum + p.pointValue);
  }

  Future<Map<int, int>> getAllTotalPoints() async {
    final allPoints = await select(points).get();
    final Map<int, int> totals = {};
    for (final p in allPoints) {
      totals[p.studentId] = (totals[p.studentId] ?? 0) + p.pointValue;
    }
    return totals;
  }

  Future<int> deletePoint(int id) {
    return (delete(points)..where((t) => t.id.equals(id))).go();
  }

  Stream<List<Point>> watchPointsByStudent(int studentId) {
    return (select(points)..where((t) => t.studentId.equals(studentId))).watch();
  }
}
