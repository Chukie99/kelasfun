import 'package:flutter/material.dart';
import 'package:kelasfun/core/database/app_database.dart';
import 'package:kelasfun/core/theme/app_theme.dart';
import 'package:provider/provider.dart';
import 'features/android/android_main_home.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  final db = AppDatabase();
  runApp(
    ChangeNotifierProvider.value(
      value: db,
      child: MaterialApp(
        title: 'kelasFun',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.darkTheme,
        home: const AndroidMainHome(),
      ),
    ),
  );
}
