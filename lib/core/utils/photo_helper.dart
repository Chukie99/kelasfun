import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;

class PhotoHelper {
  static Future<String> get _photoDir async {
    final appDir = await getApplicationDocumentsDirectory();
    final photoDir = Directory(p.join(appDir.path, 'kelasFun', 'student_photos'));
    if (!await photoDir.exists()) {
      await photoDir.create(recursive: true);
    }
    return photoDir.path;
  }

  static Future<String> savePhoto({
    required String nis,
    required File sourceFile,
  }) async {
    final dir = await _photoDir;
    final ext = p.extension(sourceFile.path).toLowerCase();
    final fileName = '$nis$ext';
    final targetPath = p.join(dir, fileName);
    final targetFile = File(targetPath);

    if (await targetFile.exists()) {
      await targetFile.delete();
    }

    await sourceFile.copy(targetPath);
    return targetPath;
  }

  static Future<String?> getPhotoPath(String nis) async {
    final dir = await _photoDir;
    for (final ext in ['.jpg', '.jpeg', '.png']) {
      final file = File(p.join(dir, '$nis$ext'));
      if (await file.exists()) {
        return file.path;
      }
    }
    return null;
  }

  static Future<bool> deletePhoto(String nis) async {
    final dir = await _photoDir;
    for (final ext in ['.jpg', '.jpeg', '.png']) {
      final file = File(p.join(dir, '$nis$ext'));
      if (await file.exists()) {
        await file.delete();
        return true;
      }
    }
    return false;
  }

  static String getInitials(String name) {
    final parts = name.trim().split(RegExp(r'\s+'));
    if (parts.isEmpty || parts.first.isEmpty) return '?';
    if (parts.length == 1) return parts[0][0].toUpperCase();
    return '${parts[0][0]}${parts.last[0]}'.toUpperCase();
  }
}
