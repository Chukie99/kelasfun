# License System Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Implement device-bound license system with email-based serial number delivery via Supabase Edge Functions.

**Architecture:** Flutter app reads device_id automatically, sends email to Edge Function which generates serial number `KF-XXXX-XXXX`, sends email via Resend API, and notifies via Telegram. App verifies serial number against device_id before activating.

**Tech Stack:** Flutter (Dart), Supabase Edge Functions (TypeScript/Deno), Supabase PostgreSQL, Resend API, Telegram Bot API

## Global Constraints

- Serial number format: `KF-XXXX-XXXX` (X = uppercase alphanumeric)
- Device ID: Android ID via `device_info_plus`
- Grace period: 30 days before re-validation required
- Local storage: SharedPreferences (existing pattern)
- Supabase URL: `https://cdgnqhdmsnrlzylgoecz.supabase.co`

---

## File Structure

| File | Purpose |
|------|---------|
| `supabase/migrations/001_license_system.sql` | Database schema + RLS |
| `supabase/functions/generate-license/index.ts` | Generate serial, send email, notify Telegram |
| `supabase/functions/verify-license/index.ts` | Verify serial + device_id |
| `lib/core/services/license_service.dart` | Update: use Edge Functions, new serial format |
| `lib/features/activation/activation_screen.dart` | Update: 2-step UI (email → serial) |

---

### Task 1: Database Schema

**Files:**
- Create: `supabase/migrations/001_license_system.sql`

**Interfaces:**
- Produces: `licenses` table with columns `id`, `email`, `device_id`, `serial_number`, `is_active`, `created_at`

- [ ] **Step 1: Create migration file**

```sql
-- supabase/migrations/001_license_system.sql

-- Drop old table if exists (breaking change from old license_key format)
DROP TABLE IF EXISTS licenses;

-- Create new licenses table
CREATE TABLE licenses (
  id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
  email TEXT NOT NULL,
  device_id TEXT,
  serial_number TEXT UNIQUE NOT NULL,
  is_active BOOLEAN DEFAULT false,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Indexes for performance
CREATE INDEX idx_serial_number ON licenses(serial_number);
CREATE INDEX idx_email ON licenses(email);
CREATE INDEX idx_device_id ON licenses(device_id);

-- Enable RLS
ALTER TABLE licenses ENABLE ROW LEVEL SECURITY;

-- Service role: full access
CREATE POLICY "Allow all for service role" ON licenses
  FOR ALL
  USING (auth.role() = 'service_role');

-- Anon: SELECT only (for verify function)
CREATE POLICY "Allow select for anon" ON licenses
  FOR SELECT
  USING (true);
```

- [ ] **Step 2: Verify SQL syntax**

Run in Supabase SQL Editor or validate locally. Ensure no syntax errors.

- [ ] **Step 3: Commit**

```bash
git add supabase/migrations/001_license_system.sql
git commit -m "feat: add license system database schema"
```

---

### Task 2: Edge Function - generate-license

**Files:**
- Create: `supabase/functions/generate-license/index.ts`

**Interfaces:**
- Consumes: `email` (string), `device_id` (string) from request body
- Produces: `{ success: boolean, message: string }` response
- Side effects: Inserts to `licenses` table, sends email via Resend, sends Telegram notification

- [ ] **Step 1: Create Edge Function directory structure**

```bash
mkdir -p supabase/functions/generate-license
```

- [ ] **Step 2: Write the Edge Function**

