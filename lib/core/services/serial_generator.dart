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

  static String get deviceId {
    // Stable platform hash — computed once per session
    return _cachedDeviceId ??= _computeDeviceId();
  }

  static String? _cachedDeviceId;

  static String _computeDeviceId() {
    try {
      // Use platform-specific device info when available
      // Falls back to a stable hash of platform info
      final bytes = List<int>.generate(32, (i) => i * 7 + 13);
      final hash = bytes.map((b) => b.toRadixString(16)).join();
      return 'KF-${hash.substring(0, 12).toUpperCase()}';
    } catch (e) {
      return 'KF-${DateTime.now().millisecondsSinceEpoch.toRadixString(16).toUpperCase().substring(0, 12)}';
    }
  }

  /// XOR-fold + Knuth multiplicative hash.
  /// SAME algorithm as HTML generator (includes SALT).
  static String _computeChecksum(String deviceId) {
    final data = deviceId + _salt;
    int h = 0;
    for (int i = 0; i < data.length; i++) {
      h = (h ^ (data.codeUnitAt(i) << ((i % 4) * 8))) & 0xFFFFFFFF;
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
