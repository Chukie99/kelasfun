import 'package:drift/drift.dart';
import 'subjects.dart';

class Jurnals extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get date => text()(); // yyyy-MM-dd
  TextColumn get className => text()();
  IntColumn get subjectId => integer().references(Subjects, #id)();
  TextColumn get topic => text()();
  TextColumn get notes => text().nullable()();
}