```typescript
// supabase/functions/generate-license/index.ts

import { serve } from "https://deno.land/std@0.168.0/http/server.ts";
import { createClient } from "https://esm.sh/@supabase/supabase-js@2";

const corsHeaders = {
  "Access-Control-Allow-Origin": "*",
  "Access-Control-Allow-Headers":
    "authorization, x-client-info, apikey, content-type",
};

interface RequestBody {
  email: string;
  device_id: string;
}

function generateSerialNumber(): string {
  const chars = "ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789";
  let result = "KF-";
  for (let i = 0; i < 4; i++) {
    result += chars.charAt(Math.floor(Math.random() * chars.length));
  }
  result += "-";
  for (let i = 0; i < 4; i++) {
    result += chars.charAt(Math.floor(Math.random() * chars.length));
  }
  return result;
}

function isValidEmail(email: string): boolean {
  return /^[^\s@]+@[^\s@]+\.[^\s@]+$/.test(email);
}

async function sendEmailViaResend(
  to: string,
  serialNumber: string
): Promise<boolean> {
  const apiKey = Deno.env.get("RESEND_API_KEY");
  const fromEmail = Deno.env.get("RESEND_FROM_EMAIL") || "licenses@kelasfun.app";

  if (!apiKey) {
    console.error("RESEND_API_KEY not configured");
    return false;
  }

  try {
    const res = await fetch("https://api.resend.com/emails", {
      method: "POST",
      headers: {
        "Content-Type": "application/json",
        Authorization: `Bearer ${apiKey}`,
      },
      body: JSON.stringify({
        from: fromEmail,
        to: [to],
        subject: "Serial Number kelasFun Anda",
        html: `
          <h2>Terima kasih telah membeli kelasFun!</h2>
          <p>Serial Number Anda:</p>
          <h1 style="font-size: 32px; letter-spacing: 4px; color: #2D3436;">${serialNumber}</h1>
          <p>Masukkan serial number ini di aplikasi untuk mengaktifkan lisensi.</p>
          <p><strong>Penting:</strong> Serial number ini hanya berlaku untuk 1 perangkat.</p>
        `,
      }),
    });

    if (!res.ok) {
      const error = await res.text();
      console.error("Resend error:", error);
      return false;
    }
    return true;
  } catch (error) {
    console.error("Email send failed:", error);
    return false;
  }
}

async function sendTelegramNotification(
  email: string,
  serialNumber: string,
  deviceId: string
): Promise<void> {
  const botToken = Deno.env.get("TELEGRAM_BOT_TOKEN");
  const chatId = Deno.env.get("TELEGRAM_CHAT_ID");

  if (!botToken || !chatId) {
    console.log("Telegram not configured, skipping notification");
    return;
  }

  const message = `🔔 *License Baru kelasFun*

📧 Email: ${email}
🔑 Serial: \`${serialNumber}\`
📱 Device: \`${deviceId}\`
🕐 Waktu: ${new Date().toISOString()}`;

  try {
    await fetch(
      `https://api.telegram.org/bot${botToken}/sendMessage`,
      {
        method: "POST",
        headers: { "Content-Type": "application/json" },
        body: JSON.stringify({
          chat_id: chatId,
          text: message,
          parse_mode: "Markdown",
        }),
      }
    );
  } catch (error) {
    console.error("Telegram notification failed:", error);
  }
}

