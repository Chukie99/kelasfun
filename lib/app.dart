import 'package:flutter/material.dart';
import 'package:kelasfun/core/theme/app_theme.dart';
import 'package:kelasfun/features/home/home_screen.dart';

class KelasFunApp extends StatelessWidget {
  const KelasFunApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'kelasFun',
      theme: AppTheme.lightTheme,
      debugShowCheckedModeBanner: false,
      home: const HomeScreen(),
    );
  }
}
