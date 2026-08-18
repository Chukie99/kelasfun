-- Add user_id and purchase columns to licenses table
-- Run this in Supabase SQL Editor

-- Add columns for linking to Supabase Auth user
ALTER TABLE licenses ADD COLUMN IF NOT EXISTS user_id UUID REFERENCES auth.users(id);
ALTER TABLE licenses ADD COLUMN IF NOT EXISTS buyer_email TEXT;
ALTER TABLE licenses ADD COLUMN IF NOT EXISTS buyer_name TEXT;
ALTER TABLE licenses ADD COLUMN IF NOT EXISTS purchase_ref_id TEXT;
ALTER TABLE licenses ADD COLUMN IF NOT EXISTS purchased_at TIMESTAMPTZ;

-- Indexes for performance
CREATE INDEX IF NOT EXISTS idx_licenses_user_id ON licenses(user_id);
CREATE INDEX IF NOT EXISTS idx_licenses_buyer_email ON licenses(buyer_email);

-- RLS: Allow authenticated users to read their own licenses
CREATE POLICY "Users can read own licenses" ON licenses
  FOR SELECT USING (auth.uid() = user_id);

-- RLS: Allow authenticated users to update their own licenses
CREATE POLICY "Users can update own licenses" ON licenses
  FOR UPDATE USING (auth.uid() = user_id);
