import 'package:drift/drift.dart';
import 'students.dart';

class Points extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get studentId => integer().references(Students, #id)();
  TextColumn get type => text()();
  TextColumn get category => text()();
  IntColumn get pointValue => integer()();
  TextColumn get description => text().nullable()();
  TextColumn get date => text()();
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
}
