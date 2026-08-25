import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:provider/provider.dart';
import 'package:printing/printing.dart';
import 'package:kelasfun/core/database/app_database.dart';
import 'package:kelasfun/core/theme/app_theme.dart';
import 'package:kelasfun/core/utils/pdf_generator.dart';
import 'package:kelasfun/core/utils/excel_generator.dart';
import 'package:kelasfun/core/utils/semester_utils.dart';
import 'package:kelasfun/shared/widgets/app_card.dart';

class ReportScreen extends StatelessWidget {
  const ReportScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Laporan & Cetak')),
      body: ListView(
        padding: const EdgeInsets.all(AppTheme.spacingBase),
        children: [
          _buildSection(
            context: context,
            title: 'Form Biodata Siswa',
            subtitle: 'Cetak form lengkap untuk arsip',
            icon: Icons.person,
            onTap: () => _printBiodata(context),
          ),
          _buildSection(
            context: context,
            title: 'Kartu QR Siswa',
            subtitle: 'Cetak kartu barcode untuk presensi',
            icon: Icons.qr_code,
            onTap: () => _printStudentCards(context),
          ),
          _buildSection(
            context: context,
            title: 'Rapor Digital',
            subtitle: 'Cetak rapor per siswa',
            icon: Icons.description,
            onTap: () => _selectStudentForReport(context),
          ),
          _buildSection(
            context: context,
            title: 'Cetak Semua Rapor',
            subtitle: 'Cetak rapor semua siswa dalam satu file',
            icon: Icons.print,
            onTap: () => _showBatchReportDialog(context),
          ),
          _buildSection(
            context: context,
            title: 'Export ke Excel',
            subtitle: 'Ekspor nilai & presensi ke file Excel',
            icon: Icons.table_chart,
            onTap: () => _showExcelExportDialog(context),
          ),
        ],
      ),
    );
  }

  Widget _buildSection({
    required BuildContext context,
    required String title,
    required String subtitle,
    required IconData icon,
    required VoidCallback onTap,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final accentColor = isDark ? AppTheme.accent : AppTheme.lightAccent;
    
    return AppCard(
      onTap: onTap,
      child: Row(
        children: [
          CircleAvatar(
            backgroundColor: accentColor,
            child: Icon(icon, color: isDark ? AppTheme.textPrimary : AppTheme.lightTextPrimary),
          ),
          const SizedBox(width: AppTheme.spacingBase),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: AppTheme.h2(context)),
                Text(subtitle, style: AppTheme.bodySmall(context)),
              ],
            ),
          ),
          Icon(Icons.print, color: accentColor),
        ],
      ),
    );
  }

  Future<void> _printBiodata(BuildContext context) async {
    try {
      final db = context.read<AppDatabase>();
      final students = await db.studentDao.getAllStudents();

      for (final student in students) {
        final pdf = await PdfGenerator.generateBiodata(
          nis: student.nis,
          fullName: student.fullName,
          className: student.className,
          gender: student.gender,
          birthDate: student.birthDate,
          address: student.address,
          parentName: student.parentName,
          parentPhone: student.parentPhone,
        );
        if (!context.mounted) break;
        if (pdf != null) {
          await Printing.layoutPdf(onLayout: (format) => pdf);
        }
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Gagal cetak biodata: $e')),
        );
      }
    }
  }

  Future<void> _printStudentCards(BuildContext context) async {
    try {
      final db = context.read<AppDatabase>();
      final students = await db.studentDao.getAllStudents();

      final studentData = <Map<String, dynamic>>[];
      for (final s in students) {
        Uint8List? photoBytes;
        if (s.photoPath != null && s.photoPath!.isNotEmpty) {
          final file = File(s.photoPath!);
          if (file.existsSync()) {
            photoBytes = await file.readAsBytes();
          }
        }
        studentData.add({
          'nis': s.nis,
          'name': s.fullName,
          'class': s.className,
          'photoBytes': photoBytes,
        });
      }

      final pdf = await PdfGenerator.generateStudentCards(students: studentData);
      if (pdf != null && context.mounted) {
        await Printing.layoutPdf(onLayout: (format) => pdf);
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Gagal cetak kartu: $e')),
        );
      }
    }
  }

  void _selectStudentForReport(BuildContext context) {
    final db = context.read<AppDatabase>();
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (ctx) => DraggableScrollableSheet(
        initialChildSize: 0.5,
        expand: false,
        builder: (ctx, scrollController) => FutureBuilder<List<Student>>(
          future: db.studentDao.getAllStudents(),
          builder: (context, snapshot) {
            final students = snapshot.data ?? [];
            return ListView.builder(
              controller: scrollController,
              itemCount: students.length,
              itemBuilder: (ctx, index) {
                final student = students[index];
                return ListTile(
                  title: Text(student.fullName),
                  subtitle: Text(student.className),
                  onTap: () {
                    Navigator.pop(ctx);
                    _generateReport(context, student);
                  },
                );
              },
            );
          },
        ),
      ),
    );
  }

  void _showBatchReportDialog(BuildContext context) {
    final db = context.read<AppDatabase>();
    String selectedClass = '';
    final semOptions = SemesterUtils.options();
    String selectedSemester = SemesterUtils.currentSemester();

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setState) => AlertDialog(
          title: const Text('Cetak Semua Rapor'),
          content: FutureBuilder<List<String>>(
            future: db.studentDao.getDistinctClassNames(),
            builder: (context, classSnapshot) {
            final classes = classSnapshot.data ?? const [];
            if (selectedClass.isEmpty && classes.isNotEmpty) {
              selectedClass = classes.first;
            }
            return Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              DropdownButtonFormField<String>(
                value: classes.contains(selectedClass) ? selectedClass : null,
                decoration: const InputDecoration(labelText: 'Kelas'),
                items: classes.map((c) => DropdownMenuItem(value: c, child: Text(c))).toList(),
                onChanged: (v) => setState(() => selectedClass = v ?? selectedClass),
              ),
              const SizedBox(height: AppTheme.spacingMd),
              DropdownButtonFormField<String>(
                value: selectedSemester,
                decoration: const InputDecoration(labelText: 'Semester'),
                items: semOptions.map((s) => DropdownMenuItem(value: s, child: Text(s))).toList(),
                onChanged: (v) => setState(() => selectedSemester = v ?? selectedSemester),
              ),
            ],
            );
            },
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Batal')),
            FilledButton(
              onPressed: () {
                if (selectedClass.isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Belum ada kelas/data siswa')),
                  );
                  return;
                }
                Navigator.pop(ctx);
                _generateBatchReport(context, selectedClass, selectedSemester);
              },
              child: const Text('Cetak'),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _generateBatchReport(BuildContext context, String className, String semester) async {
    if (!context.mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Menyiapkan rapor...')));

    final db = context.read<AppDatabase>();
    final students = await db.studentDao.getAllStudents();
    final classStudents = students.where((s) => s.className == className).toList();
    final ranking = await db.gradeDao.getRanking(semester);
    final subjects = await db.subjectDao.getAllSubjects();

    // SEMUA rapor jadi SATU PDF multi-halaman — dulu loop per siswa buka
    // dialog print sendiri-sendiri (N kali dialog untuk N siswa).
    final merged = pw.Document();

    for (final student in classStudents) {
      try {
        final grades = await db.gradeDao.getGradesByStudentSemester(student.id, semester);
        // Poin prestasi & pelanggaran DIHITUNG TERPISAH per tipe.
        // Dulu dijumlah lalu dinetralkan (+10 & -5 jadi "5") sehingga
        // pelanggaran tidak pernah muncul di rapor.
        final allPoints = await db.pointDao.getPointsByStudent(student.id);
        final achievement = allPoints
            .where((p) => p.type == 'ACHIEVEMENT')
            .fold<int>(0, (sum, p) => sum + p.pointValue);
        final violation = allPoints
            .where((p) => p.type == 'VIOLATION')
            .fold<int>(0, (sum, p) => sum + p.pointValue);
        final rankIndex = ranking.indexWhere((r) => r.studentId == student.id);

        final gradeData = <Map<String, dynamic>>[];
        for (final subject in subjects) {
          final subjectGrades = grades.where((g) => g.subjectId == subject.id).toList();
          if (subjectGrades.isNotEmpty) {
            double avgOfType(String type) {
              final list = subjectGrades.where((g) => g.examType == type).toList();
              if (list.isEmpty) return 0;
              return list.fold<double>(0, (sum, g) => sum + g.score) / list.length;
            }

            final avg = subjectGrades.fold<double>(0, (sum, g) => sum + g.score) / subjectGrades.length;
            gradeData.add({
              'subject': subject.name,
              'uts': avgOfType('UTS'),
              'uas': avgOfType('UAS'),
              'tugas': avgOfType('Tugas'),
              'average': avg,
            });
          }
        }

        final pagePdf = await PdfGenerator.buildReportCardPage(
          studentName: student.fullName,
          nis: student.nis,
          className: student.className,
          semester: semester,
          grades: gradeData,
          totalViolationPoints: violation.abs(),
          totalAchievementPoints: achievement,
          rank: rankIndex >= 0 ? rankIndex + 1 : ranking.length + 1,
          totalStudents: ranking.length,
        );
        merged.addPage(pagePdf);
      } catch (e) {
        debugPrint('Failed report for ${student.fullName}: $e');
      }
    }

    final bytes = await merged.save();
    if (!context.mounted) return;
    await Printing.layoutPdf(onLayout: (format) => bytes);

    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Rapor ${classStudents.length} siswa selesai dicetak')),
      );
    }
  }

  void _showExcelExportDialog(BuildContext context) {
    final semOptions = SemesterUtils.options();
    String selectedSemester = SemesterUtils.currentSemester();
    String selectedClass = '';

    final db = context.read<AppDatabase>();
    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setState) => AlertDialog(
          title: const Text('Export ke Excel'),
          content: FutureBuilder<List<String>>(
            future: db.studentDao.getDistinctClassNames(),
            builder: (context, classSnapshot) {
            final classes = classSnapshot.data ?? const [];
            if (selectedClass.isEmpty && classes.isNotEmpty) {
              selectedClass = classes.first;
            }
            return Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              DropdownButtonFormField<String>(
                value: selectedSemester,
                decoration: const InputDecoration(
                  labelText: 'Semester',
                ),
                items: semOptions.map((s) => DropdownMenuItem(value: s, child: Text(s))).toList(),
                onChanged: (v) => setState(() => selectedSemester = v ?? selectedSemester),
              ),
              const SizedBox(height: AppTheme.spacingMd),
              DropdownButtonFormField<String>(
                value: classes.contains(selectedClass) ? selectedClass : null,
                decoration: const InputDecoration(
                  labelText: 'Kelas',
                ),
                items: classes.map((c) => DropdownMenuItem(value: c, child: Text(c))).toList(),
                onChanged: (v) => setState(() => selectedClass = v ?? selectedClass),
              ),
            ],
            );
            },
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Batal'),
            ),
            FilledButton.icon(
              onPressed: () {
                Navigator.pop(ctx);
                _exportToExcel(context, selectedSemester, selectedClass);
              },
              icon: const Icon(Icons.download),
              label: const Text('Export'),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _exportToExcel(BuildContext context, String semester, String className) async {
    try {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Menyiapkan data...')),
      );

      final db = context.read<AppDatabase>();
      // Dulu dropdown kelas cuma jadi nama file — SEMUA siswa ikut terekspor.
      // Sekarang benar-benar difilter per kelas.
      final students = await db.studentDao.getAllStudents();
      final classStudents =
          students.where((s) => s.className == className).toList();
      if (classStudents.isEmpty && context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Tidak ada siswa di kelas $className')),
        );
        return;
      }
      final subjects = await db.subjectDao.getAllSubjects();
      // Range presensi ikut semester terpilih (dulu selalu Jan-Des).
      final dateRange = SemesterUtils.dateRange(semester);

      final studentsData = <Map<String, dynamic>>[];

      for (final student in classStudents) {
        final grades = await db.gradeDao.getGradesByStudentSemester(student.id, semester);
        final gradeMap = <String, double>{};
        for (final subject in subjects) {
          final subjectGrades = grades.where((g) => g.subjectId == subject.id).toList();
          if (subjectGrades.isNotEmpty) {
            final avg = subjectGrades.fold<double>(0, (sum, g) => sum + g.score) / subjectGrades.length;
            gradeMap[subject.name] = double.parse(avg.toStringAsFixed(1));
          }
        }

        final attendance = await db.attendanceDao.getAttendanceByStudent(
          studentId: student.id,
          startDate: dateRange.start,
          endDate: dateRange.end,
        );

        int hadir = 0, izin = 0, sakit = 0, alpa = 0;
        for (final a in attendance) {
          switch (a.status.toLowerCase()) {
            case 'hadir': hadir++; break;
            case 'izin': izin++; break;
            case 'sakit': sakit++; break;
            case 'alpa': alpa++; break;
          }
        }

        studentsData.add({
          'id': student.id,
          'nis': student.nis,
          'fullName': student.fullName,
          'className': student.className,
          'grades': gradeMap,
          'attendance': {
            'hadir': hadir,
            'izin': izin,
            'sakit': sakit,
            'alpa': alpa,
          },
        });
      }

      studentsData.sort((a, b) {
        final avgA = (a['grades'] as Map<String, double>).isEmpty ? 0.0 :
          (a['grades'] as Map<String, double>).values.fold<double>(0, (s, v) => s + v) /
          (a['grades'] as Map<String, double>).length;
        final avgB = (b['grades'] as Map<String, double>).isEmpty ? 0.0 :
          (b['grades'] as Map<String, double>).values.fold<double>(0, (s, v) => s + v) /
          (b['grades'] as Map<String, double>).length;
        return avgB.compareTo(avgA);
      });

      final filePath = await ExcelGenerator.generateReport(
        semester: semester,
        className: className,
        students: studentsData,
        subjects: subjects.map((s) => s.name).toList(),
      );

      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('File Excel tersimpan: $filePath'),
            action: SnackBarAction(
              label: 'OK',
              onPressed: () {},
            ),
          ),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Gagal export: $e')),
        );
      }
    }
  }

  Future<void> _generateReport(BuildContext context, Student student) async {
    try {
      final db = context.read<AppDatabase>();
      final grades = await db.gradeDao.getGradesByStudent(student.id);
      final allPoints = await db.pointDao.getPointsByStudent(student.id);
      final achievementPoints = allPoints
          .where((p) => p.type == 'ACHIEVEMENT')
          .fold<int>(0, (sum, p) => sum + p.pointValue);
      final violationPoints = allPoints
          .where((p) => p.type == 'VIOLATION')
          .fold<int>(0, (sum, p) => sum + p.pointValue);
      final semester = SemesterUtils.currentSemester();
      final ranking = await db.gradeDao.getRanking(semester);
      final rankIndex = ranking.indexWhere((r) => r.studentId == student.id);

      final subjects = await db.subjectDao.getAllSubjects();
      final gradeData = <Map<String, dynamic>>[];
      for (final subject in subjects) {
        final subjectGrades = grades.where((g) => g.subjectId == subject.id).toList();
        if (subjectGrades.isNotEmpty) {
          double avgOfType(String type) {
            final list = subjectGrades.where((g) => g.examType == type).toList();
            if (list.isEmpty) return 0;
            return list.fold<double>(0, (sum, g) => sum + g.score) / list.length;
          }

          final avg = subjectGrades.fold<double>(0, (sum, g) => sum + g.score) / subjectGrades.length;
          gradeData.add({
            'subject': subject.name,
            'uts': avgOfType('UTS'),
            'uas': avgOfType('UAS'),
            'tugas': avgOfType('Tugas'),
            'average': avg,
          });
        }
      }

      final pdf = await PdfGenerator.generateReportCard(
        studentName: student.fullName,
        nis: student.nis,
        className: student.className,
        semester: semester,
        grades: gradeData,
        totalViolationPoints: violationPoints.abs(),
        totalAchievementPoints: achievementPoints,
        rank: rankIndex >= 0 ? rankIndex + 1 : ranking.length + 1,
        totalStudents: ranking.length,
      );

      if (pdf != null && context.mounted) {
        await Printing.layoutPdf(onLayout: (format) => pdf);
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Gagal cetak rapor: $e')),
        );
      }
    }
  }
}
