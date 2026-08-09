import 'package:flutter/material.dart';
import 'package:kelasfun/core/database/app_database.dart';
import 'package:kelasfun/core/theme/app_theme.dart';
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

  Color _rankBadgeColor(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    if (rank == 1) return isDark ? AppTheme.amber : AppTheme.lightAmber;
    if (rank == 2) return isDark ? AppTheme.textSecondary : AppTheme.lightTextSecondary;
    if (rank == 3) return isDark ? AppTheme.mint : AppTheme.lightMint;
    return isDark ? AppTheme.accent : AppTheme.lightAccent;
  }

  Color _rankBadgeBg(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    if (rank == 1) return isDark ? AppTheme.amberSoft : AppTheme.lightAmberSoft;
    if (rank == 2) return isDark ? AppTheme.surfaceLight : AppTheme.lightSurfaceLight;
    if (rank == 3) return isDark ? AppTheme.mintSoft : AppTheme.lightMintSoft;
    return isDark ? AppTheme.accentSoft : AppTheme.lightAccentSoft;
  }

  @override
  Widget build(BuildContext context) {
    final badgeColor = _rankBadgeColor(context);
    final badgeBg = _rankBadgeBg(context);

    return AppCard(
      padding: const EdgeInsets.symmetric(
        horizontal: AppTheme.spacingBase,
        vertical: AppTheme.spacingMd,
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: badgeBg,
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Text(
                '$rank',
                style: AppTheme.body(context).copyWith(
                  color: badgeColor,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
          const SizedBox(width: AppTheme.spacingMd),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  student.fullName,
                  style: AppTheme.body(context).copyWith(fontWeight: FontWeight.w600),
                ),
                Text(student.className, style: AppTheme.caption(context)),
              ],
            ),
          ),
          Text(
            averageScore.toStringAsFixed(1),
            style: AppTheme.h3(context),
          ),
        ],
      ),
    );
  }
}
