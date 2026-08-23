-- Migration 001: License System Schema
-- Drops old licenses table (breaking change from old license_key format)
-- Creates new device-bound licensing schema

-- 1. Drop old table if exists
DROP TABLE IF EXISTS licenses;

-- 2. Create new licenses table
CREATE TABLE licenses (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  email TEXT NOT NULL,
  device_id TEXT,
  serial_number TEXT UNIQUE NOT NULL,
  is_active BOOLEAN DEFAULT false,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- 3. Create indexes for query performance
CREATE INDEX idx_serial_number ON licenses(serial_number);
CREATE INDEX idx_email ON licenses(email);
CREATE INDEX idx_device_id ON licenses(device_id);

-- 4. Enable Row Level Security (RLS)
ALTER TABLE licenses ENABLE ROW LEVEL SECURITY;

-- 5. Create policies
-- Service role: full access
CREATE POLICY "Allow all for service role" ON licenses
  FOR ALL
  USING (auth.role() = 'service_role');

-- Anon: SELECT only (for verify function)
CREATE POLICY "Allow select for anon" ON licenses
  FOR SELECT
  USING (true);
