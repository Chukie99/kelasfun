-- Migration 004: Bundle 2 device (Windows + Android) + kill switch pembelian
-- JALANKAN DI SUPABASE DASHBOARD -> SQL EDITOR (sekali saja)

-- ============================================================
-- PENTING: jalankan bagian backfill SEBELUM deploy Edge Function
-- verify-license versi baru, agar pelanggan lama tidak terkunci
-- saat revalidasi (mereka belum terdaftar di allowed_emails).
-- ============================================================

-- 1) Slot device kedua untuk bundle Android + Windows
ALTER TABLE licenses ADD COLUMN IF NOT EXISTS device_id_2 TEXT;

-- 2) Backfill: semua email pemilik lisensi masuk allowed_emails.
--    is_used=true supaya mereka TIDAK bisa minta serial tambahan.
INSERT INTO allowed_emails (email, is_used)
SELECT DISTINCT email, true FROM licenses
WHERE email IS NOT NULL AND email <> ''
ON CONFLICT (email) DO NOTHING;

UPDATE allowed_emails
SET is_used = true
WHERE email IN (SELECT DISTINCT email FROM licenses WHERE email IS NOT NULL);

-- Verifikasi setelah menjalankan:
-- SELECT column_name FROM information_schema.columns
--   WHERE table_name='licenses' AND column_name='device_id_2';  -- harus ada 1 baris
-- SELECT count(*) FROM allowed_emails;  -- >= jumlah lisensi unik

-- CARA PAKAI KILL SWITCH (refund / pelanggaran):
-- DELETE FROM allowed_emails WHERE email = 'pelanggan@gmail.com';
-- -> aktivasi & revalidasi serial milik email itu langsung ditolak.

-- RESET DEVICE PELANGGAN (ganti HP/laptop):
-- UPDATE licenses SET device_id = NULL, device_id_2 = NULL
--   WHERE serial_number = 'KF-XXXX-XXXX';
