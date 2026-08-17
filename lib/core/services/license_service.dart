import 'dart:convert';
import 'dart:io';
import 'package:crypto/crypto.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:device_info_plus/device_info_plus.dart';

class LicenseService {
  static const String _licenseKey = 'kelasfun_license_key';
  static const String _isActivated = 'kelasfun_is_activated';
  static const String _activatedAt = 'kelasfun_activated_at';
  
  // ============================================================
  // SUPABASE CONFIGURATION
  // ============================================================
  static const String _supabaseUrl = 'https://cdgnqhdmsnrlzygolecz.supabase.co';
  static const String _supabaseKey = 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImNkZ25xaGRtc25ybHp5bGdvZWN6Iiwicm9sZSI6ImFub24iLCJpYXQiOjE3ODY5NzUyNzgsImV4cCI6MjEwMjU1MTI3OH0.a3mH4gFGPV_aRvgFCJFHMjQQsc3AQc0YBvrLEeFM_HA';
  
  // Grace period: 30 hari offline
  static const int _gracePeriodDays = 30;
  
  /// Generate device ID unik
  static Future<String> getDeviceId() async {
    try {
      final deviceInfo = DeviceInfoPlugin();
      
      if (Platform.isAndroid) {
        final androidInfo = await deviceInfo.androidInfo;
        // Gunakan Android ID (unik per device)
        return androidInfo.androidId ?? _getFallbackDeviceId();
      } else if (Platform.isIOS) {
        final iosInfo = await deviceInfo.iosInfo;
        return iosInfo.identifierForVendor ?? _getFallbackDeviceId();
      } else if (Platform.isWindows) {
        final windowsInfo = await deviceInfo.windowsInfo;
        return windowsInfo.deviceId;
      } else {
        return _getFallbackDeviceId();
      }
    } catch (e) {
      return _getFallbackDeviceId();
    }
  }
  
  /// Fallback device ID (jaga-jaga)
  static String _getFallbackDeviceId() {
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    final random =.hashCode.toRadixString(16);
    return '$timestamp-$random';
  }
  
  /// Validasi format license key
  static bool _isValidFormat(String key) {
    final regex = RegExp(r'^[A-Z0-9]{4}-[A-Z0-9]{4}-[A-Z0-9]{4}-[A-Z0-9]{4}$');
    return regex.hasMatch(key.toUpperCase());
  }
  
