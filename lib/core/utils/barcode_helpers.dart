import 'dart:convert';

class BarcodeHelpers {
  static Map<String, dynamic>? parseQrPayload(String payload) {
    try {
      final decoded = jsonDecode(payload);
      if (decoded is Map<String, dynamic>) {
        return decoded;
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  static String cleanScannedInput(String input) {
    return input.trim();
  }

  static String extractNisFromScan(String input) {
    final cleaned = cleanScannedInput(input);
    final parsed = parseQrPayload(cleaned);
    if (parsed != null && parsed.containsKey('n')) {
      return parsed['n'].toString();
    }
    return cleaned;
  }
}
