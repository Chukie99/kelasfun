import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:kelasfun/core/services/serial_generator.dart';
import 'package:kelasfun/core/theme/app_theme.dart';

const String _whatsappNumber = '6282261407123';
const String _whatsappMessage = 'Halo, saya mau beli lisensi KelasFun. Berapa harganya?';

class ActivationScreen extends StatefulWidget {
  final VoidCallback onActivated;
  const ActivationScreen({super.key, required this.onActivated});
  @override
  State<ActivationScreen> createState() => _ActivationScreenState();
}

class _ActivationScreenState extends State<ActivationScreen> {
  final _serialController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool _isLoading = false;
  String? _errorMessage;

  static const String _serialKey = 'kelasfun_serial';
  static const String _activatedKey = 'kelasfun_activated';

  @override
  void dispose() {
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
                    const Text('Aktivasi KelasFun', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: AppTheme.textPrimary)),
                    const SizedBox(height: 8),
                    const Text('Masukkan serial aktivasi untuk menggunakan aplikasi', style: TextStyle(color: AppTheme.textSecondary), textAlign: TextAlign.center),
                    const SizedBox(height: 24),

                    Form(
                      key: _formKey,
                      child: Column(
                        children: [
                          TextFormField(
                            controller: _serialController,
                            style: const TextStyle(color: AppTheme.textPrimary, fontSize: 18, letterSpacing: 2),
                            textAlign: TextAlign.center,
                            textCapitalization: TextCapitalization.characters,
                            decoration: InputDecoration(
                              hintText: 'XXXX-XXXX-XXXX',
                              hintStyle: const TextStyle(color: AppTheme.textTertiary),
                              filled: true,
                              fillColor: AppTheme.surfaceLight,
                              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                            ),
                          ),
                          const SizedBox(height: 16),

                          if (_errorMessage != null)
                            Container(
                              width: double.infinity,
                              padding: const EdgeInsets.all(12),
                              margin: const EdgeInsets.only(bottom: 16),
                              decoration: BoxDecoration(color: AppTheme.coralSoft, borderRadius: BorderRadius.circular(8)),
                              child: Text(_errorMessage!, style: const TextStyle(color: AppTheme.coral)),
                            ),

                          SizedBox(
                            width: double.infinity,
                            height: 50,
                            child: ElevatedButton(
                              onPressed: _isLoading ? null : _activate,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppTheme.accent,
                                foregroundColor: Colors.white,
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                              ),
                              child: _isLoading
                                  ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                                  : const Text('Aktivasi', style: TextStyle(fontSize: 16)),
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 20),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: AppTheme.mintSoft ?? AppTheme.surfaceLight,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: AppTheme.mint?.withOpacity(0.3) ?? Colors.green.withOpacity(0.3)),
                      ),
                      child: Column(
                        children: [
                          const Icon(Icons.shopping_cart_outlined, size: 32, color: AppTheme.mint),
                          const SizedBox(height: 8),
                          const Text('Beli Serial Aktivasi', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppTheme.textPrimary)),
                          const SizedBox(height: 4),
                          const Text('Hubungi via WhatsApp untuk mendapatkan serial', style: TextStyle(color: AppTheme.textSecondary, fontSize: 12), textAlign: TextAlign.center),
                          const SizedBox(height: 12),
                          SizedBox(
                            width: double.infinity,
                            height: 44,
                            child: ElevatedButton.icon(
                              onPressed: _openWhatsApp,
                              icon: const Icon(Icons.chat, size: 20),
                              label: const Text('Chat WhatsApp', style: TextStyle(fontSize: 14)),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFF25D366),
                                foregroundColor: Colors.white,
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 12),
                    const Text('Setelah bayar, serial akan dikirim via WhatsApp', style: TextStyle(color: AppTheme.textTertiary, fontSize: 11), textAlign: TextAlign.center),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _activate() async {
    final serial = _serialController.text.trim();
    if (serial.isEmpty) {
      setState(() => _errorMessage = 'Masukkan serial aktivasi');
      return;
    }

    setState(() { _isLoading = true; _errorMessage = null; });

    // Validate OFFLINE — no internet needed
    final isValid = SerialService.validate(serial);

    if (isValid) {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_serialKey, serial.toUpperCase());
      await prefs.setBool(_activatedKey, true);

      if (mounted) {
        setState(() => _isLoading = false);
        widget.onActivated();
      }
    } else {
      setState(() {
        _isLoading = false;
        _errorMessage = 'Serial tidak valid. Periksa kembali kode serial Anda.';
      });
    }
  }

  Future<void> _openWhatsApp() async {
    final url = Uri.parse('https://wa.me/$_whatsappNumber?text=${Uri.encodeComponent(_whatsappMessage)}');
    if (await canLaunchUrl(url)) {
      await launchUrl(url, mode: LaunchMode.externalApplication);
    } else {
      setState(() => _errorMessage = 'Tidak bisa membuka WhatsApp. Chat ke: 082261407123');
    }
  }
}
