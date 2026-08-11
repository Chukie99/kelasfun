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

class StudentCacheEntry {
  final String nis;
  final String name;
  final String className;

  const StudentCacheEntry({
    required this.nis,
    required this.name,
    required this.className,
  });

  factory StudentCacheEntry.fromJson(Map<String, dynamic> json) {
    return StudentCacheEntry(
      nis: json['nis'] as String,
      name: json['name'] as String,
      className: json['className'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {'nis': nis, 'name': name, 'className': className};
  }
}

class PendingScan {
  final String nis;
  final DateTime timestamp;

  const PendingScan({required this.nis, required this.timestamp});

  factory PendingScan.fromJson(Map<String, dynamic> json) {
    return PendingScan(
      nis: json['nis'] as String,
      timestamp: DateTime.parse(json['timestamp'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {'nis': nis, 'timestamp': timestamp.toIso8601String()};
  }
}

class ScannerService {
  static const configKey = 'pairing_config';
  static const cacheKey = 'student_cache';
  static const queueKey = 'scan_queue';

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

  Future<List<StudentCacheEntry>> loadStudentCache() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(cacheKey);
    if (raw == null) return const [];
    final list = jsonDecode(raw) as List<dynamic>;
    return list
        .map((e) => StudentCacheEntry.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  Future<void> saveStudentCache(List<StudentCacheEntry> entries) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(
      cacheKey,
      jsonEncode(entries.map((e) => e.toJson()).toList()),
    );
  }

  Future<List<PendingScan>> loadQueue() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(queueKey);
    if (raw == null) return [];
    final list = jsonDecode(raw) as List<dynamic>;
    return list.map((e) => PendingScan.fromJson(e as Map<String, dynamic>)).toList();
  }

  Future<void> addToQueue(PendingScan scan) async {
    final queue = await loadQueue();
    queue.add(scan);
    await _saveQueue(queue);
  }

  Future<void> removeFromQueue(String nis) async {
    final queue = await loadQueue();
    final index = queue.indexWhere((s) => s.nis == nis);
    if (index >= 0) queue.removeAt(index);
    await _saveQueue(queue);
  }

  Future<void> clearQueue() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(queueKey);
  }

  Future<void> _saveQueue(List<PendingScan> queue) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(
      queueKey,
      jsonEncode(queue.map((s) => s.toJson()).toList()),
    );
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
