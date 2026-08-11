import 'package:flutter/material.dart';
import 'package:kelasfun/core/theme/app_theme.dart';
import 'package:kelasfun/core/utils/barcode_helpers.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'pairing_config.dart';
import 'scanner_controller.dart';
import 'scanner_service.dart';

class AndroidPairingScreen extends StatefulWidget {
  final ScannerService service;
  final ScannerController controller;
  final void Function()? onSaved;

  const AndroidPairingScreen({
    super.key,
    required this.service,
    required this.controller,
    this.onSaved,
  });

  @override
  State<AndroidPairingScreen> createState() => _AndroidPairingScreenState();
}

class _AndroidPairingScreenState extends State<AndroidPairingScreen> {
  String? _error;
  bool _processing = false;

  @override
  void initState() {
    super.initState();
    _subscribe();
  }

  void _subscribe() {
    widget.controller.barcodes.listen(_onBarcode);
  }

  Future<void> _onBarcode(String raw) async {
    if (_processing) return;
    setState(() => _processing = true);

    final payload = BarcodeHelpers.parseQrPayload(raw);
    final ip = payload?['ip'];
    final port = payload?['port'];

    if (payload == null || ip is! String || ip.isEmpty || port is! num) {
      setState(() {
        _error = 'QR tidak valid';
        _processing = false;
      });
      return;
    }

    await widget.service.saveConfig(
      PairingConfig(
        ip: ip,
        port: port.toInt(),
        token: payload['token'] as String?,
      ),
    );

    if (!mounted) return;
    setState(() => _processing = false);
    if (widget.onSaved != null) {
      widget.onSaved!();
    } else {
      Navigator.of(context).pop();
    }
  }

  @override
  void dispose() {
    widget.controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Pindai QR Laptop')),
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
          if (_error != null)
            Container(
              width: double.infinity,
              color: AppTheme.coral,
              padding: const EdgeInsets.all(AppTheme.spacingLg),
              child: Text(
                _error!,
                textAlign: TextAlign.center,
                style: AppTheme.body(context).copyWith(color: Colors.white),
              ),
            ),
          Container(
            width: double.infinity,
            color: AppTheme.surface,
            padding: const EdgeInsets.all(AppTheme.spacingLg),
            child: Text(
              'Arahkan kamera ke QR pairing laptop',
              textAlign: TextAlign.center,
              style: AppTheme.bodySmall(context),
            ),
          ),
        ],
      ),
    );
  }
}
