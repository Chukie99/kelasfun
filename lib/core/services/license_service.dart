import 'dart:async';
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
  static const String _supabaseUrl = 'https://cdgnqhdmsnrlzylgoecz.supabase.co';
  static const String _supabaseKey = 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImNkZ25xaGRtc25ybHp5bGdvZWN6Iiwicm9sZSI6ImFub24iLCJpYXQiOjE3ODY5NzUyNzgsImV4cCI6MjEwMjU1MTI3OH0.a3mH4gFGPV_aRvgFCJFHMjQQsc3AQc0YBvrLEeFM_HA';

  static const String _deviceIdKey = 'kelasfun_device_id';
  static String? _cachedDeviceId;

  static Future<String> getDeviceId() async {
    if (_cachedDeviceId != null) return _cachedDeviceId!;

    final prefs = await SharedPreferences.getInstance();

    // 1) ID platform asli (Android build fingerprint / Windows deviceId).
    try {
      final deviceInfo = DeviceInfoPlugin();
      if (Platform.isAndroid) {
        final androidInfo = await deviceInfo.androidInfo;
        _cachedDeviceId =
            '${androidInfo.model}-${androidInfo.brand}-${androidInfo.id}';
      } else if (Platform.isWindows) {
        final windowsInfo = await deviceInfo.windowsInfo;
        _cachedDeviceId = windowsInfo.deviceId;
      }
    } catch (_) {}

    if (_cachedDeviceId != null && _cachedDeviceId!.isNotEmpty) {
      await prefs.setString(_deviceIdKey, _cachedDeviceId!);
      return _cachedDeviceId!;
    }

    // 2) FALLBACK STABIL: pakai ID yang pernah tersimpan; kalau belum ada,
    // generate sekali lalu simpan PERMANEN. Dulu fallback-nya timestamp ->
    // berubah tiap error sehingga server menolak lisensi
    // ("serial sudah dipakai device lain") padahal HP-nya sama.
    final saved = prefs.getString(_deviceIdKey);
    if (saved != null && saved.isNotEmpty) {
      _cachedDeviceId = saved;
      return saved;
    }
    final fresh =
        'KF-DEV-${DateTime.now().millisecondsSinceEpoch.toRadixString(36).toUpperCase()}';
    await prefs.setString(_deviceIdKey, fresh);
    _cachedDeviceId = fresh;
    return fresh;
  }

  static bool _isValidSerialFormat(String serial) {
    return RegExp(r'^KF-[A-Z0-9]{4}-[A-Z0-9]{4}$').hasMatch(serial.toUpperCase());
  }

  static Future<LicenseResult> requestSerialNumber(
    String email, {
    http.Client? httpClient,
  }) async {
    final deviceId = await getDeviceId();
    print('[LICENSE] Request serial for: $email | Device: $deviceId');

    final client = httpClient ?? http.Client();
    try {
      final response = await client
          .post(
            Uri.parse('$_supabaseUrl/functions/v1/generate-license'),
            headers: _authHeaders(),
            body: jsonEncode({
              'email': email,
              'device_id': deviceId,
            }),
          )
          .timeout(const Duration(seconds: 30));

      print('[LICENSE] Response: ${response.statusCode} | ${response.body}');

      if (response.statusCode != 200) {
        return LicenseResult(isValid: false, message: _serverErrorMessage(response, 'Gagal request serial'));
      }

      final data = jsonDecode(response.body);
      final success = data['success'] == true;
      final message = data['message'] ?? 'Unknown response';

      return LicenseResult(isValid: success, message: message);
    } on SocketException catch (e) {
      print('[LICENSE] SocketException: $e');
      return LicenseResult(
        isValid: false,
        message: _socketErrorMessage(e, 'Tidak ada internet. Silakan online untuk request serial.'),
        networkError: true,
      );
    } on TimeoutException catch (e) {
      print('[LICENSE] TimeoutException: $e');
      return const LicenseResult(
        isValid: false,
        message: 'Koneksi lambat atau timeout. Periksa internet Anda dan coba lagi.',
        networkError: true,
      );
    } catch (e) {
      print('[LICENSE] Error: $e');
      return LicenseResult(isValid: false, message: 'Terjadi kesalahan koneksi: $e');
    } finally {
      if (httpClient == null) client.close();
    }
  }

  static bool _isDnsFailure(SocketException e) {
    final detail = '${e.message} ${e.osError?.message ?? ''}'.toLowerCase();
    return detail.contains('failed host lookup') ||
        detail.contains('no address associated') ||
        detail.contains('name or service not known') ||
        detail.contains('temporary failure in name resolution');
  }

  static String _socketErrorMessage(SocketException e, String offlineMessage) {
    if (_isDnsFailure(e)) {
      return 'Server aktivasi tidak dapat dihubungi. Server mungkin sedang bermasalah atau diblokir jaringan.';
    }
    return offlineMessage;
  }

  static String _serverErrorMessage(http.Response response, String fallback) {
    try {
      final body = jsonDecode(response.body);
      final detail = body['error'] ?? body['message'];
      if (detail is String && detail.trim().isNotEmpty) {
        return '$fallback (${response.statusCode}): $detail';
      }
    } catch (_) {}
    return '$fallback. Status: ${response.statusCode}';
  }

  static Future<LicenseResult> verifySerialNumber(
    String serialNumber, {
    http.Client? httpClient,
  }) async {
    final deviceId = await getDeviceId();
    print('[LICENSE] Serial: $serialNumber | Device: $deviceId');

    if (!_isValidSerialFormat(serialNumber)) {
      return const LicenseResult(isValid: false, message: 'Format serial salah. Contoh: KF-AB12-CD34');
    }

    final client = httpClient ?? http.Client();
    try {
      final response = await client
          .post(
            Uri.parse('$_supabaseUrl/functions/v1/verify-license'),
            headers: _authHeaders(),
            body: jsonEncode({
              'serial_number': serialNumber.toUpperCase(),
              'device_id': deviceId,
            }),
          )
          .timeout(const Duration(seconds: 30));

      print('[LICENSE] Response: ${response.statusCode} | ${response.body}');

      if (response.statusCode != 200) {
        return LicenseResult(isValid: false, message: _serverErrorMessage(response, 'Gagal aktivasi'));
      }

      final data = jsonDecode(response.body);
      final valid = data['valid'] == true;
      final message = data['message'] ?? (valid ? 'Aktivasi berhasil!' : 'Serial tidak valid');

      if (valid) {
        await _saveLocal(serialNumber);
      }

      return LicenseResult(isValid: valid, message: message);
    } on SocketException catch (e) {
      print('[LICENSE] SocketException: $e');
      if (_isDnsFailure(e)) {
        return const LicenseResult(
          isValid: false,
          message: 'Server aktivasi tidak dapat dihubungi. Server mungkin sedang bermasalah atau diblokir jaringan.',
          networkError: true,
        );
      }
      return const LicenseResult(
        isValid: false,
        message: 'Tidak ada internet. Silakan online untuk aktivasi.',
        networkError: true,
      );
    } on TimeoutException catch (e) {
      print('[LICENSE] TimeoutException: $e');
      return const LicenseResult(
        isValid: false,
        message: 'Koneksi lambat atau timeout. Periksa internet Anda dan coba lagi.',
        networkError: true,
      );
    } catch (e) {
      print('[LICENSE] Error: $e');
      return LicenseResult(isValid: false, message: 'Terjadi kesalahan koneksi: $e');
    } finally {
      if (httpClient == null) client.close();
    }
  }

  static Map<String, String> _authHeaders() => {
        'Content-Type': 'application/json',
        'apikey': _supabaseKey,
        'Authorization': 'Bearer $_supabaseKey',
      };

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
      return const LicenseResult(isValid: false, message: 'Tidak ada serial number tersimpan');
    }
    return await verifySerialNumber(savedSerial);
  }
}

class LicenseResult {
  final bool isValid;
  final String message;
  final bool networkError;
  const LicenseResult({
    required this.isValid,
    required this.message,
    this.networkError = false,
  });
}