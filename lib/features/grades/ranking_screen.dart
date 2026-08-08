import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:kelasfun/core/database/app_database.dart';
import 'package:kelasfun/core/database/daos/grade_dao.dart';
import 'package:kelasfun/features/grades/widgets/ranking_card.dart';

class RankingScreen extends StatelessWidget {
  const RankingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final db = context.read<AppDatabase>();

    return Scaffold(
      appBar: AppBar(title: const Text('Papan Peringkat')),
      body: FutureBuilder<List<Grade>>(
        future: db.gradeDao.getRanking('Ganjil 2025/2026'),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          final ranking = snapshot.data ?? [];
          if (ranking.isEmpty) {
            return const Center(child: Text('Belum ada data nilai'));
          }
          return ListView.builder(
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
