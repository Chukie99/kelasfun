import 'dart:async';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:kelasfun/core/services/auth_service.dart';
import 'package:kelasfun/core/theme/app_theme.dart';

class AuthScreen extends StatefulWidget {
  final VoidCallback onAuthenticated;
  const AuthScreen({super.key, required this.onAuthenticated});

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  bool _isLoading = false;
  String? _errorMessage;
  StreamSubscription<AuthState>? _authSub;

  @override
  void initState() {
    super.initState();
    _checkExistingSession();
    // Listen for the OAuth deep-link callback: when Google sign-in completes
    // and Supabase receives the session, continue into the app.
    _authSub = AuthService.onAuthStateChange.listen((state) {
      if (!mounted) return;
      if (state.event == AuthChangeEvent.signedIn) {
        AuthService.saveUserLocally().then((_) {
          if (mounted) widget.onAuthenticated();
        });
      } else if (state.event == AuthChangeEvent.signInError ||
                 state.event == AuthChangeEvent.passwordRecovery) {
        if (mounted) {
          setState(() => _errorMessage = 'Login gagal. Silakan coba lagi.');
        }
      }
    });
  }

  @override
  void dispose() {
    _authSub?.cancel();
    super.dispose();
  }

  Future<void> _checkExistingSession() async {
    if (AuthService.isLoggedIn) {
      await AuthService.saveUserLocally();
      widget.onAuthenticated();
    }
  }

  Future<void> _signInWithGoogle() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      await AuthService.signInWithGoogle();
      // Note: success is handled by the auth state listener above —
      // after the webview closes, Supabase processes the deep link
      // and emits AuthChangeEvent.signedIn.
      if (AuthService.isLoggedIn) {
        await AuthService.saveUserLocally();
        widget.onAuthenticated();
      } else {
        setState(() => _errorMessage =
            'Menunggu login selesai... Jika browser tertutup tanpa masuk, coba lagi.');
      }
    } catch (e) {
      setState(() => _errorMessage = 'Terjadi kesalahan: ${e.toString()}');
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.background,
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Card(
              color: AppTheme.surface,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              child: Padding(
                padding: const EdgeInsets.all(32),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 80,
                      height: 80,
                      decoration: const BoxDecoration(
                        color: AppTheme.accent,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.school, size: 48, color: Colors.white),
                    ),
                    const SizedBox(height: 20),
                    const Text(
                      'kelasFun',
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: AppTheme.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'Aplikasi Manajemen Kelas',
                      style: TextStyle(color: AppTheme.textSecondary),
                    ),
                    const SizedBox(height: 32),
                    SizedBox(
                      width: double.infinity,
                      height: 50,
                      child: OutlinedButton.icon(
                        onPressed: _isLoading ? null : _signInWithGoogle,
                        icon: _isLoading
                            ? const SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(strokeWidth: 2),
                              )
                            : const Icon(Icons.g_mobiledata, size: 24),
                        label: Text(
                          _isLoading ? 'Masuk...' : 'Login dengan Google',
                          style: const TextStyle(fontSize: 16),
                        ),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: AppTheme.textPrimary,
                          side: const BorderSide(color: AppTheme.border),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                      ),
                    ),
                    if (_errorMessage != null) ...[
                      const SizedBox(height: 16),
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: AppTheme.coralSoft,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          _errorMessage!,
                          style: const TextStyle(color: AppTheme.coral),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ],
                    const SizedBox(height: 24),
                    const Text(
                      'Login untuk mengakses aplikasi',
                      style: TextStyle(color: AppTheme.textTertiary, fontSize: 12),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
