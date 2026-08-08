import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:kelasfun/core/database/app_database.dart';
import 'package:kelasfun/core/theme/app_theme.dart';
import 'package:kelasfun/shared/widgets/app_card.dart';
import 'package:kelasfun/features/attendance/attendance_screen.dart';
import 'package:kelasfun/features/students/student_list_screen.dart';
import 'package:kelasfun/features/reports/report_screen.dart';

class DashboardScreen extends StatelessWidget {
  final VoidCallback? onNavigate;
  const DashboardScreen({super.key, this.onNavigate});

  @override
  Widget build(BuildContext context) {
    final db = context.read<AppDatabase>();
    final now = DateTime.now();
    final today = '${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}';
    final semester = now.month <= 6 ? 'Ganjil' : 'Genap';
    final year = now.year.toString();

    return Scaffold(
      appBar: AppBar(title: const Text('Dashboard')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _SchoolProfileCard(db: db),
          const SizedBox(height: 16),
          _StatsTodayCard(db: db, today: today),
          const SizedBox(height: 16),
          _QuickSummaryCard(db: db, semester: semester, year: year),
          const SizedBox(height: 16),
          _QuickActionsCard(onNavigate: onNavigate),
        ],
      ),
    );
  }
}

class _SchoolProfileCard extends StatelessWidget {
  final AppDatabase db;
  const _SchoolProfileCard({required this.db});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<Map<String, String>>(
      stream: db.settingsDao.watchAllSettings(),
      builder: (context, snapshot) {
        final settings = snapshot.data ?? {};
        final name = settings['school_name'] ?? '';
        final address = settings['school_address'] ?? '';
        final city = settings['school_city'] ?? '';
        final province = settings['school_province'] ?? '';

        final locationParts = [address, city, province].where((s) => s.isNotEmpty).toList();
        final location = locationParts.join(', ');

        return AppCard(
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [AppTheme.primaryBlue, Color(0xFF70C1B3)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Icon(Icons.school, color: Colors.white, size: 48),
                const SizedBox(height: 12),
                Text(
                  name.isNotEmpty ? name : 'Nama Sekolah',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                if (location.isNotEmpty) ...[
                  const SizedBox(height: 4),
                  Text(
                    location,
                    style: const TextStyle(color: Colors.white70, fontSize: 14),
                  ),
                ],
              ],
            ),
          ),
        );
      },
    );
  }
}

