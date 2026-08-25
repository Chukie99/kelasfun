import 'package:flutter/material.dart';
import 'package:kelasfun/core/database/app_database.dart';
import 'package:kelasfun/core/services/license_service.dart';
import 'package:kelasfun/core/theme/app_theme.dart';
import 'package:provider/provider.dart';
import 'features/activation/activation_screen.dart';
import 'features/android/android_main_home.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  final db = AppDatabase();
  runApp(
    Provider.value(
      value: db,
      child: MaterialApp(
        title: 'kelasFun',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.darkTheme,
        home: const LicenseCheckScreen(),
      ),
    ),
  );
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
    // Guard try/catch: kegagalan apapun tidak boleh bikin app hang
    // di layar "Memeriksa lisensi..." tanpa pesan.
    try {
      final isActivated = await LicenseService.isActivated();

      // Jika sudah aktif, cek grace period
      if (isActivated) {
        final isInGracePeriod = await LicenseService.isInGracePeriod();

        if (!isInGracePeriod) {
          // Grace period habis, coba re-validate online
          final result = await LicenseService.revalidate();
          // Hanya deaktivasi jika server MENOLAK lisensi.
          if (!result.isValid && !result.networkError) {
            if (!mounted) return;
            setState(() {
              _isActivated = false;
              _isLoading = false;
            });
            return;
          }
        }
      }

      if (!mounted) return;
      setState(() {
        _isActivated = isActivated;
        _isLoading = false;
      });
    } catch (e) {
      debugPrint('License check error: $e');
      if (!mounted) return;
      setState(() {
        _isActivated = false;
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
          setState(() {
            _isActivated = true;
          });
        },
      );
    }

    return const AndroidMainHome();
  }
}
