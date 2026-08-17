import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:kelasfun/core/database/app_database.dart';
import 'package:kelasfun/core/theme/app_theme.dart';
import 'android_student_list_local.dart';
import 'android_attendance_local.dart';
import 'android_settings.dart';

class AndroidMainHome extends StatefulWidget {
  const AndroidMainHome({super.key});

  @override
  State<AndroidMainHome> createState() => _AndroidMainHomeState();
}

class _AndroidMainHomeState extends State<AndroidMainHome> {
  int _currentIndex = 0;

  final _screens = const [
    AndroidStudentListLocal(),
    AndroidAttendanceLocal(),
    AndroidSettings(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _screens[_currentIndex],
      bottomNavigationBar: NavigationBar(
        selectedIndex: _currentIndex,
        onDestinationSelected: (i) => setState(() => _currentIndex = i),
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.people_outline),
            selectedIcon: Icon(Icons.people),
            label: 'Siswa',
          ),
          NavigationDestination(
            icon: Icon(Icons.fact_check_outlined),
            selectedIcon: Icon(Icons.fact_check),
            label: 'Presensi',
          ),
          NavigationDestination(
            icon: Icon(Icons.settings_outlined),
            selectedIcon: Icon(Icons.settings),
            label: 'Pengaturan',
          ),
        ],
      ),
    );
  }
}
