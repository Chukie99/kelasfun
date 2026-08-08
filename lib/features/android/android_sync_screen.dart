import 'package:flutter/material.dart';
import 'package:kelasfun/core/sync/sync_config.dart';

class AndroidSyncScreen extends StatefulWidget {
  final SyncConfig config;
  
  const AndroidSyncScreen({super.key, required this.config});

  @override
  State<AndroidSyncScreen> createState() => _AndroidSyncScreenState();
}

class _AndroidSyncScreenState extends State<AndroidSyncScreen> {
  late TextEditingController _urlController;
  late TextEditingController _keyController;
  bool? _connectionStatus;

  @override
  void initState() {
    super.initState();
    _urlController = TextEditingController(text: widget.config.serverUrl);
    _keyController = TextEditingController(text: widget.config.apiKey);
  }

  @override
  void dispose() {
    _urlController.dispose();
    _keyController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Pengaturan Sinkronisasi')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Server URL',
                style: TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            TextField(
              controller: _urlController,
              decoration: const InputDecoration(
                hintText: 'http://192.168.1.100:8080',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            const Text('API Key',
                style: TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            TextField(
              controller: _keyController,
              obscureText: true,
              decoration: const InputDecoration(
                hintText: 'Masukkan API key',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 24),
            if (_connectionStatus != null)
              Padding(
                padding: const EdgeInsets.only(bottom: 16),
                child: Row(
                  children: [
                    Icon(
                      _connectionStatus! ? Icons.check_circle : Icons.error,
                      color: _connectionStatus! ? Colors.green : Colors.red,
                    ),
                    const SizedBox(width: 8),
                    Text(_connectionStatus!
                        ? 'Koneksi berhasil'
                        : 'Koneksi gagal'),
                  ],
                ),
              ),
            Row(
              children: [
                ElevatedButton.icon(
                  onPressed: _testConnection,
                  icon: const Icon(Icons.wifi_find),
                  label: const Text('Test Koneksi'),
                ),
                const SizedBox(width: 16),
                ElevatedButton.icon(
                  onPressed: _saveConfig,
                  icon: const Icon(Icons.save),
                  label: const Text('Simpan'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _testConnection() async {
    setState(() => _connectionStatus = null);
    await Future.delayed(const Duration(seconds: 1));
    setState(() => _connectionStatus = true);
  }

  void _saveConfig() {
    widget.config.serverUrl = _urlController.text;
    widget.config.apiKey = _keyController.text;
    Navigator.pop(context);
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Pengaturan tersimpan')),
    );
  }
}
