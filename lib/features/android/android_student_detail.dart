import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:printing/printing.dart';
import 'package:kelasfun/core/theme/app_theme.dart';
import 'package:kelasfun/core/utils/pdf_generator.dart';
import 'scanner_service.dart';

class AndroidStudentDetailScreen extends StatelessWidget {
  final StudentCacheEntry student;
  final String? schoolName;

  const AndroidStudentDetailScreen({
    super.key,
    required this.student,
    this.schoolName,
  });

  Future<void> _printStudentCard(BuildContext context) async {
    try {
      final studentData = {
        'nis': student.nis,
        'name': student.name,
        'class': student.className,
        'photoBytes': null, // Android app doesn't have photo access
      };

      final pdf = await PdfGenerator.generateStudentCards(
        students: [studentData],
        schoolName: schoolName,
      );
      
      if (pdf != null && context.mounted) {
        await Printing.layoutPdf(onLayout: (format) => pdf);
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Gagal cetak: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(student.name),
      ),
      body: ListView(
        padding: const EdgeInsets.all(AppTheme.spacingBase),
        children: [
          // Student Info Card
          Card(
            child: Padding(
              padding: const EdgeInsets.all(AppTheme.spacingBase),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Biodata Siswa', style: AppTheme.h3(context)),
                  const Divider(),
                  _InfoRow(label: 'NIS', value: student.nis),
                  _InfoRow(label: 'Nama Lengkap', value: student.name),
                  _InfoRow(label: 'Kelas', value: student.className),
                ],
              ),
            ),
          ),
          const SizedBox(height: AppTheme.spacingBase),
          
          // Print Card
          Card(
            child: Padding(
              padding: const EdgeInsets.all(AppTheme.spacingBase),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Cetak', style: AppTheme.h3(context)),
                  const SizedBox(height: AppTheme.spacingBase),
                  SizedBox(
                    width: double.infinity,
                    child: FilledButton.icon(
                      onPressed: () => _printStudentCard(context),
                      icon: const Icon(Icons.print),
                      label: const Text('Cetak Kartu Siswa'),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final String label;
  final String value;
  const _InfoRow({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppTheme.spacingSm / 2),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 140,
            child: Text(label, style: AppTheme.bodySmall(context)),
          ),
          Expanded(
            child: Text(value, style: AppTheme.body(context)),
          ),
        ],
      ),
    );
  }
}
