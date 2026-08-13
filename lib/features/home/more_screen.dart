import 'package:flutter/material.dart';
import 'package:kelasfun/core/theme/app_theme.dart';
import 'package:kelasfun/features/subjects/subject_screen.dart';
import 'package:kelasfun/features/grades/ranking_screen.dart';
import 'package:kelasfun/features/discipline/point_screen.dart';
import 'package:kelasfun/features/reports/report_screen.dart';
import 'package:kelasfun/features/schedule/schedule_screen.dart';
import 'package:kelasfun/features/settings/settings_screen.dart';

class MoreScreen extends StatelessWidget {
  const MoreScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(title: const Text('Lainnya')),
      body: ListView(
        padding: const EdgeInsets.symmetric(vertical: 8),
        children: [
          _MoreItem(
            icon: Icons.subject,
            label: 'Mapel',
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const SubjectScreen()),
            ),
          ),
          _MoreItem(
            icon: Icons.emoji_events,
            label: 'Peringkat',
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const RankingScreen()),
            ),
          ),
          _MoreItem(
            icon: Icons.star,
            label: 'Poin',
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const PointScreen()),
            ),
          ),
          _MoreItem(
            icon: Icons.description,
            label: 'Laporan',
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const ReportScreen()),
            ),
          ),
          _MoreItem(
            icon: Icons.calendar_today,
            label: 'Jadwal',
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const ScheduleScreen()),
            ),
          ),
          _MoreItem(
            icon: Icons.settings,
            label: 'Settings',
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const SettingsScreen()),
            ),
          ),
        ],
      ),
    );
  }
}

class _MoreItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const _MoreItem({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return ListTile(
      leading: Icon(
        icon,
        color: isDark ? AppTheme.accent : AppTheme.lightAccent,
      ),
      title: Text(label),
      trailing: Icon(
        Icons.chevron_right,
        color: isDark ? AppTheme.textSecondary : AppTheme.lightTextSecondary,
      ),
      onTap: onTap,
    );
  }
}
