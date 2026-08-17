-- SQL SANGAT SIMPEL - cuma buat table
-- Paste ini ke Supabase SQL Editor → Run

CREATE TABLE IF NOT EXISTS licenses (
  id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
  license_key TEXT UNIQUE NOT NULL,
  device_id TEXT,
  status TEXT DEFAULT 'unused',
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  activated_at TIMESTAMP WITH TIME ZONE,
  last_validated_at TIMESTAMP WITH TIME ZONE
);

-- Insert 3 key test
INSERT INTO licenses (license_key, status) VALUES
  ('ABCD-EFGH-IJKL-MNOP', 'unused'),
  ('1234-5678-9012-3456', 'unused'),
  ('TEST-KEY-AAAA-BBBB', 'unused')
ON CONFLICT (license_key) DO NOTHING;
