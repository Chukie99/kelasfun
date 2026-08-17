import 'dart:typed_data';
import 'package:qr/qr.dart';
import 'package:image/image.dart' as img;

class QrImageHelper {
  /// Generate QR Code as PNG image
  static Uint8List generatePng(String data, {int size = 200}) {
    final qrCode = QrCode.fromData(
      data: data,
      errorCorrectLevel: QrErrorCorrectLevel.H,
    );
    final qrImage = QrImage(qrCode);
    
    // Create image with white background
    final image = img.Image(width: size, height: size);
    img.fillRect(
      image,
      x1: 0,
      y1: 0,
      x2: size - 1,
      y2: size - 1,
      color: img.ColorRgb8(255, 255, 255),
    );
    
    // Draw QR code modules
    final moduleCount = qrImage.moduleCount;
    final moduleSize = size / moduleCount;
    
    for (int y = 0; y < moduleCount; y++) {
      for (int x = 0; x < moduleCount; x++) {
        if (qrImage.isDark(y, x)) {
          // Draw dark module
          img.fillRect(
            image,
            x1: (x * moduleSize).toInt(),
            y1: (y * moduleSize).toInt(),
            x2: ((x + 1) * moduleSize).toInt() - 1,
            y2: ((y + 1) * moduleSize).toInt() - 1,
            color: img.ColorRgb8(0, 0, 0),
          );
        }
      }
    }
    
    return Uint8List.fromList(img.encodePng(image));
  }
}
