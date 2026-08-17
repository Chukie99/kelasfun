import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:kelasfun/core/database/app_database.dart';
import 'package:kelasfun/core/theme/app_theme.dart';
import 'package:kelasfun/shared/widgets/app_card.dart';
import 'package:kelasfun/features/students/student_list_screen.dart';
import 'package:kelasfun/features/reports/report_screen.dart';

Color _accentFor(BuildContext context) =>
    Theme.of(context).brightness == Brightness.dark
        ? AppTheme.accent
        : AppTheme.lightAccent;

Color _mintFor(BuildContext context) =>
    Theme.of(context).brightness == Brightness.dark
        ? AppTheme.mint
        : AppTheme.lightMint;

Color _amberFor(BuildContext context) =>
    Theme.of(context).brightness == Brightness.dark
        ? AppTheme.amber
        : AppTheme.lightAmber;

Color _coralFor(BuildContext context) =>
    Theme.of(context).brightness == Brightness.dark
        ? AppTheme.coral
        : AppTheme.lightCoral;

class DashboardScreen extends StatelessWidget {
  final VoidCallback? onNavigate;
  const DashboardScreen({super.key, this.onNavigate});

  @override
  Widget build(BuildContext context) {
    final db = context.read<AppDatabase>();
    final now = DateTime.now();
    final today =
        '${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}';
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
          _ChartsCard(db: db, today: today, semester: semester, year: year),
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

        final locationParts =
            [address, city, province].where((s) => s.isNotEmpty).toList();
        final location = locationParts.join(', ');

        final accent = _accentFor(context);

        return AppCard(
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: accent.withOpacity(0.15),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: accent.withOpacity(0.3)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(Icons.school, color: accent, size: 48),
                const SizedBox(height: 12),
                Text(
                  name.isNotEmpty ? name : 'Nama Sekolah',
                  style: AppTheme.h2(context),
                ),
                if (location.isNotEmpty) ...[
                  const SizedBox(height: 4),
                  Text(location, style: AppTheme.bodySmall(context)),
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
            final hadir = attendance.where((a) => a.status == 'Hadir').length;
            final alpha = attendance.where((a) => a.status == 'Alpa').length;

            return AppCard(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Statistik Hari Ini',
                        style: AppTheme.h3(context)),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        _StatItem(
                          count: totalStudents.toString(),
                          label: 'Total',
                          color: _accentFor(context),
                        ),
                        _StatItem(
                          count: hadir.toString(),
                          label: 'Hadir',
                          color: _mintFor(context),
                        ),
                        _StatItem(
                          count: alpha.toString(),
                          label: 'Alpha',
                          color: _coralFor(context),
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

  const _StatItem(
      {required this.count, required this.label, required this.color});

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
                      color: color,
                      fontSize: 24,
                      fontWeight: FontWeight.bold)),
            ),
          ),
          const SizedBox(height: 8),
          Text(label, style: AppTheme.bodySmall(context)),
        ],
      ),
    );
  }
}

class _QuickSummaryCard extends StatelessWidget {
  final AppDatabase db;
  final String semester;
  final String year;
  const _QuickSummaryCard(
      {required this.db, required this.semester, required this.year});

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
            final totalPoints =
                allPoints.values.fold<int>(0, (sum, p) => sum + p);

            return FutureBuilder<List<Grade>>(
              future: db.gradeDao.getRanking(semesterKey),
              builder: (context, gradeSnapshot) {
                final ranking = gradeSnapshot.data ?? [];
                final avgScore = ranking.isNotEmpty
                    ? (ranking.fold<double>(
                                0, (sum, g) => sum + g.score) /
                            ranking.length)
                        .toStringAsFixed(0)
                    : '0';

                return AppCard(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Ringkasan Cepat',
                            style: AppTheme.h3(context)),
                        const SizedBox(height: 16),
                        Row(
                          children: [
                            _SummaryItem(
                              icon: Icons.subject,
                              value: totalSubjects.toString(),
                              label: 'Mapel',
                              color: _accentFor(context),
                            ),
                            _SummaryItem(
                              icon: Icons.star,
                              value: totalPoints.toString(),
                              label: 'Poin',
                              color: _amberFor(context),
                            ),
                            _SummaryItem(
                              icon: Icons.analytics,
                              value: avgScore,
                              label: 'Rata-rata',
                              color: _mintFor(context),
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
                  color: color,
                  fontSize: 20,
                  fontWeight: FontWeight.bold)),
          Text(label, style: AppTheme.caption(context)),
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
            Text('Aksi Cepat', style: AppTheme.h3(context)),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: _ActionButton(
                    icon: Icons.qr_code_scanner,
                    label: 'Presensi',
                    color: _mintFor(context),
                    onTap: onNavigate ?? () {},
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _ActionButton(
                    icon: Icons.person_add,
                    label: 'Tambah Siswa',
                    color: _accentFor(context),
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
                    color: _amberFor(context),
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
                    color: color,
                    fontWeight: FontWeight.bold,
                    fontSize: 12),
                textAlign: TextAlign.center),
          ],
        ),
      ),
    );
  }
}

