import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:kelasfun/core/database/app_database.dart';

import 'package:kelasfun/core/theme/app_theme.dart';
import 'package:kelasfun/core/utils/semester_utils.dart';
import 'package:kelasfun/features/grades/widgets/ranking_card.dart';

class RankingScreen extends StatefulWidget {
  const RankingScreen({super.key});

  @override
  State<RankingScreen> createState() => _RankingScreenState();
}

class _RankingScreenState extends State<RankingScreen> {
  late final Future<List<RankingEntry>> _dataFuture;

  @override
  void initState() {
    super.initState();
    _dataFuture = _loadData();
  }

  Future<List<RankingEntry>> _loadData() async {
    final db = context.read<AppDatabase>();
    // Kunci semester WAJIB lewat util terpusat — dulu di sini bulannya
    // terbalik (Jan-Jun dianggap Ganjil) sehingga ranking sering kosong.
    final semester = SemesterUtils.currentSemester();

    final ranking = await db.gradeDao.getRanking(semester);
    final allStudents = await db.studentDao.getAllStudents();
    final studentMap = {for (final s in allStudents) s.id: s};

    return ranking
        .where((g) => studentMap.containsKey(g.studentId))
        .map((g) => RankingEntry(grade: g, student: studentMap[g.studentId]!))
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(title: Text('Papan Peringkat', style: AppTheme.h2(context))),
      body: FutureBuilder<List<RankingEntry>>(
        future: _dataFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(
              child: CircularProgressIndicator(
                color: isDark ? AppTheme.accent : AppTheme.lightAccent,
              ),
            );
          }
          final entries = snapshot.data ?? [];
          if (entries.isEmpty) {
            return Center(child: Text('Belum ada data nilai', style: AppTheme.bodySmall(context)));
          }
          return ListView.builder(
            padding: const EdgeInsets.symmetric(vertical: AppTheme.spacingSm),
            itemCount: entries.length,
            itemBuilder: (context, index) {
              final entry = entries[index];
              return RankingCard(
                rank: index + 1,
                student: entry.student,
                averageScore: entry.grade.score,
              );
            },
          );
        },
      ),
    );
  }
}

class RankingEntry {
  final Grade grade;
  final Student student;
  RankingEntry({required this.grade, required this.student});
}
