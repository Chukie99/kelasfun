# Design Spec: Sistem Lisensi kelasFun

## Overview

Sistem lisensi otomatis berbasis Hardware Binding (Device ID) untuk aplikasi kelasFun yang dijual di Lynk.id. Setiap pembeli menerima serial number unik via email yang terikat ke 1 perangkat.

## Goals

- Cegah pembagian APK gratis: 1 serial number = 1 device
- Aktivasi otomatis: user isi email → dapet serial number via email
- Grace period: app bisa dipakai offline sampai 30 hari sebelum re-validasi
- Reset: user bisa hubungi admin untuk reset lisensi jika HP hilang

## Architecture

### Components

1. **Supabase Database** - Tabel `licenses` menyimpan data lisensi
2. **Edge Function: `generate-license`** - Generate serial number, kirim email, notif Telegram
3. **Edge Function: `verify-license`** - Verifikasi serial number + device_id
4. **Flutter App** - Baca device_id, kirim request, simpan status lokal

### Data Flow

```
User → App → generate-license → DB + Resend (email) + Telegram
User ← Email berisi serial number
User → App → verify-license → DB check
App ← Response true/false
App → SharedPreferences (status aktif)
```

## Database Schema

### Tabel: `licenses`

```sql
CREATE TABLE licenses (
  id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
  email TEXT NOT NULL,
  device_id TEXT,
  serial_number TEXT UNIQUE NOT NULL,
  is_active BOOLEAN DEFAULT false,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

CREATE INDEX idx_serial_number ON licenses(serial_number);
CREATE INDEX idx_email ON licenses(email);
CREATE INDEX idx_device_id ON licenses(device_id);
```

### RLS Policies

- Service role: full access
- Anon: SELECT only (untuk verify)

## Edge Functions

### 1. `generate-license`

**Endpoint:** `POST /functions/v1/generate-license`

**Request Body:**
```json
{
  "email": "user@example.com",
  "device_id": "samsung-galaxy-s21-ABC123"
}
```

**Logic:**
1. Validate input (email format, device_id not empty)
2. Generate serial number format: `KF-XXXX-XXXX` (X = alphanumeric uppercase)
3. Insert ke tabel `licenses` dengan `is_active = false`
4. Kirim email via Resend API berisi serial number
5. Kirim notifikasi ke Telegram Bot
6. Return `{ success: true, message: "Serial number dikirim ke email" }`

**Error Cases:**
- Email sudah punya serial number → return error "Email sudah terdaftar"
- Resend API gagal → tetap return success (serial sudah di-DB), log error
- Telegram gagal → skip, tidak block proses

### 2. `verify-license`

**Endpoint:** `POST /functions/v1/verify-license`

**Request Body:**
```json
{
  "serial_number": "KF-AB12-CD34",
  "device_id": "samsung-galaxy-s21-ABC123"
}
```

**Logic:**
1. Cari serial_number di database
2. Jika tidak ditemukan → return `{ valid: false }`
3. Jika `is_active = false` → set `device_id`, `is_active = true`, return `{ valid: true }`
4. Jika `is_active = true` dan `device_id` cocok → return `{ valid: true }`
5. Jika `is_active = true` dan `device_id` beda → return `{ valid: false, message: "Serial sudah dipakai device lain" }`

**Response:**
```json
{ "valid": true }
```
or
```json
{ "valid": false, "message": "Serial sudah dipakai device lain" }
```

## Flutter App Changes

### `lib/core/services/license_service.dart`

**Perubahan:**
- Format serial: `KF-XXXX-XXXX` (bukan `XXXX-XXXX-XXXX-XXXX`)
- Endpoint: gunakan Edge Functions (bukan REST API langsung)
- Simpan: `serial_number` (bukan `license_key`)

**Method baru:**
- `requestSerialNumber(String email)` → POST ke generate-license
- `verifySerialNumber(String serialNumber)` → POST ke verify-license
- `getDeviceId()` → baca Android ID (sudah ada, refactor)
- `isActivated()` → cek lokal (sudah ada)
- `revalidate()` → re-validasi setelah grace period (sudah ada)

**Local Storage Keys:**
- `kelasfun_serial_number` → serial number
- `kelasfun_is_activated` → status aktif
- `kelasfun_activated_at` → timestamp aktivasi

### `lib/features/activation/activation_screen.dart`

**UI Flow:**
1. **Step 1:** Input email + tombol "Kirim Serial Number"
2. **Step 2:** Input serial number + tombol "Aktivasi"
3. Loading states untuk kedua step
4. Error message jika gagal

## Environment Variables

```
RESEND_API_KEY=re_xxxxx
RESEND_FROM_EMAIL=licenses@domainmu.com
TELEGRAM_BOT_TOKEN=123456:ABC-DEF
TELEGRAM_CHAT_ID=123456789
SUPABASE_URL=https://xxxxx.supabase.co
SUPABASE_SERVICE_ROLE_KEY=eyJxxxxx
```

## Deployment

1. Jalankan SQL migration di Supabase Dashboard
2. Deploy Edge Functions: `supabase functions deploy generate-license`
3. Deploy Edge Functions: `supabase functions deploy verify-license`
4. Set environment variables di Supabase Dashboard
5. Build dan publish APK

## Migration Notes

- Tabel `licenses` lama (`license_key`, `status`, `user_email`, `user_name`) akan DI-HAPUS dan diganti dengan schema baru
- Data lisensi lama tidak akan migrate (karena format berubah total)
- `admin_panel` perlu diupdate jika ada UI yang manage licenses

## Security Notes

- Device ID: menggunakan Android ID (`androidInfo.id`), cukup stabil untuk protection level ini
- Serial number format `KF-XXXX-XXXX` → 36^8 = 2.8 triliun kombinasi, tidak bisa di-brute-force
- RLS: anon hanya bisa SELECT, tidak bisa UPDATE/DELETE
- Service role key hanya di Edge Function (server-side)

## Testing

1. **Generate:** Masukin email → cek email masuk → cek serial number di DB
2. **Verify:** Masukin serial + device_id → return true
3. **Double verify:** Verify lagi dengan device_id sama → return true
4. **Wrong device:** Verify dengan device_id beda → return false
5. **Duplicate email:** Masukin email yang sama → return error
