import 'package:flutter/material.dart';
import 'package:kelasfun/shared/widgets/app_button.dart';

class ServerSection extends StatelessWidget {
  final bool isRunning;
  final String serverUrl;
  final VoidCallback onToggle;

  const ServerSection({
    super.key,
    required this.isRunning,
    required this.serverUrl,
    required this.onToggle,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Sync Server',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
        const SizedBox(height: 8),
        Row(
          children: [
            Icon(
              isRunning ? Icons.check_circle : Icons.cancel,
              color: isRunning ? Colors.green : Colors.red,
            ),
            const SizedBox(width: 8),
            Text(isRunning ? 'Server Aktif' : 'Server Mati'),
          ],
        ),
        if (isRunning) ...[
          const SizedBox(height: 8),
          Text('URL: $serverUrl',
              style: const TextStyle(fontFamily: 'monospace')),
          const SizedBox(height: 4),
          const Text('Port: 8080'),
        ],
        const SizedBox(height: 16),
        AppButton(
          label: isRunning ? 'Matikan Server' : 'Nyalakan Server',
          icon: isRunning ? Icons.stop : Icons.play_arrow,
          isOutlined: !isRunning,
          onPressed: onToggle,
        ),
      ],
    );
  }
}
