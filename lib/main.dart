import 'dart:async';
import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:kelasfun/app.dart';
import 'package:kelasfun/core/database/app_database.dart';

const String supabaseUrl = 'https://cdgnqhdmsnrlzylgoecz.supabase.co';
const String supabaseAnonKey = 'sb_publishable_HLnBeenbfNLvlF7sc6-lcg_fSIS87e3';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  FlutterError.onError = (details) {
    FlutterError.presentError(details);
    log('Flutter Error: ${details.exceptionAsString()}',
        stackTrace: details.stack);
  };

  await Supabase.initialize(
    url: supabaseUrl,
    anonKey: supabaseAnonKey,
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
