import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:kelasfun/core/services/license_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  SharedPreferences.setMockInitialValues({});

  group('LicenseService.requestSerialNumber', () {
    test('berhasil ketika server merespon 200 success', () async {
      final client = MockClient((request) async {
        expect(request.url.path, '/functions/v1/generate-license');
        final body = jsonDecode(request.body) as Map<String, dynamic>;
        expect(body['email'], 'guru@sekolah.sch.id');
        expect(body['device_id'], isNotEmpty);
        return http.Response(
          jsonEncode({'success': true, 'message': 'Serial terkirim'}),
          200,
        );
      });

      final result = await LicenseService.requestSerialNumber(
        'guru@sekolah.sch.id',
        httpClient: client,
      );

      expect(result.isValid, isTrue);
      expect(result.message, 'Serial terkirim');
    });

    test('SocketException jaringan biasa menghasilkan pesan tidak ada internet', () async {
      final client = MockClient((request) async {
        throw const SocketException('Network unreachable');
      });

      final result = await LicenseService.requestSerialNumber(
        'guru@sekolah.sch.id',
        httpClient: client,
      );

      expect(result.isValid, isFalse);
      expect(result.message, contains('Tidak ada internet'));
    });

    test('DNS gagal (Failed host lookup) menghasilkan pesan server tidak dapat dihubungi', () async {
      final client = MockClient((request) async {
        throw const SocketException("Failed host lookup: 'cdgnqhdmsnrlzylgoecz.supabase.co'");
      });

      final result = await LicenseService.requestSerialNumber(
        'guru@sekolah.sch.id',
        httpClient: client,
      );

      expect(result.isValid, isFalse);
      expect(result.message, contains('Server aktivasi tidak dapat dihubungi'));
      expect(result.message, isNot(contains('Tidak ada internet')));
    });

    test('TimeoutException menghasilkan pesan koneksi lambat', () async {
      final client = MockClient((request) async {
        throw TimeoutException('Connection timed out');
      });

      final result = await LicenseService.requestSerialNumber(
        'guru@sekolah.sch.id',
        httpClient: client,
      );

      expect(result.isValid, isFalse);
      expect(result.message, contains('Koneksi'));
    });

    test('error non-jaringan menampilkan detail error, bukan pesan offline', () async {
      final client = MockClient((request) async {
        throw const HttpException('TLS handshake failed');
      });

      final result = await LicenseService.requestSerialNumber(
        'guru@sekolah.sch.id',
        httpClient: client,
      );

      expect(result.isValid, isFalse);
      expect(result.message, isNot(contains('Tidak ada internet')));
      expect(result.message, contains('TLS handshake failed'));
    });

    test('HTTP error dari server menyertakan pesan error dari body', () async {
      final client = MockClient((request) async {
        return http.Response(
          jsonEncode({'success': false, 'error': 'Terlalu banyak permintaan'}),
          429,
        );
      });

      final result = await LicenseService.requestSerialNumber(
        'guru@sekolah.sch.id',
        httpClient: client,
      );

      expect(result.isValid, isFalse);
      expect(result.networkError, isFalse);
      expect(result.message, contains('Terlalu banyak permintaan'));
    });
  });

  group('LicenseService.verifySerialNumber', () {
    test('format salah ditolak tanpa request', () async {
      var called = false;
      final client = MockClient((request) async {
        called = true;
        return http.Response('{}', 200);
      });

      final result = await LicenseService.verifySerialNumber(
        'SERIAL-SALAH',
        httpClient: client,
      );

      expect(called, isFalse);
      expect(result.isValid, isFalse);
    });

    test('aktivasi berhasil menyimpan status dan mengembalikan pesan server', () async {
      final client = MockClient((request) async {
        expect(request.url.path, '/functions/v1/verify-license');
        return http.Response(
          jsonEncode({'valid': true, 'message': 'Aktivasi berhasil!'}),
          200,
        );
      });

      final result = await LicenseService.verifySerialNumber(
        'KF-AB12-CD34',
        httpClient: client,
      );

      expect(result.isValid, isTrue);
      expect(result.message, 'Aktivasi berhasil!');
    });

    test('SocketException jaringan biasa pada aktivasi menghasilkan pesan offline', () async {
      final client = MockClient((request) async {
        throw const SocketException('Connection refused');
      });

      final result = await LicenseService.verifySerialNumber(
        'KF-AB12-CD34',
        httpClient: client,
      );

      expect(result.isValid, isFalse);
      expect(result.message, contains('Tidak ada internet'));
    });

    test('DNS gagal pada aktivasi menghasilkan pesan server tidak dapat dihubungi', () async {
      final client = MockClient((request) async {
        throw const SocketException('Failed host lookup', osError: OSError('No address associated with hostname', 7));
      });

      final result = await LicenseService.verifySerialNumber(
        'KF-AB12-CD34',
        httpClient: client,
      );

      expect(result.isValid, isFalse);
      expect(result.message, contains('Server aktivasi tidak dapat dihubungi'));
      expect(result.message, isNot(contains('Tidak ada internet')));
    });

    test('error non-jaringan pada aktivasi menampilkan detail error', () async {
      final client = MockClient((request) async {
        throw const HttpException('Certificate expired');
      });

      final result = await LicenseService.verifySerialNumber(
        'KF-AB12-CD34',
        httpClient: client,
      );

      expect(result.isValid, isFalse);
      expect(result.message, isNot(contains('Tidak ada internet')));
      expect(result.message, contains('Certificate expired'));
    });
  });
}
