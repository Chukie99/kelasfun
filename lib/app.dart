import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:provider/provider.dart';
import 'package:kelasfun/core/theme/app_theme.dart';
import 'package:kelasfun/core/database/app_database.dart';
import 'package:kelasfun/core/services/license_service.dart';
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
            home: const LicenseCheckScreen(),
          );
        },
      ),
    );
  }
}

class LicenseCheckScreen extends StatefulWidget {
  const LicenseCheckScreen({super.key});

  @override
  State<LicenseCheckScreen> createState() => _LicenseCheckScreenState();
}

class _LicenseCheckScreenState extends State<LicenseCheckScreen> {
  bool _isLoading = true;
  bool _isActivated = false;

  @override
  void initState() {
    super.initState();
    _checkLicense();
  }

  Future<void> _checkLicense() async {
    final isActivated = await LicenseService.isActivated();
    
    if (isActivated) {
      final isInGracePeriod = await LicenseService.isInGracePeriod();
      
      if (!isInGracePeriod) {
        final result = await LicenseService.revalidate();
        if (!result.isValid) {
          setState(() {
            _isActivated = false;
            _isLoading = false;
          });
          return;
        }
      }
    }
    
    setState(() {
      _isActivated = isActivated;
      _isLoading = false;
    });
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
              Text('Memeriksa lisensi...'),
            ],
          ),
        ),
      );
    }

    if (!_isActivated) {
      return ActivationScreen(
        onActivated: () {
          setState(() {
            _isActivated = true;
          });
        },
      );
    }

    return Responsive.isMobilePlatform || Responsive.isMobile(context)
        ? const MobileHome()
        : const HomeScreen();
  }
}
