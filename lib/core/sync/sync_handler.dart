import 'dart:convert';
import 'package:shelf/shelf.dart';
import 'package:kelasfun/core/database/app_database.dart';

class SyncHandler {
  final AppDatabase db;
  final String apiKey;

  SyncHandler({required this.db, required this.apiKey});

  bool _validateAuth(Request request) {
    final key = request.headers['x-api-key'];
    return key == apiKey;
  }

  Response _jsonResponse(Map<String, dynamic> data, {int status = 200}) {
    return Response(
      status,
      body: jsonEncode(data),
      headers: {'Content-Type': 'application/json'},
    );
  }

  Future<Response> healthCheck(Request request) async {
    return _jsonResponse({'status': 'ok', 'version': '1.0.0'});
  }

  Future<Response> syncAttendance(Request request) async {
    if (!_validateAuth(request)) {
      return _jsonResponse({'error': 'Unauthorized'}, status: 401);
    }

    try {
      final body = await request.readAsString();
      final data = jsonDecode(body) as Map<String, dynamic>;

      final studentId = data['studentId'] as int;
      final date = data['date'] as String;
      final status = data['status'] as String;
      final scanMethod = data['scanMethod'] as String;

      await db.attendanceDao.markAttendance(
        studentId: studentId,
        date: date,
        status: status,
        scanMethod: scanMethod,
      );

      return _jsonResponse({'success': true, 'message': 'Attendance synced'});
    } catch (e) {
      return _jsonResponse({'error': e.toString()}, status: 400);
    }
  }

  Future<Response> getStudents(Request request) async {
    if (!_validateAuth(request)) {
      return _jsonResponse({'error': 'Unauthorized'}, status: 401);
    }

    final students = await db.studentDao.getAllStudents();
    final data = students.map((s) => {
      'id': s.id,
      'nis': s.nis,
      'fullName': s.fullName,
      'className': s.className,
      'qrData': s.qrData,
    }).toList();

    return _jsonResponse({'students': data});
  }
}
