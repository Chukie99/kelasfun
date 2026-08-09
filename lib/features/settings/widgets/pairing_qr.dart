import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart';

import '../../../core/theme/app_theme.dart';

class PairingQr extends StatelessWidget {
  final int port;
  final String token;

  const PairingQr({super.key, required this.port, required this.token});

  @override
  Widget build(BuildContext context) {
    final payload = jsonEncode({
      'ip': '192.168.1.100',
      'port': port,
      'token': token,
    });

    return Column(
      children: [
        Text(
          'Scan QR ini dari Android untuk koneksi',
          style: AppTheme.caption(context),
        ),
        const SizedBox(height: AppTheme.spacingBase),
        QrImageView(
          data: payload,
          version: QrVersions.auto,
          size: 200,
        ),
        const SizedBox(height: AppTheme.spacingBase),
        Text(
          'IP: 192.168.1.100',
          style: AppTheme.caption(context).copyWith(fontFamily: 'monospace'),
        ),
        Text(
          'Port: $port',
          style: AppTheme.caption(context).copyWith(fontFamily: 'monospace'),
        ),
      ],
    );
  }
}
