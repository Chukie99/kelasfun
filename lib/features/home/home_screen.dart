import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:kelasfun/core/theme/app_theme.dart';
import 'package:kelasfun/features/home/dashboard_screen.dart';
import 'package:kelasfun/features/students/student_list_screen.dart';
import 'package:kelasfun/features/subjects/subject_screen.dart';
import 'package:kelasfun/features/grades/ranking_screen.dart';
import 'package:kelasfun/features/discipline/point_screen.dart';
import 'package:kelasfun/features/reports/report_screen.dart';
import 'package:kelasfun/features/settings/settings_screen.dart';
import 'package:kelasfun/features/attendance/attendance_screen.dart';
import 'package:kelasfun/features/schedule/schedule_screen.dart';
import 'package:kelasfun/shared/widgets/kelasfun_bottom_bar.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});
  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _MenuItem {
  final IconData icon;
  final String label;
  const _MenuItem({required this.icon, required this.label});
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;

  // Full 9 menu for wide (NavigationRail) — 6 for mobile bottom bar
  static const List<_MenuItem> _menuItems = [
    _MenuItem(icon: Icons.dashboard_outlined, label: 'Beranda'),
    _MenuItem(icon: Icons.qr_code_scanner_outlined, label: 'Presensi'),
    _MenuItem(icon: Icons.people_outline, label: 'Siswa'),
    _MenuItem(icon: Icons.subject_outlined, label: 'Mapel'),
    _MenuItem(icon: Icons.emoji_events_outlined, label: 'Peringkat'),
    _MenuItem(icon: Icons.star_outline, label: 'Poin'),
    _MenuItem(icon: Icons.description_outlined, label: 'Laporan'),
    _MenuItem(icon: Icons.calendar_today_outlined, label: 'Jadwal'),
    _MenuItem(icon: Icons.settings_outlined, label: 'Setting'),
  ];

  // bottom bar 6 -> map to _menuItems index
  static const List<int> _bottomMap = [0, 1, 2, 4, 7, 8];

  Widget _buildContent() {
    switch (_selectedIndex) {
      case 0: return DashboardScreen(onNavigate: () => setState(() => _selectedIndex = 1));
      case 1: return const AttendanceScreen();
      case 2: return const StudentListScreen();
      case 3: return const SubjectScreen();
      case 4: return const RankingScreen();
      case 5: return const PointScreen();
      case 6: return const ReportScreen();
      case 7: return const ScheduleScreen();
      case 8: return const SettingsScreen();
      default: return DashboardScreen(onNavigate: () => setState(() => _selectedIndex = 1));
    }
  }

  int _bottomIndexForSelected() {
    final i = _bottomMap.indexOf(_selectedIndex);
    return i == -1 ? 0 : i;
  }

  void _onBottomTap(int bIndex) {
    setState(() => _selectedIndex = _bottomMap[bIndex]);
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final isWide = MediaQuery.of(context).size.width >= 900;
    final content = _buildContent();

    if (isWide) {
      return Scaffold(
        body: Row(
          children: [
            NavigationRail(
              selectedIndex: _selectedIndex,
              onDestinationSelected: (i) => setState(() => _selectedIndex = i),
              labelType: NavigationRailLabelType.all,
              backgroundColor: isDark ? AppTheme.surface : AppTheme.lightSurface,
              indicatorColor: AppTheme.primarySoft,
              selectedIconTheme: const IconData(0).hashCode == 0 ? null : null,
              destinations: _menuItems.map((m) => NavigationRailDestination(
                icon: Icon(m.icon, color: isDark ? AppTheme.textSecondary : AppTheme.lightTextSecondary),
                selectedIcon: Icon(m.icon, color: AppTheme.primary),
                label: Text(m.label, style: GoogleFonts.inter(fontSize: 11, fontWeight: FontWeight.w600)),
              )).toList(),
            ),
            const VerticalDivider(width: 1),
            Expanded(child: content),
          ],
        ),
      );
    }

    // Mobile: siluet floating bottom bar maroon (kayak Kasir Kita)
    return Scaffold(
      body: content,
      bottomNavigationBar: KelasFunBottomBar(
        currentIndex: _bottomIndexForSelected(),
        onTap: _onBottomTap,
      ),
    );
  }
}
