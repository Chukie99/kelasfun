import 'package:flutter/material.dart';
import 'package:kelasfun/core/database/app_database.dart';
import 'package:kelasfun/shared/widgets/app_card.dart';

class StudentCard extends StatelessWidget {
  final Student student;
  final VoidCallback? onTap;
  final VoidCallback? onDelete;

  const StudentCard({super.key, required this.student, this.onTap, this.onDelete});

  @override
  Widget build(BuildContext context) {
    return AppCard(
      onTap: onTap,
      child: Row(
        children: [
          CircleAvatar(
            backgroundColor: const Color(0xFF5B9BD5),
            child: Text(
              student.fullName.substring(0, 1).toUpperCase(),
              style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(student.fullName,
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                Text('NIS: ${student.nis} • Kelas: ${student.className}',
                    style: const TextStyle(color: Colors.grey)),
              ],
            ),
          ),
          if (onDelete != null)
            IconButton(icon: const Icon(Icons.delete, color: Color(0xFFFF6B6B)), onPressed: onDelete),
        ],
      ),
    );
  }
}
