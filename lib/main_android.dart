import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:kelasfun/core/database/app_database.dart';
import 'package:kelasfun/features/android/android_home.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  final database = AppDatabase();

  runApp(
    Provider<AppDatabase>.value(
      value: database,
      child: const MaterialApp(
        debugShowCheckedModeBanner: false,
        home: AndroidHome(),
      ),
    ),
  );
}
