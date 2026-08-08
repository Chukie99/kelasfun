import 'package:flutter_test/flutter_test.dart';
import 'package:kelasfun/core/utils/qr_generator.dart';

void main() {
  group('QrGenerator', () {
    test('generates valid QR payload from student data', () {
      final payload = QrGenerator.encodePayload(
        nis: '2025001',
        name: 'Andi Pratama',
        className: '6A',
      );
      expect(payload, '{"n":"2025001","nama":"Andi Pratama","k":"6A"}');
    });

    test('generates QR image data (Uint8List)', () async {
      final image = await QrGenerator.generateImage(
        nis: '2025001',
        name: 'Andi Pratama',
        className: '6A',
      );
      expect(image, isNotNull);
      expect(image!.length, greaterThan(0));
    });
  });
}
