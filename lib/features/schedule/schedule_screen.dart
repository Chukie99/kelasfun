import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:kelasfun/core/database/app_database.dart';
import 'package:kelasfun/core/theme/app_theme.dart';
import 'package:kelasfun/features/schedule/widgets/schedule_grid.dart';

class ScheduleScreen extends StatefulWidget {
  const ScheduleScreen({super.key});

  @override
  State<ScheduleScreen> createState() => _ScheduleScreenState();
}

class _ScheduleScreenState extends State<ScheduleScreen> {
  String _selectedClass = 'X RPL 1';

  static const classOptions = [
    'X RPL 1',
    'X RPL 2',
    'XI RPL 1',
    'XI RPL 2',
  ];

  @override
  Widget build(BuildContext context) {
    final db = context.read<AppDatabase>();
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: Text('Jadwal Pelajaran', style: AppTheme.h2(context)),
        actions: [
          DropdownButton<String>(
            value: _selectedClass,
            dropdownColor: isDark ? AppTheme.surface : AppTheme.lightSurface,
            style: AppTheme.body(context),
            underline: const SizedBox(),
            items: classOptions
                .map((c) => DropdownMenuItem(value: c, child: Text(c)))
                .toList(),
            onChanged: (v) => setState(() => _selectedClass = v ?? _selectedClass),
          ),
        ],
      ),
      body: FutureBuilder<List<Subject>>(
        future: db.subjectDao.getAllSubjects(),
        builder: (context, subjectSnapshot) {
          final subjects = subjectSnapshot.data ?? [];
          return StreamBuilder<List<Schedule>>(
            stream: db.scheduleDao.watchScheduleByClass(_selectedClass),
            builder: (context, scheduleSnapshot) {
              final schedules = scheduleSnapshot.data ?? [];
              return ScheduleGrid(
                className: _selectedClass,
                schedules: schedules,
                subjects: subjects,
              );
            },
          );
        },
      ),
    );
  }
}
