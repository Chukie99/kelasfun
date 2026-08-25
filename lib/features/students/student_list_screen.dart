import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:provider/provider.dart';
import 'package:kelasfun/core/database/app_database.dart';
import 'package:kelasfun/core/theme/app_theme.dart';
import 'package:kelasfun/core/utils/qr_generator.dart';
import 'package:kelasfun/features/students/student_form_screen.dart';
import 'package:kelasfun/features/students/student_detail_screen.dart';
import 'package:kelasfun/features/students/widgets/student_card.dart';
import 'package:kelasfun/shared/widgets/app_text_field.dart';

class StudentListScreen extends StatefulWidget {
  const StudentListScreen({super.key});

  @override
  State<StudentListScreen> createState() => _StudentListScreenState();
}

class _StudentListScreenState extends State<StudentListScreen> {
  String _searchQuery = '';
  String _selectedClass = 'Semua';
  late final Stream<List<Student>> _studentsStream;

  @override
  void initState() {
    super.initState();
    final db = context.read<AppDatabase>();
    _studentsStream = db.studentDao.watchAllStudents();
  }

  Future<void> _importCSV(BuildContext context) async {
    final db = context.read<AppDatabase>();
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['csv'],
    );
    if (result == null || result.files.isEmpty) return;

    final file = result.files.first;
    final bytes = file.bytes;
    if (bytes == null) return;

    final content = String.fromCharCodes(bytes);
    final lines = content.split('\n').where((l) => l.trim().isNotEmpty).toList();

