import 'package:flutter_test/flutter_test.dart';
import 'package:kelasfun/core/sync/sync_config.dart';

void main() {
  group('SyncConfig', () {
    test('creates from json', () {
      final config = SyncConfig.fromJson({
        'serverUrl': 'http://192.168.1.100:8080',
        'apiKey': 'my-secret-key',
      });
      expect(config.serverUrl, 'http://192.168.1.100:8080');
      expect(config.apiKey, 'my-secret-key');
    });

    test('serializes to json', () {
      final config = SyncConfig(
        serverUrl: 'http://192.168.1.100:8080',
        apiKey: 'my-secret-key',
      );
      final json = config.toJson();
      expect(json['serverUrl'], 'http://192.168.1.100:8080');
      expect(json['apiKey'], 'my-secret-key');
    });
  });
}
