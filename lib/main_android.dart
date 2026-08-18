import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:kelasfun/core/database/app_database.dart';
import 'package:kelasfun/core/services/license_service.dart';
import 'package:kelasfun/core/services/auth_service.dart';
import 'package:kelasfun/core/theme/app_theme.dart';
import 'package:kelasfun/main.dart' show supabaseUrl, supabaseAnonKey;
import 'package:provider/provider.dart';
import 'features/auth/auth_screen.dart';
import 'features/activation/activation_screen.dart';
import 'features/android/android_main_home.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Supabase.initialize(
    url: supabaseUrl,
    anonKey: supabaseAnonKey,
  );

  final db = AppDatabase();
  runApp(
    ChangeNotifierProvider.value(
      value: db,
      child: MaterialApp(
        title: 'kelasFun',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.darkTheme,
        home: const AppGate(),
      ),
    ),
  );
}

class AppGate extends StatefulWidget {
  const AppGate({super.key});

  @override
  State<AppGate> createState() => _AppGateState();
}

class _AppGateState extends State<AppGate> {
  bool _isLoading = true;
  bool _isLoggedIn = false;
  bool _isActivated = false;

  @override
  void initState() {
    super.initState();
    _checkState();
  }

  Future<void> _checkState() async {
    final loggedIn = AuthService.isLoggedIn;
    bool activated = false;

    if (loggedIn) {
      activated = await LicenseService.isActivated();

      if (activated) {
        final inGracePeriod = await LicenseService.isInGracePeriod();
        if (!inGracePeriod) {
          final result = await LicenseService.revalidate();
          if (!result.isValid) {
            activated = false;
          }
        }
      }
    }

    if (mounted) {
      setState(() {
        _isLoggedIn = loggedIn;
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
              Text('Memeriksa sesi...'),
            ],
          ),
        ),
      );
    }

    if (!_isLoggedIn) {
      return AuthScreen(
        onAuthenticated: () {
          setState(() => _isLoggedIn = true);
          _checkState();
        },
      );
    }

    if (!_isActivated) {
      return ActivationScreen(
        onActivated: () {
          setState(() => _isActivated = true);
        },
      );
    }

    return const AndroidMainHome();
  }
}
