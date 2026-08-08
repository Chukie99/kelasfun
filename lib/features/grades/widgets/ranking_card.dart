import 'package:flutter/material.dart';
import 'package:kelasfun/core/database/app_database.dart';
import 'package:kelasfun/shared/widgets/app_card.dart';

class RankingCard extends StatelessWidget {
  final int rank;
  final Student student;
  final double averageScore;

  const RankingCard({
    super.key,
    required this.rank,
    required this.student,
    required this.averageScore,
  });

  Color get rankColor {
    if (rank == 1) return const Color(0xFFFFD700);
    if (rank == 2) return const Color(0xFFC0C0C0);
    if (rank == 3) return const Color(0xFFCD7F32);
    return const Color(0xFF5B9BD5);
  }

  @override
  Widget build(BuildContext context) {
    return AppCard(
      child: Row(
        children: [
          CircleAvatar(
            backgroundColor: rankColor,
            radius: 20,
            child: Text('$rank', style: const TextStyle(
              color: Colors.white, fontWeight: FontWeight.bold, fontSize: 18)),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(student.fullName, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                Text(student.className, style: const TextStyle(color: Colors.grey)),
              ],
            ),
          ),
          Text(averageScore.toStringAsFixed(1),
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
        ],
      ),
    );
  }
}
