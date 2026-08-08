import 'package:flutter_test/flutter_test.dart';
import 'package:kelasfun/core/utils/barcode_helpers.dart';

void main() {
  group('BarcodeHelpers', () {
    test('parse QR payload returns map', () {
      final payload = '{"n":"2025001","nama":"Andi Pratama","k":"6A"}';
      final result = BarcodeHelpers.parseQrPayload(payload);
      expect(result, isNotNull);
      expect(result!['n'], '2025001');
      expect(result['nama'], 'Andi Pratama');
      expect(result['k'], '6A');
    });

    test('parse invalid payload returns null', () {
      final result = BarcodeHelpers.parseQrPayload('invalid');
      expect(result, isNull);
    });

    test('clean scanned input removes trailing newline', () {
      final cleaned = BarcodeHelpers.cleanScannedInput('2025001\n');
      expect(cleaned, '2025001');
    });

    test('extract nis from JSON payload', () {
      final nis = BarcodeHelpers.extractNisFromScan('{"n":"2025001","nama":"Andi"}');
      expect(nis, '2025001');
    });

    test('extract nis from plain text', () {
      final nis = BarcodeHelpers.extractNisFromScan('2025001');
      expect(nis, '2025001');
    });
  });
}
