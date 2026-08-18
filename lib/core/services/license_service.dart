import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:device_info_plus/device_info_plus.dart';

class LicenseService {
  static const String _licenseKey = 'kelasfun_license_key';
  static const String _isActivated = 'kelasfun_is_activated';
  static const String _activatedAt = 'kelasfun_activated_at';
  static const int _gracePeriodDays = 30;

  // Supabase
  static const String _supabaseUrl = 'https://cdgnqhdmsnrlzylgoecz.supabase.co';
  static const String _supabaseKey = 'sb_publishable_HLnBeenbfNLvlF7sc6-lcg_fSIS87e3';

  static Future<String> getDeviceId() async {
    try {
      final deviceInfo = DeviceInfoPlugin();
      if (Platform.isAndroid) {
        final androidInfo = await deviceInfo.androidInfo;
        return '${androidInfo.model}-${androidInfo.brand}-${androidInfo.id}';
      } else if (Platform.isWindows) {
        final windowsInfo = await deviceInfo.windowsInfo;
        return windowsInfo.deviceId;
      }
    } catch (e) {}
    return DateTime.now().millisecondsSinceEpoch.toString();
  }

  static bool _isValidFormat(String key) {
    return RegExp(r'^[A-Z0-9]{4}-[A-Z0-9]{4}-[A-Z0-9]{4}-[A-Z0-9]{4}$').hasMatch(key.toUpperCase());
  }

  static Future<LicenseResult> validateLicense(String licenseKey) async {
    final deviceId = await getDeviceId();
    print('[LICENSE] Key: $licenseKey | Device: $deviceId');

    if (!_isValidFormat(licenseKey)) {
      return LicenseResult(isValid: false, message: 'Format key salah. Contoh: ABCD-EFGH-IJKL-MNOP');
    }

    try {
      // 1. Cari key di Supabase
      print('[LICENSE] Cari key di Supabase...');
      final response = await http.get(
        Uri.parse('$_supabaseUrl/rest/v1/licenses?license_key=eq.${licenseKey.toUpperCase()}&select=*'),
        headers: {
          'apikey': _supabaseKey,
          'Authorization': 'Bearer $_supabaseKey',
        },
      );

      print('[LICENSE] Response: ${response.statusCode} | ${response.body}');

      if (response.statusCode != 200) {
        return LicenseResult(isValid: false, message: 'Gagal connect ke server. Status: ${response.statusCode}');
      }

      final List<dynamic> data = jsonDecode(response.body);

      // 2. Key tidak ditemukan
      if (data.isEmpty) {
        return LicenseResult(isValid: false, message: 'License key tidak ditemukan');
      }

      final license = data[0];
      final status = license['status'];
      final savedDeviceId = license['device_id'];

      print('[LICENSE] Status: $status | SavedDevice: $savedDeviceId');

      // 3. Key sudah expired
      if (status == 'expired') {
        return LicenseResult(isValid: false, message: 'License sudah expired');
      }

      // 4. Key belum dipakai → Aktivasi baru
      if (status == 'unused') {
        final updateResponse = await http.patch(
          Uri.parse('$_supabaseUrl/rest/v1/licenses?license_key=eq.${licenseKey.toUpperCase()}'),
          headers: {
            'Content-Type': 'application/json',
            'apikey': _supabaseKey,
            'Authorization': 'Bearer $_supabaseKey',
          },
          body: jsonEncode({
            'device_id': deviceId,
            'status': 'active',
            'activated_at': DateTime.now().toIso8601String(),
          }),
        );

        if (updateResponse.statusCode == 200 || updateResponse.statusCode == 204) {
          await _saveLocal(licenseKey);
          return LicenseResult(isValid: true, message: 'Aktivasi berhasil!');
        } else {
          return LicenseResult(isValid: false, message: 'Gagal aktivasi: ${updateResponse.body}');
        }
      }

      // 5. Key sudah aktif → Cek device
      if (status == 'active') {
        if (savedDeviceId == deviceId) {
          // Device sama → Update last_validated
          await http.patch(
            Uri.parse('$_supabaseUrl/rest/v1/licenses?license_key=eq.${licenseKey.toUpperCase()}'),
            headers: {
              'Content-Type': 'application/json',
              'apikey': _supabaseKey,
              'Authorization': 'Bearer $_supabaseKey',
            },
            body: jsonEncode({'last_validated_at': DateTime.now().toIso8601String()}),
          );
          await _saveLocal(licenseKey);
          return LicenseResult(isValid: true, message: 'Aktivasi berhasil!');
        } else {
          return LicenseResult(isValid: false, message: 'License sudah dipakai device lain. Hubungi admin untuk reset.');
        }
      }

      return LicenseResult(isValid: false, message: 'License tidak valid');
    } catch (e) {
      print('[LICENSE] Error: $e');
      return _validateOffline(licenseKey, deviceId);
    }
  }

  static Future<void> _saveLocal(String licenseKey) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_licenseKey, licenseKey.toUpperCase());
    await prefs.setBool(_isActivated, true);
    await prefs.setString(_activatedAt, DateTime.now().toIso8601String());
  }

  static Future<bool> isActivated() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_isActivated) == true;
  }

  static Future<bool> isInGracePeriod() async {
    final prefs = await SharedPreferences.getInstance();
    final activatedAtStr = prefs.getString(_activatedAt);
    if (activatedAtStr == null) return false;
    final days = DateTime.now().difference(DateTime.parse(activatedAtStr)).inDays;
    return days <= _gracePeriodDays;
  }

  static Future<LicenseResult> revalidate() async {
    final prefs = await SharedPreferences.getInstance();
    final savedKey = prefs.getString(_licenseKey);
    if (savedKey == null || savedKey.isEmpty) {
      return LicenseResult(isValid: false, message: 'Tidak ada license key tersimpan');
    }
    return await validateLicense(savedKey);
  }

  static LicenseResult _validateOffline(String licenseKey, String deviceId) {
    return LicenseResult(isValid: false, message: 'Tidak ada internet. Silakan online untuk aktivasi.');
  }
}

class LicenseResult {
  final bool isValid;
  final String message;
  const LicenseResult({required this.isValid, required this.message});
}
