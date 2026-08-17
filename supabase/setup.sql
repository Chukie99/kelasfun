-- ============================================================
-- SETUP SUPABASE UNTUK SISTEM LISENSI kelasFun
-- ============================================================

-- 1. BUAT TABLE LICENSES
CREATE TABLE licenses (
  id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
  license_key TEXT UNIQUE NOT NULL,
  device_id TEXT,
  status TEXT DEFAULT 'unused' CHECK (status IN ('unused', 'active', 'expired', 'reset')),
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  activated_at TIMESTAMP WITH TIME ZONE,
  last_validated_at TIMESTAMP WITH TIME ZONE,
  user_email TEXT,
  user_name TEXT
);

-- 2. BUAT INDEX UNTUK PERFORMA
CREATE INDEX idx_license_key ON licenses(license_key);
CREATE INDEX idx_device_id ON licenses(device_id);
CREATE INDEX idx_status ON licenses(status);

-- 3. BUAT FUNCTION UNTUK VALIDATE LICENSE
CREATE OR REPLACE FUNCTION validate_license(
  p_license_key TEXT,
  p_device_id TEXT
)
RETURNS TABLE (
  valid BOOLEAN,
  message TEXT,
  activated_at TIMESTAMP WITH TIME ZONE
)
LANGUAGE plpgsql
AS $$
DECLARE
  v_license RECORD;
  v_now TIMESTAMP WITH TIME ZONE := NOW();
BEGIN
  -- Cari license key
  SELECT * INTO v_license
  FROM licenses
  WHERE license_key = UPPER(p_license_key);
  
  -- Key tidak ditemukan
  IF NOT FOUND THEN
    RETURN QUERY SELECT 
      FALSE::BOOLEAN,
      'License key tidak valid'::TEXT,
      NULL::TIMESTAMP WITH TIME ZONE;
    RETURN;
  END IF;
  
  -- Key sudah expired
  IF v_license.status = 'expired' THEN
    RETURN QUERY SELECT 
      FALSE::BOOLEAN,
      'License key sudah expired'::TEXT,
      NULL::TIMESTAMP WITH TIME ZONE;
    RETURN;
  END IF;
  
  -- Key belum dipakai → Aktivasi baru
  IF v_license.status = 'unused' THEN
    UPDATE licenses
    SET 
      device_id = p_device_id,
      status = 'active',
      activated_at = v_now,
      last_validated_at = v_now
    WHERE license_key = UPPER(p_license_key);
    
    RETURN QUERY SELECT 
      TRUE::BOOLEAN,
      'Aktivasi berhasil!'::TEXT,
      v_now;
    RETURN;
  END IF;
  
  -- Key sudah aktif → Cek device
  IF v_license.status = 'active' THEN
    -- Device sama → Update last_validated
    IF v_license.device_id = p_device_id THEN
      UPDATE licenses
      SET last_validated_at = v_now
      WHERE license_key = UPPER(p_license_key);
      
      RETURN QUERY SELECT 
        TRUE::BOOLEAN,
        'Aktivasi berhasil!'::TEXT,
        v_license.activated_at;
      RETURN;
    END IF;
    
    -- Device beda → Tolak
    RETURN QUERY SELECT 
      FALSE::BOOLEAN,
      'License sudah digunakan di device lain. Hubungi admin untuk reset.'::TEXT,
      NULL::TIMESTAMP WITH TIME ZONE;
    RETURN;
  END IF;
  
  -- Status lain (expired, reset)
  RETURN QUERY SELECT 
    FALSE::BOOLEAN,
    'License tidak valid. Hubungi admin.'::TEXT,
    NULL::TIMESTAMP WITH TIME ZONE;
END;
$$;

-- 4. BUAT FUNCTION UNTUK RESET LICENSE (ADMIN)
CREATE OR REPLACE FUNCTION reset_license(
  p_license_key TEXT
)
RETURNS TABLE (
  success BOOLEAN,
  message TEXT
)
LANGUAGE plpgsql
AS $$
BEGIN
  UPDATE licenses
  SET 
    device_id = NULL,
    status = 'unused',
    activated_at = NULL,
    last_validated_at = NULL
  WHERE license_key = UPPER(p_license_key);
  
  IF FOUND THEN
    RETURN QUERY SELECT 
      TRUE::BOOLEAN,
      'License berhasil di-reset. Bisa digunakan di device baru.'::TEXT;
  ELSE
    RETURN QUERY SELECT 
      FALSE::BOOLEAN,
      'License key tidak ditemukan'::TEXT;
  END IF;
END;
$$;

-- 5. BUAT FUNCTION UNTUK GENERATE KEY (ADMIN)
CREATE OR REPLACE FUNCTION generate_license(
  p_user_email TEXT DEFAULT NULL,
  p_user_name TEXT DEFAULT NULL
)
RETURNS TABLE (
  license_key TEXT,
  message TEXT
)
LANGUAGE plpgsql
AS $$
DECLARE
  v_new_key TEXT;
  v_chars TEXT := 'ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789';
  v_i INTEGER;
BEGIN
  -- Generate random key format: XXXX-XXXX-XXXX-XXXX
  v_new_key := '';
  FOR v_i IN 1..16 LOOP
    IF v_i > 1 AND (v_i - 1) % 4 = 0 THEN
      v_new_key := v_new_key || '-';
    END IF;
    v_new_key := v_new_key || SUBSTRING(v_chars FROM (floor(random() * length(v_chars) + 1))::int FOR 1);
  END LOOP;
  
  -- Insert ke database
  INSERT INTO licenses (license_key, user_email, user_name, status)
  VALUES (v_new_key, p_user_email, p_user_name, 'unused');
  
  RETURN QUERY SELECT 
    v_new_key,
    'License key berhasil dibuat'::TEXT;
END;
$$;

-- 6. INSERT CONTOH DATA (OPSIONAL)
-- INSERT INTO licenses (license_key, status) VALUES 
-- ('ABCD-EFGH-IJKL-MNOP', 'unused'),
-- ('1234-5678-9012-3456', 'unused');

-- 7. ENABLE ROW LEVEL SECURITY (RLS)
ALTER TABLE licenses ENABLE ROW LEVEL SECURITY;

-- 8. BUAT POLICY UNTUK SERVICE ROLE (ADMIN)
CREATE POLICY "Allow all for service role" ON licenses
  FOR ALL
  USING (auth.role() = 'service_role');

-- 9. BUAT POLICY UNTUK ANON (VALIDASI)
CREATE POLICY "Allow validate for anon" ON licenses
  FOR SELECT
  USING (true);

CREATE POLICY "Allow update for anon" ON licenses
  FOR UPDATE
  USING (true);
