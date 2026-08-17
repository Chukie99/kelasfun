import 'dart:async';
import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:kelasfun/app.dart';
import 'package:kelasfun/core/database/app_database.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();

  FlutterError.onError = (details) {
    FlutterError.presentError(details);
    log('Flutter Error: ${details.exceptionAsString()}',
        stackTrace: details.stack);
  };

  final db = AppDatabase();

  runZonedGuarded<Future<void>>(() async {
    runApp(KelasFunApp(database: db));
  }, (error, stack) {
    log('Uncaught Error: $error', stackTrace: stack);
  });
}
