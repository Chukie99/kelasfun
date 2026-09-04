import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:kelasfun/core/database/app_database.dart';
import 'package:kelasfun/core/config/app_config.dart';
import 'package:kelasfun/core/theme/app_theme.dart';
import 'package:kelasfun/shared/widgets/app_card.dart';
import 'package:kelasfun/shared/widgets/app_button.dart';

class GradeScreen extends StatefulWidget {
  const GradeScreen({super.key});

  @override
  State<GradeScreen> createState() => _GradeScreenState();
}

class _GradeScreenState extends State<GradeScreen> {
  int? _selectedStudentId;
  String _semester = SemesterHelper.currentSemester();

  @override
  Widget build(BuildContext context) {
    final db = context.read<AppDatabase>();

    return Scaffold(
      appBar: AppBar(title: const Text('Input Nilai')),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(AppTheme.spacingBase),
            child: Row(
              children: [
                const Text('Semester: '),
                DropdownButton<String>(
                  value: _semester,
                  items: SemesterHelper.semesterOptions().map((s) => DropdownMenuItem(value: s, child: Text(s))).toList(),
                  onChanged: (v) => setState(() => _semester = v ?? _semester),
                ),
              ],
            ),
          ),
          Expanded(
            child: StreamBuilder<List<Student>>(
              stream: db.studentDao.watchAllStudents(),
              builder: (context, snapshot) {
                final students = snapshot.data ?? [];
                if (students.isEmpty) {
                  return const Center(child: Text('Tambah siswa terlebih dahulu'));
                }
                return ListView.builder(
                  itemCount: students.length,
                  itemBuilder: (context, index) {
                    final student = students[index];
                    return AppCard(
                      child: ListTile(
                        title: Text(student.fullName),
                        subtitle: Text('NIS: ${student.nis} - ${student.className}'),
                        trailing: const Icon(Icons.chevron_right),
                        onTap: () => _showGradeDialog(context, student),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  void _showGradeDialog(BuildContext context, Student student) {
    final db = context.read<AppDatabase>();
    final scoreController = TextEditingController();
    String? selectedSubject;
    String examType = 'UTS';

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setDialogState) => AlertDialog(
          title: Text('Nilai: ${student.fullName}'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                StreamBuilder<List<Subject>>(
                  stream: db.subjectDao.watchAllSubjects(),
                  builder: (context, snapshot) {
                    final subjects = snapshot.data ?? [];
                    return DropdownButtonFormField<String>(
                      value: selectedSubject,
                      decoration: const InputDecoration(labelText: 'Mata Pelajaran'),
                      items: subjects.map((s) =>
                        DropdownMenuItem(value: s.code, child: Text(s.name))
                      ).toList(),
                      onChanged: (v) => setDialogState(() => selectedSubject = v),
                    );
                  },
                ),
                const SizedBox(height: AppTheme.spacingSm),
                DropdownButtonFormField<String>(
                  value: examType,
                  decoration: const InputDecoration(labelText: 'Jenis Ujian'),
                  items: const [
                    DropdownMenuItem(value: 'UTS', child: Text('UTS')),
                    DropdownMenuItem(value: 'UAS', child: Text('UAS')),
                    DropdownMenuItem(value: 'Tugas', child: Text('Tugas')),
                  ],
                  onChanged: (v) => setDialogState(() => examType = v ?? examType),
                ),
                const SizedBox(height: AppTheme.spacingSm),
                TextField(
                  controller: scoreController,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(labelText: 'Nilai'),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Batal')),
            AppButton(
              label: 'Simpan',
              onPressed: () async {
                try {
                  if (selectedSubject == null || scoreController.text.isEmpty) {
                    if (ctx.mounted) {
                      ScaffoldMessenger.of(ctx).showSnackBar(
                        const SnackBar(content: Text('Pilih mata pelajaran dan isi nilai')),
                      );
                    }
                    return;
                  }
                  final score = double.tryParse(scoreController.text);
                  if (score == null) {
                    if (ctx.mounted) {
                      ScaffoldMessenger.of(ctx).showSnackBar(
                        const SnackBar(content: Text('Nilai harus berupa angka')),
                      );
                    }
                    return;
                  }
                  if (score < 0 || score > 100) {
                    if (ctx.mounted) {
                      ScaffoldMessenger.of(ctx).showSnackBar(
                        const SnackBar(content: Text('Nilai harus antara 0 dan 100')),
                      );
                    }
                    return;
                  }
                  final subject = await db.subjectDao.getSubjectByCode(selectedSubject!);
                  if (subject == null) return;
                  await db.gradeDao.insertGrade(
                    studentId: student.id,
                    subjectId: subject.id,
                    score: score,
                    examType: examType,
                    semester: _semester,
                  );
                  if (ctx.mounted) Navigator.pop(ctx);
                } catch (e) {
                  debugPrint('Error inserting grade: $e');
                  if (ctx.mounted) {
                    ScaffoldMessenger.of(ctx).showSnackBar(
                      SnackBar(content: Text('Gagal menyimpan nilai: $e')),
                    );
                    Navigator.pop(ctx);
                  }
                }
              },
            ),
          ],
        ),
      ),
    );
  }
}
