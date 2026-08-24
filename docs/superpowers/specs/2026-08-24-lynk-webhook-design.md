# Desain: Edge Function `lynk-webhook` untuk Otomatisasi Pembeli dari Lynk.id

Tanggal: 2026-08-24
Status: Disetujui (desain di-approve user)

## Latar Belakang

Saat ini pembeli yang membeli lisensi kelasFun via Lynk.id harus didaftarkan manual:
admin menjalankan `INSERT INTO allowed_emails (email) VALUES ('...')` setelah melihat
notifikasi pembayaran. Ini rawan telat/lupa. Fitur ini mengotomatisasi langkah tersebut.

Setelah fitur ini, alur pembelian menjadi 100% otomatis:

1. Pembeli bayar di Lynk.id → webhook kirim notifikasi ke Supabase
2. `lynk-webhook` verifikasi signature → insert email ke `allowed_emails`
3. Pembeli buka aplikasi → masukkan email → terima serial number (function `generate-license` existing)

## Keputusan Desain

| Pertanyaan | Keputusan |
|---|---|
| Filter produk? | Tidak — akun Lynk.id hanya menjual kelasFun, semua `payment.received` = pembeli kelasFun |
| Notifikasi admin? | Ya, Telegram (env var TELEGRAM_BOT_TOKEN & TELEGRAM_CHAT_ID sudah ada), hanya saat email benar-benar baru |
| Audit log transaksi? | Tidak (pendekatan A) — riwayat order cukup dilihat di dashboard Lynk.id |
| Perubahan skema DB? | Tidak ada |

## Referensi Resmi Lynk.id Webhook

Sumber: https://documenter.getpostman.com/view/3211564/2sB2cVf2Kp

### Event

Hanya satu event: `payment.received` — dipicu setelah customer menyelesaikan pembayaran.
Method POST, Content-Type application/json.

### Struktur Payload

```json
{
  "event": "payment.received",
  "data": {
    "message_action": "SUCCESS",
    "message_code": "0",
    "message_data": {
      "createdAt": "2025-04-10T14:30:45",
      "customer": {
        "email": "user@lynk.id",
        "name": "Lynk User",
        "phone": "0812345677889"
      },
      "items": [ { "title": "Digital Produk", "price": 25000, "qty": 1, "...": "..." } ],
      "refId": "13f8d23beeb2aacbbc01c94060cc88d7",
      "totals": { "grandTotal": 72000, "...": "..." }
    },
    "message_id": "API_CALL_1744270275143115_4624014"
  }
}
```

Field yang dipakai:

- `data.message_data.customer.email` — email pembeli (satu-satunya data wajib)
- `data.message_data.customer.name` — untuk isi notif Telegram
- `data.message_data.totals.grandTotal` — jumlah bayar, bagian dari string signature
- `data.message_data.refId` — ID referensi transaksi, bagian dari string signature
- `data.message_id` — ID unik pesan, bagian dari string signature
- `event`, `data.message_action` — penanda jenis event & status sukses

### Verifikasi Signature

Lynk.id menyertakan header `X-Lynk-Signature`. Rumus resmi (dari dokumentasi):

```
signature = SHA256_hex( String(amount/grandTotal) + refId + message_id + merchantKey )
```

Catatan implementasi:

- Urutan persis: amount, lalu refId, lalu message_id, lalu merchantKey (tanpa pemisah).
- `grandTotal` di payload contoh berupa angka JSON; harus dikonversi `String(...)` sebelum
  digabung. Jangan diformat ulang (tanpa ribuan, tanpa desimal tambahan).
- Hasil hash lowercase hex; bandingkan dengan header apa adanya.
- MerchantKey muncul di dashboard Lynk.id **setelah** URL webhook disimpan.
- Bila verifikasi gagal, log computed vs received (tanpa mencetak merchant key) agar mudah debug.

## Arsitektur

```
Pembeli bayar di Lynk.id (sukses)
   │  POST https://cdgnqhdmsnrlzylgoecz.supabase.co/functions/v1/lynk-webhook
   │  Header: X-Lynk-Signature
   ▼
lynk-webhook (Edge Function, deploy --no-verify-jwt)
   1. Baca raw body text + header X-Lynk-Signature
   2. Verifikasi signature (lihat rumus di atas). Gagal → 401, proses berhenti.
   3. Cek event == "payment.received" && message_action == "SUCCESS" → selain itu skip 200
   4. Ambil customer.email → trim + lowercase + validasi format regex
      tidak valid → console.error + Telegram warning ke admin → tetap 200
   5. Upsert allowed_emails { email } dengan ignoreDuplicates: true (idempotent terhadap retry)
   6. Jika benar-benar ada baris baru → notif Telegram (email, nama, grandTotal, refId, waktu WIB)
   7. Respons 200 {"received": true}
```

## Komponen

