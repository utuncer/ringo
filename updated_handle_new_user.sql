-- Trigger Function'ı Güncelleme
-- Bu SQL kodunu Supabase Dashboard -> SQL Editor kısmında çalıştırın.

CREATE OR REPLACE FUNCTION public.handle_new_user()
RETURNS TRIGGER AS $$
DECLARE
  interest_name_text text;
  interest_id_val int;
  interest_list jsonb;
BEGIN
  -- 1. Kullanıcı Profilini Oluştur (public.users)
  INSERT INTO public.users (
    id, 
    email, 
    full_name, 
    username, 
    role, 
    avatar_url, 
    avatar_type, 
    avatar_gender, 
    avatar_bg_color
  )
  VALUES (
    new.id,
    new.email,
    new.raw_user_meta_data->>'full_name',
    new.raw_user_meta_data->>'username',
    (new.raw_user_meta_data->>'role')::user_role,
    new.raw_user_meta_data->>'avatar_url',
    COALESCE((new.raw_user_meta_data->>'avatar_type')::avatar_type, 'preset'),
    (new.raw_user_meta_data->>'avatar_gender')::gender,
    new.raw_user_meta_data->>'avatar_bg_color'
  );

  -- 2. İlgi Alanlarını Kaydet (public.user_interests)
  -- 'interestNames' metadata içinde JSON array olarak gelir (["Frontend", "Backend"] gibi)
  interest_list := new.raw_user_meta_data->'interestNames';

  IF interest_list IS NOT NULL THEN
    -- JSON dizisindeki her bir eleman için döngü
    FOR interest_name_text IN SELECT * FROM jsonb_array_elements_text(interest_list)
    LOOP
      -- İsimden ID'yi bul
      SELECT id INTO interest_id_val FROM public.interests WHERE name = interest_name_text;
      
      -- ID bulunduysa eşleştirme tablosuna ekle
      IF interest_id_val IS NOT NULL THEN
        INSERT INTO public.user_interests (user_id, interest_id)
        VALUES (new.id, interest_id_val)
        ON CONFLICT DO NOTHING;
      END IF;
    END LOOP;
  END IF;

  RETURN new;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;
