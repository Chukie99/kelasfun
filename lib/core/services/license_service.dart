import 'dart:convert';
import 'dart:io';
import 'package:crypto/crypto.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class LicenseService {
  static const String _licenseKey = 'kelasfun_license_key';
  static const String _deviceId = 'kelasfun_device_id';
  static const String _activatedAt = 'kelasfun_activated_at';
  
  // Server URL untuk validasi lisensi
  // Ganti dengan URL server Anda
  static const String _serverUrl = 'https://your-license-server.com/api';
  
  /// Generate device ID berdasarkan hardware
  static Future<String> getDeviceId() async {
    final prefs = await SharedPreferences.getInstance();
    String? storedDeviceId = prefs.getString(_deviceId);
    
    if (storedDeviceId != null) return storedDeviceId;
    
    String rawDeviceId = '';
    
    if (Platform.isAndroid) {
      // Untuk Android, gunakan kombinasi informasi device
      // Dalam implementasi nyata, gunakan package device_info_plus
      rawDeviceId = await _getAndroidDeviceId();
    } else if (Platform.isWindows) {
      // Untuk Windows, gunakan machine GUID
      rawDeviceId = await _getWindowsDeviceId();
    }
    
    // Hash device ID untuk keamanan
    final bytes = utf8.encode(rawDeviceId);
    final hash = sha256.convert(bytes);
    final deviceId = hash.toString().substring(0, 32);
    
    await prefs.setString(_deviceId, deviceId);
    return deviceId;
  }
  
  /// Get Android device ID
  static Future<String> _getAndroidDeviceId() async {
    // Dalam implementasi nyata, gunakan:
    // - device_info_plus package
    // - await DeviceInfoPlugin().androidInfo
    // - androidInfo.id (Android ID)
    
    // Untuk sekarang, gunakan placeholder
    // Yang akan diganti dengan device_info_plus
    return 'android_${DateTime.now().millisecondsSinceEpoch}';
  }
  
  /// Get Windows device ID
  static Future<String> _getWindowsDeviceId() async {
    try {
      // Gunakan Windows machine GUID dari registry
      final result = await Process.run('reg', [
        'query',
        r'HKLM\SOFTWARE\Microsoft\Cryptography',
        '/v',
        'MachineGuid',
      ]);
      
      if (result.exitCode == 0) {
        final output = result.stdout.toString();
        final match = RegExp(r'MachineGuid\s+REG_SZ\s+(\S+)').firstMatch(output);
        if (match != null) {
          return match.group(1) ?? '';
        }
      }
    } catch (e) {
      // Fallback jika gagal
    }
    
    return 'windows_${DateTime.now().millisecondsSinceEpoch}';
  }
  
  /// Validasi license key
  static Future<LicenseResult> validateLicense(String licenseKey) async {
    try {
      final deviceId = await getDeviceId();
      
      // Format license key: XXXX-XXXX-XXXX-XXXX
      if (!_isValidFormat(licenseKey)) {
        return LicenseResult(
          isValid: false,
          message: 'Format license key tidak valid',
        );
      }
      
      // Validasi ke server
      try {
        final response = await http.post(
          Uri.parse('$_serverUrl/validate'),
          headers: {'Content-Type': 'application/json'},
          body: jsonEncode({
            'licenseKey': licenseKey,
            'deviceId': deviceId,
          }),
        );
        
        final data = jsonDecode(response.body);
        
        if (response.statusCode == 200 && data['valid'] == true) {
          // Simpan license key
          final prefs = await SharedPreferences.getInstance();
          await prefs.setString(_licenseKey, licenseKey);
          await prefs.setString(_activatedAt, data['activatedAt'] ?? DateTime.now().toIso8601String());
          
          return LicenseResult(
            isValid: true,
            message: data['message'] ?? 'Aktivasi berhasil!',
          );
        }
        
        return LicenseResult(
          isValid: false,
          message: data['error'] ?? 'License key tidak valid',
        );
      } catch (e) {
        // Jika server tidak tersedia, fallback ke validasi offline
        // (untuk development/testing saja)
        print('Server validation failed, using offline: $e');
        return await _validateOffline(licenseKey, deviceId);
      }
    } catch (e) {
      return LicenseResult(
        isValid: false,
        message: 'Gagal memvalidasi lisensi: $e',
      );
    }
  }
  
  /// Cek apakah sudah teraktivasi
  static Future<bool> isActivated() async {
    final prefs = await SharedPreferences.getInstance();
    final key = prefs.getString(_licenseKey);
    return key != null && key.isNotEmpty;
  }
  
  /// Get license key yang tersimpan
  static Future<String?> getLicenseKey() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_licenseKey);
  }
  
  /// Hapus lisensi (untuk logout atau reset)
  static Future<void> deactivate() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_licenseKey);
    await prefs.remove(_activatedAt);
  }
  
  /// Validasi format license key
  static bool _isValidFormat(String key) {
    // Format: XXXX-XXXX-XXXX-XXXX (huruf dan angka)
    final regex = RegExp(r'^[A-Z0-9]{4}-[A-Z0-9]{4}-[A-Z0-9]{4}-[A-Z0-9]{4}$');
    return regex.hasMatch(key.toUpperCase());
  }
  
  /// Validasi offline (UNTUK DEVELOPMENT SAJA)
  /// DI PRODUKSI, GUNAKAN VALIDASI SERVER
  /// 
  /// WARNING: Metode ini TIDAK AMAN untuk produksi!
  /// Gunakan hanya untuk testing/development.
  static Future<bool> _validateOffline(String licenseKey, String deviceId) async {
    // Generate hash dari license key + device ID
    // Ini hanya untuk testing, tidak aman untuk produksi
    
    final keyHash = md5.convert(utf8.encode(licenseKey)).toString();
    
    // Daftar license key yang valid (UNTUK TESTING)
    // DI PRODUKSI, INI HARUS DARI SERVER
    final validKeys = {
      'AAAA-BBBB-CCCC-DDDD': true, // Test key
      '1234-5678-9012-3456': true, // Another test key
    };
    
    // Cek apakah key ada di daftar
    if (validKeys.containsKey(licenseKey.toUpperCase())) {
      return true;
    }
    
    // Atau gunakan algoritma validasi
    // Contoh: hash harus diakhiri dengan karakter tertentu
    return keyHash.endsWith('0');
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
