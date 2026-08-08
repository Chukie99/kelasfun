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

  factory SyncConfig.fromJson(Map<String, dynamic> json) => SyncConfig(
    serverUrl: json['serverUrl'] as String,
    apiKey: json['apiKey'] as String,
  );
}