  /// Validasi license key ke Supabase
  static Future<LicenseResult> validateLicense(String licenseKey) async {
    try {
      final deviceId = await getDeviceId();
      
      // Format license key: XXXX-XXXX-XXXX-XXXX
      if (!_isValidFormat(licenseKey)) {
        return LicenseResult(
          isValid: false,
          message: 'Format license key tidak valid.\nContoh: A1B2-C3D4-E5F6-G7H8',
        );
      }
      
      // Kirim ke Supabase untuk validasi
      final response = await http.post(
        Uri.parse('$_supabaseUrl/rest/v1/rpc/validate_license'),
        headers: {
          'Content-Type': 'application/json',
          'apikey': _supabaseKey,
          'Authorization': 'Bearer $_supabaseKey',
        },
        body: jsonEncode({
          'p_license_key': licenseKey.toUpperCase(),
          'p_device_id': deviceId,
        }),
      );
      
      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        
        if (data.isNotEmpty && data[0]['valid'] == true) {
          // Simpan license key locally
          final prefs = await SharedPreferences.getInstance();
          await prefs.setString(_licenseKey, licenseKey.toUpperCase());
          await prefs.setBool(_isActivated, true);
          await prefs.setString(_activatedAt, DateTime.now().toIso8601String());
          
          return LicenseResult(
            isValid: true,
            message: data[0]['message'] ?? 'Aktivasi berhasil!',
          );
        } else {
          return LicenseResult(
            isValid: false,
            message: data[0]['message'] ?? 'License tidak valid',
          );
        }
      } else {
        // Server error, fallback ke offline mode
        return await _validateOffline(licenseKey, deviceId);
      }
    } catch (e) {
      // Network error, fallback ke offline mode
      print('Network error, using offline mode: $e');
      return await _validateOffline(licenseKey, deviceId);
    }
  }
  
  /// Offline validation (fallback saat internet mati)
  /// Cek apakah key sudah pernah diaktivasi di device ini
  static Future<LicenseResult> _validateOffline(String licenseKey, String deviceId) async {
    final prefs = await SharedPreferences.getInstance();
    final savedKey = prefs.getString(_licenseKey);
    final isActivated = prefs.getBool(_isActivated) == true;
    final activatedAtStr = prefs.getString(_activatedAt);
    
    // Jika sudah teraktivasi dengan key yang sama → izinkan
    if (isActivated && savedKey == licenseKey.toUpperCase()) {
      // Cek apakah masih dalam grace period
      if (activatedAtStr != null) {
        final activatedAt = DateTime.parse(activatedAtStr);
        final daysSinceActivation = DateTime.now().difference(activatedAt).inDays;
        
        if (daysSinceActivation <= _gracePeriodDays) {
          return LicenseResult(
            isValid: true,
            message: 'Aktivasi berhasil! (Offline mode)',
          );
        } else {
          return LicenseResult(
            isValid: false,
            message: 'Grace period habis. Silakan online untuk re-validasi.',
          );
        }
      }
      
      return LicenseResult(
        isValid: true,
        message: 'Aktivasi berhasil! (Offline mode)',
      );
    }
    
    // Belum teraktivasi atau key beda → tolak
    return LicenseResult(
      isValid: false,
      message: 'Tidak ada internet. Silakan online untuk aktivasi pertama kali.',
    );
  }
  
  /// Cek apakah sudah teraktivasi
  static Future<bool> isActivated() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_isActivated) == true;
  }
  
  /// Cek apakah masih dalam grace period (offline mode)
  static Future<bool> isInGracePeriod() async {
    final prefs = await SharedPreferences.getInstance();
    final activatedAtStr = prefs.getString(_activatedAt);
    
    if (activatedAtStr == null) return false;
    
    final activatedAt = DateTime.parse(activatedAtStr);
    final daysSinceActivation = DateTime.now().difference(activatedAt).inDays;
    
    return daysSinceActivation <= _gracePeriodDays;
  }
  
  /// Get remaining days in grace period
  static Future<int> getRemainingDays() async {
    final prefs = await SharedPreferences.getInstance();
    final activatedAtStr = prefs.getString(_activatedAt);
    
    if (activatedAtStr == null) return 0;
    
    final activatedAt = DateTime.parse(activatedAtStr);
    final daysSinceActivation = DateTime.now().difference(activatedAt).inDays;
    
    final remaining = _gracePeriodDays - daysSinceActivation;
    return remaining > 0 ? remaining : 0;
  }
  
  /// Re-validate (saat online lagi)
  static Future<LicenseResult> revalidate() async {
    final prefs = await SharedPreferences.getInstance();
    final savedKey = prefs.getString(_licenseKey);
    
    if (savedKey == null || savedKey.isEmpty) {
      return LicenseResult(
        isValid: false,
        message: 'Tidak ada license key tersimpan',
      );
    }
    
    return await validateLicense(savedKey);
  }
  
  /// Get license key yang tersimpan
  static Future<String?> getLicenseKey() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_licenseKey);
  }
  
  /// Hapus lisensi (untuk logout/reset)
  static Future<void> deactivate() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_licenseKey);
    await prefs.remove(_isActivated);
    await prefs.remove(_activatedAt);
  }
  
  /// Update activated_at (untuk sync dengan server)
  static Future<void> updateActivatedAt(String? activatedAtStr) async {
    if (activatedAtStr != null) {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_activatedAt, activatedAtStr);
    }
  }
}

class LicenseResult {
  final bool isValid;
  final String message;
  
  const LicenseResult({
    required this.isValid,
    required this.message,
  });
}
