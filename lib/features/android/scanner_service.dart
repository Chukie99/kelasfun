import 'dart:async';
import 'dart:convert';
import 'dart:io';
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

class SyncResult {
  final int syncedCount;
  final int unknownCount;
  final bool authError;
  final bool notPaired;

  const SyncResult({
    required this.syncedCount,
    required this.unknownCount,
    this.authError = false,
    this.notPaired = false,
  });
}

class CreateStudentResult {
  final bool success;
  final String? error;

  const CreateStudentResult({
    required this.success,
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
  final Duration timeout;

  ScannerService({http.Client? client, this.timeout = const Duration(seconds: 5)})
      : _client = client ?? http.Client();

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

  Future<List<PendingScan>> loadQueue() => _withQueueLock(_readQueue);

  Future<List<PendingScan>> _readQueue() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(queueKey);
    if (raw == null) return [];
    final list = jsonDecode(raw) as List<dynamic>;
    return list.map((e) => PendingScan.fromJson(e as Map<String, dynamic>)).toList();
  }

  Future<void> addToQueue(PendingScan scan) {
    return _withQueueLock(() async {
      final queue = await _readQueue();
      queue.add(scan);
      await _saveQueue(queue);
    });
  }

  Future<void> removeFromQueue(String nis) {
    return _withQueueLock(() async {
      final queue = await _readQueue();
      final index = queue.indexWhere((s) => s.nis == nis);
      if (index >= 0) queue.removeAt(index);
      await _saveQueue(queue);
    });
  }

  Future<void> clearQueue() {
    return _withQueueLock(() async {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(queueKey);
    });
  }

  Future<void> _queueLock = Future.value();

  Future<T> _withQueueLock<T>(Future<T> Function() action) {
    final result = _queueLock.then((_) => action());
    _queueLock = result.then((_) {}, onError: (_) {});
    return result;
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
      final response =
          await _client.post(uri, headers: headers, body: body).timeout(timeout);
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
    } on SocketException {
      await addToQueue(PendingScan(nis: nis, timestamp: now ?? DateTime.now()));
      return const ScanResult(
        success: false,
        statusCode: 0,
        error: 'Tersimpan offline',
      );
    } on http.ClientException {
      await addToQueue(PendingScan(nis: nis, timestamp: now ?? DateTime.now()));
      return const ScanResult(
        success: false,
        statusCode: 0,
        error: 'Tersimpan offline',
      );
    } on TimeoutException {
      await addToQueue(PendingScan(nis: nis, timestamp: now ?? DateTime.now()));
      return const ScanResult(
        success: false,
        statusCode: 0,
        error: 'Tersimpan offline',
      );
    } catch (_) {
      // Error tak terduga (respons malformed, dsb): tetap QUEUE supaya
      // scan tidak hilang permanen. Dulu di sini scan dibuang begitu saja.
      await addToQueue(PendingScan(nis: nis, timestamp: now ?? DateTime.now()));
      return const ScanResult(
        success: false,
        statusCode: 0,
        error: 'Tersimpan offline (error tak terduga)',
      );
    }
  }

  Future<SyncResult> syncPending() async {
    final config = await loadConfig();
    if (config == null) {
      return const SyncResult(syncedCount: 0, unknownCount: 0, notPaired: true);
    }

    final headers = <String, String>{
      'Content-Type': 'application/json',
      if (config.token != null) 'X-API-Key': config.token!,
    };
    final baseUri = Uri.parse('http://${config.ip}:${config.port}');

    // 1. Refresh student cache.
    try {
      final studentsResponse = await _client
          .get(baseUri.replace(path: '/api/students'), headers: headers)
          .timeout(timeout);
      if (studentsResponse.statusCode == 401) {
        return const SyncResult(syncedCount: 0, unknownCount: 0, authError: true);
      }
      if (studentsResponse.statusCode == 200) {
        final data = jsonDecode(studentsResponse.body) as Map<String, dynamic>;
        final students = (data['students'] as List<dynamic>? ?? const [])
            .map((s) => StudentCacheEntry(
                  nis: (s as Map<String, dynamic>)['nis'] as String,
                  name: s['fullName'] as String,
                  className: s['className'] as String,
                ))
            .toList();
        await saveStudentCache(students);
      }
    } catch (e) {
      return const SyncResult(syncedCount: 0, unknownCount: 0);
    }

    // 2. Push queue in order.
    var synced = 0;
    var unknown = 0;
    final queue = await loadQueue();
    for (final scan in queue) {
      try {
        final response = await _client
              .post(
                baseUri.replace(path: '/api/scan'),
                headers: headers,
                body: jsonEncode({
                  'student_id': scan.nis,
                  'timestamp': scan.timestamp.toUtc().toIso8601String(),
                }),
              )
              .timeout(timeout);
        if (response.statusCode == 200) {
          synced++;
          await removeFromQueue(scan.nis);
        } else if (response.statusCode == 404) {
          unknown++;
          await removeFromQueue(scan.nis);
        } else if (response.statusCode == 401) {
          return SyncResult(
            syncedCount: synced,
            unknownCount: unknown,
            authError: true,
          );
        }
      } catch (e) {
        return SyncResult(syncedCount: synced, unknownCount: unknown);
      }
    }

    return SyncResult(syncedCount: synced, unknownCount: unknown);
  }

  Future<bool> syncStudents() async {
    final config = await loadConfig();
    if (config == null) return false;
    final headers = <String, String>{
      'Content-Type': 'application/json',
      if (config.token != null) 'X-API-Key': config.token!,
    };
    final uri = Uri.parse('http://${config.ip}:${config.port}/api/students');
    try {
      final response = await _client.get(uri, headers: headers).timeout(timeout);
      if (response.statusCode != 200) return false;
      final data = jsonDecode(response.body) as Map<String, dynamic>;
      final students = (data['students'] as List<dynamic>? ?? const [])
          .map((s) => StudentCacheEntry(
                nis: (s as Map<String, dynamic>)['nis'] as String,
                name: s['fullName'] as String,
                className: s['className'] as String,
              ))
          .toList();
      await saveStudentCache(students);
      return true;
    } catch (e) {
      return false;
    }
  }

  Future<CreateStudentResult> createStudent({
    required String nis,
    required String fullName,
    required String className,
    required String gender,
    String? birthDate,
    String? address,
    String? parentName,
    String? parentPhone,
  }) async {
    final config = await loadConfig();
    if (config == null) {
      return const CreateStudentResult(success: false, error: 'Belum terhubung');
    }

    final headers = <String, String>{
      'Content-Type': 'application/json',
      if (config.token != null) 'X-API-Key': config.token!,
    };
    final uri = Uri.parse('http://${config.ip}:${config.port}/api/students');
    final body = jsonEncode({
      'nis': nis,
      'fullName': fullName,
      'className': className,
      'gender': gender,
      'birthDate': birthDate,
      'address': address,
      'parentName': parentName,
      'parentPhone': parentPhone,
    });

    try {
      final response = await _client.post(uri, headers: headers, body: body).timeout(timeout);
      final data = jsonDecode(response.body) as Map<String, dynamic>;

      if (response.statusCode == 200 && data['success'] == true) {
        await syncStudents();
        return const CreateStudentResult(success: true);
      }

      return CreateStudentResult(
        success: false,
        error: data['error'] as String? ?? 'Gagal menyimpan siswa',
      );
    } catch (e) {
      return CreateStudentResult(success: false, error: 'Gagal koneksi: $e');
    }
  }
}
