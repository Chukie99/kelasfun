-- Migration 003: Purchase gating (JALANKAN DI SUPABASE SQL EDITOR)
--
-- 1 email terdaftar = maksimal 1 serial number, terkunci ke 1 device.
-- Isi daftar pembeli setelah konfirmasi pembayaran:
--   INSERT INTO allowed_emails (email) VALUES ('pembeli@gmail.com');

-- 1) Tabel daftar email pembeli sah
CREATE TABLE IF NOT EXISTS allowed_emails (
  email TEXT PRIMARY KEY,
  is_used BOOLEAN NOT NULL DEFAULT false,
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

ALTER TABLE allowed_emails ENABLE ROW LEVEL SECURITY;

-- Tidak ada policy anon: hanya service-role (Edge Function) yang mengakses.
-- Kelola daftar pembeli lewat Supabase Dashboard -> Table Editor.

-- 2) Kunci unik: 1 email cuma boleh punya 1 baris lisensi,
--    dan 1 device juga cuma 1 baris lisensi.
CREATE UNIQUE INDEX IF NOT EXISTS uq_licenses_email ON licenses (email);
CREATE UNIQUE INDEX IF NOT EXISTS uq_licenses_device_id ON licenses (device_id);

-- Verifikasi setelah menjalankan:
-- SELECT tablename, policyname FROM pg_policies WHERE tablename='allowed_emails';  -- kosong = benar
-- SELECT indexname FROM pg_indexes WHERE tablename='licenses';
