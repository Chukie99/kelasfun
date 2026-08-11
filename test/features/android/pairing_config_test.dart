import 'package:flutter_test/flutter_test.dart';
import 'package:kelasfun/features/android/pairing_config.dart';

void main() {
  test('toJson serializes ip, port, token', () {
    const config = PairingConfig(ip: '192.168.1.50', port: 8080, token: 'kelasfun-secret-key');
    expect(config.toJson(), {
      'ip': '192.168.1.50',
      'port': 8080,
      'token': 'kelasfun-secret-key',
    });
  });

  test('fromJson round-trips a full config', () {
    final json = {
      'ip': '192.168.1.50',
      'port': 8080,
      'token': 'kelasfun-secret-key',
    };
    final config = PairingConfig.fromJson(json);
    expect(config.ip, '192.168.1.50');
    expect(config.port, 8080);
    expect(config.token, 'kelasfun-secret-key');
  });

  test('token is optional and serializes as null', () {
    const config = PairingConfig(ip: '192.168.1.50', port: 8080);
    expect(config.toJson(), {'ip': '192.168.1.50', 'port': 8080, 'token': null});
  });
}
