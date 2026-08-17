import 'dart:convert';
import 'package:crypto/crypto.dart';

/// Script untuk generate license key baru
/// 
/// Cara pakai:
/// 1. Jalankan script ini: dart generate_keys.dart
/// 2. Copy hash yang dihasilkan
/// 3. Tambahkan ke list _validKeyHashes di license_service.dart

void main() {
  print('=== LICENSE KEY GENERATOR ===');
  print('');
  
  // Generate 10 key baru
  for (int i = 0; i < 10; i++) {
    final key = _generateKey();
    final hash = _hashKey(key);
    
    print('Key ${i + 1}: $key');
    print('Hash:    $hash');
    print('Copy:    \'$hash\', // $key');
    print('');
  }
  
  print('=== CARA MENAMBAH KE APLIKASI ===');
  print('1. Copy baris "Copy:" di atas');
  print('2. Buka lib/core/services/license_service.dart');
  print('3. Tambahkan ke list _validKeyHashes');
  print('4. Build ulang aplikasi');
}

String _generateKey() {
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

String _hashKey(String key) {
  final bytes = utf8.encode(key.toUpperCase());
  final hash = sha256.convert(bytes);
  return hash.toString().substring(0, 16);
}
