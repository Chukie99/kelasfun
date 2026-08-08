import 'package:drift/drift.dart';
import '../app_database.dart';
import '../tables/subjects.dart';

part 'subject_dao.g.dart';

@DriftAccessor(tables: [Subjects])
class SubjectDao extends DatabaseAccessor<AppDatabase> with _$SubjectDaoMixin {
  SubjectDao(super.db);

  Future<int> insertSubject({required String name, required String code, int? teacherId}) {
    return into(subjects).insert(SubjectsCompanion.insert(
      name: name,
      code: code,
      teacherId: Value.absentIfNull(teacherId),
    ));
  }

  Future<List<Subject>> getAllSubjects() => select(subjects).get();

  Future<Subject?> getSubjectById(int id) {
    return (select(subjects)..where((t) => t.id.equals(id))).getSingleOrNull();
  }

  Future<Subject?> getSubjectByCode(String code) {
    return (select(subjects)..where((t) => t.code.equals(code))).getSingleOrNull();
  }

  Future<bool> updateSubject(int id, {String? name, String? code, int? teacherId}) async {
    final companion = SubjectsCompanion(
      name: name != null ? Value(name) : const Value.absent(),
      code: code != null ? Value(code) : const Value.absent(),
      teacherId: Value.absentIfNull(teacherId),
    );
    final rows = await (update(subjects)..where((t) => t.id.equals(id))).write(companion);
    return rows > 0;
  }

  Future<int> deleteSubject(int id) {
    return (delete(subjects)..where((t) => t.id.equals(id))).go();
  }

  Stream<List<Subject>> watchAllSubjects() => select(subjects).watch();
}
