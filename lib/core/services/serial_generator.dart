import 'dart:convert';

/// Offline serial code generator & validator for KelasFun.
/// 
/// Serial format: KFUN-XXXX-XX
/// Serial is BOUND to a specific device ID.
/// 
/// Flow:
/// 1. User opens app → shows device ID
/// 2. User sends device ID via WhatsApp
/// 3. Seller opens HTML generator → pastes device ID → generates code
/// 4. User enters code → validated offline against device ID
class SerialService {
  static const String _salt = 'KELASFUN_2024_SCHOOL_MGMT';
  static const String _charSet = 'ABCDEFGHJKLMNPQRSTUVWXYZ23456789';

  /// Stable device ID — same across restarts.
  /// In production: use device_info_plus package.
  static String get deviceId {
    // TODO: Replace with real device ID using device_info_plus:
    // final androidInfo = await DeviceInfoPlugin().androidInfo;
    // return 'KF-${androidInfo.model}-${androidInfo.id}'.toUpperCase();
    // For now: stable platform hash
    return 'KF-ANDROID-DEVICE';
  }

  /// XOR-fold + Knuth multiplicative hash.
  /// SAME algorithm as HTML generator.
  static String _computeChecksum(String deviceId) {
    int h = 0;
    for (int i = 0; i < deviceId.length; i++) {
      h = (h ^ (deviceId.codeUnitAt(i) << ((i % 4) * 8))) & 0xFFFFFFFF;
    }
    h = ((h * 2654435761) & 0xFFFFFFFF).toInt();

    final c1 = _charSet[h % _charSet.length];
    final c2 = _charSet[(h ~/ _charSet.length) % _charSet.length];
    return '$c1$c2';
  }

  /// Part hash — SAME algorithm as HTML generator.
  static String _computePart(String deviceId) {
    int h = 0;
    for (int i = 0; i < deviceId.length; i++) {
      h = (h + deviceId.codeUnitAt(i) * (i + 1) * 31) & 0xFFFF;
    }
    
    return '${_charSet[h % _charSet.length]}'
        '${_charSet[(h >> 4) % _charSet.length]}'
        '${_charSet[(h >> 8) % _charSet.length]}'
        '${_charSet[(h >> 12) % _charSet.length]}';
  }

  /// Generate activation code for a given device ID.
  /// Returns: KFUN-XXXX-XX
  static String generateCode(String deviceId) {
    final normalized = deviceId.replaceAll(RegExp(r'\s+'), '-').toUpperCase();
    final part = _computePart(normalized);
    final checksum = _computeChecksum(normalized);
    return 'KFUN-$part-$checksum';
  }

  /// Validate activation code against device ID.
  static bool validateCode(String code, String deviceId) {
    final cleaned = code.trim().toUpperCase();
    final expected = generateCode(deviceId);
    return cleaned == expected;
  }

  /// Basic format check (no device binding).
  static bool isValidFormat(String code) {
    final cleaned = code.trim().toUpperCase();
    if (cleaned.startsWith('KFUN-')) {
      return RegExp(r'^KFUN-[A-Z0-9]{4}-[A-Z0-9]{2}$').hasMatch(cleaned);
    }
    return RegExp(r'^[A-Z0-9]{4}-[A-Z0-9]{2}$').hasMatch(cleaned);
  }
}

// CLI test
void main(List<String> args) {
  final deviceId = args.isNotEmpty ? args[0] : SerialService.deviceId;
  final code = SerialService.generateCode(deviceId);
  final valid = SerialService.validateCode(code, deviceId);
  
  print('=== KelasFun Serial (Dart) ===');
  print('Device:   $deviceId');
  print('Code:     $code');
  print('Valid:    ${valid ? "✓" : "✗"}');
}
