import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:kelasfun/features/settings/widgets/pairing_qr.dart';

void main() {
  testWidgets('PairingQr embeds the provided real IP in its QR payload',
      (tester) async {
    await tester.pumpWidget(const MaterialApp(
      home: Scaffold(
        body: PairingQr(ip: '192.168.1.55', port: 8080, token: 'kelasfun-secret-key'),
      ),
    ));

    expect(find.byType(QrImageView), findsOneWidget);

    final qr = tester.widget<PairingQr>(find.byType(PairingQr));
    expect(qr.payload, contains('"ip":"192.168.1.55"'));
    expect(qr.payload, contains('"port":8080'));
    expect(qr.payload, contains('"token":"kelasfun-secret-key"'));

    expect(find.textContaining('192.168.1.55'), findsWidgets);
  });
}