serve(async (req) => {
  // Handle CORS preflight
  if (req.method === "OPTIONS") {
    return new Response("ok", { headers: corsHeaders });
  }

  try {
    const { email, device_id }: RequestBody = await req.json();

    // Validate input
    if (!email || !isValidEmail(email)) {
      return new Response(
        JSON.stringify({ success: false, message: "Email tidak valid" }),
        {
          status: 400,
          headers: { ...corsHeaders, "Content-Type": "application/json" },
        }
      );
    }

    if (!device_id || device_id.trim() === "") {
      return new Response(
        JSON.stringify({ success: false, message: "Device ID diperlukan" }),
        {
          status: 400,
          headers: { ...corsHeaders, "Content-Type": "application/json" },
        }
      );
    }

    // Create Supabase client with service role key
    const supabaseUrl = Deno.env.get("SUPABASE_URL")!;
    const supabaseKey = Deno.env.get("SUPABASE_SERVICE_ROLE_KEY")!;
    const supabase = createClient(supabaseUrl, supabaseKey);

    // Check if email already has a serial number
    const { data: existing } = await supabase
      .from("licenses")
      .select("serial_number")
      .eq("email", email.toLowerCase())
      .single();

    if (existing) {
      return new Response(
        JSON.stringify({
          success: false,
          message: "Email sudah terdaftar. Cek email Anda untuk serial number.",
        }),
        {
          status: 409,
          headers: { ...corsHeaders, "Content-Type": "application/json" },
        }
      );
    }

    // Generate serial number
    const serialNumber = generateSerialNumber();

    // Insert to database
    const { error: insertError } = await supabase.from("licenses").insert({
      email: email.toLowerCase(),
      device_id: null,
      serial_number: serialNumber,
      is_active: false,
    });

    if (insertError) {
      console.error("Insert error:", insertError);
      return new Response(
        JSON.stringify({ success: false, message: "Gagal membuat lisensi" }),
        {
          status: 500,
          headers: { ...corsHeaders, "Content-Type": "application/json" },
        }
      );
    }

    // Send email (non-blocking, log errors)
    const emailSent = await sendEmailViaResend(email, serialNumber);
    if (!emailSent) {
      console.log("Email send failed, but serial number created:", serialNumber);
    }

    // Send Telegram notification (non-blocking)
    await sendTelegramNotification(email, serialNumber, device_id);

    return new Response(
      JSON.stringify({
        success: true,
        message: "Serial number dikirim ke email Anda",
      }),
      {
        status: 200,
        headers: { ...corsHeaders, "Content-Type": "application/json" },
      }
    );
  } catch (error) {
    console.error("Unexpected error:", error);
    return new Response(
      JSON.stringify({ success: false, message: "Terjadi kesalahan server" }),
      {
        status: 500,
        headers: { ...corsHeaders, "Content-Type": "application/json" },
      }
    );
  }
});
```

- [ ] **Step 3: Verify TypeScript syntax**

Check for any import errors or type issues.

- [ ] **Step 4: Commit**

```bash
git add supabase/functions/generate-license/index.ts
git commit -m "feat: add generate-license Edge Function"
```

---

### Task 3: Edge Function - verify-license

**Files:**
- Create: `supabase/functions/verify-license/index.ts`

**Interfaces:**
- Consumes: `serial_number` (string), `device_id` (string) from request body
- Produces: `{ valid: boolean, message?: string }` response

- [ ] **Step 1: Create Edge Function**

```typescript
// supabase/functions/verify-license/index.ts

import { serve } from "https://deno.land/std@0.168.0/http/server.ts";
import { createClient } from "https://esm.sh/@supabase/supabase-js@2";

const corsHeaders = {
  "Access-Control-Allow-Origin": "*",
  "Access-Control-Allow-Headers":
    "authorization, x-client-info, apikey, content-type",
};

interface RequestBody {
  serial_number: string;
  device_id: string;
}

serve(async (req) => {
  // Handle CORS preflight
  if (req.method === "OPTIONS") {
    return new Response("ok", { headers: corsHeaders });
  }

  try {
    const { serial_number, device_id }: RequestBody = await req.json();

    // Validate input
    if (!serial_number || serial_number.trim() === "") {
      return new Response(
        JSON.stringify({ valid: false, message: "Serial number diperlukan" }),
        {
          status: 400,
          headers: { ...corsHeaders, "Content-Type": "application/json" },
        }
      );
    }

    if (!device_id || device_id.trim() === "") {
      return new Response(
        JSON.stringify({ valid: false, message: "Device ID diperlukan" }),
        {
          status: 400,
          headers: { ...corsHeaders, "Content-Type": "application/json" },
        }
      );
    }

    // Create Supabase client with service role key
    const supabaseUrl = Deno.env.get("SUPABASE_URL")!;
    const supabaseKey = Deno.env.get("SUPABASE_SERVICE_ROLE_KEY")!;
    const supabase = createClient(supabaseUrl, supabaseKey);

    // Find the serial number
    const { data: license, error: fetchError } = await supabase
      .from("licenses")
      .select("*")
      .eq("serial_number", serial_number.toUpperCase())
      .single();

    if (fetchError || !license) {
      return new Response(
        JSON.stringify({ valid: false, message: "Serial number tidak valid" }),
        {
          status: 200,
          headers: { ...corsHeaders, "Content-Type": "application/json" },
        }
      );
    }

    // Serial is not active yet → activate and bind to this device
    if (!license.is_active) {
      const { error: updateError } = await supabase
        .from("licenses")
        .update({
          device_id: device_id,
          is_active: true,
        })
        .eq("id", license.id);

      if (updateError) {
        console.error("Update error:", updateError);
        return new Response(
          JSON.stringify({ valid: false, message: "Gagal mengaktifkan lisensi" }),
          {
            status: 500,
            headers: { ...corsHeaders, "Content-Type": "application/json" },
          }
        );
      }

      return new Response(
        JSON.stringify({ valid: true }),
        {
          status: 200,
          headers: { ...corsHeaders, "Content-Type": "application/json" },
        }
      );
    }

    // Serial is active → check if device matches
    if (license.device_id === device_id) {
      return new Response(
        JSON.stringify({ valid: true }),
        {
          status: 200,
          headers: { ...corsHeaders, "Content-Type": "application/json" },
        }
      );
    }

    // Device doesn't match
    return new Response(
      JSON.stringify({
        valid: false,
        message: "Serial sudah dipakai device lain. Hubungi admin untuk reset.",
      }),
      {
        status: 200,
        headers: { ...corsHeaders, "Content-Type": "application/json" },
      }
    );
  } catch (error) {
    console.error("Unexpected error:", error);
    return new Response(
      JSON.stringify({ valid: false, message: "Terjadi kesalahan server" }),
      {
        status: 500,
        headers: { ...corsHeaders, "Content-Type": "application/json" },
      }
    );
  }
});
```

- [ ] **Step 2: Commit**

```bash
git add supabase/functions/verify-license/index.ts
git commit -m "feat: add verify-license Edge Function"
```

---

### Task 4: Update License Service (Flutter)

**Files:**
- Modify: `lib/core/services/license_service.dart`

**Interfaces:**
- Consumes: Edge Function responses from Task 2 and Task 3
- Produces: `requestSerialNumber()`, `verifySerialNumber()`, `isActivated()`, `revalidate()`

- [ ] **Step 1: Rewrite license_service.dart**

```dart
// lib/core/services/license_service.dart

