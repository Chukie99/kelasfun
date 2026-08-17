class SyncConfig {
  String serverUrl;
  String apiKey;

  SyncConfig({
    required this.serverUrl,
    required this.apiKey,
  });

  Map<String, dynamic> toJson() => {
    'serverUrl': serverUrl,
    'apiKey': apiKey,
  };

  factory SyncConfig.fromJson(Map<String, dynamic> json) {
    final serverUrl = json['serverUrl'] as String?;
    if (serverUrl == null || serverUrl.isEmpty) {
      throw ArgumentError('serverUrl is required');
    }
    final apiKey = json['apiKey'] as String?;
    if (apiKey == null || apiKey.isEmpty) {
      throw ArgumentError('apiKey is required');
    }
    return SyncConfig(
      serverUrl: serverUrl,
      apiKey: apiKey,
    );
  }
}
