<div align="center">

# KelasFun

**Aplikasi Manajemen Kelas Offline-First untuk Sekolah Indonesia**

![Version](https://img.shields.io/badge/version-1.3.0-blue?style=flat-square)
![Flutter](https://img.shields.io/badge/Flutter-3.x-02569B?style=flat-square&logo=flutter)
![Dart](https://img.shields.io/badge/Dart-3.x-0175C2?style=flat-square&logo=dart)
![License](https://img.shields.io/badge/license-MIT-green?style=flat-square)
![Platform](https://img.shields.io/badge/platform-Windows%20%7C%20Android-lightgrey?style=flat-square)

[Download APK](https://github.com/Chukie99/kelasfun/releases/latest) | [Download EXE](https://github.com/Chukie99/kelasfun/releases/latest)

</div>

---

## Tentang KelasFun

KelasFun adalah aplikasi manajemen kelas berbasis Flutter yang dirancang untuk sekolah-sekolah di Indonesia. Aplikasi ini berjalan secara **offline-first** dengan SQLite lokal, sehingga tetap dapat digunakan tanpa koneksi internet. Untuk sinkronisasi antara perangkat Desktop dan Android, KelasFun menyediakan built-in sync server yang terintegrasi.

## Fitur Utama

### Manajemen Siswa
- CRUD siswa lengkap (NIS, nama, kelas, jenis kelamin, tanggal lahir, alamat, orang tua)
- Pencarian & filter berdasarkan kelas
- Foto siswa dengan auto-resize
- QR Code unik untuk setiap siswa
- Import bulk dari file CSV

### Presensi / Absensi
- Scan barcode/QR code (USB, Bluetooth, kamera)
- Input manual (Hadir, Izin, Sakit, Alpa)
- Filter berdasarkan tanggal & status
- Real-time update

### Nilai & Ranking
- Input nilai per siswa per mata pelajaran (UTS, UAS, Tugas)
- Peringkat siswa berdasarkan rata-rata nilai
- Grafik rata-rata nilai per mata pelajaran

### Poin Disiplin
- Pelanggaran (poin negatif) & Prestasi (poin positif)
- Kategori: Terlambat, PR, Juara Olimpiade, Juara Lomba
- Total poin per siswa

### Jadwal Pelajaran
- Grid mingguan (Senin-Jumat, 8 jam)
- Per kelas dengan pemilihan mata pelajaran

### Laporan & Cetak (PDF & Excel)
- Biodata siswa (A4)
- Kartu identitas siswa (54mm x 86mm) dengan foto & QR
- Raport digital lengkap
- Export Excel (nilai & absensi)

### Sinkronisasi Desktop - Android
- Built-in HTTP sync server (port 8080)
- QR-based pairing (otomatis konfigurasi IP, port, API key)
- Offline queue untuk scan saat offline
- REST API (GET/POST students, attendance, scan)

### Sistem Lisensi & Autentikasi
- Login dengan Google (Supabase Auth)
- Beli lisensi langsung dari lynk.id
- License key dikirim otomatis via email
- Aktivasi lisensi online (Supabase backend)
- Device binding untuk mencegah multi-device
- Grace period 30 hari untuk mode offline
- Admin panel web untuk generate & manage lisensi

### Pengaturan
- Profil sekolah (nama, alamat, kota, provinsi)
- Tema Dark / Light / System
- Backup & restore database SQLite

## Screenshot

<div align="center">

| Dashboard | Presensi | Siswa |
|:---------:|:--------:|:-----:|
| ![Dashboard](assets/screenshot/dashboard.png) | ![Presensi](assets/screenshot/presensi.png) | ![Siswa](assets/screenshot/siswa.png) |

| Nilai | Jadwal | Pengaturan |
|:-----:|:------:|:----------:|
| ![Nilai](assets/screenshot/nilai.png) | ![Jadwal](assets/screenshot/jadwal.png) | ![Pengaturan](assets/screenshot/pengaturan.png) |

</div>

## Download

| Platform | Link | Size |
|----------|------|------|
| Android (APK) | [Download APK](https://github.com/Chukie99/kelasfun/releases/latest) | ~81 MB |
| Windows (EXE) | [Download EXE](https://github.com/Chukie99/kelasfun/releases/latest) | - |

## Tech Stack

| Komponen | Teknologi |
|----------|-----------|
| Framework | Flutter 3.x |
| Bahasa | Dart 3.x |
| Database Lokal | Drift (SQLite) |
| Backend | Supabase (auth + lisensi) |
| Autentikasi | Google OAuth (Supabase Auth) |
| Email Service | Resend |
| State Management | Provider |
| Charts | fl_chart |
| PDF | printing + pdf |
| Excel | excel |
| QR/Scanner | qr_flutter + mobile_scanner |
| Sync Server | shelf + shelf_router |
| Font | Google Fonts (Inter) |

## Struktur Folder

```
kelasfun/
├── android/            # Konfigurasi Android
├── windows/            # Konfigurasi Windows
├── lib/                # Source code Flutter utama
├── admin_panel/        # Panel admin web (lisensi)
├── license_server/     # Server Node.js (lisensi)
├── supabase/           # Config & migrasi database Supabase
├── assets/             # Icon & aset aplikasi
├── tools/              # Tools & utilitas
└── test/               # Unit & widget tests
```

## Cara Build & Jalankan

### Prasyarat
- [Flutter SDK](https://flutter.dev/docs/get-started/install) >= 3.5.4
- Android SDK (untuk build APK)
- Visual Studio dengan workload "Desktop development with C++" (untuk build EXE Windows)

### Build APK (Android)
```bash
flutter pub get
flutter build apk --release
```

### Build EXE (Windows)
```bash
flutter pub get
flutter build windows --release
```

### Jalankan License Server
```bash
cd license_server
npm install
npm start
```

## Kontribusi

Kontribusi sangat diterima! Silakan fork repository ini dan buat pull request.

1. Fork repository ini
2. Buat branch baru (`git checkout -b feature/fitur-baru`)
3. Commit perubahan (`git commit -m 'Tambah fitur baru'`)
4. Push ke branch (`git push origin feature/fitur-baru`)
5. Buat Pull Request

## Lisensi

Proyek ini dilisensikan di bawah [MIT License](LICENSE).

## Kontak

- **Developer**: Sopian Chukie99
- **GitHub**: [@Chukie99](https://github.com/Chukie99)

---

<div align="center">

Dibuat dengan Flutter di Indonesia

</div>
