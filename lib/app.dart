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
    final db = database ?? AppDatabase();
    return Provider<AppDatabase>.value(
      value: db,
      child: StreamBuilder<String?>(
        stream: db.settingsDao.watchSetting('theme_mode'),
        builder: (context, snapshot) {
          final mode = snapshot.data ?? 'dark';
          ThemeMode themeMode;
          switch (mode) {
            case 'light':
              themeMode = ThemeMode.light;
              break;
            case 'system':
              themeMode = ThemeMode.system;
              break;
            default:
              themeMode = ThemeMode.dark;
          }
          return MaterialApp(
            title: 'kelasFun',
            theme: AppTheme.lightTheme,
            darkTheme: AppTheme.darkTheme,
            themeMode: themeMode,
            debugShowCheckedModeBanner: false,
            home: const HomeScreen(),
          );
        },
      ),
    );
  }
}
