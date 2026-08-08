import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:kelasfun/core/database/app_database.dart';
import 'package:kelasfun/core/theme/app_theme.dart';
import 'package:kelasfun/shared/widgets/app_card.dart';
import 'package:kelasfun/shared/widgets/app_button.dart';
import 'package:kelasfun/features/students/student_form_screen.dart';

class StudentDetailScreen extends StatelessWidget {
  final Student student;
  const StudentDetailScreen({super.key, required this.student});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(student.fullName),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit),
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => StudentFormScreen(student: student),
              ),
            ),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _QRPreview(student: student),
          const SizedBox(height: 16),
          _BiodataCard(student: student),
          const SizedBox(height: 16),
          _PrintActionsCard(student: student),
        ],
      ),
    );
  }
}

class _QRPreview extends StatelessWidget {
  final Student student;
  const _QRPreview({required this.student});

  @override
  Widget build(BuildContext context) {
    return AppCard(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppTheme.textPrimary,
                borderRadius: BorderRadius.circular(12),
              ),
              child: QrImageView(
                data: student.qrData,
                version: QrVersions.auto,
                size: 180,
                eyeStyle: const QrEyeStyle(
                  eyeShape: QrEyeShape.circle,
                  color: AppTheme.background,
                ),
                dataModuleStyle: const QrDataModuleStyle(
                  dataModuleShape: QrDataModuleShape.circle,
                  color: AppTheme.background,
                ),
              ),
            ),
            const SizedBox(height: 12),
            Text(student.fullName,
                style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                    color: AppTheme.textPrimary)),
            Text('NIS: ${student.nis}',
                style: const TextStyle(color: AppTheme.textSecondary)),
          ],
        ),
      ),
    );
  }
}

class _BiodataCard extends StatelessWidget {
  final Student student;
  const _BiodataCard({required this.student});

  @override
  Widget build(BuildContext context) {
    return AppCard(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Biodata Lengkap',
                style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                    color: AppTheme.textPrimary)),
            const Divider(),
            _InfoRow(label: 'NIS', value: student.nis),
            _InfoRow(label: 'Nama Lengkap', value: student.fullName),
            _InfoRow(label: 'Kelas', value: student.className),
            _InfoRow(label: 'Jenis Kelamin', value: student.gender),
            _InfoRow(
                label: 'Tanggal Lahir',
                value: student.birthDate?.isNotEmpty == true
                    ? student.birthDate!
                    : '-'),
            _InfoRow(
                label: 'Alamat',
                value: student.address?.isNotEmpty == true
                    ? student.address!
                    : '-'),
            _InfoRow(
                label: 'Nama Orang Tua',
                value: student.parentName?.isNotEmpty == true
                    ? student.parentName!
                    : '-'),
            _InfoRow(
                label: 'No. HP Orang Tua',
                value: student.parentPhone?.isNotEmpty == true
                    ? student.parentPhone!
                    : '-'),
          ],
        ),
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
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 140,
            child: Text(label, style: const TextStyle(color: AppTheme.textSecondary)),
          ),
          Expanded(
            child: Text(value,
                style: const TextStyle(
                    fontWeight: FontWeight.w500, color: AppTheme.textPrimary)),
          ),
        ],
      ),
    );
  }
}

class _PrintActionsCard extends StatelessWidget {
  final Student student;
  const _PrintActionsCard({required this.student});

  @override
  Widget build(BuildContext context) {
    return AppCard(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Cetak',
                style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                    color: AppTheme.textPrimary)),
            const SizedBox(height: 16),
            AppButton(
              label: 'Cetak Kartu KTP (10/A4)',
              icon: Icons.print,
              onPressed: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Cetak Kartu KTP - Fitur dalam pengembangan')),
                );
              },
            ),
            const SizedBox(height: 12),
            AppButton(
              label: 'Cetak Biodata (A4)',
              icon: Icons.print,
              isOutlined: true,
              onPressed: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Cetak Biodata - Fitur dalam pengembangan')),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
