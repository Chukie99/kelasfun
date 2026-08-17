import 'package:flutter/material.dart';
import 'package:kelasfun/core/services/license_service.dart';
import 'package:kelasfun/core/theme/app_theme.dart';

class ActivationScreen extends StatefulWidget {
  final VoidCallback onActivated;
  
  const ActivationScreen({
    super.key,
    required this.onActivated,
  });
  
  @override
  State<ActivationScreen> createState() => _ActivationScreenState();
}

class _ActivationScreenState extends State<ActivationScreen> {
  final _licenseController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool _isLoading = false;
  String? _errorMessage;
  String? _deviceId;
  
  @override
  void initState() {
    super.initState();
    _loadDeviceId();
  }
  
  Future<void> _loadDeviceId() async {
    final deviceId = await LicenseService.getDeviceId();
    setState(() {
      _deviceId = deviceId;
    });
  }
  
  @override
  void dispose() {
    _licenseController.dispose();
    super.dispose();
  }
  
  Future<void> _activate() async {
    if (!_formKey.currentState!.validate()) return;
    
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });
    
    final licenseKey = _licenseController.text.trim();
    final result = await LicenseService.validateLicense(licenseKey);
    
    setState(() {
      _isLoading = false;
    });
    
    if (result.isValid) {
      widget.onActivated();
    } else {
      setState(() {
        _errorMessage = result.message;
      });
    }
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.background,
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Card(
              color: AppTheme.surface,
              elevation: 8,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              child: Padding(
                padding: const EdgeInsets.all(32),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 100,
                      height: 100,
                      decoration: BoxDecoration(
                        color: AppTheme.accent,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.school,
                        size: 60,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 24),
                    
                    Text(
                      'Aktivasi kelasFun',
                      style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: AppTheme.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Masukkan license key yang Anda dapatkan',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: AppTheme.textSecondary,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 32),
                    
                    Form(
                      key: _formKey,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          TextFormField(
                            controller: _licenseController,
                            style: const TextStyle(color: AppTheme.textPrimary),
                            decoration: InputDecoration(
                              labelText: 'License Key',
                              labelStyle: const TextStyle(color: AppTheme.textSecondary),
                              hintText: 'XXXX-XXXX-XXXX-XXXX',
                              hintStyle: const TextStyle(color: AppTheme.textTertiary),
                              prefixIcon: const Icon(Icons.vpn_key, color: AppTheme.accent),
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: const BorderSide(color: AppTheme.border),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: const BorderSide(color: AppTheme.accent),
                              ),
                            ),
                            textCapitalization: TextCapitalization.characters,
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Masukkan license key';
                              }
                              if (!RegExp(r'^[A-Z0-9]{4}-[A-Z0-9]{4}-[A-Z0-9]{4}-[A-Z0-9]{4}$').hasMatch(value.toUpperCase())) {
                                return 'Format: XXXX-XXXX-XXXX-XXXX';
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 16),
                          
                          if (_deviceId != null) ...[
                            Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: AppTheme.surfaceLight,
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Device ID Anda:',
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: AppTheme.textTertiary,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    _deviceId!,
                                    style: const TextStyle(
                                      fontSize: 10,
                                      fontFamily: 'monospace',
                                      color: AppTheme.textSecondary,
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 16),
                          ],
                          
                          if (_errorMessage != null) ...[
                            Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: AppTheme.coralSoft,
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(color: AppTheme.coral),
                              ),
                              child: Text(
                                _errorMessage!,
                                style: const TextStyle(color: AppTheme.coral),
                              ),
                            ),
                            const SizedBox(height: 16),
                          ],
                          
                          ElevatedButton(
                            onPressed: _isLoading ? null : _activate,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppTheme.accent,
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            child: _isLoading
                                ? const SizedBox(
                                    height: 20,
                                    width: 20,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                                    ),
                                  )
                                : const Text(
                                    'Aktivasi',
                                    style: TextStyle(fontSize: 16),
                                  ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),
                    
                    Text(
                      'Belum punya license key?',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: AppTheme.textSecondary,
                      ),
                    ),
                    const SizedBox(height: 8),
                    OutlinedButton(
                      onPressed: () {},
                      style: OutlinedButton.styleFrom(
                        foregroundColor: AppTheme.accent,
                        side: const BorderSide(color: AppTheme.accent),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: const Text('Hubungi Admin'),
                    ),
                    const SizedBox(height: 16),
                    
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: AppTheme.accentSoft,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Column(
                        children: [
                          Text(
                            'Cara Mendapatkan License Key:',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: AppTheme.accent,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            '1. Beli di Link.id/kelasfun\n'
                            '2. Terima key via Email/WhatsApp\n'
                            '3. Masukkan key di atas',
                            style: TextStyle(
                              fontSize: 12,
                              color: AppTheme.textSecondary,
                            ),
                            textAlign: TextAlign.left,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
