import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:provider/provider.dart';
import 'package:kelasfun/core/theme/app_theme.dart';
import 'package:kelasfun/core/database/app_database.dart';
import 'package:kelasfun/features/home/home_screen.dart';

class KelasFunApp extends StatelessWidget {
  final AppDatabase? database;
  const KelasFunApp({super.key, this.database});

  @override
  Widget build(BuildContext context) {
    final db = database!;
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
            localizationsDelegates: const [
              GlobalMaterialLocalizations.delegate,
              GlobalWidgetsLocalizations.delegate,
              GlobalCupertinoLocalizations.delegate,
            ],
            supportedLocales: const [
              Locale('id', 'ID'),
              Locale('en', 'US'),
            ],
            locale: const Locale('id', 'ID'),
            home: const HomeScreen(),
          );
        },
      ),
    );
  }
}
