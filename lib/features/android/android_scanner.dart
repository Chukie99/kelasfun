import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:kelasfun/core/theme/app_theme.dart';
import 'package:kelasfun/core/utils/barcode_helpers.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'scanner_controller.dart';
import 'scanner_service.dart';

class AndroidScanner extends StatefulWidget {
  final ScannerService service;
  final ScannerController controller;

  const AndroidScanner({
    super.key,
    required this.service,
    required this.controller,
  });

  @override
  State<AndroidScanner> createState() => _AndroidScannerState();
}

class _AndroidScannerState extends State<AndroidScanner> {
  String? _banner;
  bool _isSuccess = false;
  bool _processing = false;

  @override
  void initState() {
    super.initState();
    widget.controller.barcodes.listen(_onBarcode);
  }

  Future<void> _onBarcode(String raw) async {
    if (_processing) return;
    setState(() => _processing = true);

    final nis = BarcodeHelpers.extractNisFromScan(raw);
    final result = await widget.service.sendScan(nis);

    if (!mounted) return;

    if (result.success) {
      HapticFeedback.vibrate();
      SystemSound.play(SystemSoundType.click);
      setState(() {
        _banner = '${result.studentName ?? nis} - Hadir';
        _isSuccess = true;
      });
      await Future<void>.delayed(const Duration(seconds: 1));
    } else {
      setState(() {
        _banner = result.error ?? 'Gagal mengirim scan';
        _isSuccess = false;
      });
      await Future<void>.delayed(const Duration(seconds: 2));
    }

    if (!mounted) return;
    setState(() {
      _banner = null;
      _processing = false;
    });
  }

  @override
  void dispose() {
    widget.controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Scan QR Siswa')),
      body: Column(
        children: [
          Expanded(
            child: widget.controller is MobileScannerControllerImpl
                ? MobileScanner(
                    controller:
                        (widget.controller as MobileScannerControllerImpl).nativeController,
                    onDetect: (capture) =>
                        (widget.controller as MobileScannerControllerImpl).onDetect(capture),
                  )
                : Container(
                    color: AppTheme.surfaceLight,
                    alignment: Alignment.center,
                    child: const Text('Kamera tidak tersedia'),
                  ),
          ),
          if (_banner != null)
            Container(
              width: double.infinity,
              color: _isSuccess ? AppTheme.mint : AppTheme.coral,
              padding: const EdgeInsets.all(AppTheme.spacingLg),
              child: Text(
                _banner!,
                textAlign: TextAlign.center,
                style: AppTheme.body(context).copyWith(color: Colors.white),
              ),
            ),
          Container(
            width: double.infinity,
            color: AppTheme.surface,
            padding: const EdgeInsets.all(AppTheme.spacingLg),
            child: Text(
              'Arahkan kamera ke QR kartu siswa',
              textAlign: TextAlign.center,
              style: AppTheme.bodySmall(context),
            ),
          ),
        ],
      ),
    );
  }
}
