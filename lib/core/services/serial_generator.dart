import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

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

  /// Device ID real: persisted per-install UUID (stable survives reinstall? no — bind per install).
  /// Future: ganti ke device_info_plus androidId when plugin added.
  /// Untuk ROM ini: generate once simpan di prefs via ensureDeviceId(), fallback sync di getter.
  static String _computeDeviceId() {
    try {
      // Deterministic per-process fallback before prefs loaded — will be replaced by persisted ID
      final now = DateTime.now().millisecondsSinceEpoch;
      final rnd = (now ^ 0x5A17) & 0xFFFFFF;
      final hash = (rnd.toRadixString(16).padLeft(6,'0') + now.toRadixString(16).padLeft(6,'0')).toUpperCase();
      return 'KF-${hash.substring(0, 12)}';
    } catch (e) {
      return 'KF-${DateTime.now().millisecondsSinceEpoch.toRadixString(16).toUpperCase().substring(0, 12)}';
    }
  }

  /// Call at startup to load/persist real device ID (call from ActivationScreen / AuthGate)
  static Future<String> ensureDeviceId() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final saved = prefs.getString('device_id_persist');
      if (saved != null && saved.length >= 6) {
        _cachedDeviceId = saved;
        return saved;
      }
      final id = _cachedDeviceId ?? _computeDeviceId();
      try { await prefs.setString('device_id_persist', id); } catch(_){}
      _cachedDeviceId = id;
      return id;
    } catch (_) { return deviceId; }
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
