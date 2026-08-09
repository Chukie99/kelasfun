import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:kelasfun/core/database/app_database.dart';

import 'package:kelasfun/core/theme/app_theme.dart';
import 'package:kelasfun/features/grades/widgets/ranking_card.dart';

class RankingScreen extends StatelessWidget {
  const RankingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final db = context.read<AppDatabase>();
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(title: Text('Papan Peringkat', style: AppTheme.h2(context))),
      body: FutureBuilder<List<Grade>>(
        future: db.gradeDao.getRanking('Ganjil 2025/2026'),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(
              child: CircularProgressIndicator(
                color: isDark ? AppTheme.accent : AppTheme.lightAccent,
              ),
            );
          }
          final ranking = snapshot.data ?? [];
          if (ranking.isEmpty) {
            return Center(child: Text('Belum ada data nilai', style: AppTheme.bodySmall(context)));
          }
          return ListView.builder(
            padding: const EdgeInsets.symmetric(vertical: AppTheme.spacingSm),
            itemCount: ranking.length,
            itemBuilder: (context, index) {
              final entry = ranking[index];
              return FutureBuilder<Student?>(
                future: db.studentDao.getStudentById(entry.studentId),
                builder: (context, studentSnap) {
                  final student = studentSnap.data;
                  if (student == null) return const SizedBox();
                  return RankingCard(
                    rank: index + 1,
                    student: student,
                    averageScore: entry.score,
                  );
                },
              );
            },
          );
        },
      ),
    );
  }
}
