import 'package:flutter/material.dart';
import 'package:kelasfun/app.dart';
import 'package:kelasfun/core/database/app_database.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  final db = AppDatabase();
  runApp(KelasFunApp(database: db));
}
