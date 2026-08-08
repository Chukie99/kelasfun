import 'package:flutter/material.dart';
import 'package:kelasfun/core/database/app_database.dart';
import 'package:kelasfun/shared/widgets/app_card.dart';

class AttendanceCard extends StatelessWidget {
  final AttendanceData attendance;
  final Student student;

  const AttendanceCard({super.key, required this.attendance, required this.student});

  Color get statusColor {
    switch (attendance.status) {
      case 'Hadir': return const Color(0xFF70C1B3);
      case 'Izin': return const Color(0xFFFFB347);
      case 'Sakit': return const Color(0xFFFFB347);
      case 'Alfa': return const Color(0xFFFF6B6B);
      default: return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    return AppCard(
      child: Row(
        children: [
          CircleAvatar(
            backgroundColor: statusColor,
            child: Icon(
              attendance.status == 'Hadir' ? Icons.check : Icons.close,
              color: Colors.white,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(student.fullName, style: const TextStyle(fontWeight: FontWeight.bold)),
                Text('${student.className} • ${attendance.scanMethod}',
                    style: const TextStyle(color: Colors.grey, fontSize: 12)),
              ],
            ),
          ),
          Text(attendance.status,
              style: TextStyle(color: statusColor, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }
}
