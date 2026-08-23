import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:device_info_plus/device_info_plus.dart';

class LicenseService {
  static const String _serialNumberKey = 'kelasfun_serial_number';
  static const String _isActivated = 'kelasfun_is_activated';
  static const String _activatedAt = 'kelasfun_activated_at';
  static const int _gracePeriodDays = 30;

  // Supabase
  static const String _supabaseUrl = 'https://cdgnqhdmsnrlzygolecz.supabase.co';
  static const String _supabaseKey = 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImNkZ25xaGRtc25ybHp5bGdvZWN6Iiwicm9sZSI6ImFub24iLCJpYXQiOjE3ODY5NzUyNzgsImV4cCI6MjEwMjU1MTI3OH0.a3mH4gFGPV_aRvgFCJFHMjQQsc3AQc0YBvrLEeFM_HA';

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

  static bool _isValidSerialFormat(String serial) {
    return RegExp(r'^KF-[A-Z0-9]{4}-[A-Z0-9]{4}$').hasMatch(serial.toUpperCase());
  }

  static Future<LicenseResult> requestSerialNumber(String email) async {
    final deviceId = await getDeviceId();
    print('[LICENSE] Request serial for: $email | Device: $deviceId');

    try {
      final response = await http.post(
        Uri.parse('$_supabaseUrl/functions/v1/generate-license'),
        headers: {
          'Content-Type': 'application/json',
          'apikey': _supabaseKey,
          'Authorization': 'Bearer $_supabaseKey',
        },
        body: jsonEncode({
          'email': email,
          'device_id': deviceId,
        }),
      );

      print('[LICENSE] Response: ${response.statusCode} | ${response.body}');

      if (response.statusCode != 200) {
        return LicenseResult(isValid: false, message: 'Gagal request serial. Status: ${response.statusCode}');
      }

      final data = jsonDecode(response.body);
      final success = data['success'] == true;
      final message = data['message'] ?? 'Unknown response';

      return LicenseResult(isValid: success, message: message);
    } catch (e) {
      print('[LICENSE] Error: $e');
      return LicenseResult(isValid: false, message: 'Tidak ada internet. Silakan online untuk request serial.');
    }
  }

  static Future<LicenseResult> verifySerialNumber(String serialNumber) async {
    final deviceId = await getDeviceId();
    print('[LICENSE] Serial: $serialNumber | Device: $deviceId');

    if (!_isValidSerialFormat(serialNumber)) {
      return LicenseResult(isValid: false, message: 'Format serial salah. Contoh: KF-AB12-CD34');
    }

    try {
      final response = await http.post(
        Uri.parse('$_supabaseUrl/functions/v1/verify-license'),
        headers: {
          'Content-Type': 'application/json',
          'apikey': _supabaseKey,
          'Authorization': 'Bearer $_supabaseKey',
        },
        body: jsonEncode({
          'serial_number': serialNumber.toUpperCase(),
          'device_id': deviceId,
        }),
      );

      print('[LICENSE] Response: ${response.statusCode} | ${response.body}');

      if (response.statusCode != 200) {
        return LicenseResult(isValid: false, message: 'Gagal connect ke server. Status: ${response.statusCode}');
      }

      final data = jsonDecode(response.body);
      final valid = data['valid'] == true;
      final message = data['message'] ?? (valid ? 'Aktivasi berhasil!' : 'Serial tidak valid');

      if (valid) {
        await _saveLocal(serialNumber);
      }

      return LicenseResult(isValid: valid, message: message);
    } catch (e) {
      print('[LICENSE] Error: $e');
      return _validateOffline(serialNumber, deviceId);
    }
  }

  static Future<void> _saveLocal(String serialNumber) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_serialNumberKey, serialNumber.toUpperCase());
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
    final savedSerial = prefs.getString(_serialNumberKey);
    if (savedSerial == null || savedSerial.isEmpty) {
      return LicenseResult(isValid: false, message: 'Tidak ada serial number tersimpan');
    }
    return await verifySerialNumber(savedSerial);
  }

  static LicenseResult _validateOffline(String serialNumber, String deviceId) {
    return LicenseResult(isValid: false, message: 'Tidak ada internet. Silakan online untuk aktivasi.');
  }
}

class LicenseResult {
  final bool isValid;
  final String message;
  const LicenseResult({required this.isValid, required this.message});
}