    int success = 0, failed = 0;
    for (final line in lines.skip(1)) {
      final parts = line.split(',');
      if (parts.length < 4) { failed++; continue; }

      final nis = parts[0].trim();
      final name = parts[1].trim();
      final className = parts[2].trim();
      final gender = parts[3].trim();

      if (nis.isEmpty || name.isEmpty || className.isEmpty || gender.isEmpty) {
        failed++;
        continue;
      }
      if (gender != 'Laki-laki' && gender != 'Perempuan') {
        failed++;
        continue;
      }

      try {
        final existing = await db.studentDao.getStudentByNis(nis);
        if (existing != null) { failed++; continue; }

        await db.studentDao.insertStudent(
          nis: nis,
          fullName: name,
          className: className,
          gender: gender,
          qrData: QrGenerator.encodePayload(nis: nis, name: name, className: className),
        );
        success++;
      } catch (e) {
        failed++;
      }
    }

    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Import selesai: $success berhasil, $failed gagal')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final db = context.read<AppDatabase>();
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: Text('Data Siswa', style: AppTheme.h2(context)),
        actions: [
          IconButton(
            icon: Icon(Icons.file_upload,
                color: isDark ? AppTheme.textPrimary : AppTheme.lightTextPrimary),
            onPressed: () => _importCSV(context),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const StudentFormScreen()),
        ),
        child: const Icon(Icons.add),
      ),
      body: StreamBuilder<List<Student>>(
        stream: _studentsStream,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(
                child: CircularProgressIndicator(
                    color: isDark ? AppTheme.accent : AppTheme.lightAccent));
          }
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }
          final students = snapshot.data ?? [];
          
          final classSet = <String>{};
          final classes = ['Semua', ...students.map((s) => s.className).where((c) => classSet.add(c))];
          if (!classes.contains(_selectedClass)) {
            _selectedClass = 'Semua';
          }
          
          final filteredStudents = students.where((s) {
            final matchesSearch = _searchQuery.isEmpty ||
                s.nis.toLowerCase().contains(_searchQuery.toLowerCase()) ||
                s.fullName.toLowerCase().contains(_searchQuery.toLowerCase());
            final matchesClass = _selectedClass == 'Semua' || s.className == _selectedClass;
            return matchesSearch && matchesClass;
          }).toList();

          if (students.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.school_outlined,
                      size: 64,
                      color: isDark ? AppTheme.textTertiary : AppTheme.lightTextTertiary),
                  const SizedBox(height: AppTheme.spacingBase),
                  Text('Belum ada siswa',
                      style: AppTheme.h3(context)),
                  const SizedBox(height: AppTheme.spacingSm),
                  Text('Tambahkan siswa dengan menekan tombol +',
                      style: AppTheme.bodySmall(context)),
                ],
              ),
            );
          }
          return Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(AppTheme.spacingBase),
                child: AppTextField(
                  hint: 'Cari siswa...',
                  prefixIcon: Icons.search,
                  onChanged: (v) => setState(() => _searchQuery = v),
                ),
              ),
              SizedBox(
                height: 48,
                child: ListView.separated(
                  padding: const EdgeInsets.symmetric(horizontal: AppTheme.spacingBase),
                  scrollDirection: Axis.horizontal,
                  itemCount: classes.length,
                  separatorBuilder: (_, __) => const SizedBox(width: AppTheme.spacingSm),
                  itemBuilder: (context, index) {
                    final cls = classes[index];
                    final isSelected = _selectedClass == cls;
                    return ChoiceChip(
                      label: Text(cls),
                      selected: isSelected,
                      onSelected: (_) => setState(() => _selectedClass = cls),
                      selectedColor: isDark ? AppTheme.mintSoft : AppTheme.lightMintSoft,
                      backgroundColor: isDark ? AppTheme.surfaceLight : AppTheme.lightSurfaceLight,
                      labelStyle: AppTheme.bodySmall(context).copyWith(
                        color: isSelected
                            ? (isDark ? AppTheme.mint : AppTheme.lightMint)
                            : (isDark ? AppTheme.textSecondary : AppTheme.lightTextSecondary),
                        fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                      ),
                      checkmarkColor: isDark ? AppTheme.mint : AppTheme.lightMint,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(AppTheme.radiusChip),
                        side: BorderSide(
                          color: isSelected
                              ? (isDark ? AppTheme.mint : AppTheme.lightMint)
                              : (isDark ? AppTheme.divider : AppTheme.lightDivider),
                        ),
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(height: AppTheme.spacingSm),
              Expanded(
                child: filteredStudents.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.search_off,
                                size: 48,
                                color: isDark ? AppTheme.textTertiary : AppTheme.lightTextTertiary),
                            const SizedBox(height: AppTheme.spacingBase),
                            Text('Tidak ada siswa ditemukan',
                                style: AppTheme.h3(context)),
                            const SizedBox(height: AppTheme.spacingSm),
                            Text('Coba kata kunci lain atau ubah filter',
                                style: AppTheme.bodySmall(context)),
                          ],
                        ),
                      )
                    : ListView.builder(
                        padding: const EdgeInsets.only(bottom: AppTheme.spacingXl),
                        itemCount: filteredStudents.length,
                        itemBuilder: (context, index) {
                          final student = filteredStudents[index];
                          return StudentCard(
                            student: student,
                            onTap: () => Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => StudentDetailScreen(student: student),
                              ),
                            ),
                            onDelete: () async {
                              // Konfirmasi dulu + arsip (soft delete), BUKAN
                              // hard delete — salah tap gak boleh menghapus
                              // permanen beserta riwayat presensi/nilainya.
                              final confirmed = await showDialog<bool>(
                                context: context,
                                builder: (ctx) => AlertDialog(
                                  title: Text('Arsipkan siswa?',
                                      style: AppTheme.h3(context)),
                                  content: Text(
                                    '${student.fullName} akan disembunyikan dari daftar aktif. Riwayat presensi & nilai tetap tersimpan dan bisa dipulihkan lewat database.',
                                    style: AppTheme.body(context),
                                  ),
                                  actions: [
                                    TextButton(
                                      onPressed: () =>
                                          Navigator.pop(ctx, false),
                                      child: const Text('Batal'),
                                    ),
                                    FilledButton(
                                      onPressed: () =>
                                          Navigator.pop(ctx, true),
                                      style: FilledButton.styleFrom(
                                          backgroundColor: AppTheme.coral),
                                      child: const Text('Arsipkan'),
                                    ),
                                  ],
                                ),
                              );
                              if (confirmed != true || !context.mounted) return;
                              try {
                                await db.studentDao
                                    .softDeleteStudent(student.id);
                                if (!context.mounted) return;
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                      content: Text(
                                          '${student.fullName} diarsipkan')),
                                );
                              } catch (e, stackTrace) {
                                debugPrint('DELETE ERROR: $e');
                                debugPrint('STACK TRACE: $stackTrace');
                                if (context.mounted) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                        content: Text(
                                            'Gagal mengarsipkan siswa: $e')),
                                  );
                                }
                              }
                            },
                          );
                        },
                      ),
              ),
            ],
          );
        },
      ),
    );
  }
}
