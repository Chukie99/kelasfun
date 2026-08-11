import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:file_picker/file_picker.dart';
import 'package:kelasfun/core/database/app_database.dart';
import 'package:kelasfun/core/sync/sync_server.dart';
import 'package:kelasfun/core/theme/app_theme.dart';
import 'package:kelasfun/core/utils/network_utils.dart';
import 'package:kelasfun/shared/widgets/app_card.dart';
import 'package:kelasfun/shared/widgets/app_button.dart';
import 'package:kelasfun/shared/widgets/app_text_field.dart';
import 'package:kelasfun/features/settings/widgets/server_section.dart';
import 'package:kelasfun/features/settings/widgets/pairing_qr.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  SyncServer? _server;
  bool _serverRunning = false;
  String _serverUrl = '';
  String _localIp = '';

  @override
  void initState() {
    super.initState();
    _loadServerStatus();
  }

  Future<void> _loadServerStatus() async {
    final ip = await NetworkUtils.getLocalIp();
    setState(() => _localIp = ip);
  }

  Future<void> _toggleServer() async {
    final db = context.read<AppDatabase>();

    if (_serverRunning) {
      await _server?.stop();
      setState(() {
        _serverRunning = false;
        _serverUrl = '';
      });
    } else {
      _server = SyncServer(
        db: db,
        apiKey: 'kelasfun-secret-key',
      );
      await _server!.start();
      setState(() {
        _serverRunning = true;
        _serverUrl = 'http://$_localIp:8080';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Pengaturan')),
      body: ListView(
        padding: const EdgeInsets.all(AppTheme.spacingBase),
        children: [
          AppCard(
            child: _SchoolProfileSection(),
          ),
          const SizedBox(height: AppTheme.spacingBase),
          AppCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Tema Aplikasi', style: AppTheme.h2(context)),
                const SizedBox(height: AppTheme.spacingSm),
                Text('Pilih mode tampilan', style: AppTheme.bodySmall(context)),
                const SizedBox(height: AppTheme.spacingSm),
                ListTile(
                  leading: Icon(Icons.palette, color: AppTheme.accent),
                  title: Text('Mode Tema', style: AppTheme.body(context)),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () => _showThemeDialog(context),
                ),
              ],
            ),
          ),
          const SizedBox(height: AppTheme.spacingBase),
          AppCard(
            child: ServerSection(
              isRunning: _serverRunning,
              serverUrl: _serverUrl,
              onToggle: _toggleServer,
            ),
          ),
          if (_serverRunning) ...[
            const SizedBox(height: AppTheme.spacingBase),
            AppCard(
              child: PairingQr(
                ip: _localIp,
                port: 8080,
                token: 'kelasfun-secret-key',
              ),
            ),
          ],
          const SizedBox(height: AppTheme.spacingBase),
          AppCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Backup & Restore', style: AppTheme.h2(context)),
                const SizedBox(height: AppTheme.spacingBase),
                AppButton(
                  label: 'Backup Database',
                  icon: Icons.backup,
                  onPressed: () => _backupDatabase(context),
                ),
                const SizedBox(height: AppTheme.spacingBase),
                AppButton(
                  label: 'Restore Database',
                  icon: Icons.restore,
                  isOutlined: true,
                  onPressed: () => _restoreDatabase(context),
                ),
              ],
            ),
          ),
          const SizedBox(height: AppTheme.spacingBase),
          AppCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Tentang', style: AppTheme.h2(context)),
                const SizedBox(height: AppTheme.spacingSm),
                Text('kelasFun v1.0.0', style: AppTheme.body(context)),
                Text('Aplikasi Manajemen Kelas Offline-First',
                    style: AppTheme.bodySmall(context)),
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

  void _showThemeDialog(BuildContext context) {
    final db = context.read<AppDatabase>();
    showDialog(
      context: context,
      builder: (ctx) => StreamBuilder<String?>(
        stream: db.settingsDao.watchSetting('theme_mode'),
        builder: (context, snapshot) {
          final current = snapshot.data ?? 'dark';
          return AlertDialog(
            title: Text('Mode Tema', style: AppTheme.h3(context)),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                RadioListTile<String>(
                  title: Text('Gelap', style: AppTheme.body(context)),
                  value: 'dark',
                  groupValue: current,
                  onChanged: (v) async {
                    await db.settingsDao.setSetting('theme_mode', v!);
                    if (ctx.mounted) Navigator.pop(ctx);
                  },
                ),
                RadioListTile<String>(
                  title: Text('Terang', style: AppTheme.body(context)),
                  value: 'light',
                  groupValue: current,
                  onChanged: (v) async {
                    await db.settingsDao.setSetting('theme_mode', v!);
                    if (ctx.mounted) Navigator.pop(ctx);
                  },
                ),
                RadioListTile<String>(
                  title: Text('Sistem', style: AppTheme.body(context)),
                  value: 'system',
                  groupValue: current,
                  onChanged: (v) async {
                    await db.settingsDao.setSetting('theme_mode', v!);
                    if (ctx.mounted) Navigator.pop(ctx);
                  },
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

class _SchoolProfileSection extends StatefulWidget {
  @override
  State<_SchoolProfileSection> createState() => _SchoolProfileSectionState();
}

class _SchoolProfileSectionState extends State<_SchoolProfileSection> {
  final _nameController = TextEditingController();
  final _addressController = TextEditingController();
  final _cityController = TextEditingController();
  final _provinceController = TextEditingController();
  final _phoneController = TextEditingController();
  final _emailController = TextEditingController();
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadProfile();
  }

  Future<void> _loadProfile() async {
    final db = context.read<AppDatabase>();
    final settings = await db.settingsDao.getAllSettings();
    _nameController.text = settings['school_name'] ?? '';
    _addressController.text = settings['school_address'] ?? '';
    _cityController.text = settings['school_city'] ?? '';
    _provinceController.text = settings['school_province'] ?? '';
    _phoneController.text = settings['school_phone'] ?? '';
    _emailController.text = settings['school_email'] ?? '';
    setState(() => _isLoading = false);
  }

  @override
  void dispose() {
    _nameController.dispose();
    _addressController.dispose();
    _cityController.dispose();
    _provinceController.dispose();
    _phoneController.dispose();
    _emailController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Padding(
        padding: EdgeInsets.all(AppTheme.spacingBase),
        child: Center(child: CircularProgressIndicator()),
      );
    }

    return Padding(
      padding: const EdgeInsets.all(AppTheme.spacingBase),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Profil Sekolah', style: AppTheme.h2(context)),
          const SizedBox(height: AppTheme.spacingBase),
          AppTextField(
            label: 'Nama Sekolah',
            controller: _nameController,
            onChanged: (_) {},
          ),
          AppTextField(
            label: 'Alamat',
            controller: _addressController,
            onChanged: (_) {},
          ),
          AppTextField(
            label: 'Kota/Kabupaten',
            controller: _cityController,
            onChanged: (_) {},
          ),
          AppTextField(
            label: 'Provinsi',
            controller: _provinceController,
            onChanged: (_) {},
          ),
          AppTextField(
            label: 'No. Telepon',
            controller: _phoneController,
            onChanged: (_) {},
          ),
          AppTextField(
            label: 'Email',
            controller: _emailController,
            onChanged: (_) {},
          ),
          const SizedBox(height: AppTheme.spacingBase),
          AppButton(
            label: 'Simpan Profil',
            icon: Icons.save,
            onPressed: _saveProfile,
          ),
        ],
      ),
    );
  }

  Future<void> _saveProfile() async {
    final db = context.read<AppDatabase>();
    await db.settingsDao.setSchoolProfile(
      name: _nameController.text,
      address: _addressController.text,
      city: _cityController.text,
      province: _provinceController.text,
      phone: _phoneController.text,
      email: _emailController.text,
    );
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Profil sekolah berhasil disimpan')),
      );
    }
  }
}
