# Setup Supabase untuk kelasFun License

## Langkah 1: Buat Akun Supabase

1. Buka https://supabase.com
2. Klik "Start your project" → Login pakai GitHub
3. Buat project baru:
   - Nama: `kelasfun-license`
   - Database Password: (simpan!)
   - Region: `Southeast Asia (Singapore)`

## Langkah 2: Setup Database

1. Buka Supabase Dashboard → klik project
2. Klik **SQL Editor** di sidebar
3. Copy-paste isi file `supabase/setup.sql`
4. Klik **Run** untuk execute

## Langkah 3: Ambil API Keys

1. Buka **Settings** → **API**
2. Copy 2 value ini:

```
Project URL: https://xxxxx.supabase.co
anon public: eyJhbGciOiJIUzI1NiIs...
service_role: eyJhbGciOiJIUzI1NiIs...  ← INI YANG PENTING!
```

## Langkah 4: Update Aplikasi

Buka `lib/core/services/license_service.dart`, ganti:

```dart
static const String _supabaseUrl = 'https://YOUR_PROJECT.supabase.co';
static const String _supabaseKey = 'YOUR_ANON_KEY';
```

## Langkah 5: Update Admin Panel

Buka `admin_panel/index.html`, ganti:

```javascript
const SUPABASE_URL = 'https://YOUR_PROJECT.supabase.co';
const SUPABASE_KEY = 'YOUR_SERVICE_ROLE_KEY'; // PAKAI SERVICE ROLE KEY!
```

## Langkah 6: Deploy Admin Panel

Admin panel bisa diakses langsung dari file HTML, atau deploy ke:
- GitHub Pages (gratis)
- Netlify (gratis)
- Vercel (gratis)

## Cara Pakai

### Generate Key (Admin):
1. Buka admin panel
2. Masukkan jumlah key
3. Klik "Generate"
4. Copy key yang dihasilkan

### Kirim ke User:
```
Halo! Terima kasih sudah membeli kelasFun.

License Key Anda:
XXXX-XXXX-XXXX-XXXX

Cara Aktivasi:
1. Install aplikasi kelasFun
2. Buka aplikasi
3. Masukkan license key di atas
4. Klik "Aktivasi"
5. Selesai! Bisa dipakai offline
```

### User Aktivasi:
1. User buka aplikasi
2. Masukkan key
3. Klik Aktivasi
4. Server cek → Valid → Aktif!

### Device Hilang:
1. User hubungi admin
2. Admin buka admin panel
3. Klik "Reset" di key yang sesuai
4. User bisa aktivasi di device baru

## Testing

### Generate test key:
1. Buka admin panel
2. Generate 1 key
3. Buka aplikasi
4. Masukkan key tersebut
5. Klik Aktivasi

### Test device lock:
1. Aktivasi di Device A → Berhasil
2. Aktivasi di Device B dengan key sama → Ditolak

### Test reset:
1. Reset key via admin panel
2. Aktivasi di Device B → Berhasil

## Troubleshooting

| Masalah | Solusi |
|---------|--------|
| "Network error" | Cek koneksi internet |
| "Key tidak valid" | Pastikan key benar (huruf besar) |
| "Sudah dipakai" | Reset key via admin panel |
| "Grace period habis" | Online sebentar untuk re-validasi |
