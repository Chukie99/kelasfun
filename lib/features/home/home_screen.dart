import 'package:flutter/material.dart';
import 'package:kelasfun/core/theme/app_theme.dart';
import 'package:kelasfun/features/home/dashboard_screen.dart';
import 'package:kelasfun/features/students/student_list_screen.dart';
import 'package:kelasfun/features/subjects/subject_screen.dart';
import 'package:kelasfun/features/grades/ranking_screen.dart';
import 'package:kelasfun/features/discipline/point_screen.dart';
import 'package:kelasfun/features/reports/report_screen.dart';
import 'package:kelasfun/features/settings/settings_screen.dart';
import 'package:kelasfun/features/attendance/attendance_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;

  static const List<_MenuItem> _menuItems = [
    _MenuItem(icon: Icons.dashboard, label: 'Beranda'),
    _MenuItem(icon: Icons.qr_code_scanner, label: 'Presensi'),
    _MenuItem(icon: Icons.people, label: 'Siswa'),
    _MenuItem(icon: Icons.subject, label: 'Mapel'),
    _MenuItem(icon: Icons.emoji_events, label: 'Peringkat'),
    _MenuItem(icon: Icons.star, label: 'Poin'),
    _MenuItem(icon: Icons.description, label: 'Laporan'),
    _MenuItem(icon: Icons.settings, label: 'Setting'),
  ];

  Widget _buildContent() {
    switch (_selectedIndex) {
      case 0:
        return DashboardScreen(
          onNavigate: () => setState(() => _selectedIndex = 1),
        );
      case 1: return const AttendanceScreen();
      case 2: return const StudentListScreen();
      case 3: return const SubjectScreen();
      case 4: return const RankingScreen();
      case 5: return const PointScreen();
      case 6: return const ReportScreen();
      case 7: return const SettingsScreen();
      default: return DashboardScreen(
        onNavigate: () => setState(() => _selectedIndex = 1),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Row(
        children: [
          NavigationRail(
            selectedIndex: _selectedIndex,
            onDestinationSelected: (index) => setState(() => _selectedIndex = index),
            labelType: NavigationRailLabelType.all,
            selectedIconTheme: const IconThemeData(color: AppTheme.cyan),
            selectedLabelTextStyle: const TextStyle(color: AppTheme.cyan),
            destinations: _menuItems.map((item) {
              return NavigationRailDestination(
                icon: Icon(item.icon),
                label: Text(item.label),
              );
            }).toList(),
          ),
          const VerticalDivider(width: 1),
          Expanded(child: _buildContent()),
        ],
      ),
    );
  }
}

class _MenuItem {
  final IconData icon;
  final String label;
  const _MenuItem({required this.icon, required this.label});
}
