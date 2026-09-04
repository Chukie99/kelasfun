import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:kelasfun/core/database/app_database.dart';
import 'package:kelasfun/shared/widgets/app_card.dart';
import 'package:kelasfun/shared/widgets/app_button.dart';
import 'package:kelasfun/shared/widgets/app_text_field.dart';
import 'package:kelasfun/core/theme/app_theme.dart';

class SubjectScreen extends StatelessWidget {
  const SubjectScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final db = context.read<AppDatabase>();
    final isDark = Theme.of(context).brightness == Brightness.dark;

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
                    backgroundColor: isDark ? AppTheme.accent : AppTheme.lightAccent,
                    child: Text(
                      subject.code,
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.onPrimary,
                      ),
                    ),
                  ),
                  title: Text(subject.name),
                  subtitle: Text('Kode: ${subject.code}'),
                  trailing: IconButton(
                    icon: Icon(
                      Icons.delete,
                      color: isDark ? AppTheme.coral : AppTheme.lightCoral,
                    ),
                    onPressed: () async {
                      try {
                        await db.subjectDao.deleteSubject(subject.id);
                      } catch (e) {
                        if (context.mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text('Gagal menghapus mapel: $e')),
                          );
                        }
                      }
                    },
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
              if (nameController.text.trim().isEmpty || codeController.text.trim().isEmpty) {
                if (ctx.mounted) {
                  ScaffoldMessenger.of(ctx).showSnackBar(
                    const SnackBar(content: Text('Nama dan kode mapel wajib diisi')),
                  );
                }
                return;
              }
              final db = context.read<AppDatabase>();
              try {
                await db.subjectDao.insertSubject(
                  name: nameController.text.trim(),
                  code: codeController.text.trim().toUpperCase(),
                );
                if (ctx.mounted) Navigator.pop(ctx);
              } catch (e) {
                if (ctx.mounted) {
                  ScaffoldMessenger.of(ctx).showSnackBar(
                    SnackBar(content: Text('Gagal menambahkan mapel: $e')),
                  );
                }
              }
            },
          ),
        ],
      ),
    );
  }
}