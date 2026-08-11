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
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final payload = jsonEncode({
      'ip': '192.168.1.100',
      'port': port,
      'token': token,
    });

    return Column(
      children: [
        Text(
          'Scan QR ini dari Android untuk koneksi',
          style: AppTheme.bodySmall(context),
        ),
        const SizedBox(height: AppTheme.spacingLg),
        Container(
          padding: const EdgeInsets.all(AppTheme.spacingBase),
          decoration: BoxDecoration(
            color: isDark ? AppTheme.surfaceLight : AppTheme.lightSurfaceLight,
            borderRadius: BorderRadius.circular(AppTheme.radiusCard),
          ),
          child: QrImageView(
            data: payload,
            version: QrVersions.auto,
            size: 200,
          ),
        ),
        const SizedBox(height: AppTheme.spacingLg),
        Container(
          padding: const EdgeInsets.symmetric(
            horizontal: AppTheme.spacingBase,
            vertical: AppTheme.spacingSm,
          ),
          decoration: BoxDecoration(
            color: isDark ? AppTheme.surfaceLight : AppTheme.lightSurfaceLight,
            borderRadius: BorderRadius.circular(AppTheme.radiusChip),
          ),
          child: Column(
            children: [
              Text(
                'IP: 192.168.1.100',
                style: AppTheme.caption(context).copyWith(fontFamily: 'monospace'),
              ),
              const SizedBox(height: AppTheme.spacingXs),
              Text(
                'Port: $port',
                style: AppTheme.caption(context).copyWith(fontFamily: 'monospace'),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
