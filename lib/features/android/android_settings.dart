import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:kelasfun/core/database/app_database.dart';
import 'package:kelasfun/core/theme/app_theme.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

class AndroidSettings extends StatefulWidget {
  const AndroidSettings({super.key});

  @override
  State<AndroidSettings> createState() => _AndroidSettingsState();
}

class _AndroidSettingsState extends State<AndroidSettings> {
  String _serverUrl = '';
  String _apiKey = '';
  bool _isConnected = false;
  bool _syncing = false;
  int _syncedCount = 0;

  @override
  void initState() {
    super.initState();
    _loadConfig();
  }

  Future<void> _loadConfig() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _serverUrl = prefs.getString('server_url') ?? '';
      _apiKey = prefs.getString('api_key') ?? '';
      _isConnected = _serverUrl.isNotEmpty;
    });
  }

  Future<void> _saveConfig() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('server_url', _serverUrl);
    await prefs.setString('api_key', _apiKey);
    setState(() => _isConnected = _serverUrl.isNotEmpty);
  }

  Future<void> _testConnection() async {
    if (_serverUrl.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Masukkan URL server dulu')),
      );
      return;
    }

    try {
      final response = await http.get(
        Uri.parse('$_serverUrl/api/health'),
        headers: {'X-API-Key': _apiKey},
      ).timeout(const Duration(seconds: 5));

      if (response.statusCode == 200) {
        await _saveConfig();
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Koneksi berhasil!'),
            backgroundColor: AppTheme.mint,
          ),
        );
      } else {
        throw Exception('Status: ${response.statusCode}');
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Koneksi gagal: $e'),
          backgroundColor: AppTheme.coral,
        ),
      );
    }
  }

  Future<void> _syncToDesktop() async {
    if (!_isConnected) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Hubungkan ke server dulu')),
      );
      return;
    }

    setState(() => _syncing = true);

    try {
      final db = context.read<AppDatabase>();
      final students = await db.studentDao.getAllStudents();

      final headers = <String, String>{
        'Content-Type': 'application/json',
        'X-API-Key': _apiKey,
      };

      var synced = 0;
      for (final student in students) {
        try {
          final response = await http.post(
            Uri.parse('$_serverUrl/api/students'),
            headers: headers,
            body: jsonEncode({
              'nis': student.nis,
              'fullName': student.fullName,
              'className': student.className,
              'gender': student.gender,
              'qrData': student.qrData,
              'birthDate': student.birthDate,
              'address': student.address,
              'parentName': student.parentName,
              'parentPhone': student.parentPhone,
            }),
          ).timeout(const Duration(seconds: 5));

          if (response.statusCode == 200) synced++;
        } catch (e) {
          // Skip failed sync
        }
      }

      if (!mounted) return;
      setState(() {
        _syncedCount = synced;
        _syncing = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('$synced dari ${students.length} siswa tersinkron'),
          backgroundColor: AppTheme.mint,
        ),
      );
    } catch (e) {
      if (!mounted) return;
      setState(() => _syncing = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Sync gagal: $e'),
          backgroundColor: AppTheme.coral,
        ),
      );
    }
  }

  Future<void> _disconnect() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('server_url');
    await prefs.remove('api_key');
    setState(() {
      _serverUrl = '';
      _apiKey = '';
      _isConnected = false;
    });
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Terputus dari server')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Pengaturan')),
      body: ListView(
        padding: const EdgeInsets.all(AppTheme.spacingBase),
        children: [
          Card(
            child: Padding(
              padding: const EdgeInsets.all(AppTheme.spacingBase),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(
                        _isConnected ? Icons.cloud_done : Icons.cloud_off,
                        color: _isConnected ? AppTheme.mint : AppTheme.coral,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        _isConnected ? 'Terhubung ke Desktop' : 'Belum Terhubung',
                        style: AppTheme.h3(context),
                      ),
                    ],
                  ),
                  const SizedBox(height: AppTheme.spacingBase),
                  TextField(
                    decoration: const InputDecoration(
                      labelText: 'URL Server',
                      border: OutlineInputBorder(),
                      hintText: 'http://192.168.1.100:8080',
                    ),
                    controller: TextEditingController(text: _serverUrl),
                    onChanged: (v) => _serverUrl = v,
                  ),
                  const SizedBox(height: AppTheme.spacingBase),
                  TextField(
                    decoration: const InputDecoration(
                      labelText: 'API Key',
                      border: OutlineInputBorder(),
                    ),
                    controller: TextEditingController(text: _apiKey),
                    onChanged: (v) => _apiKey = v,
                    obscureText: true,
                  ),
                  const SizedBox(height: AppTheme.spacingBase),
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          onPressed: _testConnection,
                          child: const Text('Test Koneksi'),
                        ),
                      ),
                      if (_isConnected) ...[
                        const SizedBox(width: 8),
                        Expanded(
                          child: OutlinedButton(
                            onPressed: _disconnect,
                            style: OutlinedButton.styleFrom(
                              foregroundColor: AppTheme.coral,
                            ),
                            child: const Text('Putuskan'),
                          ),
                        ),
                      ],
                    ],
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: AppTheme.spacingBase),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(AppTheme.spacingBase),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Sinkronisasi', style: AppTheme.h3(context)),
                  const SizedBox(height: AppTheme.spacingBase),
                  Text(
                    'Kirim semua data siswa dari Android ke Desktop',
                    style: AppTheme.bodySmall(context),
                  ),
                  const SizedBox(height: AppTheme.spacingBase),
                  SizedBox(
                    width: double.infinity,
                    child: FilledButton.icon(
                      onPressed: (_isConnected && !_syncing) ? _syncToDesktop : null,
                      icon: _syncing
                          ? const SizedBox(
                              width: 16,
                              height: 16,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : const Icon(Icons.sync),
                      label: Text(_syncing ? 'Menyinkron...' : 'Sinkron ke Desktop'),
                    ),
                  ),
                  if (_syncedCount > 0) ...[
                    const SizedBox(height: 8),
                    Text(
                      'Terakhir: $_syncedCount siswa tersinkron',
                      style: AppTheme.caption(context),
                    ),
                  ],
                ],
              ),
            ),
          ),
          const SizedBox(height: AppTheme.spacingBase),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(AppTheme.spacingBase),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Tentang', style: AppTheme.h3(context)),
                  const SizedBox(height: AppTheme.spacingBase),
                  Text('kelasFun v1.1.0', style: AppTheme.body(context)),
                  Text('Aplikasi Manajemen Kelas', style: AppTheme.bodySmall(context)),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