class _AttendancePieChart extends StatelessWidget {
  final int hadir, izin, sakit, alpa;
  const _AttendancePieChart(
      {required this.hadir,
      required this.izin,
      required this.sakit,
      required this.alpa});

  @override
  Widget build(BuildContext context) {
    final total = hadir + izin + sakit + alpa;
    if (total == 0) {
      return Center(
          child: Text('Belum ada data',
              style: AppTheme.bodySmall(context)));
    }

    return SizedBox(
      height: 150,
      child: PieChart(
        PieChartData(
          sectionsSpace: 2,
          centerSpaceRadius: 30,
          sections: [
            PieChartSectionData(
                value: hadir.toDouble(),
                color: _accentFor(context),
                title: '$hadir',
                radius: 40),
            PieChartSectionData(
                value: izin.toDouble(),
                color: _amberFor(context),
                title: '$izin',
                radius: 40),
            PieChartSectionData(
                value: sakit.toDouble(),
                color: _mintFor(context),
                title: '$sakit',
                radius: 40),
            PieChartSectionData(
                value: alpa.toDouble(),
                color: _coralFor(context),
                title: '$alpa',
                radius: 40),
          ],
        ),
      ),
    );
  }
}

class _GradeBarChart extends StatelessWidget {
  final Map<String, double> subjectAverages;
  const _GradeBarChart({required this.subjectAverages});

  @override
  Widget build(BuildContext context) {
    if (subjectAverages.isEmpty) {
      return Center(
          child: Text('Belum ada data',
              style: AppTheme.bodySmall(context)));
    }

    final entries = subjectAverages.entries.toList();
    return SizedBox(
      height: 150,
      child: BarChart(
        BarChartData(
          alignment: BarChartAlignment.spaceAround,
          maxY: 100,
          barGroups: List.generate(entries.length, (i) {
            return BarChartGroupData(x: i, barRods: [
              BarChartRodData(
                toY: entries[i].value,
                color: _accentFor(context),
                width: 20,
                borderRadius:
                    const BorderRadius.vertical(top: Radius.circular(4)),
              ),
            ]);
          }),
          titlesData: FlTitlesData(
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                getTitlesWidget: (i, meta) {
                  final name = entries[i.toInt()].key;
                  return Text(
                      name.length > 6 ? name.substring(0, 6) : name,
                      style: AppTheme.small(context));
                },
              ),
            ),
            leftTitles: const AxisTitles(
                sideTitles: SideTitles(
                    showTitles: true, reservedSize: 30)),
            topTitles: const AxisTitles(
                sideTitles: SideTitles(showTitles: false)),
            rightTitles: const AxisTitles(
                sideTitles: SideTitles(showTitles: false)),
          ),
          borderData: FlBorderData(show: false),
          gridData: const FlGridData(show: false),
        ),
      ),
    );
  }
}

class _ChartsCard extends StatelessWidget {
  final AppDatabase db;
  final String today;
  final String semester;
  final String year;
  const _ChartsCard(
      {required this.db,
      required this.today,
      required this.semester,
      required this.year});

  @override
  Widget build(BuildContext context) {
    final semesterKey = '$semester $year';

    return StreamBuilder<List<AttendanceData>>(
      stream: db.attendanceDao.watchAttendanceByDate(today),
      builder: (context, attendanceSnapshot) {
        final attendance = attendanceSnapshot.data ?? [];
        final hadir =
            attendance.where((a) => a.status == 'Hadir').length;
        final sakit =
            attendance.where((a) => a.status == 'Sakit').length;
        final izin =
            attendance.where((a) => a.status == 'Izin').length;
        final alpa =
            attendance.where((a) => a.status == 'Alpa').length;

        return FutureBuilder<List<Subject>>(
          future: db.subjectDao.getAllSubjects(),
          builder: (context, subjectSnapshot) {
            final subjects = subjectSnapshot.data ?? [];

            return FutureBuilder<List<Grade>>(
              future: db.gradeDao.getRanking(semesterKey),
              builder: (context, gradeSnapshot) {
                final grades = gradeSnapshot.data ?? [];
                final subjectAverages = <String, double>{};

                for (final subject in subjects) {
                  final subjectGrades = grades
                      .where((g) => g.subjectId == subject.id)
                      .toList();
                  if (subjectGrades.isNotEmpty) {
                    final avg = subjectGrades.fold<double>(
                            0, (sum, g) => sum + g.score) /
                        subjectGrades.length;
                    subjectAverages[subject.name] = avg;
                  }
                }

                return AppCard(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Grafik',
                            style: AppTheme.h3(context)),
                        const SizedBox(height: 16),
                        Text('Kehadiran Hari Ini',
                            style: AppTheme.bodySmall(context)
                                .copyWith(fontWeight: FontWeight.bold)),
                        const SizedBox(height: 8),
                        _AttendancePieChart(
                            hadir: hadir,
                            izin: izin,
                            sakit: sakit,
                            alpa: alpa),
                        const SizedBox(height: 16),
                        Text('Rata-rata Nilai per Mapel',
                            style: AppTheme.bodySmall(context)
                                .copyWith(fontWeight: FontWeight.bold)),
                        const SizedBox(height: 8),
                        _GradeBarChart(subjectAverages: subjectAverages),
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
