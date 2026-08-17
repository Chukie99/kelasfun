# Sistem Lisensi kelasFun

## Cara Kerja

```
┌─────────────────────────────────────────────────────────────┐
│                    APLIKASI kelasFun                        │
│                                                             │
│  ┌─────────────────────────────────────────────────────┐   │
│  │  1000 LICENSE KEY (sudah di-hash)                   │   │
│  │  sudah ditanem di dalam aplikasi                    │   │
│  └─────────────────────────────────────────────────────┘   │
│                          │                                  │
│                          ▼                                  │
│  ┌─────────────────────────────────────────────────────┐   │
│  │  User masukkan key                                   │   │
│  │  Aplikasi hash key → cek ke daftar → cocok?        │   │
│  └─────────────────────────────────────────────────────┘   │
│                          │                                  │
│                    ┌─────┴─────┐                           │
│                    │           │                           │
│                    ▼           ▼                           │
│                 ✅ YA        ❌ TIDAK                      │
│                 Aktif        Tolak                         │
└─────────────────────────────────────────────────────────────┘
```

## Kelebihan

- ✅ **100% Offline** - Tidak perlu internet
- ✅ **Cepat** - Validasi lokal, tidak ada delay
- ✅ **Sederhana** - Tidak perlu server

## Kekurangan

- ⚠️ **1000 key** - Jika habis, harus update aplikasi
- ⚠️ **Bisa di-hack** - Key bisa di-extract (tapi rumit)

## Cara Generate Key Baru

### 1. Jalankan script generator

```bash
dart tools/generate_keys.dart
```

Output:
```
Key 1: A1B2-C3D4-E5F6-G7H8
Hash:    a1b2c3d4e5f6g7h8
Copy:    'a1b2c3d4e5f6g7h8', // A1B2-C3D4-E5F6-G7H8
```

### 2. Tambahkan ke aplikasi

Buka `lib/core/services/license_service.dart`, tambahkan hash ke list:

```dart
static const List<String> _validKeyHashes = [
  // ... key yang sudah ada ...
  'a1b2c3d4e5f6g7h8', // A1B2-C3D4-E5F6-G7H8  ← TAMBAHKAN DI SINI
];
```

### 3. Build ulang aplikasi

```bash
flutter build apk --release
flutter build windows --release
```

## Cara Jual

1. **Generate key** menggunakan script
2. **Kirim key** ke pembeli (via WhatsApp/Email)
3. **Pembeli masukkan key** di aplikasi
4. **Selesai!** Bisa dipakai offline

## Reset Key (Device Hilang)

Karena offline, reset harus manual:

1. **User hubungi admin**: "HP saya hilang"
2. **Admin cek**: Key yang dipakai user
3. **Admin kasih key baru**: Generate key lain
4. **User install ulang**: Masukkan key baru

## Template Pesan untuk Pembeli

```
Halo! Terima kasih sudah membeli kelasFun.

License Key Anda:
XXXX-XXXX-XXXX-XXXX

Cara Aktivasi:
1. Install aplikasi kelasFun
2. Buka aplikasi
3. Masukkan license key di atas
4. Klik "Aktivasi"

Catatan:
- License key hanya berlaku untuk 1 device
- Simpan key ini untuk keperluan di masa depan
- Jika device hilang, hubungi admin untuk reset

Terima kasih!
```

## Tips Keamanan

1. **Jangan publish key di public** (GitHub, sosmed, dll)
2. **Jual per key** (bukan bundle 1000 key)
3. **Catat siapa yang beli** (untuk reset jika perlu)
4. **Gunakan format key yang unik** (mudah diingat customer)
