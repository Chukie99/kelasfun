import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:kelasfun/core/database/app_database.dart';
import 'sync_config.dart';

class SyncService {
  final AppDatabase db;
  final SyncConfig config;

  SyncService({required this.db, required this.config});

  Future<bool> syncAttendance() async {
    try {
      final unsynced = await db.attendanceDao.getUnsyncedAttendance();
      
      for (final record in unsynced) {
        final response = await http.post(
          Uri.parse('${config.serverUrl}/api/attendance'),
          headers: {
            'Content-Type': 'application/json',
            'X-API-Key': config.apiKey,
          },
          body: jsonEncode({
            'studentId': record.studentId,
            'date': record.date,
            'status': record.status,
            'scanMethod': record.scanMethod,
          }),
        );

        if (response.statusCode == 200) {
          await db.attendanceDao.markSynced(record.id);
        }
      }
      return true;
    } catch (e) {
      return false;
    }
  }

  Future<bool> testConnection() async {
    try {
      final response = await http.get(
        Uri.parse('${config.serverUrl}/api/health'),
        headers: {'X-API-Key': config.apiKey},
      );
      return response.statusCode == 200;
    } catch (e) {
      return false;
    }
  }
}
