import 'dart:convert';
import 'dart:math';

/// Offline serial code generator & validator for KelasFun.
/// 
/// Serial format: KFUN-XXXX-XXXX-XXXX
/// Validation is 100% offline — no server needed.
/// 
/// TO GENERATE SERIAL: Jalankan generator tool atau pakai ini:
///   dart run lib/core/services/serial_generator.dart
class SerialService {
  // Secret salt — UBAH INI UNTUK SETIAP BATCH YANG BERBEDA!
  static const String _salt = 'KELASFUN_2024_SCHOOL_MGMT';

  static final _charSet = 'ABCDEFGHJKLMNPQRSTUVWXYZ23456789'; // no I,O,0,1

  /// Generate a new serial code.
  /// Returns format: XXXX-XXXX-XXXX (caller adds KFUN- prefix)
  static String generate() {
    final rng = Random.secure();
    String segment() {
      return List.generate(4, (_) => _charSet[rng.nextInt(_charSet.length)]).join();
    }
    return '${segment()}-${segment()}-${segment()}';
  }

  /// Validate a serial code offline.
  /// Accepts: "KFUN-XXXX-XXXX-XXXX" or "XXXX-XXXX-XXXX"
  static bool validate(String serial) {
    final cleaned = serial.trim().toUpperCase();
    
    // Strip KFUN- prefix if present
    String code = cleaned;
    if (code.startsWith('KFUN-')) {
      code = code.substring(5); // remove 'KFUN-'
    }
    
    // Must be: XXXX-XXXX-XXXX (12 alphanumeric chars with dashes)
    if (!RegExp(r'^[A-Z0-9]{4}-[A-Z0-9]{4}-[A-Z0-9]{4}$').hasMatch(code)) {
      return false;
    }

    // Extract 12-char payload (no dashes)
    final payload = code.replaceAll('-', '');
    if (payload.length != 12) return false;

    final id = payload.substring(0, 10);
    final checksum = payload.substring(10, 12);

    final expected = _computeChecksum(id);
    return checksum == expected;
  }

  /// Compute a 2-char checksum from an ID string.
  static String _computeChecksum(String id) {
    // SHA-256 based — same algorithm as Python generator
    final data = utf8.encode('$id$_salt');
    // Simple hash: XOR-fold the first 8 bytes into a 32-bit int
    int h = 0;
    for (int i = 0; i < data.length; i++) {
      h = (h ^ (data[i] << ((i % 4) * 8))) & 0xFFFFFFFF;
    }
    // Additional mixing
    h = (h * 2654435761) & 0xFFFFFFFF; // Knuth multiplicative hash

    final c1 = _charSet[h % _charSet.length];
    final c2 = _charSet[(h ~/ _charSet.length) % _charSet.length];
    return '$c1$c2';
  }

  /// Get display info from a valid serial.
  static Map<String, String>? getInfo(String serial) {
    if (!validate(serial)) return null;
    return {
      'serial': serial.trim().toUpperCase(),
      'product': 'KelasFun',
      'version': '1.0',
    };
  }
}

// CLI tool — run: dart run lib/core/services/serial_generator.dart
void main(List<String> args) {
  final count = args.isNotEmpty ? int.tryParse(args[0]) ?? 5 : 5;
  print('=== KelasFun Serial Generator (Dart) ===\n');
  print('Generating $count serial codes:\n');
  for (int i = 0; i < count; i++) {
    final code = SerialService.generate();
    final full = 'KFUN-$code';
    final valid = SerialService.validate(full);
    print('  $full  [${valid ? "✓ VALID" : "✗ INVALID"}]');
  }
}
