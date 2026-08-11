class PairingConfig {
  final String ip;
  final int port;
  final String? token;

  const PairingConfig({required this.ip, required this.port, this.token});

  factory PairingConfig.fromJson(Map<String, dynamic> json) {
    return PairingConfig(
      ip: json['ip'] as String,
      port: (json['port'] as num).toInt(),
      token: json['token'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'ip': ip,
      'port': port,
      'token': token,
    };
  }
}
