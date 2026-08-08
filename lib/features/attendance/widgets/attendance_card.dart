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

  Color get statusColor {
    if (attendance == null) return AppTheme.textSecondary;
    switch (attendance!.status) {
      case 'Hadir': return AppTheme.mint;
      case 'Izin': return AppTheme.amber;
      case 'Sakit': return AppTheme.cyan;
      case 'Alpa': return AppTheme.coral;
      default: return AppTheme.textSecondary;
    }
  }

  IconData get statusIcon {
    if (attendance == null) return Icons.help_outline;
    switch (attendance!.status) {
      case 'Hadir': return Icons.check_circle;
      case 'Izin': return Icons.info;
      case 'Sakit': return Icons.local_hospital;
      case 'Alpa': return Icons.cancel;
      default: return Icons.help_outline;
    }
  }

  @override
  Widget build(BuildContext context) {
    final hasAttended = attendance != null;

    return AppCard(
      child: Column(
        children: [
          Row(
            children: [
              CircleAvatar(
                backgroundColor: statusColor.withOpacity(0.2),
                child: Icon(statusIcon, color: statusColor, size: 20),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(student.fullName,
                        style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                            color: AppTheme.textPrimary)),
                    Text(student.className,
                        style: const TextStyle(
                            color: AppTheme.textSecondary, fontSize: 12)),
                  ],
                ),
              ),
              if (hasAttended)
                Text(attendance!.status,
                    style: TextStyle(
                        color: statusColor, fontWeight: FontWeight.bold)),
            ],
          ),
          if (attendance?.description?.isNotEmpty == true) ...[
            const SizedBox(height: 8),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: statusColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                attendance!.description!,
                style: TextStyle(color: statusColor, fontSize: 12),
              ),
            ),
          ],
          if (!hasAttended) ...[
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: _ActionButton(
                    label: 'Izin',
                    color: AppTheme.amber,
                    onPressed: onIzin,
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: _ActionButton(
                    label: 'Sakit',
                    color: AppTheme.cyan,
                    onPressed: onSakit,
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: _ActionButton(
                    label: 'Alpa',
                    color: AppTheme.coral,
                    onPressed: onAlpa,
                  ),
                ),
              ],
            ),
          ],
          if (hasAttended && attendance!.status != 'Hadir') ...[
            const SizedBox(height: 8),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: onReset,
                icon: const Icon(Icons.refresh, size: 16),
                label: const Text('Reset Status'),
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppTheme.textSecondary,
                  side: const BorderSide(color: AppTheme.divider),
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
    return ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: color,
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(vertical: 8),
      ),
      child: Text(label, style: const TextStyle(fontSize: 12)),
    );
  }
}
