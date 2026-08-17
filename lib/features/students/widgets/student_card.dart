import 'dart:io';
import 'package:flutter/material.dart';
import 'package:kelasfun/core/database/app_database.dart';
import 'package:kelasfun/core/theme/app_theme.dart';
import 'package:kelasfun/core/utils/photo_helper.dart';
import 'package:kelasfun/shared/widgets/app_card.dart';

class StudentCard extends StatelessWidget {
  final Student student;
  final VoidCallback? onTap;
  final VoidCallback? onDelete;

  const StudentCard({super.key, required this.student, this.onTap, this.onDelete});

  Widget _buildPhoto(Student student, String initials, bool isDark) {
    if (student.photoPath != null && student.photoPath!.isNotEmpty) {
      try {
        final file = File(student.photoPath!);
        if (file.existsSync()) {
          return CircleAvatar(
            backgroundImage: FileImage(file),
          );
        }
      } catch (_) {}
    }
    return CircleAvatar(
      backgroundColor: (isDark ? AppTheme.accent : AppTheme.lightAccent).withOpacity(0.2),
      child: Text(
        initials,
        style: TextStyle(
          color: isDark ? AppTheme.accent : AppTheme.lightAccent,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final initials = PhotoHelper.getInitials(student.fullName);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return AppCard(
      onTap: onTap,
      child: Row(
        children: [
          _buildPhoto(student, initials, isDark),
          const SizedBox(width: AppTheme.spacingMd),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(student.fullName,
                    style: AppTheme.body(context).copyWith(
                        fontWeight: FontWeight.w600)),
                const SizedBox(height: AppTheme.spacingXs),
                Text('NIS: ${student.nis} • Kelas: ${student.className}',
                    style: AppTheme.caption(context)),
              ],
            ),
          ),
          if (onDelete != null)
            IconButton(
                icon: Icon(Icons.delete,
                    color: isDark ? AppTheme.coral : AppTheme.lightCoral),
                onPressed: onDelete),
        ],
      ),
    );
  }
}
