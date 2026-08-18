import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AuthService {
  static final SupabaseClient _supabase = Supabase.instance.client;

  static const String _userEmailKey = 'kelasfun_user_email';
  static const String _userNameKey = 'kelasfun_user_name';
  static const String _userIdKey = 'kelasfun_user_id';

  static User? get currentUser => _supabase.auth.currentUser;

  static bool get isLoggedIn => currentUser != null;

  static String? get userEmail => currentUser?.email;

  static String? get userName => currentUser?.userMetadata?['full_name'] ?? currentUser?.email;

  static Stream<AuthState> get onAuthStateChange => _supabase.auth.onAuthStateChange;

  static Future<void> signInWithGoogle() async {
    try {
      await _supabase.auth.signInWithOAuth(
        OAuthProvider.google,
        redirectTo: 'io.supabase.kelasfun://login-callback/',
        authScreenLaunchMode: LaunchMode.inAppWebView,
      );
    } catch (e) {
      debugPrint('[AUTH] Google sign-in error: $e');
      rethrow;
    }
  }

  static Future<void> signOut() async {
    await _supabase.auth.signOut();
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_userEmailKey);
    await prefs.remove(_userNameKey);
    await prefs.remove(_userIdKey);
  }

  static Future<void> saveUserLocally() async {
    final user = currentUser;
    if (user != null) {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_userEmailKey, user.email ?? '');
      await prefs.setString(_userNameKey, userName ?? '');
      await prefs.setString(_userIdKey, user.id);
    }
  }

  static Future<String?> getSavedUserId() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_userIdKey);
  }

  static Future<void> handleAuthCallback() async {
    final session = _supabase.auth.currentSession;
    if (session != null) {
      await saveUserLocally();
    }
  }
}
