import 'dart:typed_data';
import 'package:image/image.dart' as img;

class ImageHelper {
  /// Auto-rotate image based on EXIF orientation
  static Uint8List? autoRotatePhoto(Uint8List photoBytes) {
    if (photoBytes.isEmpty) return null;
    
    try {
      final image = img.decodeImage(photoBytes);
      if (image == null) return null;
      
      // Auto-rotate based on EXIF orientation
      final rotated = img.bakeOrientation(image);
      
      // Convert back to bytes
      return Uint8List.fromList(img.encodePng(rotated));
    } catch (e) {
      return photoBytes; // Return original if error
    }
  }
}
