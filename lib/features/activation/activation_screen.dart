import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:kelasfun/core/services/serial_generator.dart';

/// Activation Screen — Shows device ID, user sends to seller via WhatsApp
class ActivationScreen extends StatefulWidget {
  final VoidCallback onActivated;
  
  const ActivationScreen({super.key, required this.onActivated});

  @override
  State<ActivationScreen> createState() => _ActivationScreenState();
}

class _ActivationScreenState extends State<ActivationScreen> {
  final _codeController = TextEditingController();
  bool _loading = false;
  String? _error;
  bool _activated = false;

  String get _deviceId => SerialService.deviceId;

  Future<void> _activate() async {
    final code = _codeController.text.trim().toUpperCase();
    if (code.isEmpty) {
      setState(() => _error = 'Masukkan kode aktivasi!');
      return;
    }

    setState(() { _loading = true; _error = null; });

    // Validate serial offline — tied to THIS device
    if (SerialService.validateCode(code, _deviceId)) {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool('license_valid', true);
      await prefs.setString('license_key', code);
      await prefs.setString('device_id', _deviceId);
      setState(() => _activated = true);
      
      // Auto-navigate after 2 seconds
      await Future.delayed(const Duration(seconds: 2));
      widget.onActivated();
    } else {
      setState(() {
        _error = 'Kode tidak valid untuk device ini!';
        _loading = false;
      });
    }
  }

  Future<void> _openWhatsApp() async {
    final phone = '6282261407123';
    final message = Uri.encodeComponent(
      'Halo, saya mau beli lisensi KelasFun.\n\n'
      'Device ID saya:\n$_deviceId\n\n'
      'Tolong kirim kode aktivasi ya.'
    );
    final url = Uri.parse('https://wa.me/$phone?text=$message');
    if (await canLaunchUrl(url)) {
      await launchUrl(url, mode: LaunchMode.externalApplication);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_activated) {
      return Scaffold(
        backgroundColor: const Color(0xFFF5F7FA),
        body: const Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text('✅', style: TextStyle(fontSize: 80)),
              SizedBox(height: 20),
              Text(
                'Aktivasi Berhasil!',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 8),
              Text('Memuat aplikasi...', style: TextStyle(color: Colors.grey)),
            ],
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(32),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Logo
                const Text('🎓', style: TextStyle(fontSize: 64)),
                const SizedBox(height: 16),
                const Text(
                  'KelasFun',
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF333333),
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  'Aplikasi Manajemen Kelas Offline',
                  style: TextStyle(fontSize: 14, color: Color(0xFF999999)),
                ),
                
                const SizedBox(height: 40),

                // Device ID Card
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.05),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      const Text(
                        '📱 Device ID Anda',
                        style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        'Kirim ID ini ke seller untuk\nmendapatkan kode aktivasi',
                        textAlign: TextAlign.center,
                        style: TextStyle(fontSize: 12, color: Color(0xFF999999)),
                      ),
                      const SizedBox(height: 12),
                      Container(
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF0F4FF),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Row(
                          children: [
                            Expanded(
                              child: Text(
                                _deviceId,
                                textAlign: TextAlign.center,
                                style: const TextStyle(
                                  fontFamily: 'Courier',
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFF667EEA),
                                  letterSpacing: 1.5,
                                ),
                              ),
                            ),
                            IconButton(
                              icon: const Icon(Icons.copy, size: 20),
                              onPressed: () {
                                Clipboard.setData(ClipboardData(text: _deviceId));
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text('Device ID disalin!'),
                                    backgroundColor: Color(0xFF28A745),
                                  ),
                                );
                              },
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 20),

                // WhatsApp Button
                SizedBox(
                  width: double.infinity,
                  height: 52,
                  child: ElevatedButton.icon(
                    onPressed: _openWhatsApp,
                    icon: const Text('💬', style: TextStyle(fontSize: 20)),
                    label: const Text(
                      'Chat Seller via WhatsApp',
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF25D366),
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 24),
                const Divider(),
                const SizedBox(height: 16),

                // Activation Code Input
                const Text(
                  'Sudah punya kode aktivasi?',
                  style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: _codeController,
                  textAlign: TextAlign.center,
                  textCapitalization: TextCapitalization.characters,
                  style: const TextStyle(
                    fontFamily: 'Courier',
                    fontSize: 18,
                    letterSpacing: 3,
                  ),
                  decoration: InputDecoration(
                    hintText: 'KFUN-XXXX-XX',
                    hintStyle: const TextStyle(color: Color(0xFFCCCCCC)),
                    filled: true,
                    fillColor: Colors.white,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(14),
                      borderSide: const BorderSide(color: Color(0xFFE0E0E0)),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(14),
                      borderSide: const BorderSide(color: Color(0xFFE0E0E0)),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(14),
                      borderSide: const BorderSide(color: Color(0xFF667EEA), width: 2),
                    ),
                  ),
                ),
                
                if (_error != null) ...[
                  const SizedBox(height: 12),
                  Text(_error!, style: const TextStyle(color: Colors.red, fontSize: 13)),
                ],

                const SizedBox(height: 16),
                SizedBox(
                  width: double.infinity,
                  height: 52,
                  child: ElevatedButton(
                    onPressed: _loading ? null : _activate,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF667EEA),
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                    child: _loading
                        ? const CircularProgressIndicator(color: Colors.white)
                        : const Text(
                            'Aktifkan',
                            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
                          ),
                  ),
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
    _codeController.dispose();
    super.dispose();
  }
}
