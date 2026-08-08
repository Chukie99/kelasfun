import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart';

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
        const Text('Scan QR ini dari Android untuk koneksi',
            style: TextStyle(fontSize: 14)),
        const SizedBox(height: 16),
        QrImageView(
          data: payload,
          version: QrVersions.auto,
          size: 200,
        ),
        const SizedBox(height: 16),
        const Text('IP: 192.168.1.100',
            style: TextStyle(fontFamily: 'monospace')),
        Text('Port: $port', style: const TextStyle(fontFamily: 'monospace')),
      ],
    );
  }
}
