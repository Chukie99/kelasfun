import 'package:flutter/material.dart';
import 'package:kelasfun/core/theme/app_theme.dart';
import 'android_pairing_screen.dart';
import 'android_scanner.dart';
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

  @override
  void initState() {
    super.initState();
    _loadStatus();
  }

  Future<void> _loadStatus() async {
    final config = await widget.service.loadConfig();
    if (!mounted) return;
    setState(() {
      _status = config == null ? 'Belum terhubung' : 'Terhubung: ${config.ip}:${config.port}';
    });
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

  void _openScanner() {
    Navigator.of(context).push(MaterialPageRoute(
      builder: (_) => AndroidScanner(
        service: widget.service,
        controller: widget.scannerBuilder(),
      ),
    ));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('kelasFun Scanner')),
      body: Padding(
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
            const SizedBox(height: AppTheme.spacing2xl),
            FilledButton(
              onPressed: _openPairing,
              child: const Text('Pindai QR Laptop'),
            ),
            const SizedBox(height: AppTheme.spacingBase),
            OutlinedButton(
              onPressed: _openScanner,
              child: const Text('Buka Scanner'),
            ),
          ],
        ),
      ),
    );
  }
}
