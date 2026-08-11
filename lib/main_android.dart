import 'package:flutter/material.dart';
import 'package:kelasfun/core/theme/app_theme.dart';
import 'package:kelasfun/features/android/android_home.dart';
import 'package:kelasfun/features/android/scanner_controller.dart';
import 'package:kelasfun/features/android/scanner_service.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(MaterialApp(
    title: 'kelasFun Scanner',
    debugShowCheckedModeBanner: false,
    theme: AppTheme.darkTheme,
    home: AndroidHome(
      service: ScannerService(),
      scannerBuilder: MobileScannerControllerImpl.new,
    ),
  ));
}
