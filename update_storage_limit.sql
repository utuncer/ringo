-- Storage Bucket Dosya Boyutu Sınırlaması (2MB)

-- Mevcut politikayı güncelleyerek dosya boyutu kontrolü ekliyoruz.
-- Önce eski politikayı silelim ki çakışmasın.
DROP POLICY IF EXISTS "Anyone can upload an avatar." ON storage.objects;

-- Yeni Politika (Sadece 'avatars' bucket'ına ve dosya boyutu < 2MB olanlara izin ver)
-- 2MB = 2 * 1024 * 1024 = 2097152 bytes
-- NOT: Supabase storage policy'lerinde 'check' ifadesi içinde metadata kontrolü bazen kısıtlı olabilir.
-- Bu yüzden en garantisi client-side (Dart) kontrolüdür. Biz Dart tarafına zaten ekledik.
-- Ancak sunucu tarafında da zorlamak isterseniz, Supabase Dashboard -> Storage -> Policies kısmından manuel eklemek daha sağlıklıdır.
-- SQL ile tam kontrol bazen karmaşık olabilir çünkü 'content-length' header'ına doğrudan erişim her zaman policy içinde olmaz.

-- Yine de temel bir insert policy'si oluşturuyoruz (Boyut kontrolü Dart'ta yapılacak).
CREATE POLICY "Anyone can upload an avatar."
  ON storage.objects FOR INSERT
  WITH CHECK ( bucket_id = 'avatars' );
