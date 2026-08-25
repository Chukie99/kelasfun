import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:printing/printing.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:kelasfun/core/database/app_database.dart';
import 'package:kelasfun/core/theme/app_theme.dart';
import 'package:kelasfun/core/utils/photo_helper.dart';
import 'package:kelasfun/core/utils/pdf_generator.dart';
import 'package:kelasfun/shared/widgets/app_card.dart';
import 'package:kelasfun/shared/widgets/app_button.dart';
import 'package:kelasfun/features/students/student_form_screen.dart';

class StudentDetailScreen extends StatelessWidget {
  final Student student;
  const StudentDetailScreen({super.key, required this.student});

  @override
  Widget build(BuildContext context) {
    final db = context.read<AppDatabase>();
    return StreamBuilder<Student>(
      // Live-watch: setelah edit disimpan lalu kembali ke layar ini,
      // seluruh tampilan otomatis memakai data TERBARU dari database.
      // Dulu render dari objek statis -> detail selalu data lama.
      stream: db.studentDao.watchStudentById(student.id),
      initialData: student,
      builder: (context, snapshot) {
        final current = snapshot.data ?? student;
        return Scaffold(
          appBar: AppBar(
            title: Text(current.fullName),
            actions: [
              IconButton(
                icon: const Icon(Icons.edit),
                onPressed: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => StudentFormScreen(student: current),
                  ),
                ),
              ),
            ],
          ),
          body: ListView(
            padding: const EdgeInsets.all(AppTheme.spacingBase),
            children: [
              _PhotoPreview(student: current),
              const SizedBox(height: AppTheme.spacingBase),
              _QRPreview(student: current),
              const SizedBox(height: AppTheme.spacingBase),
              _BiodataCard(student: current),
              const SizedBox(height: AppTheme.spacingBase),
              _PrintActionsCard(student: current),
              const SizedBox(height: AppTheme.spacingBase),
              _ArchiveCard(student: current),
            ],
          ),
        );
      },
    );
  }
}

class _PhotoPreview extends StatelessWidget {
  final Student student;
  const _PhotoPreview({required this.student});

  @override
  Widget build(BuildContext context) {
    final initials = PhotoHelper.getInitials(student.fullName);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final accentColor = isDark ? AppTheme.accent : AppTheme.lightAccent;
    final accentSoftColor = isDark ? AppTheme.accentSoft : AppTheme.lightAccentSoft;

    Widget avatar = CircleAvatar(
      radius: 60,
      backgroundColor: accentSoftColor,
      child: Text(
        initials,
        style: AppTheme.h1(context).copyWith(color: accentColor),
      ),
    );

    if (student.photoPath != null && student.photoPath!.isNotEmpty) {
      try {
        final file = File(student.photoPath!);
        if (file.existsSync()) {
          avatar = CircleAvatar(
            radius: 60,
            backgroundImage: FileImage(file),
          );
        }
      } catch (_) {}
    }

    return AppCard(
      child: Center(child: avatar),
    );
  }
}

class _QRPreview extends StatelessWidget {
  final Student student;
  const _QRPreview({required this.student});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bgColor = isDark ? AppTheme.textPrimary : AppTheme.lightTextPrimary;
    final fgColor = isDark ? AppTheme.background : AppTheme.lightBackground;

    return AppCard(
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(AppTheme.spacingBase),
            decoration: BoxDecoration(
              color: bgColor,
              borderRadius: BorderRadius.circular(AppTheme.radiusCard),
            ),
            child: QrImageView(
              data: student.qrData,
              version: QrVersions.auto,
              size: 180,
              eyeStyle: QrEyeStyle(
                eyeShape: QrEyeShape.circle,
                color: fgColor,
              ),
              dataModuleStyle: QrDataModuleStyle(
                dataModuleShape: QrDataModuleShape.circle,
                color: fgColor,
              ),
            ),
          ),
          const SizedBox(height: AppTheme.spacingMd),
          Text(student.fullName, style: AppTheme.h3(context)),
          Text('NIS: ${student.nis}', style: AppTheme.bodySmall(context)),
        ],
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Biodata Lengkap', style: AppTheme.h3(context)),
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
          if (student.notes != null && student.notes!.isNotEmpty) ...[
            const Divider(),
            Text('Catatan:', style: AppTheme.caption(context)),
            Text(student.notes!, style: AppTheme.body(context)),
          ],
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

class _PrintActionsCard extends StatelessWidget {
  final Student student;
  const _PrintActionsCard({required this.student});

  Future<void> _printStudentCard(BuildContext context) async {
    try {
      final db = context.read<AppDatabase>();
      Uint8List? photoBytes;
      if (student.photoPath != null && student.photoPath!.isNotEmpty) {
        final file = File(student.photoPath!);
        if (file.existsSync()) {
          photoBytes = await file.readAsBytes();
        }
      }

      final studentData = {
        'nis': student.nis,
        'name': student.fullName,
        'class': student.className,
        'photoBytes': photoBytes,
      };

      final schoolName = await db.settingsDao.getSetting('school_name');

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

  Future<void> _printBiodata(BuildContext context) async {
    try {
      final db = context.read<AppDatabase>();
      final schoolName = await db.settingsDao.getSetting('school_name');

      final pdf = await PdfGenerator.generateBiodata(
        nis: student.nis,
        fullName: student.fullName,
        className: student.className,
        gender: student.gender,
        birthDate: student.birthDate,
        address: student.address,
        parentName: student.parentName,
        parentPhone: student.parentPhone,
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
    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Cetak', style: AppTheme.h3(context)),
          const SizedBox(height: AppTheme.spacingBase),
          AppButton(
            label: 'Cetak Kartu Siswa',
            icon: Icons.print,
            onPressed: () => _printStudentCard(context),
          ),
          const SizedBox(height: AppTheme.spacingMd),
          AppButton(
            label: 'Cetak Biodata (A4)',
            icon: Icons.print,
            isOutlined: true,
            onPressed: () => _printBiodata(context),
          ),
        ],
      ),
    );
  }
}

class _ArchiveCard extends StatelessWidget {
  final Student student;
  const _ArchiveCard({required this.student});

  @override
  Widget build(BuildContext context) {
    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Arsip', style: AppTheme.h3(context)),
          const SizedBox(height: AppTheme.spacingBase),
          OutlinedButton.icon(
            onPressed: () async {
              final confirm = await showDialog<bool>(
                context: context,
                builder: (ctx) => AlertDialog(
                  title: const Text('Arsipkan Siswa?'),
                  content: Text(
                      'Apakah Anda yakin ingin mengarsipkan ${student.fullName}? Siswa yang diarsipkan tidak akan muncul di daftar aktif.'),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(ctx, false),
                      child: const Text('Batal'),
                    ),
                    TextButton(
                      onPressed: () => Navigator.pop(ctx, true),
                      child: const Text('Arsipkan'),
                    ),
                  ],
                ),
              );
              if (confirm == true && context.mounted) {
                final db = context.read<AppDatabase>();
                try {
                  await db.studentDao.softDeleteStudent(student.id);
                  if (context.mounted) Navigator.pop(context);
                } catch (e, stackTrace) {
                  debugPrint('SOFT DELETE ERROR: $e');
                  debugPrint('STACK TRACE: $stackTrace');
                }
              }
            },
            icon: const Icon(Icons.archive),
            label: const Text('Arsipkan'),
          ),
        ],
      ),
    );
  }
}
