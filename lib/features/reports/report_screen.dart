import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:printing/printing.dart';
import 'package:kelasfun/core/database/app_database.dart';
import 'package:kelasfun/core/utils/pdf_generator.dart';
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