- **File baru**: `kelasfun/supabase/functions/lynk-webhook/index.ts`
  - Import sama dengan function existing: `https://deno.land/std@0.177.0/http/server.ts`
    dan `https://esm.sh/@supabase/supabase-js@2`
  - Client Supabase memakai service role (`SUPABASE_URL`, `SUPABASE_SERVICE_ROLE_KEY`
    otomatis tersedia di runtime Edge Function)
- **Perubahan kecil di function existing**: `generate-license/index.ts` — input email
  dari aplikasi di-normalisasi (`trim().toLowerCase()`) sebelum dicek ke `allowed_emails`
  dan sebelum insert lisensi. Alasan: webhook menyimpan email dalam bentuk lowercase,
  sedangkan `generate-license` saat ini membandingkan string mentah. Tanpa normalisasi,
  pembeli yang mengetik "Budi@Gmail.com" di aplikasi akan ditolak padahal terdaftar
  sebagai "budi@gmail.com". Perubahan hanya 1-2 baris, tidak mengubah perilaku lain.
- **Env var baru**: `LYNK_MERCHANT_KEY` — di-set lewat `supabase secrets set`
  (atau Dashboard → Edge Functions → Settings)
- **Tanpa migrasi SQL** — tabel `allowed_emails (email PK, is_used, created_at)` sudah ada

## Aturan Error Handling

| Kondisi | Respons | Alasan |
|---|---|---|
| Method bukan POST | `405` | Konsisten dengan function lain |
| Env `LYNK_MERCHANT_KEY` belum di-set | `500` | Kesalahan konfigurasi server |
| Signature tidak cocok / header hilang | `401` | Tolak request tidak sah; jangan sentuh DB |
| Event != payment.received atau message_action != SUCCESS | `200`, dilewati | Hindari retry tanpa guna untuk event lain |
| Email hilang/format salah | `200` + Telegram warning + console.error | Retry tidak akan memperbaiki payload rusak |
| Error database saat upsert | `500` | Lynk.id akan retry otomatis |
| Email sudah terdaftar (duplikat/retry) | `200`, tanpa Telegram baru | Idempoten |

## Perilaku yang Sengaja Tidak Diubah

- Pembeli yang beli 2x dengan email sama tetap hanya berhak atas 1 serial number
  (sesuai desain existing "1 email terdaftar = maksimal 1 serial", unique index
  `uq_licenses_email`). Repeat purchase tidak me-reset `is_used`.
- `verify-license` tidak disentuh sama sekali; `generate-license` hanya dapat
  normalisasi email (lihat komponen).
- RLS `allowed_emails` tidak berubah (tetap tanpa policy anon).

## Keamanan

- Verifikasi signature WAJIB sebelum ada akses DB. Tanpa ini, siapa pun yang tahu URL
  bisa allowlist email sendiri dan mendapat lisensi gratis.
- Merchant key hanya hidup sebagai secret Edge Function, tidak pernah dikirim/log.
- Email dinormalisasi (trim + lowercase) saat insert, dan input di `generate-license`
  dinormalisasi dengan cara yang sama — sehingga pencocokan selalu konsisten berapa
  pun kapitalisasi yang diketik pembeli di checkout maupun di aplikasi.

## Testing

1. **Unit-ish via curl**: hit endpoint dengan payload contoh resmi + signature yang
   dihitung dari merchant key asli. Ekspektasi: baris baru muncul di `allowed_emails`
   (is_used=false) + notif Telegram.
2. **Signature salah**: curl dengan signature ngawur → ekspektasi `401`, tidak ada baris baru.
3. **Duplikat**: kirim payload sama 2x → ekspektasi tetap `200`, hanya 1 notif, 1 baris.
4. **End-to-end**: transaksi nyata di Lynk.id (atau tombol test bila tersedia) → email
   pembeli muncul otomatis di Table Editor.
5. Setelah itu jalankan flow aplikasi: generate serial pakai email tsb → sukses.

## Instruksi Setup untuk Admin (deliverable)

1. Deploy:
   ```
   supabase functions deploy lynk-webhook --no-verify-jwt
   ```
2. Buka dashboard Lynk.id → menu API/Webhook → paste URL:
   ```
   https://cdgnqhdmsnrlzylgoecz.supabase.co/functions/v1/lynk-webhook
   ```
   → Save. Copy **Merchant Key** yang ditampilkan.
3. Set secret:
   ```
   supabase secrets set LYNK_MERCHANT_KEY=<merchant_key_dari_dashboard>
   ```
4. Jalankan pengujian di atas.

## Batasan yang Dikenal (out of scope)

- Refund/pembatalan tidak membuang email dari `allowed_emails` (Lynk.id pun tidak
  mengirim event refund pada webhook ini).
- Tidak ada retry internal jika Telegram gagal — kegagalan Telegram tidak boleh
  membuat webhook gagal (insert DB adalah aksi utama).
