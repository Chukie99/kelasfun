import 'package:drift/drift.dart';
import 'students.dart';
import 'subjects.dart';

class Grades extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get studentId => integer().references(Students, #id)();
  IntColumn get subjectId => integer().references(Subjects, #id)();
  RealColumn get score => real()();
  TextColumn get examType => text()();
  TextColumn get semester => text()();
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();

  @override
  List<Set<Column>> get uniqueKeys => [{studentId, subjectId, examType, semester}];
}
