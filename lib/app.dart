import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:kelasfun/core/theme/app_theme.dart';
import 'package:kelasfun/core/database/app_database.dart';
import 'package:kelasfun/core/utils/responsive.dart';
import 'package:kelasfun/features/activation/activation_screen.dart';
import 'package:kelasfun/features/home/home_screen.dart';
import 'package:kelasfun/features/home/mobile_home.dart';

class KelasFunApp extends StatelessWidget {
  final AppDatabase? database;
  const KelasFunApp({super.key, required this.database});

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
            home: const AppGate(),
          );
        },
      ),
    );
  }
}

class AppGate extends StatefulWidget {
  const AppGate({super.key});

  @override
  State<AppGate> createState() => _AppGateState();
}

class _AppGateState extends State<AppGate> {
  bool _isLoading = true;
  bool _isActivated = false;

  @override
  void initState() {
    super.initState();
    _checkState();
  }

  Future<void> _checkState() async {
    final prefs = await SharedPreferences.getInstance();
    final activated = prefs.getBool('kelasfun_activated') ?? false;

    if (mounted) {
      setState(() {
        _isActivated = activated;
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircularProgressIndicator(),
              SizedBox(height: 20),
              Text('Memeriksa aktivasi...'),
            ],
          ),
        ),
      );
    }

    // Belum aktivasi → Serial Activation Screen
    if (!_isActivated) {
      return ActivationScreen(
        onActivated: () {
          setState(() {
            _isActivated = true;
          });
        },
      );
    }

    // Sudah aktivasi → Main App
    return Responsive.isMobilePlatform || Responsive.isMobile(context)
        ? const MobileHome()
        : const HomeScreen();
  }
}
