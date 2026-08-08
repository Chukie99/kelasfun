import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:kelasfun/core/theme/app_theme.dart';
import 'package:kelasfun/core/database/app_database.dart';
import 'package:kelasfun/features/home/home_screen.dart';

class KelasFunApp extends StatelessWidget {
  final AppDatabase? database;
  const KelasFunApp({super.key, this.database});

  @override
  Widget build(BuildContext context) {
    return Provider<AppDatabase>.value(
      value: database ?? AppDatabase(),
      child: MaterialApp(
        title: 'kelasFun',
        theme: AppTheme.darkTheme,
        debugShowCheckedModeBanner: false,
        home: const HomeScreen(),
      ),
    );
  }
}
