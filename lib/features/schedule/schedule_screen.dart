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
  String? _selectedClass;

  @override
  Widget build(BuildContext context) {
    final db = context.read<AppDatabase>();
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Scaffold(
      appBar: AppBar(
        title: Text('Jadwal Pelajaran', style: AppTheme.h2(context)),
        actions: [
          FutureBuilder<List<Student>>(
            future: db.studentDao.getAllStudents(),
            builder: (context, snap) {
              final students = snap.data ?? [];
              final classes = students.map((s) => s.className).toSet().toList()..sort();
              if (classes.isEmpty) return const SizedBox();
              _selectedClass ??= classes.first;
              // ensure selected still exists
              if (!classes.contains(_selectedClass)) _selectedClass = classes.first;
              return Padding(
                padding: const EdgeInsets.only(right: 8),
                child: DropdownButton<String>(
                  value: _selectedClass,
                  dropdownColor: isDark ? AppTheme.surface : AppTheme.lightSurface,
                  style: AppTheme.body(context).copyWith(fontSize: 13, fontWeight: FontWeight.w700),
                  underline: const SizedBox(),
                  items: classes.map((c) => DropdownMenuItem(value: c, child: Text(c))).toList(),
                  onChanged: (v) => setState(() => _selectedClass = v),
                ),
              );
            },
          ),
        ],
      ),
      body: FutureBuilder<List<Student>>(
        future: db.studentDao.getAllStudents(),
        builder: (context, stSnap) {
          final students = stSnap.data ?? [];
          final classes = students.map((s) => s.className).toSet().toList()..sort();
          if (students.isEmpty || classes.isEmpty) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(mainAxisSize: MainAxisSize.min, children: [
                  Icon(Icons.calendar_today, size: 48, color: Colors.grey.withValues(alpha: 0.5)),
                  const SizedBox(height: 12),
                  Text('Belum ada kelas', style: AppTheme.h3(context)),
                  const SizedBox(height: 6),
                  Text('Tambah siswa dulu di menu Siswa — kelas akan muncul otomatis di sini.', style: AppTheme.bodySmall(context), textAlign: TextAlign.center),
                ]),
              ),
            );
          }
          _selectedClass ??= classes.first;
          return FutureBuilder<List<Subject>>(
            future: db.subjectDao.getAllSubjects(),
            builder: (context, subjectSnap) {
              final subjects = subjectSnap.data ?? [];
              if (subjects.isEmpty) {
                return Center(child: Text('Belum ada mata pelajaran. Tambah di Master Data dulu.', style: AppTheme.bodySmall(context)));
              }
              return StreamBuilder<List<Schedule>>(
                stream: db.scheduleDao.watchScheduleByClass(_selectedClass!),
                builder: (context, schedSnap) {
                  final schedules = schedSnap.data ?? [];
                  return ScheduleGrid(
                    className: _selectedClass!,
                    schedules: schedules,
                    subjects: subjects,
                  );
                },
              );
            },
          );
        },
      ),
    );
  }
}