class _StatsTodayCard extends StatelessWidget {
  final AppDatabase db;
  final String today;
  const _StatsTodayCard({required this.db, required this.today});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<List<Student>>(
      stream: db.studentDao.watchAllStudents(),
      builder: (context, studentSnapshot) {
        final totalStudents = (studentSnapshot.data ?? []).length;

        return StreamBuilder<List<AttendanceData>>(
          stream: db.attendanceDao.watchAttendanceByDate(today),
          builder: (context, attendanceSnapshot) {
            final attendance = attendanceSnapshot.data ?? [];
            final hadir = attendance.where((a) => a.status == 'hadir').length;
            final alpha = totalStudents - hadir;

            return AppCard(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Statistik Hari Ini',
                        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        _StatItem(
                          count: totalStudents.toString(),
                          label: 'Total',
                          color: AppTheme.primaryBlue,
                        ),
                        _StatItem(
                          count: hadir.toString(),
                          label: 'Hadir',
                          color: AppTheme.softGreen,
                        ),
                        _StatItem(
                          count: alpha.toString(),
                          label: 'Alpha',
                          color: AppTheme.softPink,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }
}

class _StatItem extends StatelessWidget {
  final String count;
  final String label;
  final Color color;

  const _StatItem({required this.count, required this.label, required this.color});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Column(
        children: [
          Container(
            width: 64,
            height: 64,
            decoration: BoxDecoration(
              color: color.withOpacity(0.15),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Center(
              child: Text(count,
                  style: TextStyle(
                      color: color, fontSize: 24, fontWeight: FontWeight.bold)),
            ),
          ),
          const SizedBox(height: 8),
          Text(label, style: const TextStyle(color: Colors.grey)),
        ],
      ),
    );
  }
}

class _QuickSummaryCard extends StatelessWidget {
  final AppDatabase db;
  final String semester;
  final String year;
  const _QuickSummaryCard({required this.db, required this.semester, required this.year});

  @override
  Widget build(BuildContext context) {
    final semesterKey = '$semester $year';

    return FutureBuilder<List<Subject>>(
      future: db.subjectDao.getAllSubjects(),
      builder: (context, subjectSnapshot) {
        final totalSubjects = (subjectSnapshot.data ?? []).length;

        return FutureBuilder<Map<int, int>>(
          future: db.pointDao.getAllTotalPoints(),
          builder: (context, pointSnapshot) {
            final allPoints = pointSnapshot.data ?? {};
            final totalPoints = allPoints.values.fold<int>(0, (sum, p) => sum + p);

            return FutureBuilder<List<Grade>>(
              future: db.gradeDao.getRanking(semesterKey),
              builder: (context, gradeSnapshot) {
                final ranking = gradeSnapshot.data ?? [];
                final avgScore = ranking.isNotEmpty
                    ? (ranking.fold<double>(0, (sum, g) => sum + g.score) / ranking.length).toStringAsFixed(0)
                    : '0';

                return AppCard(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('Ringkasan Cepat',
                            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
                        const SizedBox(height: 16),
                        Row(
                          children: [
                            _SummaryItem(
                              icon: Icons.subject,
                              value: totalSubjects.toString(),
                              label: 'Mapel',
                              color: AppTheme.primaryBlue,
                            ),
                            _SummaryItem(
                              icon: Icons.star,
                              value: totalPoints.toString(),
                              label: 'Poin',
                              color: AppTheme.warmOrange,
                            ),
                            _SummaryItem(
                              icon: Icons.analytics,
                              value: avgScore,
                              label: 'Rata-rata',
                              color: AppTheme.softGreen,
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                );
              },
            );
          },
        );
      },
    );
  }
}

class _SummaryItem extends StatelessWidget {
  final IconData icon;
  final String value;
  final String label;
  final Color color;

  const _SummaryItem({
    required this.icon,
    required this.value,
    required this.label,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Column(
        children: [
          Icon(icon, color: color, size: 28),
          const SizedBox(height: 4),
          Text(value,
              style: TextStyle(
                  color: color, fontSize: 20, fontWeight: FontWeight.bold)),
          Text(label, style: const TextStyle(color: Colors.grey, fontSize: 12)),
        ],
      ),
    );
  }
}

class _QuickActionsCard extends StatelessWidget {
  final VoidCallback? onNavigate;
  const _QuickActionsCard({this.onNavigate});

  @override
  Widget build(BuildContext context) {
    return AppCard(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Aksi Cepat',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: _ActionButton(
                    icon: Icons.qr_code_scanner,
                    label: 'Presensi',
                    color: AppTheme.softGreen,
                    onTap: () {
                      final homeState = context.findAncestorStateOfType<State>();
                      if (homeState != null && homeState.mounted) {
                        (homeState as dynamic).setState(() {});
                      }
                    },
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _ActionButton(
                    icon: Icons.person_add,
                    label: 'Tambah Siswa',
                    color: AppTheme.primaryBlue,
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (_) => const StudentListScreen()),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _ActionButton(
                    icon: Icons.description,
                    label: 'Laporan',
                    color: AppTheme.warmOrange,
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (_) => const ReportScreen()),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _ActionButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;

  const _ActionButton({
    required this.icon,
    required this.label,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: color.withOpacity(0.3)),
        ),
        child: Column(
          children: [
            Icon(icon, color: color, size: 28),
            const SizedBox(height: 8),
            Text(label,
                style: TextStyle(
                    color: color, fontWeight: FontWeight.bold, fontSize: 12),
                textAlign: TextAlign.center),
          ],
        ),
      ),
    );
  }
}
