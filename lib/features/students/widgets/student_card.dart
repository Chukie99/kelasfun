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

  @override
  Widget build(BuildContext context) {
    final initials = PhotoHelper.getInitials(student.fullName);

    return AppCard(
      onTap: onTap,
      child: Row(
        children: [
          student.photoPath != null && File(student.photoPath!).existsSync()
              ? CircleAvatar(
                  backgroundImage: FileImage(File(student.photoPath!)),
                )
              : CircleAvatar(
                  backgroundColor: AppTheme.cyan.withOpacity(0.2),
                  child: Text(
                    initials,
                    style: const TextStyle(
                        color: AppTheme.cyan, fontWeight: FontWeight.bold),
                  ),
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
                Text('NIS: ${student.nis} • Kelas: ${student.className}',
                    style: const TextStyle(color: AppTheme.textSecondary)),
              ],
            ),
          ),
          if (onDelete != null)
            IconButton(
                icon: const Icon(Icons.delete, color: AppTheme.coral),
                onPressed: onDelete),
        ],
      ),
    );
  }
}