import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:device_info_plus/device_info_plus.dart';

class LicenseService {
  static const String _serialNumberKey = 'kelasfun_serial_number';
  static const String _isActivated = 'kelasfun_is_activated';
  static const String _activatedAt = 'kelasfun_activated_at';
  static const int _gracePeriodDays = 30;

  // Supabase Edge Functions
  static const String _supabaseUrl = 'https://cdgnqhdmsnrlzylgoecz.supabase.co';
  static const String _supabaseKey = 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImNkZ25xaGRtc25ybHp5bGdvZWN6Iiwicm9sZSI6ImFub24iLCJpYXQiOjE3ODY5NzUyNzgsImV4cCI6MjEwMjU1MTI3OH0.a3mH4gFGPV_aRvgFCJFHMjQQsc3AQc0YBvrLEeFM_HA';

  static Future<String> getDeviceId() async {
    try {
      final deviceInfo = DeviceInfoPlugin();
      if (Platform.isAndroid) {
        final androidInfo = await deviceInfo.androidInfo;
        return androidInfo.id;
      } else if (Platform.isWindows) {
        final windowsInfo = await deviceInfo.windowsInfo;
        return windowsInfo.deviceId;
      }
    } catch (e) {
      print('[LICENSE] Error getting device ID: $e');
    }
    return DateTime.now().millisecondsSinceEpoch.toString();
  }

  static bool _isValidSerialFormat(String serial) {
    return RegExp(r'^KF-[A-Z0-9]{4}-[A-Z0-9]{4}$').hasMatch(serial.toUpperCase());
  }

  /// Request serial number to be sent to email
  static Future<LicenseResult> requestSerialNumber(String email) async {
    final deviceId = await getDeviceId();
    print('[LICENSE] Request serial for: $email | Device: $deviceId');

    if (email.isEmpty || !email.contains('@')) {
      return LicenseResult(isValid: false, message: 'Email tidak valid');
    }

    try {
      final response = await http.post(
        Uri.parse('$_supabaseUrl/functions/v1/generate-license'),
        headers: {
          'Content-Type': 'application/json',
          'apikey': _supabaseKey,
          'Authorization': 'Bearer $_supabaseKey',
        },
        body: jsonEncode({
          'email': email,
          'device_id': deviceId,
        }),
      );

      print('[LICENSE] Response: ${response.statusCode} | ${response.body}');

      final data = jsonDecode(response.body);

      if (response.statusCode == 200 && data['success'] == true) {
        return LicenseResult(isValid: true, message: data['message']);
      } else {
        return LicenseResult(isValid: false, message: data['message'] ?? 'Gagal mengirim serial number');
      }
    } catch (e) {
      print('[LICENSE] Error: $e');
      return LicenseResult(isValid: false, message: 'Tidak ada internet. Coba lagi nanti.');
    }
  }

