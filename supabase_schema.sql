-- --------------------------------------------------------
-- Supabase Database Schema for Al-Faisal General Trading
-- --------------------------------------------------------

-- 1. Create Categories Table
CREATE TABLE categories (
  id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
  name_ar TEXT NOT NULL,
  name_en TEXT NOT NULL,
  sort_order INTEGER DEFAULT 0,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT timezone('utc'::text, now()) NOT NULL
);

-- 2. Create Products Table
CREATE TABLE products (
  id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
  category_id UUID REFERENCES categories(id) ON DELETE SET NULL,
  name_ar TEXT NOT NULL,
  name_en TEXT NOT NULL,
  description_ar TEXT,
  description_en TEXT,
  price INTEGER NOT NULL,
  image_url TEXT,
  in_stock BOOLEAN DEFAULT true,
  sort_order INTEGER DEFAULT 0,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT timezone('utc'::text, now()) NOT NULL
);

-- 3. Create Agencies Table
CREATE TABLE agencies (
  id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
  name TEXT NOT NULL,
  description_ar TEXT,
  description_en TEXT,
  logo_url TEXT,
  is_exclusive BOOLEAN DEFAULT true,
  sort_order INTEGER DEFAULT 0,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT timezone('utc'::text, now()) NOT NULL
);

-- --------------------------------------------------------
-- Security: Row Level Security (RLS) Setup
-- --------------------------------------------------------

-- Enable RLS on all tables
ALTER TABLE categories ENABLE ROW LEVEL SECURITY;
ALTER TABLE products ENABLE ROW LEVEL SECURITY;
ALTER TABLE agencies ENABLE ROW LEVEL SECURITY;

-- Create Policies for Public Read Access (Anyone can read the catalog)
CREATE POLICY "Allow public read access on categories" ON categories FOR SELECT USING (true);
CREATE POLICY "Allow public read access on products" ON products FOR SELECT USING (true);
CREATE POLICY "Allow public read access on agencies" ON agencies FOR SELECT USING (true);

-- Create Policies for Authenticated Admin Full Access (Only logged in admins can modify)
CREATE POLICY "Allow admin full access on categories" ON categories FOR ALL USING (auth.role() = 'authenticated');
CREATE POLICY "Allow admin full access on products" ON products FOR ALL USING (auth.role() = 'authenticated');
CREATE POLICY "Allow admin full access on agencies" ON agencies FOR ALL USING (auth.role() = 'authenticated');

-- --------------------------------------------------------
-- Storage Bucket Setup for Images
-- --------------------------------------------------------

-- Create a public bucket named "product-images" if it doesn't exist
INSERT INTO storage.buckets (id, name, public)
VALUES ('product-images', 'product-images', true)
ON CONFLICT (id) DO NOTHING;

-- Storage Policies: Public can view images
CREATE POLICY "Public Access"
ON storage.objects FOR SELECT
USING ( bucket_id = 'product-images' );

-- Storage Policies: Admins can upload, update, delete images
CREATE POLICY "Admin Upload"
ON storage.objects FOR INSERT
WITH CHECK ( bucket_id = 'product-images' AND auth.role() = 'authenticated' );

CREATE POLICY "Admin Update"
ON storage.objects FOR UPDATE
USING ( bucket_id = 'product-images' AND auth.role() = 'authenticated' );

CREATE POLICY "Admin Delete"
ON storage.objects FOR DELETE
USING ( bucket_id = 'product-images' AND auth.role() = 'authenticated' );
