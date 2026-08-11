import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:kelasfun/features/android/android_home.dart';
import 'package:kelasfun/features/android/android_pairing_screen.dart';
import 'package:kelasfun/features/android/android_scanner.dart';
import 'package:kelasfun/features/android/scanner_controller.dart';
import 'package:kelasfun/features/android/scanner_service.dart';
import 'package:kelasfun/core/theme/app_theme.dart';
import 'package:shared_preferences/shared_preferences.dart';

ScannerService _serviceWithClient(MockClient client) {
  return ScannerService(client: client);
}

Future<void> _pumpApp(WidgetTester tester, Widget home) async {
  await tester.pumpWidget(MaterialApp(
    theme: AppTheme.darkTheme,
    home: home,
  ));
  await tester.pump();
}

void main() {
  setUp(() {
    TestWidgetsFlutterBinding.ensureInitialized();
    SharedPreferences.setMockInitialValues({});
    // Silence platform channels (haptics/system sound) in tests.
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(SystemChannels.platform, (call) async => null);
  });

  group('AndroidHome', () {
    testWidgets('shows "Belum terhubung" when no pairing saved', (tester) async {
      final home = AndroidHome(service: ScannerService(), scannerBuilder: FakeScannerController.new);
      await _pumpApp(tester, home);

      expect(find.text('Belum terhubung'), findsOneWidget);
      expect(find.text('Pindai QR Laptop'), findsOneWidget);
      expect(find.text('Buka Scanner'), findsOneWidget);
    });

    testWidgets('shows saved IP when pairing exists', (tester) async {
      SharedPreferences.setMockInitialValues({
        'pairing_config': jsonEncode({'ip': '192.168.1.50', 'port': 8080, 'token': 'kelasfun-secret-key'}),
      });
      final home = AndroidHome(service: ScannerService(), scannerBuilder: FakeScannerController.new);
      await _pumpApp(tester, home);
      await tester.pump();

      expect(find.textContaining('192.168.1.50'), findsWidgets);
      expect(find.text('Belum terhubung'), findsNothing);
    });
  });

  group('AndroidHome sync', () {
    testWidgets('shows pending scan count', (tester) async {
      SharedPreferences.setMockInitialValues({
        'pairing_config': jsonEncode({'ip': '192.168.1.50', 'port': 8080, 'token': 'kelasfun-secret-key'}),
        'scan_queue': jsonEncode([
          {'nis': '12345', 'timestamp': '2026-08-11T01:00:00.000Z'},
          {'nis': '67890', 'timestamp': '2026-08-11T02:00:00.000Z'},
          {'nis': '11223', 'timestamp': '2026-08-11T03:00:00.000Z'},
        ]),
      });
      final home = AndroidHome(service: ScannerService(), scannerBuilder: FakeScannerController.new);
      await _pumpApp(tester, home);
      await tester.pump();

      expect(find.textContaining('3 scan menunggu sinkron'), findsOneWidget);
    });

    testWidgets('shows "Sinkron" button', (tester) async {
      SharedPreferences.setMockInitialValues({
        'pairing_config': jsonEncode({'ip': '192.168.1.50', 'port': 8080, 'token': 'kelasfun-secret-key'}),
      });
      final home = AndroidHome(service: ScannerService(), scannerBuilder: FakeScannerController.new);
      await _pumpApp(tester, home);
      await tester.pump();

      expect(find.text('Sinkron'), findsOneWidget);
    });

    testWidgets('tapping Sinkron shows sync result banner', (tester) async {
      SharedPreferences.setMockInitialValues({
        'pairing_config': jsonEncode({'ip': '192.168.1.50', 'port': 8080, 'token': 'kelasfun-secret-key'}),
      });
      final client = MockClient((request) async {
        if (request.method == 'GET') {
          return http.Response(jsonEncode({'students': []}), 200,
              headers: {'content-type': 'application/json'});
        }
        return http.Response(
          jsonEncode({'success': true, 'student': {'name': 'Rina', 'className': 'X RPL 1', 'status': 'Hadir'}}),
          200,
          headers: {'content-type': 'application/json'},
        );
      });
      final home = AndroidHome(
        service: _serviceWithClient(client),
        scannerBuilder: FakeScannerController.new,
      );
      await _pumpApp(tester, home);
      await tester.pump();

      await tester.tap(find.text('Sinkron'));
      await tester.pump();
      await tester.pump();

      expect(find.textContaining('Sinkron selesai'), findsOneWidget);
    });
  });

  group('AndroidPairingScreen', () {
    testWidgets('saves config from valid laptop QR payload', (tester) async {
      var saved = false;
      final controller = FakeScannerController();
      await _pumpApp(
        tester,
        AndroidPairingScreen(
          service: ScannerService(),
          controller: controller,
          onSaved: () => saved = true,
        ),
      );

      controller.emit(
        '{"ip":"192.168.1.55","port":8080,"token":"kelasfun-secret-key"}',
      );
      await tester.pump();
      await tester.pump();

      expect(saved, isTrue);
      final service = ScannerService();
      final config = await service.loadConfig();
      expect(config, isNotNull);
      expect(config!.ip, '192.168.1.55');
      expect(config.port, 8080);
    });

    testWidgets('ignores invalid payload and stays on screen', (tester) async {
      var saved = false;
      final controller = FakeScannerController();
      await _pumpApp(
        tester,
        AndroidPairingScreen(
          service: ScannerService(),
          controller: controller,
          onSaved: () => saved = true,
        ),
      );

      controller.emit('bukan-json');
      await tester.pump();
      await tester.pump();

      expect(saved, isFalse);
      expect(find.text('QR tidak valid'), findsOneWidget);
    });
  });

  group('AndroidScanner', () {
    testWidgets('happy path shows success banner then resets', (tester) async {
      SharedPreferences.setMockInitialValues({
        'pairing_config': jsonEncode({'ip': '192.168.1.50', 'port': 8080, 'token': 'kelasfun-secret-key'}),
      });
      final client = MockClient((request) async {
        return http.Response(
          jsonEncode({
            'success': true,
            'student': {'name': 'Rina', 'className': 'X RPL 1', 'status': 'Hadir'},
          }),
          200,
          headers: {'content-type': 'application/json'},
        );
      });
      final controller = FakeScannerController();
      await _pumpApp(
        tester,
        AndroidScanner(
          service: _serviceWithClient(client),
          controller: controller,
        ),
      );

      controller.emit('{"n":"12345"}');
      await tester.pump();
      await tester.pump();

      expect(find.textContaining('Rina'), findsOneWidget);
      expect(find.textContaining('Hadir'), findsOneWidget);

      // Auto-reset after ~1s.
      await tester.pump(const Duration(seconds: 2));
      expect(find.textContaining('Rina'), findsNothing);
    });

    testWidgets('error path shows error banner then resets', (tester) async {
      SharedPreferences.setMockInitialValues({
        'pairing_config': jsonEncode({'ip': '192.168.1.50', 'port': 8080, 'token': 'kelasfun-secret-key'}),
      });
      final client = MockClient((request) async {
        return http.Response(
          jsonEncode({'success': false, 'error': 'Siswa tidak ditemukan'}),
          404,
          headers: {'content-type': 'application/json'},
        );
      });
      final controller = FakeScannerController();
      await _pumpApp(
        tester,
        AndroidScanner(
          service: _serviceWithClient(client),
          controller: controller,
        ),
      );

      controller.emit('{"n":"999999"}');
      await tester.pump();
      await tester.pump();

      expect(find.textContaining('Siswa tidak ditemukan'), findsOneWidget);

      // Auto-reset after ~1.5s.
      await tester.pump(const Duration(seconds: 3));
      expect(find.textContaining('Siswa tidak ditemukan'), findsNothing);
    });
  });
}