  /// Verify serial number and activate if valid
  static Future<LicenseResult> verifySerialNumber(String serialNumber) async {
    final deviceId = await getDeviceId();
    print('[LICENSE] Verify: $serialNumber | Device: $deviceId');

    if (!_isValidSerialFormat(serialNumber)) {
      return LicenseResult(isValid: false, message: 'Format serial salah. Contoh: KF-AB12-CD34');
    }

    try {
      final response = await http.post(
        Uri.parse('$_supabaseUrl/functions/v1/verify-license'),
        headers: {
          'Content-Type': 'application/json',
          'apikey': _supabaseKey,
          'Authorization': 'Bearer $_supabaseKey',
        },
        body: jsonEncode({
          'serial_number': serialNumber.toUpperCase(),
          'device_id': deviceId,
        }),
      );

      print('[LICENSE] Response: ${response.statusCode} | ${response.body}');

      final data = jsonDecode(response.body);

      if (response.statusCode == 200 && data['valid'] == true) {
        await _saveLocal(serialNumber.toUpperCase());
        return LicenseResult(isValid: true, message: 'Aktivasi berhasil!');
      } else {
        return LicenseResult(isValid: false, message: data['message'] ?? 'Serial number tidak valid');
      }
    } catch (e) {
      print('[LICENSE] Error: $e');
      return LicenseResult(isValid: false, message: 'Tidak ada internet. Silakan online untuk aktivasi.');
    }
  }

  static Future<void> _saveLocal(String serialNumber) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_serialNumberKey, serialNumber);
    await prefs.setBool(_isActivated, true);
    await prefs.setString(_activatedAt, DateTime.now().toIso8601String());
  }

  static Future<bool> isActivated() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_isActivated) == true;
  }

  static Future<bool> isInGracePeriod() async {
    final prefs = await SharedPreferences.getInstance();
    final activatedAtStr = prefs.getString(_activatedAt);
    if (activatedAtStr == null) return false;
    final days = DateTime.now().difference(DateTime.parse(activatedAtStr)).inDays;
    return days <= _gracePeriodDays;
  }

  static Future<LicenseResult> revalidate() async {
    final prefs = await SharedPreferences.getInstance();
    final savedSerial = prefs.getString(_serialNumberKey);
    if (savedSerial == null || savedSerial.isEmpty) {
      return LicenseResult(isValid: false, message: 'Tidak ada lisensi tersimpan');
    }
    return await verifySerialNumber(savedSerial);
  }
}

