import 'package:flutter/material.dart';
import 'package:kelasfun/core/theme/app_theme.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('kelasFun')),
      body: const Center(
        child: Text(
          'kelasFun - Aplikasi Manajemen Kelas',
          style: TextStyle(fontSize: 18, color: AppTheme.darkGray),
        ),
      ),
    );
  }
}
