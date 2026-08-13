import 'package:flutter/material.dart';
import 'package:kelasfun/core/theme/app_theme.dart';
import 'package:kelasfun/features/home/dashboard_screen.dart';
import 'package:kelasfun/features/attendance/attendance_screen.dart';
import 'package:kelasfun/features/students/student_list_screen.dart';
import 'package:kelasfun/features/home/more_screen.dart';

class MobileHome extends StatefulWidget {
  const MobileHome({super.key});

  @override
  State<MobileHome> createState() => _MobileHomeState();
}

class _MobileHomeState extends State<MobileHome> {
  int _selectedIndex = 0;

  static const List<_NavItem> _navItems = [
    _NavItem(icon: Icons.dashboard, label: 'Beranda'),
    _NavItem(icon: Icons.qr_code_scanner, label: 'Presensi'),
    _NavItem(icon: Icons.people, label: 'Siswa'),
    _NavItem(icon: Icons.more_horiz, label: 'Lainnya'),
  ];

  Widget _buildContent() {
    switch (_selectedIndex) {
      case 0:
        return DashboardScreen(
          onNavigate: () => setState(() => _selectedIndex = 1),
        );
      case 1:
        return const AttendanceScreen();
      case 2:
        return const StudentListScreen();
      case 3:
        return const MoreScreen();
      default:
        return DashboardScreen(
          onNavigate: () => setState(() => _selectedIndex = 1),
        );
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      body: _buildContent(),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _selectedIndex,
        onDestinationSelected: (index) {
          setState(() => _selectedIndex = index);
        },
        backgroundColor: isDark ? AppTheme.surface : AppTheme.lightSurface,
        indicatorColor: isDark ? AppTheme.accentSoft : AppTheme.lightAccentSoft,
        destinations: _navItems.map((item) {
          return NavigationDestination(
            icon: Icon(
              item.icon,
              color: isDark ? AppTheme.textSecondary : AppTheme.lightTextSecondary,
            ),
            selectedIcon: Icon(
              item.icon,
              color: isDark ? AppTheme.accent : AppTheme.lightAccent,
            ),
            label: item.label,
          );
        }).toList(),
      ),
    );
  }
}

class _NavItem {
  final IconData icon;
  final String label;
  const _NavItem({required this.icon, required this.label});
}