class LicenseResult {
  final bool isValid;
  final String message;
  const LicenseResult({required this.isValid, required this.message});
}
```

- [ ] **Step 2: Verify no import errors**

Check that all imports resolve correctly.

- [ ] **Step 3: Commit**

```bash
git add lib/core/services/license_service.dart
git commit -m "feat: update license service to use Edge Functions"
```

---

### Task 5: Update Activation Screen (Flutter)

**Files:**
- Modify: `lib/features/activation/activation_screen.dart`

**Interfaces:**
- Consumes: `LicenseService.requestSerialNumber()`, `LicenseService.verifySerialNumber()` from Task 4
- Produces: Updated UI with 2-step flow

- [ ] **Step 1: Rewrite activation_screen.dart**

```dart
// lib/features/activation/activation_screen.dart

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
  String? _errorMessage;
  String? _successMessage;
  bool _serialSent = false;

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
                      _serialSent ? 'Masukkan serial number dari email' : 'Masukkan email untuk mendapatkan serial number',
                      style: const TextStyle(color: AppTheme.textSecondary),
                    ),
                    const SizedBox(height: 24),

                    Form(
                      key: _formKey,
                      child: Column(
                        children: [
                          if (!_serialSent) ...[
                            // Step 1: Email input
                            TextFormField(
                              controller: _emailController,
                              keyboardType: TextInputType.emailAddress,
                              style: const TextStyle(color: AppTheme.textPrimary, fontSize: 16),
                              decoration: InputDecoration(
                                hintText: 'email@contoh.com',
                                hintStyle: const TextStyle(color: AppTheme.textTertiary),
                                filled: true,
                                fillColor: AppTheme.surfaceLight,
                                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                                prefixIcon: const Icon(Icons.email_outlined, color: AppTheme.textTertiary),
                              ),
                            ),
                            const SizedBox(height: 16),
                          ] else ...[
                            // Step 2: Serial number input
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
                            const SizedBox(height: 12),
                            TextButton(
                              onPressed: () {
                                setState(() {
                                  _serialSent = false;
                                  _errorMessage = null;
                                  _successMessage = null;
                                });
                              },
                              child: const Text('Ganti email', style: TextStyle(color: AppTheme.accent)),
                            ),
                          ],

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
                              decoration: BoxDecoration(color: AppTheme.accentSoft, borderRadius: BorderRadius.circular(8)),
                              child: Text(_successMessage!, style: const TextStyle(color: AppTheme.accent)),
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
                                  : Text(_serialSent ? 'Aktivasi' : 'Kirim Serial Number', style: const TextStyle(fontSize: 16)),
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 20),
                    const Text('Belum punya? Beli di Lynk.id', style: TextStyle(color: AppTheme.textTertiary, fontSize: 12)),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
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
        _successMessage = 'Serial number dikirim ke $email. Cek inbox/spam Anda.';
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

    setState(() { _isLoading = true; _errorMessage = null; });

    final result = await LicenseService.verifySerialNumber(serial);

    setState(() => _isLoading = false);

    if (result.isValid) {
      widget.onActivated();
    } else {
      setState(() => _errorMessage = result.message);
    }
  }
}
```

- [ ] **Step 2: Verify no import errors**

Check that `AppTheme.accentSoft` exists or replace with appropriate color.

- [ ] **Step 3: Commit**

```bash
git add lib/features/activation/activation_screen.dart
git commit -m "feat: update activation screen with 2-step flow"
```

---

### Task 6: Deploy and Test

**Files:**
- No new files, deployment steps only

**Interfaces:**
- Consumes: All files from Tasks 1-5
- Produces: Working system ready for production

- [ ] **Step 1: Run SQL migration**

Go to Supabase Dashboard → SQL Editor → paste content from `supabase/migrations/001_license_system.sql` → Run

- [ ] **Step 2: Set environment variables**

Go to Supabase Dashboard → Edge Functions → Settings → Add:
- `RESEND_API_KEY` = your Resend API key
- `RESEND_FROM_EMAIL` = your verified email
- `TELEGRAM_BOT_TOKEN` = your bot token
- `TELEGRAM_CHAT_ID` = your chat ID

- [ ] **Step 3: Deploy Edge Functions**

```bash
supabase functions deploy generate-license
supabase functions deploy verify-license
```

- [ ] **Step 4: Test generate-license**

```bash
curl -X POST https://cdgnqhdmsnrlzylgoecz.supabase.co/functions/v1/generate-license \
  -H "Content-Type: application/json" \
  -H "apikey: YOUR_ANON_KEY" \
  -d '{"email":"test@example.com","device_id":"test-device-123"}'
```

Expected: Email received with serial number `KF-XXXX-XXXX`

- [ ] **Step 5: Test verify-license**

```bash
curl -X POST https://cdgnqhdmsnrlzylgoecz.supabase.co/functions/v1/verify-license \
  -H "Content-Type: application/json" \
  -H "apikey: YOUR_ANON_KEY" \
  -d '{"serial_number":"KF-XXXX-XXXX","device_id":"test-device-123"}'
```

Expected: `{"valid": true}`

- [ ] **Step 6: Test wrong device**

```bash
curl -X POST https://cdgnqhdmsnrlzylgoecz.supabase.co/functions/v1/verify-license \
  -H "Content-Type: application/json" \
  -H "apikey: YOUR_ANON_KEY" \
  -d '{"serial_number":"KF-XXXX-XXXX","device_id":"different-device"}'
```

Expected: `{"valid":false,"message":"Serial sudah dipakai device lain..."}`

- [ ] **Step 7: Build and test Flutter app**

```bash
flutter build apk --debug
# Install on device and test full flow
```

- [ ] **Step 8: Commit deployment notes**

```bash
git add docs/superpowers/plans/
git commit -m "docs: add license system implementation plan"
```
