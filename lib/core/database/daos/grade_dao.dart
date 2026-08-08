import 'package:drift/drift.dart';
import '../app_database.dart';
import '../tables/grades.dart';

part 'grade_dao.g.dart';

@DriftAccessor(tables: [Grades])
class GradeDao extends DatabaseAccessor<AppDatabase> with _$GradeDaoMixin {
  GradeDao(super.db);

  Future<void> insertGrade({
    required int studentId,
    required int subjectId,
    required double score,
    required String examType,
    required String semester,
  }) async {
    final existing = await (select(grades)
      ..where((t) =>
          t.studentId.equals(studentId) &
          t.subjectId.equals(subjectId) &
          t.examType.equals(examType) &
          t.semester.equals(semester))
    ).getSingleOrNull();

    if (existing != null) {
      await (update(grades)..where((t) => t.id.equals(existing.id)))
          .write(GradesCompanion(score: Value(score)));
    } else {
      await into(grades).insert(GradesCompanion.insert(
        studentId: studentId,
        subjectId: subjectId,
        score: score,
        examType: examType,
        semester: semester,
      ));
    }
  }

  Future<List<Grade>> getGradesByStudent(int studentId) {
    return (select(grades)..where((t) => t.studentId.equals(studentId))).get();
  }

  Future<List<Grade>> getGradesByStudentSemester(int studentId, String semester) {
    return (select(grades)
      ..where((t) => t.studentId.equals(studentId) & t.semester.equals(semester))
    ).get();
  }

  Future<double> getAverageScore(int studentId, String semester) async {
    final gradesList = await (select(grades)
      ..where((t) =>
          t.studentId.equals(studentId) & t.semester.equals(semester))
    ).get();
    if (gradesList.isEmpty) return 0.0;
    final total = gradesList.fold<double>(0, (sum, g) => sum + g.score);
    return total / gradesList.length;
  }

  Future<List<Grade>> getRanking(String semester) async {
    final allGrades = await (select(grades)
      ..where((t) => t.semester.equals(semester))
    ).get();

    final Map<int, List<Grade>> grouped = {};
    for (final g in allGrades) {
      grouped.putIfAbsent(g.studentId, () => []).add(g);
    }

    final ranking = <Grade>[];
    for (final entry in grouped.entries) {
      final avg = entry.value.fold<double>(0, (sum, g) => sum + g.score) / entry.value.length;
      ranking.add(entry.value.first.copyWith(score: avg));
    }

    ranking.sort((a, b) => b.score.compareTo(a.score));
    return ranking;
  }

  Future<int> deleteGrade(int id) {
    return (delete(grades)..where((t) => t.id.equals(id))).go();
  }
}
