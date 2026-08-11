import 'dart:convert';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:kelasfun/features/android/pairing_config.dart';
import 'package:kelasfun/features/android/scanner_service.dart';

Future<void> _seedConfig({String? token = 'kelasfun-secret-key'}) async {
  SharedPreferences.setMockInitialValues({
    'pairing_config': jsonEncode({
      'ip': '192.168.1.50',
      'port': 8080,
      'token': token,
    }),
  });
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('PairingConfig persistence', () {
    test('saveConfig then loadConfig round-trips', () async {
      SharedPreferences.setMockInitialValues({});
      final service = ScannerService();
      const config = PairingConfig(ip: '10.0.0.2', port: 8080, token: 'abc');

      await service.saveConfig(config);
      final loaded = await service.loadConfig();

      expect(loaded, isNotNull);
      expect(loaded!.ip, '10.0.0.2');
      expect(loaded.port, 8080);
      expect(loaded.token, 'abc');
    });

    test('loadConfig returns null when nothing saved', () async {
      SharedPreferences.setMockInitialValues({});
      final service = ScannerService();
      expect(await service.loadConfig(), isNull);
    });
  });

  group('sendScan', () {
    test('builds correct URL, headers, body and parses success', () async {
      await _seedConfig();
      late http.Request captured;
      final client = MockClient((request) async {
        captured = request;
        return http.Response(
          jsonEncode({
            'success': true,
            'student': {'name': 'Rina', 'className': 'X RPL 1', 'status': 'Hadir'},
          }),
          200,
          headers: {'content-type': 'application/json'},
        );
      });
      final service = ScannerService(client: client);
      final now = DateTime.parse('2026-08-10T08:15:00.000Z');

      final result = await service.sendScan('12345', now: now);

      expect(captured.method, 'POST');
      expect(captured.url.toString(), 'http://192.168.1.50:8080/api/scan');
      expect(captured.headers['Content-Type'], 'application/json');
      expect(captured.headers['X-API-Key'], 'kelasfun-secret-key');
      final body = jsonDecode(captured.body) as Map<String, dynamic>;
      expect(body['student_id'], '12345');
      expect(body['timestamp'], '2026-08-10T08:15:00.000Z');

      expect(result.success, isTrue);
      expect(result.statusCode, 200);
      expect(result.studentName, 'Rina');
      expect(result.className, 'X RPL 1');
      expect(result.error, isNull);
    });

    test('parses 404 as failure with error message', () async {
      await _seedConfig();
      final client = MockClient((request) async {
        return http.Response(
          jsonEncode({'success': false, 'error': 'Siswa tidak ditemukan'}),
          404,
          headers: {'content-type': 'application/json'},
        );
      });
      final service = ScannerService(client: client);

      final result = await service.sendScan('999999');

      expect(result.success, isFalse);
      expect(result.statusCode, 404);
      expect(result.error, 'Siswa tidak ditemukan');
      expect(result.studentName, isNull);
    });

    test('omits X-API-Key header when config has no token', () async {
      SharedPreferences.setMockInitialValues({
        'pairing_config': jsonEncode({'ip': '192.168.1.50', 'port': 8080, 'token': null}),
      });
      late http.Request captured;
      final client = MockClient((request) async {
        captured = request;
        return http.Response(jsonEncode({'success': true, 'student': {}}), 200);
      });
      final service = ScannerService(client: client);

      await service.sendScan('12345');

      expect(captured.headers.containsKey('X-API-Key'), isFalse);
    });

    test('returns failure when no pairing config saved', () async {
      SharedPreferences.setMockInitialValues({});
      final service = ScannerService(client: MockClient((_) async {
        return http.Response('{}', 200);
      }));

      final result = await service.sendScan('12345');

      expect(result.success, isFalse);
      expect(result.statusCode, 0);
    });

    test('returns failure on network exception', () async {
      await _seedConfig();
      final client = MockClient((request) async {
        throw http.ClientException('Connection refused');
      });
      final service = ScannerService(client: client);

      final result = await service.sendScan('12345');

      expect(result.success, isFalse);
      expect(result.error, 'Tersimpan offline');
    });

    test('queues the scan on transport failure and reports offline', () async {
      await _seedConfig();
      final client = MockClient((request) async {
        throw http.ClientException('Connection refused');
      });
      final service = ScannerService(client: client);
      final now = DateTime.parse('2026-08-11T01:00:00.000Z');

      final result = await service.sendScan('12345', now: now);

      expect(result.success, isFalse);
      expect(result.error, 'Tersimpan offline');
      final queue = await service.loadQueue();
      expect(queue.length, 1);
      expect(queue.single.nis, '12345');
      expect(queue.single.timestamp.toUtc(), now);
    });

    test('does NOT queue on HTTP 404 response', () async {
      await _seedConfig();
      final client = MockClient((request) async {
        return http.Response(
          jsonEncode({'success': false, 'error': 'Siswa tidak ditemukan'}),
          404,
          headers: {'content-type': 'application/json'},
        );
      });
      final service = ScannerService(client: client);

      final result = await service.sendScan('999999');

      expect(result.success, isFalse);
      expect(result.error, 'Siswa tidak ditemukan');
      expect(await service.loadQueue(), isEmpty);
    });

    test('does NOT queue on HTTP 200 success', () async {
      await _seedConfig();
      final client = MockClient((request) async {
        return http.Response(
          jsonEncode({'success': true, 'student': {'name': 'Rina', 'className': 'X RPL 1', 'status': 'Hadir'}}),
          200,
          headers: {'content-type': 'application/json'},
        );
      });
      final service = ScannerService(client: client);

      final result = await service.sendScan('12345');

      expect(result.success, isTrue);
      expect(await service.loadQueue(), isEmpty);
    });
  });

  group('student cache and pending queue', () {
    test('student cache round-trips', () async {
      SharedPreferences.setMockInitialValues({});
      final service = ScannerService();

      await service.saveStudentCache(const [
        StudentCacheEntry(nis: '12345', name: 'Rina', className: 'X RPL 1'),
      ]);
      final loaded = await service.loadStudentCache();

      expect(loaded.length, 1);
      expect(loaded.first.nis, '12345');
      expect(loaded.first.name, 'Rina');
      expect(loaded.first.className, 'X RPL 1');
    });

    test('empty cache returns empty list', () async {
      SharedPreferences.setMockInitialValues({});
      final service = ScannerService();
      expect(await service.loadStudentCache(), isEmpty);
    });

    test('queue add/load round-trips in order', () async {
      SharedPreferences.setMockInitialValues({});
      final service = ScannerService();
      final ts = DateTime.parse('2026-08-11T01:00:00.000Z');

      await service.addToQueue(PendingScan(nis: '111', timestamp: ts));
      await service.addToQueue(PendingScan(nis: '222', timestamp: ts));

      final queue = await service.loadQueue();
      expect(queue.length, 2);
      expect(queue[0].nis, '111');
      expect(queue[1].nis, '222');
      expect(queue[0].timestamp.toUtc(), ts);
    });

    test('removeFromQueue removes first matching nis only', () async {
      SharedPreferences.setMockInitialValues({});
      final service = ScannerService();
      final ts = DateTime.parse('2026-08-11T01:00:00.000Z');

      await service.addToQueue(PendingScan(nis: '111', timestamp: ts));
      await service.addToQueue(PendingScan(nis: '111', timestamp: ts));
      await service.removeFromQueue('111');

      final queue = await service.loadQueue();
      expect(queue.length, 1);
    });

    test('clearQueue empties the queue', () async {
      SharedPreferences.setMockInitialValues({});
      final service = ScannerService();
      await service.addToQueue(PendingScan(nis: '111', timestamp: DateTime.now()));
      await service.clearQueue();
      expect(await service.loadQueue(), isEmpty);
    });
  });
}
