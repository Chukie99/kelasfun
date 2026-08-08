import 'package:drift/drift.dart';

class Subjects extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get name => text().withLength(min: 1, max: 50)();
  TextColumn get code => text().withLength(min: 1, max: 10).unique()();
  IntColumn get teacherId => integer().nullable()();
}
