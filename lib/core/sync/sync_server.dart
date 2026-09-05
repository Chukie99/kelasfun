import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:shelf/shelf.dart';
import 'package:shelf/shelf_io.dart' as io;
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

    // Simple manual router — no shelf_router needed
    Future<Response> router(Request request) async {
      final path = request.url.path;
      final method = request.method.toUpperCase();

      if (method == 'GET' && path == 'api/health') {
        return handler.healthCheck(request);
      }
      if (method == 'GET' && path == 'api/students') {
        return handler.getStudents(request);
      }
      if (method == 'POST' && path == 'api/students') {
        return handler.createStudent(request);
      }
      if (method == 'POST' && path == 'api/attendance') {
        return handler.syncAttendance(request);
      }
      if (method == 'POST' && path == 'api/scan') {
        return handler.scanAttendance(request);
      }
      return Response.notFound('Not Found');
    }

    final pipeline = const Pipeline()
        .addMiddleware(logRequests())
        .addHandler(router);

    try {
      _server = await io.serve(pipeline, InternetAddress.anyIPv4, port);
      debugPrint('Sync server running on port $port');
    } catch (e) {
      debugPrint('Failed to start sync server: $e');
      rethrow;
    }
  }

  Future<void> stop() async {
    await _server?.close();
    _server = null;
    debugPrint('Sync server stopped');
  }

  String getServerUrl() {
    return 'http://localhost:$port';
  }
}
