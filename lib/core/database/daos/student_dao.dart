import 'package:drift/drift.dart';
import '../app_database.dart';
import '../tables/students.dart';

part 'student_dao.g.dart';

@DriftAccessor(tables: [Students])
class StudentDao extends DatabaseAccessor<AppDatabase> with _$StudentDaoMixin {
  StudentDao(super.db);

  Future<int> insertStudent({
    required String nis,
    required String fullName,
    required String className,
    required String gender,
    required String qrData,
    String? birthDate,
    String? address,
    String? parentName,
    String? parentPhone,
    String? photoPath,
    String? notes,
  }) {
    return into(students).insert(StudentsCompanion.insert(
      nis: nis,
      fullName: fullName,
      className: className,
      gender: gender,
      qrData: qrData,
      birthDate: Value.absentIfNull(birthDate),
      address: Value.absentIfNull(address),
      parentName: Value.absentIfNull(parentName),
      parentPhone: Value.absentIfNull(parentPhone),
      photoPath: Value.absentIfNull(photoPath),
      notes: Value.absentIfNull(notes),
    ));
  }

  Future<List<Student>> getAllStudents() {
    return (select(students)..where((t) => t.isActive.equals(1))).get();
  }

  Stream<List<Student>> watchAllStudents() {
    return (select(students)..where((t) => t.isActive.equals(1))).watch();
  }

  /// Daftar kelas unik dari siswa aktif, terurut alfabetis.
  /// Dipakai dropdown laporan/export — dulu daftar kelas hardcode
  /// "X RPL 1..XI RPL 2" sehingga sekolah lain tidak bisa memakai fiturnya.
  Future<List<String>> getDistinctClassNames() async {
    final rows = await (select(students)
          ..where((t) => t.isActive.equals(1)))
        .get();
    final names = rows.map((s) => s.className).toSet().toList()..sort();
    return names;
  }

  Future<Student?> getStudentById(int id) {
    return (select(students)..where((t) => t.id.equals(id))).getSingleOrNull();
  }

  /// Live-watch satu siswa. Dipakai layar detail agar tampilan otomatis
  /// memakai data terbaru setelah edit disimpan (dulu stale).
  Stream<Student> watchStudentById(int id) {
    return (select(students)..where((t) => t.id.equals(id))).watchSingle();
  }

  Future<Student?> getStudentByNis(String nis) {
    return (select(students)..where((t) => t.nis.equals(nis))).getSingleOrNull();
  }

  Future<bool> updateStudent(StudentsCompanion entry) {
    return update(students).replace(entry);
  }

  Future<int> deleteStudent(int id) {
    return (delete(students)..where((t) => t.id.equals(id))).go();
  }

  Future<int> softDeleteStudent(int id) {
    return (update(students)..where((t) => t.id.equals(id)))
        .write(StudentsCompanion(isActive: const Value(0)));
  }
}
