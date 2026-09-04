import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
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

  void _showSubjectPicker(BuildContext context, String day, int period) {
    final db = context.read<AppDatabase>();
    final existingSchedule = schedules.where(
      (s) => s.day == day && s.period == period,
    ).firstOrNull;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.5,
        minChildSize: 0.3,
        maxChildSize: 0.8,
        expand: false,
        builder: (context, scrollController) => Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    '$day - Jam $period',
                    style: AppTheme.h3(context),
                  ),
                  if (existingSchedule != null)
                    IconButton(
                      icon: const Icon(Icons.delete, color: Colors.red),
                      onPressed: () async {
                        await db.scheduleDao.deleteSchedule(existingSchedule.id);
                        if (context.mounted) Navigator.pop(context);
                      },
                    ),
                ],
              ),
            ),
            const Divider(),
            Expanded(
              child: ListView.builder(
                controller: scrollController,
                itemCount: subjects.length,
                itemBuilder: (context, index) {
                  final subject = subjects[index];
                  final isSelected = existingSchedule?.subjectId == subject.id;
                  
                  return ListTile(
                    leading: CircleAvatar(
                      backgroundColor: isSelected 
                          ? AppTheme.accent 
                          : AppTheme.accent.withOpacity(0.2),
                      child: Text(
                        subject.code,
                        style: TextStyle(
                          color: isSelected ? Colors.white : AppTheme.accent,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    title: Text(subject.name),
                    subtitle: Text(subject.code),
                    trailing: isSelected ? const Icon(Icons.check, color: AppTheme.accent) : null,
                    onTap: () async {
                      await db.scheduleDao.upsertSchedule(
                        day: day,
                        period: period,
                        subjectId: subject.id,
                        className: className,
                      );
                      if (context.mounted) Navigator.pop(context);
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

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
          child: InkWell(
            onTap: () => _showSubjectPicker(context, day, period),
            borderRadius: BorderRadius.circular(4),
            child: Center(
              child: subject != null
                  ? Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          subject.name,
                          style: AppTheme.small(context),
                          textAlign: TextAlign.center,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        if (subject.code.isNotEmpty)
                          Text(
                            subject.code,
                            style: AppTheme.caption(context).copyWith(
                              color: AppTheme.accent,
                            ),
                          ),
                      ],
                    )
                  : Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.add,
                          size: 16,
                          color: Colors.grey.withOpacity(0.5),
                        ),
                        Text(
                          '-',
                          style: AppTheme.small(context).copyWith(
                            color: Colors.grey.withOpacity(0.5),
                          ),
                        ),
                      ],
                    ),
            ),
          ),
        );
      },
    );
  }
}
