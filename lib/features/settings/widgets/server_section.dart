import 'package:flutter/material.dart';
import 'package:kelasfun/core/theme/app_theme.dart';
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
    final colorScheme = Theme.of(context).colorScheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Sync Server', style: AppTheme.h3(context)),
        const SizedBox(height: AppTheme.spacingSm),
        Row(
          children: [
            Icon(
              isRunning ? Icons.check_circle : Icons.cancel,
              color: isRunning ? colorScheme.secondary : colorScheme.error,
            ),
            const SizedBox(width: AppTheme.spacingSm),
            Text(
              isRunning ? 'Server Aktif' : 'Server Mati',
              style: AppTheme.body(context),
            ),
          ],
        ),
        if (isRunning) ...[
          const SizedBox(height: AppTheme.spacingSm),
          Text('URL: $serverUrl', style: AppTheme.caption(context).copyWith(fontFamily: 'monospace')),
          const SizedBox(height: AppTheme.spacingXs),
          Text('Port: 8080', style: AppTheme.caption(context)),
        ],
        const SizedBox(height: AppTheme.spacingBase),
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
