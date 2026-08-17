import 'dart:convert';
import 'package:intl/intl.dart';
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

      final studentId = data['studentId'] as int?;
      if (studentId == null) {
        return _jsonResponse({'error': 'studentId is required'}, status: 400);
      }
      final date = data['date'] as String?;
      if (date == null || date.isEmpty) {
        return _jsonResponse({'error': 'date is required'}, status: 400);
      }
      final status = data['status'] as String?;
      if (status == null || status.isEmpty) {
        return _jsonResponse({'error': 'status is required'}, status: 400);
      }
      final scanMethod = data['scanMethod'] as String?;
      if (scanMethod == null || scanMethod.isEmpty) {
        return _jsonResponse({'error': 'scanMethod is required'}, status: 400);
      }
      final description = data['description'] as String?;

      await db.attendanceDao.markAttendance(
        studentId: studentId,
        date: date,
        status: status,
        scanMethod: scanMethod,
        description: description,
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

  Future<Response> scanAttendance(Request request) async {
    if (!_validateAuth(request)) {
      return _jsonResponse({'error': 'Unauthorized'}, status: 401);
    }

    try {
      final body = await request.readAsString();
      final data = jsonDecode(body) as Map<String, dynamic>;

      final rawStudentId = data['student_id'];
      if (rawStudentId == null || rawStudentId.toString().isEmpty) {
        return _jsonResponse({'error': 'student_id is required'}, status: 400);
      }
      final studentId = rawStudentId.toString();

      final student = await db.studentDao.getStudentByNis(studentId);
      if (student == null) {
        return _jsonResponse(
          {'success': false, 'error': 'Siswa tidak ditemukan'},
          status: 404,
        );
      }

      final timestamp = _parseTimestamp(data['timestamp']);
      final date = DateFormat('yyyy-MM-dd').format(timestamp.toLocal());

      await db.attendanceDao.markAttendance(
        studentId: student.id,
        date: date,
        status: 'Hadir',
        scanMethod: 'WIRELESS',
      );

      return _jsonResponse({
        'success': true,
        'student': {
          'name': student.fullName,
          'className': student.className,
          'status': 'Hadir',
        },
      });
    } on FormatException {
      return _jsonResponse({'error': 'Malformed JSON'}, status: 400);
    } catch (e) {
      return _jsonResponse({'error': e.toString()}, status: 400);
    }
  }

  Future<Response> createStudent(Request request) async {
    if (!_validateAuth(request)) {
      return _jsonResponse({'error': 'Unauthorized'}, status: 401);
    }

    try {
      final body = await request.readAsString();
      final data = jsonDecode(body) as Map<String, dynamic>;

      final nis = data['nis'] as String?;
      if (nis == null || nis.isEmpty) {
        return _jsonResponse({'error': 'nis is required'}, status: 400);
      }
      final fullName = data['fullName'] as String?;
      if (fullName == null || fullName.isEmpty) {
        return _jsonResponse({'error': 'fullName is required'}, status: 400);
      }
      final className = data['className'] as String?;
      if (className == null || className.isEmpty) {
        return _jsonResponse({'error': 'className is required'}, status: 400);
      }
      final gender = data['gender'] as String?;
      if (gender == null || gender.isEmpty) {
        return _jsonResponse({'error': 'gender is required'}, status: 400);
      }

      final existing = await db.studentDao.getStudentByNis(nis);
      if (existing != null) {
        return _jsonResponse({'error': 'NIS sudah digunakan'}, status: 409);
      }

      final qrData = data['qrData'] as String? ?? nis;
      final birthDate = data['birthDate'] as String?;
      final address = data['address'] as String?;
      final parentName = data['parentName'] as String?;
      final parentPhone = data['parentPhone'] as String?;

      final id = await db.studentDao.insertStudent(
        nis: nis,
        fullName: fullName,
        className: className,
        gender: gender,
        qrData: qrData,
        birthDate: birthDate,
        address: address,
        parentName: parentName,
        parentPhone: parentPhone,
      );

      return _jsonResponse({
        'success': true,
        'student': {
          'id': id,
          'nis': nis,
          'fullName': fullName,
          'className': className,
        },
      });
    } on FormatException {
      return _jsonResponse({'error': 'Malformed JSON'}, status: 400);
    } catch (e) {
      return _jsonResponse({'error': e.toString()}, status: 400);
    }
  }

  DateTime _parseTimestamp(dynamic raw) {
    if (raw is String) {
      final parsed = DateTime.tryParse(raw);
      if (parsed != null) return parsed;
    }
    return DateTime.now().toLocal();
  }
}
