import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:kelasfun/core/database/app_database.dart';
import 'package:kelasfun/core/theme/app_theme.dart';
import 'package:kelasfun/shared/widgets/app_card.dart';
import 'package:kelasfun/shared/widgets/app_button.dart';
import 'package:kelasfun/shared/widgets/app_text_field.dart';

class PointScreen extends StatefulWidget {
  const PointScreen({super.key});

  @override
  State<PointScreen> createState() => _PointScreenState();
}

class _PointScreenState extends State<PointScreen> {
  @override
  Widget build(BuildContext context) {
    final db = context.read<AppDatabase>();

    return Scaffold(
      appBar: AppBar(title: const Text('Poin Disiplin')),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddDialog(context),
        child: const Icon(Icons.add),
      ),
      body: StreamBuilder<List<Student>>(
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
              return FutureBuilder<int>(
                future: db.pointDao.getTotalPoints(student.id),
                builder: (context, pointSnap) {
                  final totalPoints = pointSnap.data ?? 0;
                  return AppCard(
                    child: ListTile(
                      leading: CircleAvatar(
                        backgroundColor: Theme.of(context).brightness == Brightness.dark
                            ? (totalPoints >= 0 ? AppTheme.mint : AppTheme.coral)
                            : (totalPoints >= 0 ? AppTheme.lightMint : AppTheme.lightCoral),
                        child: Text(
                          '$totalPoints',
                          style: TextStyle(
                            color: Theme.of(context).brightness == Brightness.dark
                                ? AppTheme.textPrimary
                                : AppTheme.lightTextPrimary,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      title: Text(
                        student.fullName,
                        style: AppTheme.body(context),
                      ),
                      subtitle: Text(
                        student.className,
                        style: AppTheme.caption(context),
                      ),
                      trailing: IconButton(
                        icon: const Icon(Icons.add_circle_outline),
                        onPressed: () => _showPointDialog(context, student),
                      ),
                    ),
                  );
                },
              );
            },
          );
        },
      ),
    );
  }

  void _showAddDialog(BuildContext context) {
    final nameController = TextEditingController();
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Tambah Kategori Poin'),
        content: AppTextField(label: 'Kategori', controller: nameController, onChanged: (_) {}),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Batal')),
          AppButton(
            label: 'Simpan',
            onPressed: () => Navigator.pop(ctx),
          ),
        ],
      ),
    );
  }

  void _showPointDialog(BuildContext context, Student student) {
    final db = context.read<AppDatabase>();
    final descController = TextEditingController();
    int pointValue = 0;
    String type = 'VIOLATION';
    String category = 'Terlambat';

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setDialogState) => AlertDialog(
          title: Text('Poin: ${student.fullName}'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              DropdownButtonFormField<String>(
                value: type,
                decoration: const InputDecoration(labelText: 'Tipe'),
                items: const [
                  DropdownMenuItem(value: 'VIOLATION', child: Text('Pelanggaran')),
                  DropdownMenuItem(value: 'ACHIEVEMENT', child: Text('Prestasi')),
                ],
                onChanged: (v) => setDialogState(() {
                  type = v ?? type;
                  pointValue = type == 'ACHIEVEMENT' ? 10 : -5;
                }),
              ),
              const SizedBox(height: AppTheme.spacingSm),
              DropdownButtonFormField<String>(
                value: category,
                decoration: const InputDecoration(labelText: 'Kategori'),
                items: const [
                  DropdownMenuItem(value: 'Terlambat', child: Text('Terlambat')),
                  DropdownMenuItem(value: 'Tidak Mengerjakan PR', child: Text('Tidak Mengerjakan PR')),
                  DropdownMenuItem(value: 'Juara Olimpiade', child: Text('Juara Olimpiade')),
                  DropdownMenuItem(value: 'Juara Lomba', child: Text('Juara Lomba')),
                ],
                onChanged: (v) => setDialogState(() => category = v ?? category),
              ),
              const SizedBox(height: AppTheme.spacingSm),
              TextField(
                controller: descController,
                decoration: const InputDecoration(labelText: 'Keterangan'),
              ),
            ],
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Batal')),
            AppButton(
              label: 'Simpan',
              onPressed: () async {
                await db.pointDao.insertPoint(
                  studentId: student.id,
                  type: type,
                  category: category,
                  pointValue: pointValue,
                  date: DateTime.now().toIso8601String().substring(0, 10),
                  description: descController.text.isNotEmpty ? descController.text : null,
                );
                if (ctx.mounted) Navigator.pop(ctx);
              },
            ),
          ],
        ),
      ),
    );
  }
}
