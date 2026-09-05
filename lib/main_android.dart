import 'package:flutter/material.dart';
import 'package:kelasfun/core/database/app_database.dart';
import 'package:kelasfun/core/theme/app_theme.dart';
import 'package:kelasfun/core/services/serial_generator.dart';
import 'package:kelasfun/features/activation/activation_screen.dart';
import 'package:kelasfun/features/android/android_main_home.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:provider/provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

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
  bool _isActivated = false;

  @override
  void initState() {
    super.initState();
    _checkState();
  }

  Future<void> _checkState() async {
    final prefs = await SharedPreferences.getInstance();
    final valid = prefs.getBool('license_valid') ?? false;
    if (mounted) {
      setState(() {
        _isActivated = valid;
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
              Text('Memeriksa lisensi...'),
            ],
          ),
        ),
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
