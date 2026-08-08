import 'dart:io';
import 'package:shelf/shelf.dart';
import 'package:shelf/shelf_io.dart' as io;
import 'package:shelf_router/shelf_router.dart';
import 'package:kelasfun/core/database/app_database.dart';
import 'sync_handler.dart';

class SyncServer {
  HttpServer? _server;
  final AppDatabase db;
  final String apiKey;
  final int port;

  SyncServer({
    required this.db,
    required this.apiKey,
    this.port = 8080,
  });

  bool get isRunning => _server != null;

  Future<void> start() async {
    if (_server != null) return;

    final handler = SyncHandler(db: db, apiKey: apiKey);
    
    final router = Router()
      ..get('/api/health', handler.healthCheck)
      ..get('/api/students', handler.getStudents)
      ..post('/api/attendance', handler.syncAttendance);

    final pipeline = const Pipeline()
        .addMiddleware(logRequests())
        .addHandler(router.call);

    _server = await io.serve(pipeline, InternetAddress.anyIPv4, port);
    print('Sync server running on port $port');
  }

  Future<void> stop() async {
    await _server?.close();
    _server = null;
    print('Sync server stopped');
  }

  String getServerUrl() {
    return 'http://localhost:$port';
  }
}
