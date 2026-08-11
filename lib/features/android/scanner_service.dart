import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'pairing_config.dart';

class ScanResult {
  final bool success;
  final int statusCode;
  final String? studentName;
  final String? className;
  final String? error;

  const ScanResult({
    required this.success,
    required this.statusCode,
    this.studentName,
    this.className,
    this.error,
  });
}

class ScannerService {
  static const configKey = 'pairing_config';

  final http.Client _client;

  ScannerService({http.Client? client}) : _client = client ?? http.Client();

  Future<PairingConfig?> loadConfig() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(configKey);
    if (raw == null) return null;
    return PairingConfig.fromJson(jsonDecode(raw) as Map<String, dynamic>);
  }

  Future<void> saveConfig(PairingConfig config) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(configKey, jsonEncode(config.toJson()));
  }

  Future<ScanResult> sendScan(String nis, {DateTime? now}) async {
    final config = await loadConfig();
    if (config == null) {
      return const ScanResult(success: false, statusCode: 0, error: 'Belum terhubung');
    }

    final timestamp = (now ?? DateTime.now()).toUtc().toIso8601String();
    final uri = Uri.parse('http://${config.ip}:${config.port}/api/scan');
    final headers = <String, String>{
      'Content-Type': 'application/json',
      if (config.token != null) 'X-API-Key': config.token!,
    };
    final body = jsonEncode({'student_id': nis, 'timestamp': timestamp});

    try {
      final response = await _client.post(uri, headers: headers, body: body);
      final data = jsonDecode(response.body) as Map<String, dynamic>;

      if (response.statusCode == 200 && data['success'] == true) {
        final student = (data['student'] ?? {}) as Map<String, dynamic>;
        return ScanResult(
          success: true,
          statusCode: 200,
          studentName: student['name'] as String?,
          className: student['className'] as String?,
        );
      }

      return ScanResult(
        success: false,
        statusCode: response.statusCode,
        error: data['error'] as String? ?? 'Gagal mengirim scan',
      );
    } catch (e) {
      return ScanResult(success: false, statusCode: 0, error: e.toString());
    }
  }
}
