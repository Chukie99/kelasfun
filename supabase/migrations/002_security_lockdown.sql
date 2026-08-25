-- Migration 002: Security lockdown (JALANKAN DI SUPABASE SQL EDITOR)
--
-- Latar belakang: migrasi 001 versi lama membuat policy yang mengizinkan
-- siapa pun dengan anon key membaca SELURUH isi tabel licenses
-- (email pelanggan, serial number, device id).
--
-- Policy tersebut tidak diperlukan karena kedua Edge Function
-- (generate-license / verify-license) menggunakan service-role client.
--
-- Jalankan sekali di Dashboard -> SQL Editor:

DROP POLICY IF EXISTS "Allow select for anon" ON licenses;

-- Verifikasi setelah menjalankan:
-- SELECT policyname, cmd FROM pg_policies WHERE tablename = 'licenses';
-- Harus tersisa hanya: "Allow all for service role" | ALL
