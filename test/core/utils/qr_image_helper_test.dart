import 'package:flutter_test/flutter_test.dart';
import 'package:kelasfun/core/utils/qr_image_helper.dart';

void main() {
  group('QrImageHelper.generatePng', () {
    test('should return valid PNG bytes', () {
      final result = QrImageHelper.generatePng('test data', size: 100);
      expect(result, isNotEmpty);
      // Check PNG signature (first 8 bytes)
      expect(result[0], equals(0x89));
      expect(result[1], equals(0x50)); // P
      expect(result[2], equals(0x4E)); // N
      expect(result[3], equals(0x47)); // G
    });

    test('should generate QR code with correct size', () {
      final result = QrImageHelper.generatePng('test', size: 150);
      expect(result, isNotEmpty);
      // PNG should be valid and decodable
    });

    test('should handle empty string', () {
      final result = QrImageHelper.generatePng('', size: 100);
      expect(result, isNotEmpty);
    });
  });
}
