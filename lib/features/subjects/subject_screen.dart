import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:kelasfun/core/database/app_database.dart';
import 'package:kelasfun/shared/widgets/app_card.dart';
import 'package:kelasfun/shared/widgets/app_button.dart';
import 'package:kelasfun/shared/widgets/app_text_field.dart';

class SubjectScreen extends StatelessWidget {
  const SubjectScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final db = context.read<AppDatabase>();

    return Scaffold(
      appBar: AppBar(title: const Text('Mata Pelajaran')),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddDialog(context),
        child: const Icon(Icons.add),
      ),
      body: StreamBuilder<List<Subject>>(
        stream: db.subjectDao.watchAllSubjects(),
        builder: (context, snapshot) {
          final subjects = snapshot.data ?? [];
          if (subjects.isEmpty) {
            return const Center(child: Text('Belum ada mata pelajaran'));
          }
          return ListView.builder(
            itemCount: subjects.length,
            itemBuilder: (context, index) {
              final subject = subjects[index];
              return AppCard(
                child: ListTile(
                  leading: CircleAvatar(
                    backgroundColor: const Color(0xFF5B9BD5),
                    child: Text(subject.code, style: const TextStyle(color: Colors.white)),
                  ),
                  title: Text(subject.name),
                  subtitle: Text('Kode: ${subject.code}'),
                  trailing: IconButton(
                    icon: const Icon(Icons.delete, color: Color(0xFFFF6B6B)),
                    onPressed: () => db.subjectDao.deleteSubject(subject.id),
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }

  void _showAddDialog(BuildContext context) {
    final nameController = TextEditingController();
    final codeController = TextEditingController();
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Tambah Mapel'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            AppTextField(label: 'Nama Mapel', controller: nameController, onChanged: (_) {}),
            AppTextField(label: 'Kode', controller: codeController, onChanged: (_) {}),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Batal')),
          AppButton(
            label: 'Simpan',
            onPressed: () async {
              final db = context.read<AppDatabase>();
              await db.subjectDao.insertSubject(
                name: nameController.text,
                code: codeController.text,
              );
              if (ctx.mounted) Navigator.pop(ctx);
            },
          ),
        ],
      ),
    );
  }
}
