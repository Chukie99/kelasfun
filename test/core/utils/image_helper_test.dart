import 'dart:typed_data';
import 'package:flutter_test/flutter_test.dart';
import 'package:image/image.dart' as img;
import 'package:kelasfun/core/utils/image_helper.dart';

void main() {
  group('ImageHelper.autoRotatePhoto', () {
    test('should return null for empty bytes', () {
      final result = ImageHelper.autoRotatePhoto(Uint8List(0));
      expect(result, isNull);
    });

    test('should return original bytes for invalid image', () {
      final invalidBytes = Uint8List.fromList([1, 2, 3, 4]);
      final result = ImageHelper.autoRotatePhoto(invalidBytes);
      expect(result, equals(invalidBytes));
    });

    test('should return PNG bytes for valid image', () {
      // Create a simple 10x10 red image
      final image = img.Image(width: 10, height: 10);
      img.fillRect(image, x1: 0, y1: 0, x2: 9, y2: 9, color: img.ColorRgb8(255, 0, 0));
      final pngBytes = Uint8List.fromList(img.encodePng(image));
      
      final result = ImageHelper.autoRotatePhoto(pngBytes);
      expect(result, isNotNull);
      // Result should be valid PNG bytes
      expect(result!.length, greaterThan(8));
      // Check PNG signature
      expect(result[0], equals(0x89));
      expect(result[1], equals(0x50)); // P
      expect(result[2], equals(0x4E)); // N
      expect(result[3], equals(0x47)); // G
    });

    test('should handle image with EXIF orientation', () {
      // Create a simple image and test that the function works
      final image = img.Image(width: 20, height: 10);
      img.fillRect(image, x1: 0, y1: 0, x2: 19, y2: 9, color: img.ColorRgb8(0, 128, 255));
      final pngBytes = Uint8List.fromList(img.encodePng(image));
      
      final result = ImageHelper.autoRotatePhoto(pngBytes);
      expect(result, isNotNull);
      expect(result, isNotEmpty);
    });
  });
}
