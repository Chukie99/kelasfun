import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:kelasfun/core/database/app_database.dart';
import 'package:kelasfun/core/theme/app_theme.dart';
import 'android_student_form_local.dart';

class AndroidStudentListLocal extends StatefulWidget {
  const AndroidStudentListLocal({super.key});

  @override
  State<AndroidStudentListLocal> createState() => _AndroidStudentListLocalState();
}

class _AndroidStudentListLocalState extends State<AndroidStudentListLocal> {
  String _search = '';
  String _classFilter = 'Semua';

  @override
  Widget build(BuildContext context) {
    final db = context.read<AppDatabase>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Daftar Siswa'),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          final result = await Navigator.push<bool>(
            context,
            MaterialPageRoute(builder: (_) => const AndroidStudentFormLocal()),
          );
          if (result == true) setState(() {});
        },
        child: const Icon(Icons.person_add),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(AppTheme.spacingBase),
            child: TextField(
              decoration: const InputDecoration(
                hintText: 'Cari nama atau NIS...',
                prefixIcon: Icon(Icons.search),
                border: OutlineInputBorder(),
              ),
              onChanged: (v) => setState(() => _search = v),
            ),
          ),
          Expanded(
            child: StreamBuilder<List<Student>>(
              stream: db.studentDao.watchAllStudents(),
              builder: (context, snapshot) {
                final students = snapshot.data ?? [];

                final filtered = students.where((s) {
                  final matchSearch = _search.isEmpty ||
                      s.fullName.toLowerCase().contains(_search.toLowerCase()) ||
                      s.nis.contains(_search);
                  final matchClass = _classFilter == 'Semua' ||
                      s.className == _classFilter;
                  return matchSearch && matchClass;
                }).toList();

                final classes = students
                    .map((s) => s.className)
                    .toSet()
                    .toList()
                  ..sort();

                if (students.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.people_outline, size: 64, color: AppTheme.textSecondary),
                        const SizedBox(height: 16),
                        Text('Belum ada siswa', style: AppTheme.body(context)),
                        const SizedBox(height: 8),
                        Text('Tekan + untuk menambah siswa', style: AppTheme.caption(context)),
                      ],
                    ),
                  );
                }

                return Column(
                  children: [
                    if (classes.isNotEmpty)
                      SizedBox(
                        height: 40,
                        child: ListView(
                          scrollDirection: Axis.horizontal,
                          padding: const EdgeInsets.symmetric(horizontal: AppTheme.spacingBase),
                          children: [
                            _buildClassChip('Semua'),
                            ...classes.map((c) => _buildClassChip(c)),
                          ],
                        ),
                      ),
                    Expanded(
                      child: ListView.builder(
                        padding: const EdgeInsets.all(AppTheme.spacingBase),
                        itemCount: filtered.length,
                        itemBuilder: (context, index) {
                          final s = filtered[index];
                          return Card(
                            margin: const EdgeInsets.only(bottom: 8),
                            child: ListTile(
                              leading: CircleAvatar(
                                backgroundColor: AppTheme.accent.withOpacity(0.2),
                                child: Text(
                                  s.fullName.isNotEmpty
                                      ? s.fullName[0].toUpperCase()
                                      : '?',
                                  style: TextStyle(color: AppTheme.accent),
                                ),
                              ),
                              title: Text(s.fullName),
                              subtitle: Text('NIS: ${s.nis} | Kelas: ${s.className}'),
                              trailing: PopupMenuButton(
                                itemBuilder: (context) => [
                                  const PopupMenuItem(
                                    value: 'delete',
                                    child: Text('Hapus'),
                                  ),
                                ],
                                onSelected: (value) async {
                                  if (value == 'delete') {
                                    final confirm = await showDialog<bool>(
                                      context: context,
                                      builder: (ctx) => AlertDialog(
                                        title: const Text('Hapus Siswa'),
                                        content: Text('Hapus ${s.fullName}?'),
                                        actions: [
                                          TextButton(
                                            onPressed: () => Navigator.pop(ctx, false),
                                            child: const Text('Batal'),
                                          ),
                                          TextButton(
                                            onPressed: () => Navigator.pop(ctx, true),
                                            child: const Text('Hapus',
                                                style: TextStyle(color: Colors.red)),
                                          ),
                                        ],
                                      ),
                                    );
                                    if (confirm == true) {
                                      await db.studentDao.softDeleteStudent(s.id);
                                    }
                                  }
                                },
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  ],
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildClassChip(String label) {
    final isSelected = _classFilter == label;
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: FilterChip(
        label: Text(label),
        selected: isSelected,
        onSelected: (_) => setState(() => _classFilter = label),
        selectedColor: AppTheme.accent.withOpacity(0.2),
      ),
    );
  }
}
