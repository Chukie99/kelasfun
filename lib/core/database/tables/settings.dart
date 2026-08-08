import 'package:drift/drift.dart';

class Settings extends Table {
  TextColumn get key => text().withLength(min: 1, max: 50).unique()();
  TextColumn get value => text()();
  DateTimeColumn get updatedAt => dateTime().withDefault(currentDateAndTime)();
}
