-- Storage Bucket: 'avatars' Oluşturma ve Politika Ayarları
-- Bu kodu Supabase SQL Editor'de çalıştırarak bucket'ı oluşturabilirsiniz.

-- 1. 'avatars' bucket'ını oluştur (Eğer yoksa)
INSERT INTO storage.buckets (id, name, public)
VALUES ('avatars', 'avatars', true)
ON CONFLICT (id) DO NOTHING;

-- 2. Güvenlik Politikaları (RLS)
-- Kimler dosya görebilir? HERKES (Public bucket olduğu için)
CREATE POLICY "Avatar Images are publicly accessible."
  ON storage.objects FOR SELECT
  USING ( bucket_id = 'avatars' );

-- Kimler dosya yükleyebilir? SADECE Giriş Yapmış (Authenticated) Kullanıcılar
-- NOT: Kayıt olurken de yükleme yapabilmek için 'anon' rolüne de izin verebiliriz veya
-- kullanıcı önce kayıt olur, sonra profilini günceller.
-- Ancak senin senaryonda "Kayıt Ekranında" yükleme var. O an kullanıcı daha 'anon' (giriş yapmamış).
-- Bu yüzden 'anon' rolüne de YÜKLEME (INSERT) izni vermeliyiz.

CREATE POLICY "Anyone can upload an avatar."
  ON storage.objects FOR INSERT
  WITH CHECK ( bucket_id = 'avatars' );

-- Kimler dosya silebilir/güncelleyebilir? Sadece dosyanın sahibi (Kendi avatarını değiştiren)
CREATE POLICY "Users can update their own avatar."
  ON storage.objects FOR UPDATE
  USING ( auth.uid() = owner )
  WITH CHECK ( bucket_id = 'avatars' );

CREATE POLICY "Users can delete their own avatar."
  ON storage.objects FOR DELETE
  USING ( auth.uid() = owner AND bucket_id = 'avatars' );
