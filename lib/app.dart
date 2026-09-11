import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:kelasfun/core/theme/app_theme.dart';
import 'package:kelasfun/core/database/app_database.dart';
import 'package:kelasfun/features/activation/activation_screen.dart';
import 'package:kelasfun/features/home/home_screen.dart';
import 'package:kelasfun/core/services/serial_generator.dart';

class KelasFunApp extends StatelessWidget {
  final AppDatabase database;
  
  const KelasFunApp({super.key, required this.database});

  @override
  Widget build(BuildContext context) {
    return Provider.value(
      value: database,
      child: MaterialApp(
        title: 'KelasFun',
        theme: AppTheme.lightTheme,
        debugShowCheckedModeBanner: false,
        localizationsDelegates: const [
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        supportedLocales: const [Locale('id', 'ID'), Locale('en', 'US')],
        locale: const Locale('id', 'ID'),
        home: const AuthGate(),
      ),
    );
  }
}

class AuthGate extends StatefulWidget {
  const AuthGate({super.key});

  @override
  State<AuthGate> createState() => _AuthGateState();
}

class _AuthGateState extends State<AuthGate> {
  bool _loading = true;
  bool _authenticated = false;

  @override
  void initState() {
    super.initState();
    _checkAuth();
  }

  Future<void> _checkAuth() async {
    final prefs = await SharedPreferences.getInstance();
    final valid = prefs.getBool('license_valid') ?? false;
    final key = prefs.getString('license_key') ?? '';
    final deviceId = prefs.getString('device_id') ?? '';
    if (!valid || key.isEmpty) { setState(() { _authenticated = false; _loading = false; }); return; }
    // Grace 30 hari: jika activatedAt >30 hari & offline tetap valid, online wajib re-validate server
    final activatedAtMs = prefs.getInt('license_activated_at') ?? 0;
    if (activatedAtMs > 0) {
      final days = DateTime.now().difference(DateTime.fromMillisecondsSinceEpoch(activatedAtMs)).inDays;
      if (days > 30) {
        // grace habis — butuh online re-validate (untuk ROM: tetap kasih lewat tapi flag warning)
        // TODO: hit Supabase validate_license when online
      }
    }
    try {
      final persisted = await SerialService.ensureDeviceId();
      final dev = deviceId.isNotEmpty ? deviceId : persisted;
      final ok = SerialService.validateCode(key, dev);
      setState(() { _authenticated = ok; _loading = false; });
    } catch (_) {
      setState(() { _authenticated = false; _loading = false; });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Scaffold(
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text('🎓', style: TextStyle(fontSize: 64)),
              SizedBox(height: 16),
              CircularProgressIndicator(color: Color(0xFF7A1C1C)),
            ],
          ),
        ),
      );
    }

    if (!_authenticated) {
      return ActivationScreen(onActivated: () {
        setState(() => _authenticated = true);
      });
    }

    return const HomeScreen();
  }
}
