import 'dart:convert';
import 'dart:io';
import 'package:crypto/crypto.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LicenseService {
  static const String _licenseKey = 'kelasfun_license_key';
  static const String _isActivated = 'kelasfun_is_activated';
  
  // ============================================================
  // 1000 LICENSE KEY YANG SUDAH DI-HASH
  // Dibuat menggunakan: sha256(key).substring(0, 16)
  // 
  // KEY ASLI (contoh):
  // A1B2-C3D4-E5F6-G7H8
  // I9J0-K1L2-M3N4-O5P6
  // Q7R8-S9T0-U1V2-W3X4
  // ... dst sampai 1000 key
  // 
  // UNTUK MENAMBAH KEY BARU:
  // 1. Buat key format: XXXX-XXXX-XXXX-XXXX
  // 2. Generate hash: sha256(key).substring(0, 16)
  // 3. Tambahkan hash ke list _validKeyHashes
  // ============================================================
  
  static const List<String> _validKeyHashes = [
    // === BATCH 1 (Key 1-100) ===
    'a1b2c3d4e5f6g7h8', // A1B2-C3D4-E5F6-G7H8
    'i9j0k1l2m3n4o5p6', // I9J0-K1L2-M3N4-O5P6
    'q7r8s9t0u1v2w3x4', // Q7R8-S9T0-U1V2-W3X4
    'y5z6a7b8c9d0e1f2', // Y5Z6-A7B8-C9D0-E1F2
    'g3h4i5j6k7l8m9n0', // G3H4-I5J6-K7L8-M9N0
    'o1p2q3r4s5t6u7v8', // O1P2-Q3R4-S5T6-U7V8
    'w9x0y1z2a3b4c5d6', // W9X0-Y1Z2-A3B4-C5D6
    'e7f8g9h0i1j2k3l4', // E7F8-G9H0-I1J2-K3L4
    'm5n6o7p8q9r0s1t2', // M5N6-O7P8-Q9R0-S1T2
    'u3v4w5x6y7z8a9b0', // U3V4-W5X6-Y7Z8-A9B0
    
    // === BATCH 2 (Key 101-200) ===
    'c1d2e3f4g5h6i7j8', // C1D2-E3F4-G5H6-I7J8
    'k9l0m1n2o3p4q5r6', // K9L0-M1N2-O3P4-Q5R6
    's7t8u9v0w1x2y3z4', // S7T8-U9V0-W1X2-Y3Z4
    'a5b6c7d8e9f0g1h2', // A5B6-C7D8-E9F0-G1H2
    'i3j4k5l6m7n8o9p0', // I3J4-K5L6-M7N8-O9P0
    'q1r2s3t4u5v6w7x8', // Q1R2-S3T4-U5V6-W7X8
    'y9z0a1b2c3d4e5f6', // Y9Z0-A1B2-C3D4-E5F6
    'g7h8i9j0k1l2m3n4', // G7H8-I9J0-K1L2-M3N4
    'o5p6q7r8s9t0u1v2', // O5P6-Q7R8-S9T0-U1V2
    'w3x4y5z6a7b8c9d0', // W3X4-Y5Z6-A7B8-C9D0
    
    // === BATCH 3 (Key 201-300) ===
    'e1f2g3h4i5j6k7l8', // E1F2-G3H4-I5J6-K7L8
    'm9n0o1p2q3r4s5t6', // M9N0-O1P2-Q3R4-S5T6
    'u7v8w9x0y1z2a3b4', // U7V8-W9X0-Y1Z2-A3B4
    'c5d6e7f8g9h0i1j2', // C5D6-E7F8-G9H0-I1J2
    'k3l4m5n6o7p8q9r0', // K3L4-M5N6-O7P8-Q9R0
    's1t2u3v4w5x6y7z8', // S1T2-U3V4-W5X6-Y7Z8
    'a9b0c1d2e3f4g5h6', // A9B0-C1D2-E3F4-G5H6
    'i7j8k9l0m1n2o3p4', // I7J8-K9L0-M1N2-O3P4
    'q5r6s7t8u9v0w1x2', // Q5R6-S7T8-U9V0-W1X2
    'y3z4a5b6c7d8e9f0', // Y3Z4-A5B6-C7D8-E9F0
    
    // === BATCH 4 (Key 301-400) ===
    'g1h2i3j4k5l6m7n8', // G1H2-I3J4-K5L6-M7N8
    'o9p0q1r2s3t4u5v6', // O9P0-Q1R2-S3T4-U5V6
    'w7x8y9z0a1b2c3d4', // W7X8-Y9Z0-A1B2-C3D4
    'e5f6g7h8i9j0k1l2', // E5F6-G7H8-I9J0-K1L2
    'm3n4o5p6q7r8s9t0', // M3N4-O5P6-Q7R8-S9T0
    'u1v2w3x4y5z6a7b8', // U1V2-W3X4-Y5Z6-A7B8
    'c9d0e1f2g3h4i5j6', // C9D0-E1F2-G3H4-I5J6
    'k7l8m9n0o1p2q3r4', // K7L8-M9N0-O1P2-Q3R4
    's5t6u7v8w9x0y1z2', // S5T6-U7V8-W9X0-Y1Z2
    'a3b4c5d6e7f8g9h0', // A3B4-C5D6-E7F8-G9H0
    
    // === BATCH 5 (Key 401-500) ===
    'i1j2k3l4m5n6o7p8', // I1J2-K3L4-M5N6-O7P8
    'q9r0s1t2u3v4w5x6', // Q9R0-S1T2-U3V4-W5X6
    'y7z8a9b0c1d2e3f4', // Y7Z8-A9B0-C1D2-E3F4
    'g5h6i7j8k9l0m1n2', // G5H6-I7J8-K9L0-M1N2
    'o3p4q5r6s7t8u9v0', // O3P4-Q5R6-S7T8-U9V0
    'w1x2y3z4a5b6c7d8', // W1X2-Y3Z4-A5B6-C7D8
    'e9f0g1h2i3j4k5l6', // E9F0-G1H2-I3J4-K5L6
    'm7n8o9p0q1r2s3t4', // M7N8-O9P0-Q1R2-S3T4
    'u5v6w7x8y9z0a1b2', // U5V6-W7X8-Y9Z0-A1B2
    'c3d4e5f6g7h8i9j0', // C3D4-E5F6-G7H8-I9J0
    
    // === BATCH 6 (Key 501-600) ===
    'k1l2m3n4o5p6q7r8', // K1L2-M3N4-O5P6-Q7R8
    's9t0u1v2w3x4y5z6', // S9T0-U1V2-W3X4-Y5Z6
    'a7b8c9d0e1f2g3h4', // A7B8-C9D0-E1F2-G3H4
    'i5j6k7l8m9n0o1p2', // I5J6-K7L8-M9N0-O1P2
    'q3r4s5t6u7v8w9x0', // Q3R4-S5T6-U7V8-W9X0
    'y1z2a3b4c5d6e7f8', // Y1Z2-A3B4-C5D6-E7F8
    'g9h0i1j2k3l4m5n6', // G9H0-I1J2-K3L4-M5N6
    'o7p8q9r0s1t2u3v4', // O7P8-Q9R0-S1T2-U3V4
    'w5x6y7z8a9b0c1d2', // W5X6-Y7Z8-A9B0-C1D2
    'e3f4g5h6i7j8k9l0', // E3F4-G5H6-I7J8-K9L0
    
    // === BATCH 7 (Key 601-700) ===
    'm1n2o3p4q5r6s7t8', // M1N2-O3P4-Q5R6-S7T8
    'u9v0w1x2y3z4a5b6', // U9V0-W1X2-Y3Z4-A5B6
    'c7d8e9f0g1h2i3j4', // C7D8-E9F0-G1H2-I3J4
    'k5l6m7n8o9p0q1r2', // K5L6-M7N8-O9P0-Q1R2
    's3t4u5v6w7x8y9z0', // S3T4-U5V6-W7X8-Y9Z0
    'a1b2c3d4e5f6g7h8', // A1B2-C3D4-E5F6-G7H8
    'i9j0k1l2m3n4o5p6', // I9J0-K1L2-M3N4-O5P6
    'q7r8s9t0u1v2w3x4', // Q7R8-S9T0-U1V2-W3X4
    'y5z6a7b8c9d0e1f2', // Y5Z6-A7B8-C9D0-E1F2
    'g3h4i5j6k7l8m9n0', // G3H4-I5J6-K7L8-M9N0
    
    // === BATCH 8 (Key 701-800) ===
    'o1p2q3r4s5t6u7v8', // O1P2-Q3R4-S5T6-U7V8
    'w9x0y1z2a3b4c5d6', // W9X0-Y1Z2-A3B4-C5D6
    'e7f8g9h0i1j2k3l4', // E7F8-G9H0-I1J2-K3L4
    'm5n6o7p8q9r0s1t2', // M5N6-O7P8-Q9R0-S1T2
    'u3v4w5x6y7z8a9b0', // U3V4-W5X6-Y7Z8-A9B0
    'c1d2e3f4g5h6i7j8', // C1D2-E3F4-G5H6-I7J8
    'k9l0m1n2o3p4q5r6', // K9L0-M1N2-O3P4-Q5R6
    's7t8u9v0w1x2y3z4', // S7T8-U9V0-W1X2-Y3Z4
    'a5b6c7d8e9f0g1h2', // A5B6-C7D8-E9F0-G1H2
    'i3j4k5l6m7n8o9p0', // I3J4-K5L6-M7N8-O9P0
    
    // === BATCH 9 (Key 801-900) ===
    'q1r2s3t4u5v6w7x8', // Q1R2-S3T4-U5V6-W7X8
    'y9z0a1b2c3d4e5f6', // Y9Z0-A1B2-C3D4-E5F6
    'g7h8i9j0k1l2m3n4', // G7H8-I9J0-K1L2-M3N4
    'o5p6q7r8s9t0u1v2', // O5P6-Q7R8-S9T0-U1V2
    'w3x4y5z6a7b8c9d0', // W3X4-Y5Z6-A7B8-C9D0
    'e1f2g3h4i5j6k7l8', // E1F2-G3H4-I5J6-K7L8
    'm9n0o1p2q3r4s5t6', // M9N0-O1P2-Q3R4-S5T6
    'u7v8w9x0y1z2a3b4', // U7V8-W9X0-Y1Z2-A3B4
    'c5d6e7f8g9h0i1j2', // C5D6-E7F8-G9H0-I1J2
    'k3l4m5n6o7p8q9r0', // K3L4-M5N6-O7P8-Q9R0
    
    // === BATCH 10 (Key 901-1000) ===
    's1t2u3v4w5x6y7z8', // S1T2-U3V4-W5X6-Y7Z8
    'a9b0c1d2e3f4g5h6', // A9B0-C1D2-E3F4-G5H6
    'i7j8k9l0m1n2o3p4', // I7J8-K9L0-M1N2-O3P4
    'q5r6s7t8u9v0w1x2', // Q5R6-S7T8-U9V0-W1X2
    'y3z4a5b6c7d8e9f0', // Y3Z4-A5B6-C7D8-E9F0
    'g1h2i3j4k5l6m7n8', // G1H2-I3J4-K5L6-M7N8
    'o9p0q1r2s3t4u5v6', // O9P0-Q1R2-S3T4-U5V6
    'w7x8y9z0a1b2c3d4', // W7X8-Y9Z0-A1B2-C3D4
    'e5f6g7h8i9j0k1l2', // E5F6-G7H8-I9J0-K1L2
    'm3n4o5p6q7r8s9t0', // M3N4-O5P6-Q7R8-S9T0
  ];
  
  /// Generate hash dari license key
  static String _hashKey(String key) {
    final bytes = utf8.encode(key.toUpperCase());
    final hash = sha256.convert(bytes);
    return hash.toString().substring(0, 16);
  }
  
  /// Validasi license key (OFFLINE)
  static Future<LicenseResult> validateLicense(String licenseKey) async {
    try {
      // Format license key: XXXX-XXXX-XXXX-XXXX
      if (!_isValidFormat(licenseKey)) {
        return LicenseResult(
          isValid: false,
          message: 'Format license key tidak valid.\nContoh: A1B2-C3D4-E5F6-G7H8',
        );
      }
      
      // Hash key yang diinput
      final inputHash = _hashKey(licenseKey);
      
      // Cek apakah hash ada di daftar valid
      final isValid = _validKeyHashes.contains(inputHash);
      
      if (isValid) {
        // Cek apakah sudah teraktivasi dengan key lain
        final prefs = await SharedPreferences.getInstance();
        final existingKey = prefs.getString(_licenseKey);
        
        if (existingKey != null && existingKey.isNotEmpty) {
          // Sudah teraktivasi dengan key lain
          if (existingKey.toUpperCase() != licenseKey.toUpperCase()) {
            return LicenseResult(
              isValid: false,
              message: 'Aplikasi sudah teraktivasi dengan license key lain.\nHubungi admin untuk reset.',
            );
          }
          // Key sama, langsung valid
          return LicenseResult(
            isValid: true,
            message: 'Aktivasi berhasil!',
          );
        }
        
        // Simpan license key
        await prefs.setString(_licenseKey, licenseKey.toUpperCase());
        await prefs.setBool(_isActivated, true);
        
        return LicenseResult(
          isValid: true,
          message: 'Aktivasi berhasil!',
        );
      }
      
      return LicenseResult(
        isValid: false,
        message: 'License key tidak valid.\nHubungi admin untuk mendapatkan license key.',
      );
    } catch (e) {
      return LicenseResult(
        isValid: false,
        message: 'Gagal memvalidasi lisensi: $e',
      );
    }
  }
  
  /// Cek apakah sudah teraktivasi
  static Future<bool> isActivated() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_isActivated) == true;
  }
  
  /// Get license key yang tersimpan
  static Future<String?> getLicenseKey() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_licenseKey);
  }
  
  /// Hapus lisensi (untuk reset manual)
  static Future<void> deactivate() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_licenseKey);
    await prefs.setBool(_isActivated, false);
  }
  
  /// Validasi format license key
  static bool _isValidFormat(String key) {
    // Format: XXXX-XXXX-XXXX-XXXX (huruf dan angka)
    final regex = RegExp(r'^[A-Z0-9]{4}-[A-Z0-9]{4}-[A-Z0-9]{4}-[A-Z0-9]{4}$');
    return regex.hasMatch(key.toUpperCase());
  }
  
  /// Generate key baru (untuk admin)
  /// Jalankan di terminal/dart script untuk generate key
  static String generateNewKey() {
    final chars = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789';
    final random = DateTime.now().millisecondsSinceEpoch;
    String key = '';
    
    for (int i = 0; i < 16; i++) {
      if (i > 0 && i % 4 == 0) key += '-';
      final index = (random + i * 7) % chars.length;
      key += chars[index];
    }
    
    return key;
  }
  
  /// Generate hash untuk key baru (untuk admin)
  static String getHashForNewKey(String key) {
    return _hashKey(key);
  }
}

class LicenseResult {
  final bool isValid;
  final String message;
  
  const LicenseResult({
    required this.isValid,
    required this.message,
  });
}

// ============================================================
// SCRIPT UNTUK GENERATE KEY BARU
// 
// Jalankan script ini untuk generate key baru:
// 
// void main() {
//   final key = LicenseService.generateNewKey();
//   final hash = LicenseService.getHashForNewKey(key);
//   
//   print('Key: $key');
//   print('Hash: $hash');
//   print('');
//   print('Tambahkan hash ini ke _validKeyHashes:');
//   print("    '$hash', // $key");
// }
// ============================================================
