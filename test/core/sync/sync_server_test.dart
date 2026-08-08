import 'dart:convert';
import 'dart:io';
import 'package:drift/native.dart';
import 'package:drift/drift.dart' hide isNotNull;
import 'package:flutter_test/flutter_test.dart';
import 'package:shelf/shelf.dart';
import 'package:shelf/shelf_io.dart' as io;
import 'package:shelf_router/shelf_router.dart';
import 'package:kelasfun/core/database/app_database.dart';
import 'package:kelasfun/core/sync/sync_handler.dart';

void main() {
  late AppDatabase db;
  late SyncHandler handler;
  late HttpServer testServer;
  late String baseUrl;

  setUp(() async {
    db = AppDatabase.forTesting(DatabaseConnection(NativeDatabase.memory()));
    handler = SyncHandler(db: db, apiKey: 'test-key-123');

    final router = Router()
      ..get('/api/health', handler.healthCheck)
      ..get('/api/students', handler.getStudents)
      ..post('/api/attendance', handler.syncAttendance);

    final pipeline = const Pipeline()
        .addMiddleware(logRequests())
        .addHandler(router.call);

    testServer = await io.serve(pipeline, InternetAddress.loopbackIPv4, 0);
    baseUrl = 'http://localhost:${testServer.port}';
  });

  tearDown(() async {
    await testServer.close();
    await db.close();
  });

  group('SyncHandler', () {
    test('health check returns ok', () async {
      final client = HttpClient();
      final request = await client.getUrl(Uri.parse('$baseUrl/api/health'));
      final response = await request.close();
      final body = await utf8.decoder.bind(response).join();
      final data = jsonDecode(body);

      expect(response.statusCode, 200);
      expect(data['status'], 'ok');
      expect(data['version'], '1.0.0');
    });

    test('sync attendance without auth returns 401', () async {
      final client = HttpClient();
      final request = await client.postUrl(Uri.parse('$baseUrl/api/attendance'));
      request.headers.set('Content-Type', 'application/json');
      request.write(jsonEncode({
        'studentId': 1,
        'date': '2026-08-08',
        'status': 'hadir',
        'scanMethod': 'qr',
      }));
      final response = await request.close();
      expect(response.statusCode, 401);
    });

    test('sync attendance with valid auth succeeds', () async {
      final client = HttpClient();
      final request = await client.postUrl(Uri.parse('$baseUrl/api/attendance'));
      request.headers.set('Content-Type', 'application/json');
      request.headers.set('x-api-key', 'test-key-123');
      request.write(jsonEncode({
        'studentId': 1,
        'date': '2026-08-08',
        'status': 'hadir',
        'scanMethod': 'qr',
      }));
      final response = await request.close();
      final body = await utf8.decoder.bind(response).join();
      final data = jsonDecode(body);

      expect(response.statusCode, 200);
      expect(data['success'], true);
    });

    test('get students without auth returns 401', () async {
      final client = HttpClient();
      final request = await client.getUrl(Uri.parse('$baseUrl/api/students'));
      final response = await request.close();
      expect(response.statusCode, 401);
    });

    test('get students with valid auth returns list', () async {
      final client = HttpClient();
      final request = await client.getUrl(Uri.parse('$baseUrl/api/students'));
      request.headers.set('x-api-key', 'test-key-123');
      final response = await request.close();
      final body = await utf8.decoder.bind(response).join();
      final data = jsonDecode(body);

      expect(response.statusCode, 200);
      expect(data['students'], isA<List>());
    });
  });
}
