import 'dart:typed_data';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart';

class QrGenerator {
  static String encodePayload({
    required String nis,
    required String name,
    required String className,
  }) {
    return '{"n":"$nis","nama":"$name","k":"$className"}';
  }

  static Future<Uint8List?> generateImage({
    required String nis,
    required String name,
    required String className,
    double size = 200,
  }) async {
    final payload = encodePayload(nis: nis, name: name, className: className);
    final painter = QrPainter(
      data: payload,
      version: QrVersions.auto,
      eyeStyle: const QrEyeStyle(
        eyeShape: QrEyeShape.circle,
        color: Color(0xFF2D3436),
      ),
      dataModuleStyle: const QrDataModuleStyle(
        dataModuleShape: QrDataModuleShape.circle,
        color: Color(0xFF2D3436),
      ),
    );

    final image = await painter.toImage(size);
    if (image == null) return null;

    final byteData = await image.toByteData(format: ui.ImageByteFormat.png);
    return byteData?.buffer.asUint8List();
  }
}
