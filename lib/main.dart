import 'dart:async';
import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:kelasfun/core/config/app_config.dart';
import 'package:kelasfun/app.dart';
import 'package:kelasfun/core/database/app_database.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  FlutterError.onError = (details) {
    FlutterError.presentError(details);
    log('Flutter Error: ${details.exceptionAsString()}',
        stackTrace: details.stack);
  };

  await Supabase.initialize(
    url: AppConfig.supabaseUrl,
    anonKey: AppConfig.supabaseAnonKey,
    authOptions: const FlutterAuthClientOptions(
      // Must match the redirectTo scheme/host registered in AndroidManifest.
      authScreenLaunchMode: LaunchMode.inAppWebView,
    ),
  );

  final db = AppDatabase();

  runZonedGuarded<Future<void>>(() async {
    runApp(KelasFunApp(database: db));
  }, (error, stack) {
    log('Uncaught Error: $error', stackTrace: stack);
  });
}
