import 'package:drift/drift.dart';
import 'subjects.dart';

class Schedules extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get day => text().withLength(min: 1, max: 10)();
  IntColumn get period => integer()();
  IntColumn get subjectId => integer().references(Subjects, #id)();
  TextColumn get className => text().withLength(min: 1, max: 20)();

  @override
  List<Set<Column>> get uniqueKeys => [{day, period, className}];
}
