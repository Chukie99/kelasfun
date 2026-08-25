import 'dart:io';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:package_info_plus/package_info_plus.dart';
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


/// Server sinkronisasi LAN dibuat SINGLETON global: dulu disimpan di
/// State layar Pengaturan -> keluar layar = referensi hilang, server
/// HTTP tetap jalan di background tapi tak bisa dihentikan, dan start
/// berikutnya gagal bind (port dipakai).
SyncServer? _globalSyncServer;

class _SettingsScreenState extends State<SettingsScreen> {
  bool _serverRunning = false;
  String _serverUrl = '';
  String _localIp = '';
  String _apiKey = '';
  String _appVersion = '';

  @override
  void initState() {
    super.initState();
    _loadServerStatus();
    _loadAppVersion();
  }

  // Versi asli dari pubspec — dulu hardcode "v1.0.0" padahal app sudah
  // v1.3.4+5, menyulitkan dukungan teknis.
  Future<void> _loadAppVersion() async {
    final info = await PackageInfo.fromPlatform();
    if (!mounted) return;
    setState(() => _appVersion = 'kelasFun v${info.version}+${info.buildNumber}');
  }

  String _generateApiKey() {
    final random = Random.secure();
    final values = List<int>.generate(32, (_) => random.nextInt(256));
    return values.map((b) => b.toRadixString(16).padLeft(2, '0')).join();
  }

  Future<String> _getOrCreateApiKey() async {
    final db = context.read<AppDatabase>();
    final existing = await db.settingsDao.getSetting('api_key');
    if (existing != null && existing.isNotEmpty) return existing;
    final newKey = _generateApiKey();
    await db.settingsDao.setSetting('api_key', newKey);
    return newKey;
  }

  Future<void> _loadServerStatus() async {
    final ip = await NetworkUtils.getLocalIp();
    if (!mounted) return;
    setState(() => _localIp = ip);
  }

  Future<void> _toggleServer() async {
    try {
      final db = context.read<AppDatabase>();

      if (_serverRunning) {
        await _globalSyncServer?.stop();
        _globalSyncServer = null;
        if (!mounted) return;
        setState(() {
          _serverRunning = false;
          _serverUrl = '';
        });
      } else {
        final apiKey = await _getOrCreateApiKey();
        _apiKey = apiKey;
        // Pakai instance global: layar ditutup pun server tetap hidup
        // DAN tetap bisa di-stop kapan pun dari layar ini.
        await _globalSyncServer?.stop();
        _globalSyncServer = SyncServer(
          db: db,
          apiKey: apiKey,
        );
        await _globalSyncServer!.start();
        if (!mounted) return;
        setState(() {
          _serverRunning = true;
          _serverUrl = 'http://$_localIp:8080';
        });
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error server: $e')),
        );
      }
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
                token: _apiKey,
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
                const SizedBox(height: AppTheme.spacingBase),
                Text(_appVersion.isNotEmpty ? _appVersion : 'kelasFun',
                    style: AppTheme.body(context)),
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
      final db = context.read<AppDatabase>();
      final directory = await FilePicker.platform.getDirectoryPath(
        dialogTitle: 'Pilih lokasi backup',
      );
      if (directory != null) {
        // VACUUM INTO menghasilkan snapshot bersih yang SELALU mencakup
        // transaksi terakhir — dulu cuma copy file .db sehingga data yang
        // masih di file -wal bisa lolos dari backup.
        final stamp = DateTime.now().toIso8601String().substring(0, 10);
        final targetPath = '$directory/kelasfun_backup_$stamp.db';
        await db.customStatement('VACUUM INTO ?', [targetPath]);
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Backup berhasil: $targetPath')),
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
      final db = context.read<AppDatabase>();
      final result = await FilePicker.platform.pickFiles(
        dialogTitle: 'Pilih file backup',
        type: FileType.any,
      );
      if (result == null || result.files.single.path == null) return;

      // Konfirmasi dulu — restore menimpa SEMUA data saat ini.
      final confirmed = await showDialog<bool>(
        context: context,
        builder: (ctx) => AlertDialog(
          title: Text('Restore database?', style: AppTheme.h3(context)),
          content: Text(
            'Semua data saat ini akan DIGANTI dengan isi file backup. Aplikasi akan menutup database dan perlu direstart setelahnya. Lanjutkan?',
            style: AppTheme.body(context),
          ),
          actions: [
            TextButton(
                onPressed: () => Navigator.pop(ctx, false),
                child: const Text('Batal')),
            FilledButton(
                onPressed: () => Navigator.pop(ctx, true),
                child: const Text('Ya, Restore')),
          ],
        ),
      );
      if (confirmed != true || !context.mounted) return;

      // TUTUP koneksi drift SEBELUM menimpa file. Dulu file ditimpa
      // padahal DB sedang terbuka + WAL aktif -> korupsi / data campur.
      final dbPath = await db.getDatabasePath();
      await db.close();

      final sourceFile = File(result.files.single.path!);
      final targetFile = File(dbPath);
      // Hapus sisa journal lama supaya tidak "menempel" ke backup baru.
      for (final suffix in ['-wal', '-shm']) {
        final j = File('$dbPath$suffix');
        if (j.existsSync()) j.delete();
      }
      await sourceFile.copy(targetFile.path);

      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Restore berhasil! Tutup dan buka kembali aplikasi.'),
            duration: Duration(seconds: 5),
          ),
        );
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
    if (!mounted) return;
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
    try {
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
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Gagal menyimpan profil: $e')),
        );
      }
    }
  }
}
