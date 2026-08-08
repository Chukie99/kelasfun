import 'package:drift/drift.dart';
import 'students.dart';

class Attendance extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get studentId => integer().references(Students, #id)();
  TextColumn get date => text()();
  TextColumn get status => text()();
  TextColumn get scanMethod => text()();
  TextColumn get description => text().nullable()();
  DateTimeColumn get scannedAt => dateTime().withDefault(currentDateAndTime)();
  TextColumn get synced => text().withDefault(const Constant('false'))();

  @override
  List<Set<Column>> get uniqueKeys => [{studentId, date}];
}
