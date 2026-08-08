import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:printing/printing.dart';
import 'package:kelasfun/core/database/app_database.dart';
import 'package:kelasfun/core/utils/pdf_generator.dart';
import 'package:kelasfun/core/utils/excel_generator.dart';
import 'package:kelasfun/shared/widgets/app_card.dart';

class ReportScreen extends StatelessWidget {
  const ReportScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Laporan & Cetak')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _buildSection(
            title: 'Form Biodata Siswa',
            subtitle: 'Cetak form lengkap untuk arsip',
            icon: Icons.person,
            onTap: () => _printBiodata(context),
          ),
          _buildSection(
            title: 'Kartu QR Siswa',
            subtitle: 'Cetak kartu barcode untuk presensi',
            icon: Icons.qr_code,
            onTap: () => _printStudentCards(context),
          ),
          _buildSection(
            title: 'Rapor Digital',
            subtitle: 'Cetak rapor per siswa',
            icon: Icons.description,
            onTap: () => _selectStudentForReport(context),
          ),
          _buildSection(
            title: 'Cetak Semua Rapor',
            subtitle: 'Cetak rapor semua siswa dalam satu file',
            icon: Icons.print,
            onTap: () => _showBatchReportDialog(context),
          ),
          _buildSection(
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
    required String title,
    required String subtitle,
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return AppCard(
      onTap: onTap,
      child: Row(
        children: [
          CircleAvatar(
            backgroundColor: const Color(0xFF5B9BD5),
            child: Icon(icon, color: Colors.white),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                Text(subtitle, style: const TextStyle(color: Colors.grey)),
              ],
            ),
          ),
          const Icon(Icons.print, color: Color(0xFF5B9BD5)),
        ],
      ),
    );
  }

  Future<void> _printBiodata(BuildContext context) async {
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
      if (pdf != null) {
        await Printing.layoutPdf(onLayout: (format) => pdf);
      }
    }
  }

  Future<void> _printStudentCards(BuildContext context) async {
    final db = context.read<AppDatabase>();
    final students = await db.studentDao.getAllStudents();

    final studentData = students.map((s) => {
      'nis': s.nis,
      'name': s.fullName,
      'class': s.className,
    }).toList();

    final pdf = await PdfGenerator.generateStudentCards(students: studentData);
    if (pdf != null) {
      await Printing.layoutPdf(onLayout: (format) => pdf);
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
    String selectedClass = 'X RPL 1';
    String selectedSemester = 'Ganjil 2025/2026';

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setState) => AlertDialog(
          title: const Text('Cetak Semua Rapor'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              DropdownButtonFormField<String>(
                value: selectedClass,
                decoration: const InputDecoration(labelText: 'Kelas', border: OutlineInputBorder()),
                items: const [
                  DropdownMenuItem(value: 'X RPL 1', child: Text('X RPL 1')),
                  DropdownMenuItem(value: 'X RPL 2', child: Text('X RPL 2')),
                  DropdownMenuItem(value: 'XI RPL 1', child: Text('XI RPL 1')),
                  DropdownMenuItem(value: 'XI RPL 2', child: Text('XI RPL 2')),
                ],
                onChanged: (v) => setState(() => selectedClass = v ?? selectedClass),
              ),
              const SizedBox(height: 12),
              DropdownButtonFormField<String>(
                value: selectedSemester,
                decoration: const InputDecoration(labelText: 'Semester', border: OutlineInputBorder()),
                items: const [
                  DropdownMenuItem(value: 'Ganjil 2025/2026', child: Text('Ganjil 2025/2026')),
                  DropdownMenuItem(value: 'Genap 2025/2026', child: Text('Genap 2025/2026')),
                ],
                onChanged: (v) => setState(() => selectedSemester = v ?? selectedSemester),
              ),
            ],
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Batal')),
            FilledButton(
              onPressed: () {
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

    for (final student in classStudents) {
      final grades = await db.gradeDao.getGradesByStudentSemester(student.id, semester);
      final totalPoints = await db.pointDao.getTotalPoints(student.id);
      final ranking = await db.gradeDao.getRanking(semester);
      final rankIndex = ranking.indexWhere((r) => r.studentId == student.id);

      final subjects = await db.subjectDao.getAllSubjects();
      final gradeData = <Map<String, dynamic>>[];
      for (final subject in subjects) {
        final subjectGrades = grades.where((g) => g.subjectId == subject.id).toList();
        if (subjectGrades.isNotEmpty) {
          final avg = subjectGrades.fold<double>(0, (sum, g) => sum + g.score) / subjectGrades.length;
          gradeData.add({
            'subject': subject.name,
            'uts': subjectGrades.where((g) => g.examType == 'UTS').fold<double>(0, (sum, g) => sum + g.score),
            'uas': subjectGrades.where((g) => g.examType == 'UAS').fold<double>(0, (sum, g) => sum + g.score),
            'tugas': subjectGrades.where((g) => g.examType == 'Tugas').fold<double>(0, (sum, g) => sum + g.score),
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
        totalViolationPoints: totalPoints < 0 ? totalPoints.abs() : 0,
        totalAchievementPoints: totalPoints > 0 ? totalPoints : 0,
        rank: rankIndex >= 0 ? rankIndex + 1 : ranking.length + 1,
        totalStudents: ranking.length,
      );

      if (pdf != null) {
        await Printing.layoutPdf(onLayout: (format) => pdf);
      }
    }

    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Rapor ${classStudents.length} siswa selesai dicetak')),
      );
    }
  }

  void _showExcelExportDialog(BuildContext context) {
    String selectedSemester = 'Ganjil 2025/2026';
    String selectedClass = 'X RPL 1';

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setState) => AlertDialog(
          title: const Text('Export ke Excel'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              DropdownButtonFormField<String>(
                value: selectedSemester,
                decoration: const InputDecoration(
                  labelText: 'Semester',
                  border: OutlineInputBorder(),
                ),
                items: const [
                  DropdownMenuItem(value: 'Ganjil 2025/2026', child: Text('Ganjil 2025/2026')),
                  DropdownMenuItem(value: 'Genap 2025/2026', child: Text('Genap 2025/2026')),
                  DropdownMenuItem(value: 'Ganjil 2024/2025', child: Text('Ganjil 2024/2025')),
                  DropdownMenuItem(value: 'Genap 2024/2025', child: Text('Genap 2024/2025')),
                ],
                onChanged: (v) => setState(() => selectedSemester = v ?? selectedSemester),
              ),
              const SizedBox(height: 12),
              DropdownButtonFormField<String>(
                value: selectedClass,
                decoration: const InputDecoration(
                  labelText: 'Kelas',
                  border: OutlineInputBorder(),
                ),
                items: const [
                  DropdownMenuItem(value: 'X RPL 1', child: Text('X RPL 1')),
                  DropdownMenuItem(value: 'X RPL 2', child: Text('X RPL 2')),
                  DropdownMenuItem(value: 'XI RPL 1', child: Text('XI RPL 1')),
                  DropdownMenuItem(value: 'XI RPL 2', child: Text('XI RPL 2')),
                ],
                onChanged: (v) => setState(() => selectedClass = v ?? selectedClass),
              ),
            ],
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
    if (!context.mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Menyiapkan data...')),
    );

    final db = context.read<AppDatabase>();
    final students = await db.studentDao.getAllStudents();
    final subjects = await db.subjectDao.getAllSubjects();

    final studentsData = <Map<String, dynamic>>[];

    for (final student in students) {
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
        startDate: '2025-01-01',
        endDate: '2025-12-31',
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

    try {
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
    final db = context.read<AppDatabase>();
    final grades = await db.gradeDao.getGradesByStudent(student.id);
    final totalPoints = await db.pointDao.getTotalPoints(student.id);
    final ranking = await db.gradeDao.getRanking('Ganjil 2025/2026');
    final rankIndex = ranking.indexWhere((r) => r.studentId == student.id);

    final subjects = await db.subjectDao.getAllSubjects();
    final gradeData = <Map<String, dynamic>>[];
    for (final subject in subjects) {
      final subjectGrades = grades.where((g) => g.subjectId == subject.id).toList();
      if (subjectGrades.isNotEmpty) {
        final avg = subjectGrades.fold<double>(0, (sum, g) => sum + g.score) / subjectGrades.length;
        gradeData.add({
          'subject': subject.name,
          'uts': subjectGrades.where((g) => g.examType == 'UTS').fold<double>(0, (sum, g) => sum + g.score),
          'uas': subjectGrades.where((g) => g.examType == 'UAS').fold<double>(0, (sum, g) => sum + g.score),
          'tugas': subjectGrades.where((g) => g.examType == 'Tugas').fold<double>(0, (sum, g) => sum + g.score),
          'average': avg,
        });
      }
    }

    final pdf = await PdfGenerator.generateReportCard(
      studentName: student.fullName,
      nis: student.nis,
      className: student.className,
      semester: 'Ganjil 2025/2026',
      grades: gradeData,
      totalViolationPoints: totalPoints < 0 ? totalPoints.abs() : 0,
      totalAchievementPoints: totalPoints > 0 ? totalPoints : 0,
      rank: rankIndex >= 0 ? rankIndex + 1 : ranking.length + 1,
      totalStudents: ranking.length,
    );

    if (pdf != null && context.mounted) {
      await Printing.layoutPdf(onLayout: (format) => pdf);
    }
  }
}
