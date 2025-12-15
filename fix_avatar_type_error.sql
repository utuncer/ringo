-- Trigger Function'ı Güncelleme (Avatar Type Cast Düzeltmesi)

CREATE OR REPLACE FUNCTION public.handle_new_user()
RETURNS TRIGGER AS $$
DECLARE
  interest_name_text text;
  interest_id_val int;
  interest_list jsonb;
  role_text text;
  cast_role public.user_role;
  -- Enum değerlerini string olarak tut. Cast işlemini insert anında deneriz.
BEGIN
  role_text := new.raw_user_meta_data->>'role';

  -- Rol Dönüşümü Denemesi
  BEGIN
    cast_role := role_text::public.user_role;
  EXCEPTION WHEN OTHERS THEN
     RAISE EXCEPTION 'Gecersiz Rol Degeri: %', role_text;
  END;

  -- 1. Kullanıcı Profilini Oluştur (public.users)
  -- NOT: avatar_type ENUM'ı 'preset' ve 'custom' değerlerini alır.
  -- Veritabanında daha önce oluşturduğumuz ENUM: CREATE TYPE avatar_type AS ENUM ('preset', 'custom');
  -- Kod tarafında da 'preset' veya 'custom' gönderiyoruz.
  
  INSERT INTO public.users (
    id, 
    email, 
    full_name, 
    username, 
    role, 
    avatar_url, 
    avatar_type,           -- Enum sütunu
    avatar_gender, 
    avatar_bg_color
  )
  VALUES (
    new.id,
    new.email,
    new.raw_user_meta_data->>'full_name',
    new.raw_user_meta_data->>'username',
    cast_role,
    new.raw_user_meta_data->>'avatar_url',
    -- Avatar Type Casting (Önemli: Veritabanında enum smallcase ise gelen veri de öyle olmalı)
    (new.raw_user_meta_data->>'avatar_type')::public.avatar_type, 
    (new.raw_user_meta_data->>'avatar_gender')::public.gender,
    new.raw_user_meta_data->>'avatar_bg_color'
  );

  -- 2. İlgi Alanlarını Kaydet
  IF (new.raw_user_meta_data ? 'interestNames') AND (jsonb_typeof(new.raw_user_meta_data->'interestNames') = 'array') THEN
      interest_list := new.raw_user_meta_data->'interestNames';
      
      FOR interest_name_text IN SELECT * FROM jsonb_array_elements_text(interest_list)
      LOOP
        SELECT id INTO interest_id_val FROM public.interests WHERE name = interest_name_text LIMIT 1;
        
        IF interest_id_val IS NOT NULL THEN
          INSERT INTO public.user_interests (user_id, interest_id)
          VALUES (new.id, interest_id_val)
          ON CONFLICT DO NOTHING;
        END IF;
      END LOOP;
  END IF;

  RETURN new;
EXCEPTION WHEN OTHERS THEN
  RAISE EXCEPTION 'Trigger Hatasi (Detay): %', SQLERRM;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;
