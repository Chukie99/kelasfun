import 'package:flutter/material.dart';
import 'package:kelasfun/core/database/app_database.dart';
import 'package:kelasfun/core/theme/app_theme.dart';
import 'package:kelasfun/shared/widgets/app_card.dart';

class AttendanceCard extends StatelessWidget {
  final AttendanceData? attendance;
  final Student student;
  final VoidCallback? onIzin;
  final VoidCallback? onSakit;
  final VoidCallback? onAlpa;
  final VoidCallback? onReset;

  const AttendanceCard({
    super.key,
    this.attendance,
    required this.student,
    this.onIzin,
    this.onSakit,
    this.onAlpa,
    this.onReset,
  });

  Color _statusColor(bool isDark) {
    if (attendance == null) {
      return isDark ? AppTheme.textSecondary : AppTheme.lightTextSecondary;
    }
    switch (attendance!.status) {
      case 'Hadir':
        return isDark ? AppTheme.mint : AppTheme.lightMint;
      case 'Izin':
        return isDark ? AppTheme.amber : AppTheme.lightAmber;
      case 'Sakit':
        return isDark ? AppTheme.accent : AppTheme.lightAccent;
      case 'Alpa':
        return isDark ? AppTheme.coral : AppTheme.lightCoral;
      default:
        return isDark ? AppTheme.textSecondary : AppTheme.lightTextSecondary;
    }
  }

  IconData get statusIcon {
    if (attendance == null) return Icons.help_outline;
    switch (attendance!.status) {
      case 'Hadir':
        return Icons.check_circle;
      case 'Izin':
        return Icons.info;
      case 'Sakit':
        return Icons.local_hospital;
      case 'Alpa':
        return Icons.cancel;
      default:
        return Icons.help_outline;
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final hasAttended = attendance != null;
    final statusCol = _statusColor(isDark);
    final textPrimaryColor = isDark ? AppTheme.textPrimary : AppTheme.lightTextPrimary;
    final textSecondaryColor = isDark ? AppTheme.textSecondary : AppTheme.lightTextSecondary;
    final accentColor = isDark ? AppTheme.accent : AppTheme.lightAccent;
    final dividerColor = isDark ? AppTheme.divider : AppTheme.lightDivider;

    return AppCard(
      child: Column(
        children: [
          Row(
            children: [
              CircleAvatar(
                backgroundColor: statusCol.withOpacity(0.15),
                child: Icon(statusIcon, color: statusCol, size: 20),
              ),
              const SizedBox(width: AppTheme.spacingMd),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      student.fullName,
                      style: AppTheme.body(context).copyWith(
                        fontWeight: FontWeight.w600,
                        color: textPrimaryColor,
                      ),
                    ),
                    const SizedBox(height: AppTheme.spacingXs),
                    Text(
                      student.className,
                      style: AppTheme.caption(context).copyWith(
                        color: textSecondaryColor,
                      ),
                    ),
                  ],
                ),
              ),
              if (hasAttended)
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppTheme.spacingSm,
                    vertical: AppTheme.spacingXs,
                  ),
                  decoration: BoxDecoration(
                    color: statusCol.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(AppTheme.radiusChip),
                  ),
                  child: Text(
                    attendance!.status,
                    style: AppTheme.small(context).copyWith(
                      color: statusCol,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
            ],
          ),
          if (attendance?.description?.isNotEmpty == true) ...[
            const SizedBox(height: AppTheme.spacingSm),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(AppTheme.spacingSm),
              decoration: BoxDecoration(
                color: statusCol.withOpacity(0.08),
                borderRadius: BorderRadius.circular(AppTheme.radiusButton),
              ),
              child: Text(
                attendance!.description!,
                style: AppTheme.caption(context).copyWith(
                  color: statusCol,
                ),
              ),
            ),
          ],
          if (!hasAttended) ...[
            const SizedBox(height: AppTheme.spacingMd),
            Row(
              children: [
                Expanded(
                  child: _ActionButton(
                    label: 'Izin',
                    color: isDark ? AppTheme.amber : AppTheme.lightAmber,
                    onPressed: onIzin,
                  ),
                ),
                const SizedBox(width: AppTheme.spacingSm),
                Expanded(
                  child: _ActionButton(
                    label: 'Sakit',
                    color: accentColor,
                    onPressed: onSakit,
                  ),
                ),
                const SizedBox(width: AppTheme.spacingSm),
                Expanded(
                  child: _ActionButton(
                    label: 'Alpa',
                    color: isDark ? AppTheme.coral : AppTheme.lightCoral,
                    onPressed: onAlpa,
                  ),
                ),
              ],
            ),
          ],
          if (hasAttended && attendance!.status != 'Hadir') ...[
            const SizedBox(height: AppTheme.spacingSm),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: onReset,
                icon: const Icon(Icons.refresh, size: 16),
                label: const Text('Reset Status'),
                style: OutlinedButton.styleFrom(
                  foregroundColor: textSecondaryColor,
                  side: BorderSide(color: dividerColor),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _ActionButton extends StatelessWidget {
  final String label;
  final Color color;
  final VoidCallback? onPressed;

  const _ActionButton({
    required this.label,
    required this.color,
    this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final onColor = isDark ? AppTheme.textPrimary : AppTheme.lightTextPrimary;

    return ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: color,
        foregroundColor: onColor,
        padding: const EdgeInsets.symmetric(vertical: AppTheme.spacingSm),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppTheme.radiusButton),
        ),
        elevation: 0,
      ),
      child: Text(
        label,
        style: AppTheme.small(context),
      ),
    );
  }
}
