import 'package:flutter/material.dart';
import 'package:kelasfun/core/services/license_service.dart';
import 'package:kelasfun/core/theme/app_theme.dart';

class ActivationScreen extends StatefulWidget {
  final VoidCallback onActivated;
  
  const ActivationScreen({super.key, required this.onActivated});

  @override
  State<ActivationScreen> createState() => _ActivationScreenState();
}

class _ActivationScreenState extends State<ActivationScreen> {
  final _licenseController = TextEditingController();
  bool _isLoading = false;
  String? _error;
  String? _deviceId;

  @override
  void initState() {
    super.initState();
    _loadDeviceId();
  }

  Future<void> _loadDeviceId() async {
    final deviceId = await LicenseService.getDeviceId();
    setState(() => _deviceId = deviceId);
  }

  Future<void> _activate() async {
    final licenseKey = _licenseController.text.trim();
    
    if (licenseKey.isEmpty) {
      setState(() => _error = 'Masukkan license key');
      return;
    }

    setState(() {
      _isLoading = true;
      _error = null;
    });

    final result = await LicenseService.validateLicense(licenseKey);

    setState(() => _isLoading = false);

    if (result.isValid) {
      widget.onActivated();
    } else {
      setState(() => _error = result.message);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.lock_outline,
                  size: 80,
                  color: AppTheme.accent,
                ),
                const SizedBox(height: 24),
                Text(
                  'Aktivasi kelasFun',
                  style: AppTheme.h1(context),
                ),
                const SizedBox(height: 8),
                Text(
                  'Masukkan license key untuk mengaktifkan aplikasi',
                  style: AppTheme.body(context),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 32),
                Container(
                  width: double.infinity,
                  constraints: const BoxConstraints(maxWidth: 400),
                  child: TextField(
                    controller: _licenseController,
                    decoration: InputDecoration(
                      labelText: 'License Key',
                      hintText: 'XXXX-XXXX-XXXX-XXXX',
                      border: const OutlineInputBorder(),
                      prefixIcon: const Icon(Icons.vpn_key),
                      errorText: _error,
                    ),
                    textCapitalization: TextCapitalization.characters,
                    onSubmitted: (_) => _activate(),
                  ),
                ),
                const SizedBox(height: 16),
                if (_deviceId != null)
                  Container(
                    width: double.infinity,
                    constraints: const BoxConstraints(maxWidth: 400),
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: AppTheme.surface,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Device ID Anda:',
                          style: AppTheme.caption(context),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          _deviceId!,
                          style: AppTheme.bodySmall(context).copyWith(
                            fontFamily: 'monospace',
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Simpan Device ID ini untuk keperluan reset lisensi',
                          style: AppTheme.caption(context).copyWith(
                            color: AppTheme.amber,
                          ),
                        ),
                      ],
                    ),
                  ),
                const SizedBox(height: 24),
                SizedBox(
                  width: double.infinity,
                  constraints: const BoxConstraints(maxWidth: 400),
                  child: FilledButton(
                    onPressed: _isLoading ? null : _activate,
                    child: _isLoading
                        ? const SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.white,
                            ),
                          )
                        : const Text('Aktivasi'),
                  ),
                ),
                const SizedBox(height: 16),
                TextButton(
                  onPressed: () {
                    // Tampilkan info kontak admin
                    showDialog(
                      context: context,
                      builder: (context) => AlertDialog(
                        title: const Text('Beli License Key'),
                        content: Column(
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text('Hubungi admin untuk membeli license key:'),
                            const SizedBox(height: 12),
                            Text(
                              'WhatsApp: 08xxxxxxxxxx',
                              style: AppTheme.body(context),
                            ),
                            Text(
                              'Email: admin@kelasfun.com',
                              style: AppTheme.body(context),
                            ),
                            const SizedBox(height: 12),
                            Text(
                              'Sertakan Device ID Anda saat membeli:',
                              style: AppTheme.caption(context),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              _deviceId ?? '-',
                              style: AppTheme.bodySmall(context).copyWith(
                                fontFamily: 'monospace',
                              ),
                            ),
                          ],
                        ),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.pop(context),
                            child: const Text('Tutup'),
                          ),
                        ],
                      ),
                    );
                  },
                  child: const Text('Belum punya license?'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _licenseController.dispose();
    super.dispose();
  }
}
