-- Migration 001: License System Schema
-- Idempotent: aman dijalankan berulang tanpa menghapus data produksi.
-- CATATAN: jangan pernah DROP TABLE di migrasi produksi!

-- 1. Create table (tanpa drop!)
CREATE TABLE IF NOT EXISTS licenses (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  email TEXT NOT NULL,
  device_id TEXT,
  serial_number TEXT UNIQUE NOT NULL,
  is_active BOOLEAN DEFAULT false,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- 2. Indexes
CREATE INDEX IF NOT EXISTS idx_serial_number ON licenses(serial_number);
CREATE INDEX IF NOT EXISTS idx_email ON licenses(email);
CREATE INDEX IF NOT EXISTS idx_device_id ON licenses(device_id);

-- 3. RLS
ALTER TABLE licenses ENABLE ROW LEVEL SECURITY;

-- 4. Policies
-- Service role: full access (service role sebenarnya sudah bypass RLS,
-- policy ini hanya dokumentasi eksplisit)
DROP POLICY IF EXISTS "Allow all for service role" ON licenses;
CREATE POLICY "Allow all for service role" ON licenses
  FOR ALL
  USING (auth.role() = 'service_role');

-- TIDAK ADA policy untuk anon sama sekali.
-- Kedua Edge Function membaca/menulis via service-role client,
-- sedangkan anon tidak boleh bisa SELECT (melindungi email & serial pelanggan).
