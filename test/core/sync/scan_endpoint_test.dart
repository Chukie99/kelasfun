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

Future<void> _insertStudent(AppDatabase db, String nis,
    {String name = 'Rina', String className = 'X RPL 1'}) async {
  await db.studentDao.insertStudent(
    nis: nis,
    fullName: name,
    className: className,
    gender: 'P',
    qrData: '{"n":"$nis"}',
  );
}

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
      ..post('/api/attendance', handler.syncAttendance)
      ..post('/api/scan', handler.scanAttendance);

    final pipeline = const Pipeline().addMiddleware(logRequests()).addHandler(router.call);

    testServer = await io.serve(pipeline, InternetAddress.loopbackIPv4, 0);
    baseUrl = 'http://localhost:${testServer.port}';
  });

  tearDown(() async {
    await testServer.close();
    await db.close();
  });

  Future<HttpClientResponse> postScan(
    Map<String, dynamic> body, {
    String? apiKey = 'test-key-123',
  }) async {
    final client = HttpClient();
    final request = await client.postUrl(Uri.parse('$baseUrl/api/scan'));
    request.headers.set('Content-Type', 'application/json');
    if (apiKey != null) request.headers.set('x-api-key', apiKey);
    request.write(jsonEncode(body));
    return request.close();
  }

  Future<Map<String, dynamic>> readJson(HttpClientResponse response) async {
    final body = await utf8.decoder.bind(response).join();
    return jsonDecode(body) as Map<String, dynamic>;
  }

  group('POST /api/scan', () {
    test('valid scan returns 200 with student name and className', () async {
      await _insertStudent(db, '12345', name: 'Rina', className: 'X RPL 1');

      final response = await postScan({
        'student_id': '12345',
        'timestamp': '2026-08-10T08:15:00.000Z',
      });
      final data = await readJson(response);

      expect(response.statusCode, 200);
      expect(data['success'], true);
      expect(data['student']['name'], 'Rina');
      expect(data['student']['className'], 'X RPL 1');
      expect(data['student']['status'], 'Hadir');

      final rows = await db.attendanceDao.getAttendanceByDate('2026-08-10');
      expect(rows.length, 1);
      expect(rows.single.status, 'Hadir');
      expect(rows.single.scanMethod, 'WIRELESS');
    });

    test('unknown NIS returns 404', () async {
      final response = await postScan({
        'student_id': '999999',
        'timestamp': '2026-08-10T08:15:00.000Z',
      });
      final data = await readJson(response);

      expect(response.statusCode, 404);
      expect(data['success'], false);
      expect(data['error'], 'Siswa tidak ditemukan');
    });

    test('missing API key returns 401', () async {
      final response = await postScan(
        {'student_id': '12345', 'timestamp': '2026-08-10T08:15:00.000Z'},
        apiKey: null,
      );
      expect(response.statusCode, 401);
    });

    test('same NIS + same date twice is deduped to one row', () async {
      await _insertStudent(db, '12345');

      final r1 = await postScan({
        'student_id': '12345',
        'timestamp': '2026-08-10T08:15:00.000Z',
      });
      final r2 = await postScan({
        'student_id': '12345',
        'timestamp': '2026-08-10T10:30:00.000Z',
      });

      expect(r1.statusCode, 200);
      expect(r2.statusCode, 200);
      final rows = await db.attendanceDao.getAttendanceByDate('2026-08-10');
      expect(rows.length, 1);
    });

    test('malformed timestamp falls back to today and still returns 200', () async {
      await _insertStudent(db, '12345');

      final response = await postScan({
        'student_id': '12345',
        'timestamp': 'bukan-timestamp',
      });
      final data = await readJson(response);

      expect(response.statusCode, 200);
      expect(data['success'], true);

      final today = DateTime.now().toLocal();
      final dateKey =
          '${today.year}-${today.month.toString().padLeft(2, '0')}-${today.day.toString().padLeft(2, '0')}';
      final rows = await db.attendanceDao.getAttendanceByDate(dateKey);
      expect(rows.length, 1);
    });

    test('UTC timestamp is bucketed by local date, not UTC date', () async {
      await _insertStudent(db, '12345');

      const raw = '2026-08-10T23:00:00.000Z';
      final local = DateTime.parse(raw).toLocal();
      final dateKey =
          '${local.year}-${local.month.toString().padLeft(2, '0')}-${local.day.toString().padLeft(2, '0')}';

      final response = await postScan({
        'student_id': '12345',
        'timestamp': raw,
      });
      final data = await readJson(response);

      expect(response.statusCode, 200);
      expect(data['success'], true);

      final rows = await db.attendanceDao.getAttendanceByDate(dateKey);
      expect(rows.length, 1);
    });

    test('missing student_id returns 400', () async {
      final response = await postScan({'timestamp': '2026-08-10T08:15:00.000Z'});
      final data = await readJson(response);
      expect(response.statusCode, 400);
      expect(data['error'], isNotEmpty);
    });
  });
}
