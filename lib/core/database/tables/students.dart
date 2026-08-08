import 'package:drift/drift.dart';

class Students extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get nis => text().withLength(min: 1, max: 20).unique()();
  TextColumn get fullName => text().withLength(min: 1, max: 100)();
  TextColumn get className => text().withLength(min: 1, max: 20)();
  TextColumn get gender => text().withLength(min: 1, max: 10)();
  TextColumn get birthDate => text().nullable()();
  TextColumn get address => text().nullable()();
  TextColumn get parentName => text().nullable()();
  TextColumn get parentPhone => text().nullable()();
  TextColumn get qrData => text().unique()();
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
  DateTimeColumn get updatedAt => dateTime().withDefault(currentDateAndTime)();
}
