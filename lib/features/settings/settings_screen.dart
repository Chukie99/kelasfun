import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:file_picker/file_picker.dart';
import 'package:kelasfun/core/database/app_database.dart';
import 'package:kelasfun/shared/widgets/app_card.dart';
import 'package:kelasfun/shared/widgets/app_button.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Pengaturan')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          AppCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Backup & Restore', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
                const SizedBox(height: 16),
                const Text('Backup database ke flashdisk untuk keamanan data'),
                const SizedBox(height: 8),
                AppButton(
                  label: 'Backup Database',
                  icon: Icons.backup,
                  onPressed: () => _backupDatabase(context),
                ),
                const SizedBox(height: 16),
                const Divider(),
                const SizedBox(height: 16),
                const Text('Restore database dari file backup'),
                const SizedBox(height: 8),
                AppButton(
                  label: 'Restore Database',
                  icon: Icons.restore,
                  isOutlined: true,
                  onPressed: () => _restoreDatabase(context),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          AppCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Tentang', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
                const SizedBox(height: 8),
                const Text('kelasFun v1.0.0'),
                const Text('Aplikasi Manajemen Kelas Offline-First'),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _backupDatabase(BuildContext context) async {
    try {
      final directory = await FilePicker.platform.getDirectoryPath(
        dialogTitle: 'Pilih lokasi backup',
      );
      if (directory != null) {
        final db = context.read<AppDatabase>();
        final dbPath = await db.getDatabasePath();
        final sourceFile = File(dbPath);
        final targetFile = File('$directory/kelasfun_backup.db');
        await sourceFile.copy(targetFile.path);
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Backup berhasil: ${targetFile.path}')),
          );
        }
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Backup gagal: $e')),
        );
      }
    }
  }

  Future<void> _restoreDatabase(BuildContext context) async {
    try {
      final result = await FilePicker.platform.pickFiles(
        dialogTitle: 'Pilih file backup',
      );
      if (result != null && result.files.single.path != null) {
        final db = context.read<AppDatabase>();
        final dbPath = await db.getDatabasePath();
        final sourceFile = File(result.files.single.path!);
        final targetFile = File(dbPath);
        await sourceFile.copy(targetFile.path);
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Restore berhasil! Restart aplikasi.')),
          );
        }
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Restore gagal: $e')),
        );
      }
    }
  }
}
