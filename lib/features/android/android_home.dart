import 'package:flutter/material.dart';
import 'package:kelasfun/core/theme/app_theme.dart';
import 'android_pairing_screen.dart';
import 'android_scanner.dart';
import 'android_student_list.dart';
import 'scanner_controller.dart';
import 'scanner_service.dart';

class AndroidHome extends StatefulWidget {
  final ScannerService service;
  final ScannerController Function() scannerBuilder;

  const AndroidHome({
    super.key,
    required this.service,
    required this.scannerBuilder,
  });

  @override
  State<AndroidHome> createState() => _AndroidHomeState();
}

class _AndroidHomeState extends State<AndroidHome> {
  String? _status;
  int _pendingCount = 0;
  String? _syncResult;
  DateTime? _lastSync;
  bool _syncing = false;

  @override
  void initState() {
    super.initState();
    _loadStatus();
    _sync();
  }

  Future<void> _loadStatus() async {
    final config = await widget.service.loadConfig();
    final queue = await widget.service.loadQueue();
    if (!mounted) return;
    setState(() {
      _status = config == null ? 'Belum terhubung' : 'Terhubung: ${config.ip}:${config.port}';
      _pendingCount = queue.length;
    });
  }

  Future<void> _sync() async {
    if (_syncing) return;
    _syncing = true;
    try {
      final result = await widget.service.syncPending();
      if (!mounted) return;
      setState(() {
        _lastSync = DateTime.now();
        if (result.notPaired) {
          _syncResult = 'Belum terhubung. Pindai QR laptop dulu.';
        } else if (result.authError) {
          _syncResult = 'Token tidak cocok. Pindai QR laptop ulang.';
        } else {
          final parts = <String>['${result.syncedCount} tersinkron'];
          if (result.unknownCount > 0) {
            parts.add('${result.unknownCount} tidak dikenal');
          }
          _syncResult = 'Sinkron selesai: ${parts.join(', ')}';
        }
      });
      await _loadStatus();
    } finally {
      _syncing = false;
    }
  }

  void _openPairing() {
    Navigator.of(context).push(MaterialPageRoute(
      builder: (_) => AndroidPairingScreen(
        service: widget.service,
        controller: widget.scannerBuilder(),
        onSaved: () {
          Navigator.of(context).pop();
          _loadStatus();
        },
      ),
    ));
  }

  void _openStudentList() {
    Navigator.of(context).push(MaterialPageRoute(
      builder: (_) => AndroidStudentList(service: widget.service),
    ));
  }

  Future<void> _openScanner() async {
    await Navigator.of(context).push(MaterialPageRoute(
      builder: (_) => AndroidScanner(
        service: widget.service,
        controller: widget.scannerBuilder(),
      ),
    ));
    if (!mounted) return;
    await _loadStatus();
  }

  String _formatSyncTime(DateTime t) {
    final h = t.hour.toString().padLeft(2, '0');
    final m = t.minute.toString().padLeft(2, '0');
    return '$h:$m';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('kelasFun Scanner')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppTheme.spacingXl),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Icon(Icons.qr_code_scanner, size: 72, color: AppTheme.accent),
            const SizedBox(height: AppTheme.spacingLg),
            Text(
              _status ?? 'Memuat...',
              textAlign: TextAlign.center,
              style: AppTheme.h2(context),
            ),
            if (_pendingCount > 0) ...[
              const SizedBox(height: AppTheme.spacingBase),
              Text(
                '$_pendingCount scan menunggu sinkron',
                textAlign: TextAlign.center,
                style: AppTheme.body(context).copyWith(color: AppTheme.amber),
              ),
            ],
            if (_lastSync != null) ...[
              const SizedBox(height: AppTheme.spacingBase),
              Text(
                'Terakhir sinkron: ${_formatSyncTime(_lastSync!)}',
                textAlign: TextAlign.center,
                style: AppTheme.bodySmall(context),
              ),
            ],
            if (_syncResult != null) ...[
              const SizedBox(height: AppTheme.spacingBase),
              Text(
                _syncResult!,
                textAlign: TextAlign.center,
                style: AppTheme.body(context).copyWith(color: AppTheme.amber),
              ),
            ],
            const SizedBox(height: AppTheme.spacing2xl),
            FilledButton(
              onPressed: _openPairing,
              child: const Text('Pindai QR Laptop'),
            ),
            const SizedBox(height: AppTheme.spacingBase),
            OutlinedButton.icon(
              onPressed: _openStudentList,
              icon: const Icon(Icons.people),
              label: const Text('Daftar Siswa'),
            ),
            const SizedBox(height: AppTheme.spacingBase),
            OutlinedButton(
              onPressed: _openScanner,
              child: const Text('Buka Scanner'),
            ),
            const SizedBox(height: AppTheme.spacingBase),
            OutlinedButton.icon(
              onPressed: _sync,
              icon: const Icon(Icons.sync),
              label: const Text('Sinkron'),
            ),
          ],
        ),
      ),
    );
  }
}
