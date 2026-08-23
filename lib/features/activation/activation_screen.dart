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
  final _emailController = TextEditingController();
  final _serialController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool _isLoading = false;
  bool _serialSent = false;
  String? _errorMessage;
  String? _successMessage;

  @override
  void dispose() {
    _emailController.dispose();
    _serialController.dispose();
    super.dispose();
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
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              child: Padding(
                padding: const EdgeInsets.all(32),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 80, height: 80,
                      decoration: const BoxDecoration(color: AppTheme.accent, shape: BoxShape.circle),
                      child: const Icon(Icons.school, size: 48, color: Colors.white),
                    ),
                    const SizedBox(height: 20),
                    const Text('Aktivasi kelasFun', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: AppTheme.textPrimary)),
                    const SizedBox(height: 8),
                    Text(
                      _serialSent ? 'Masukkan serial number' : 'Masukkan email untuk mendapatkan serial',
                      style: const TextStyle(color: AppTheme.textSecondary),
                    ),
                    const SizedBox(height: 24),

                    Form(
                      key: _formKey,
                      child: Column(
                        children: [
                          if (!_serialSent) ...[
                            TextFormField(
                              controller: _emailController,
                              keyboardType: TextInputType.emailAddress,
                              style: const TextStyle(color: AppTheme.textPrimary, fontSize: 16),
                              decoration: InputDecoration(
                                hintText: 'Email',
                                prefixIcon: const Icon(Icons.email_outlined, color: AppTheme.textTertiary),
                                hintStyle: const TextStyle(color: AppTheme.textTertiary),
                                filled: true,
                                fillColor: AppTheme.surfaceLight,
                                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                              ),
                            ),
                          ] else ...[
                            TextFormField(
                              controller: _serialController,
                              style: const TextStyle(color: AppTheme.textPrimary, fontSize: 18, letterSpacing: 2),
                              textAlign: TextAlign.center,
                              decoration: InputDecoration(
                                hintText: 'KF-XXXX-XXXX',
                                hintStyle: const TextStyle(color: AppTheme.textTertiary),
                                filled: true,
                                fillColor: AppTheme.surfaceLight,
                                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                              ),
                              textCapitalization: TextCapitalization.characters,
                            ),
                            const SizedBox(height: 8),
                            Align(
                              alignment: Alignment.centerLeft,
                              child: TextButton(
                                onPressed: _isLoading ? null : _goBackToEmail,
                                child: const Text('Ganti email', style: TextStyle(color: AppTheme.accent)),
                              ),
                            ),
                          ],

                          const SizedBox(height: 8),

                          if (_errorMessage != null)
                            Container(
                              width: double.infinity,
                              padding: const EdgeInsets.all(12),
                              margin: const EdgeInsets.only(bottom: 16),
                              decoration: BoxDecoration(color: AppTheme.coralSoft, borderRadius: BorderRadius.circular(8)),
                              child: Text(_errorMessage!, style: const TextStyle(color: AppTheme.coral)),
                            ),

                          if (_successMessage != null)
                            Container(
                              width: double.infinity,
                              padding: const EdgeInsets.all(12),
                              margin: const EdgeInsets.only(bottom: 16),
                              decoration: BoxDecoration(color: Colors.green.shade50, borderRadius: BorderRadius.circular(8)),
                              child: Text(_successMessage!, style: TextStyle(color: Colors.green.shade700)),
                            ),

                          SizedBox(
                            width: double.infinity,
                            height: 50,
                            child: ElevatedButton(
                              onPressed: _isLoading ? null : (_serialSent ? _activate : _requestSerial),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppTheme.accent,
                                foregroundColor: Colors.white,
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                              ),
                              child: _isLoading
                                  ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                                  : Text(
                                      _serialSent ? 'Aktivasi' : 'Kirim Serial Number',
                                      style: const TextStyle(fontSize: 16),
                                    ),
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 20),
                    const Text('Beli di Lynk.id', style: TextStyle(color: AppTheme.textTertiary, fontSize: 12)),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  void _goBackToEmail() {
    setState(() {
      _serialSent = false;
      _errorMessage = null;
      _successMessage = null;
      _serialController.clear();
    });
  }

  Future<void> _requestSerial() async {
    final email = _emailController.text.trim();
    if (email.isEmpty || !email.contains('@')) {
      setState(() => _errorMessage = 'Masukkan email yang valid');
      return;
    }

    setState(() { _isLoading = true; _errorMessage = null; _successMessage = null; });

    final result = await LicenseService.requestSerialNumber(email);

    setState(() => _isLoading = false);

    if (result.isValid) {
      setState(() {
        _serialSent = true;
        _successMessage = result.message;
        _errorMessage = null;
      });
    } else {
      setState(() => _errorMessage = result.message);
    }
  }

  Future<void> _activate() async {
    final serial = _serialController.text.trim();
    if (serial.isEmpty) {
      setState(() => _errorMessage = 'Masukkan serial number');
      return;
    }

    setState(() { _isLoading = true; _errorMessage = null; _successMessage = null; });

    final result = await LicenseService.verifySerialNumber(serial);

    setState(() => _isLoading = false);

    if (result.isValid) {
      widget.onActivated();
    } else {
      setState(() => _errorMessage = result.message);
    }
  }
}
