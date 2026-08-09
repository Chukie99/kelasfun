import 'package:flutter/material.dart';
import 'package:kelasfun/core/database/app_database.dart';
import 'package:kelasfun/core/theme/app_theme.dart';

class ScheduleGrid extends StatelessWidget {
  final String className;
  final List<Schedule> schedules;
  final List<Subject> subjects;

  const ScheduleGrid({
    super.key,
    required this.className,
    required this.schedules,
    required this.subjects,
  });

  static const days = ['Senin', 'Selasa', 'Rabu', 'Kamis', 'Jumat'];
  static const periods = [1, 2, 3, 4, 5, 6, 7, 8];

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 6,
        childAspectRatio: 1.2,
      ),
      itemCount: periods.length * (days.length + 1),
      itemBuilder: (context, index) {
        final col = index % 6;
        final row = index ~/ 6;

        if (col == 0 && row == 0) return const SizedBox();
        if (col == 0) {
          return Center(
            child: Text(
              'Jam ${periods[row - 1]}',
              style: AppTheme.caption(context),
            ),
          );
        }
        if (row == 0) {
          return Center(
            child: Text(
              days[col - 1],
              style: AppTheme.caption(context).copyWith(fontWeight: FontWeight.bold),
            ),
          );
        }

        final day = days[col - 1];
        final period = periods[row - 1];
        final schedule = schedules.where(
          (s) => s.day == day && s.period == period,
        ).firstOrNull;
        final subject = schedule != null
            ? subjects.where((s) => s.id == schedule.subjectId).firstOrNull
            : null;

        return Card(
          child: Center(
            child: Text(
              subject?.name ?? '-',
              style: AppTheme.small(context),
              textAlign: TextAlign.center,
            ),
          ),
        );
      },
    );
  }
}
