import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:kelasfun/core/database/app_database.dart';
import 'package:kelasfun/core/theme/app_theme.dart';
import 'package:drift/drift.dart' as drift;

class JurnalScreen extends StatefulWidget {
  const JurnalScreen({super.key});

  @override
  State<JurnalScreen> createState() => _JurnalScreenState();
}

class _JurnalScreenState extends State<JurnalScreen> {
  String? _selectedClass;

  void _showAddJurnalDialog(BuildContext context, List<Subject> subjects) {
    if (_selectedClass == null) return;
    final db = context.read<AppDatabase>();

    final dateController = TextEditingController(
      text: DateFormat('yyyy-MM-dd').format(DateTime.now()),
    );
    final topicController = TextEditingController();
    final notesController = TextEditingController();
    int? selectedSubjectId = subjects.isNotEmpty ? subjects.first.id : null;

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Tambah Jurnal Mengajar'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: dateController,
                decoration: const InputDecoration(labelText: 'Tanggal (yyyy-MM-dd)'),
              ),
              const SizedBox(height: 8),
              DropdownButtonFormField<int>(
                value: selectedSubjectId,
                items: subjects
                    .map((s) => DropdownMenuItem(
                          value: s.id,
                          child: Text('\${s.name} (\${s.code})'),
                        ))
                    .toList(),
                onChanged: (val) => selectedSubjectId = val,
                decoration: const InputDecoration(labelText: 'Mata Pelajaran'),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: topicController,
                decoration: const InputDecoration(labelText: 'Materi / Topik Pembahasan'),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: notesController,
                decoration: const InputDecoration(labelText: 'Catatan / Kendall (Opsional)'),
                maxLines: 2,
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Batal'),
          ),
          ElevatedButton(
            onPressed: () async {
              if (selectedSubjectId == null || topicController.text.trim().isEmpty) return;
              await db.jurnalDao.insertJurnal(
                JurnalsCompanion.insert(
                  date: dateController.text.trim(),
                  className: _selectedClass!,
                  subjectId: selectedSubjectId!,
                  topic: topicController.text.trim(),
                  notes: drift.Value(
                    notesController.text.trim().isEmpty ? null : notesController.text.trim(),
                  ),
                ),
              );
              if (ctx.mounted) Navigator.pop(ctx);
            },
            child: const Text('Simpan'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final db = context.read<AppDatabase>();
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Jurnal Mengajar'),
        actions: [
          FutureBuilder<List<Student>>(
            future: db.studentDao.getAllStudents(),
            builder: (context, snap) {
              final students = snap.data ?? [];
              final classes = students.map((s) => s.className).toSet().toList()..sort();
              if (classes.isEmpty) return const SizedBox();
              _selectedClass ??= classes.first;
              if (!classes.contains(_selectedClass)) _selectedClass = classes.first;

              return Padding(
                padding: const EdgeInsets.only(right: 12),
                child: DropdownButton<String>(
                  value: _selectedClass,
                  dropdownColor: isDark ? AppTheme.surface : AppTheme.lightSurface,
                  underline: const SizedBox(),
                  items: classes.map((c) => DropdownMenuItem(value: c, child: Text(c))).toList(),
                  onChanged: (v) => setState(() => _selectedClass = v),
                ),
              );
            },
          ),
        ],
      ),
      floatingActionButton: FutureBuilder<List<Subject>>(
        future: db.subjectDao.getAllSubjects(),
        builder: (context, snap) {
          final subjects = snap.data ?? [];
          if (subjects.isEmpty) return const SizedBox();
          return FloatingActionButton(
            onPressed: () => _showAddJurnalDialog(context, subjects),
            child: const Icon(Icons.add),
          );
        },
      ),
      body: _selectedClass == null
          ? const Center(child: Text('Pilih / Tambah data siswa & kelas terlebih dahulu'))
          : StreamBuilder<List<Jurnal>>(
              stream: db.jurnalDao.watchJurnalsByClass(_selectedClass!),
              builder: (context, snapshot) {
                final jurnals = snapshot.data ?? [];
                if (jurnals.isEmpty) {
                  return const Center(child: Text('Belum ada jurnal mengajar'));
                }
                return ListView.builder(
                  padding: const EdgeInsets.all(12),
                  itemCount: jurnals.length,
                  itemBuilder: (context, index) {
                    final j = jurnals[index];
                    return Card(
                      child: ListTile(
                        title: Text(j.topic, style: const TextStyle(fontWeight: FontWeight.bold)),
                        subtitle: Text('\${j.date} • Catatan: \${j.notes ?? "-"}'),
                        trailing: IconButton(
                          icon: const Icon(Icons.delete, color: Colors.red),
                          onPressed: () => db.jurnalDao.deleteJurnal(j.id),
                        ),
                      ),
                    );
                  },
                );
              },
            ),
    );
  }
}
