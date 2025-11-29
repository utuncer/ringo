-- Enable UUID extension
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";

-- Enums
CREATE TYPE user_role AS ENUM ('competitor', 'instructor', 'team');
CREATE TYPE avatar_type AS ENUM ('preset', 'custom');
CREATE TYPE gender AS ENUM ('male', 'female');
CREATE TYPE invitation_status AS ENUM ('pending', 'accepted', 'rejected');

-- Users Table
CREATE TABLE users (
    id UUID PRIMARY KEY REFERENCES auth.users(id) ON DELETE CASCADE,
    username TEXT UNIQUE NOT NULL CHECK (username ~* '^[a-zA-Z0-9_]+$'),
    full_name TEXT NOT NULL,
    email TEXT UNIQUE NOT NULL,
    role user_role NOT NULL,
    avatar_url TEXT,
    avatar_type avatar_type DEFAULT 'preset',
    avatar_gender gender,
    avatar_bg_color TEXT,
    email_verified BOOLEAN DEFAULT FALSE,
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- Interests Table
CREATE TABLE interests (
    id SERIAL PRIMARY KEY,
    name TEXT UNIQUE NOT NULL
);

-- Insert predefined interests
INSERT INTO interests (name) VALUES 
('Frontend'), ('Backend'), ('Savaşan İHA'), ('Sürü İHA'), ('Mobil'), ('Oyun Tasarımı'), ('Yapay Zeka')
ON CONFLICT (name) DO NOTHING;

-- User Interests Table
CREATE TABLE user_interests (
    user_id UUID REFERENCES users(id) ON DELETE CASCADE,
    interest_id INTEGER REFERENCES interests(id) ON DELETE CASCADE,
    PRIMARY KEY (user_id, interest_id)
);

-- Posts Table
CREATE TABLE posts (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    user_id UUID REFERENCES users(id) ON DELETE CASCADE NOT NULL,
    content TEXT CHECK (char_length(content) <= 200),
    image_url TEXT,
    image_aspect_ratio FLOAT,
    created_at TIMESTAMPTZ DEFAULT NOW(),
    CONSTRAINT content_or_image_check CHECK (
        (image_url IS NOT NULL) OR (char_length(content) >= 50)
    )
);

-- Post Tags Table
CREATE TABLE post_tags (
    post_id UUID REFERENCES posts(id) ON DELETE CASCADE,
    interest_id INTEGER REFERENCES interests(id) ON DELETE CASCADE,
    PRIMARY KEY (post_id, interest_id)
);

-- Comments Table
CREATE TABLE comments (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    user_id UUID REFERENCES users(id) ON DELETE CASCADE NOT NULL,
    post_id UUID REFERENCES posts(id) ON DELETE CASCADE NOT NULL,
    content TEXT NOT NULL CHECK (char_length(content) >= 50 AND char_length(content) <= 100),
    created_at TIMESTAMPTZ DEFAULT NOW()
);

-- Votes Table
CREATE TABLE votes (
    user_id UUID REFERENCES users(id) ON DELETE CASCADE,
    post_id UUID REFERENCES posts(id) ON DELETE CASCADE,
    value INTEGER CHECK (value IN (-1, 0, 1)),
    created_at TIMESTAMPTZ DEFAULT NOW(),
    PRIMARY KEY (user_id, post_id)
);

-- Saved Posts Table
CREATE TABLE saved_posts (
    user_id UUID REFERENCES users(id) ON DELETE CASCADE,
    post_id UUID REFERENCES posts(id) ON DELETE CASCADE,
    created_at TIMESTAMPTZ DEFAULT NOW(),
    PRIMARY KEY (user_id, post_id)
);

-- Saved Users Table
CREATE TABLE saved_users (
    user_id UUID REFERENCES users(id) ON DELETE CASCADE,
    saved_user_id UUID REFERENCES users(id) ON DELETE CASCADE,
    created_at TIMESTAMPTZ DEFAULT NOW(),
    PRIMARY KEY (user_id, saved_user_id),
    CONSTRAINT no_self_save CHECK (user_id != saved_user_id)
);

-- Messages Table
CREATE TABLE messages (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    sender_id UUID REFERENCES users(id) ON DELETE CASCADE NOT NULL,
    receiver_id UUID REFERENCES users(id) ON DELETE CASCADE, -- Can be null for team chat? No, receiver is user or team. Wait, for team chat, receiver might be null if we use team_id.
    team_id UUID REFERENCES users(id) ON DELETE CASCADE, -- If team chat, this is the team's user_id
    content TEXT NOT NULL CHECK (char_length(content) <= 100),
    is_read BOOLEAN DEFAULT FALSE,
    created_at TIMESTAMPTZ DEFAULT NOW(),
    deleted_by UUID[] DEFAULT '{}', -- Array of user_ids who deleted this message
    CONSTRAINT team_or_receiver_check CHECK (
        (team_id IS NOT NULL AND receiver_id IS NULL) OR 
        (team_id IS NULL AND receiver_id IS NOT NULL)
    )
);
-- Correction: For team chat, usually messages are linked to a group. Here 'team_id' refers to the team account.
-- If it's a 1-1 chat, team_id is null.
-- If it's a team chat, team_id is the team's id.

-- Invitations Table
CREATE TABLE invitations (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    team_id UUID REFERENCES users(id) ON DELETE CASCADE NOT NULL,
    user_id UUID REFERENCES users(id) ON DELETE CASCADE NOT NULL,
    status invitation_status DEFAULT 'pending',
    created_at TIMESTAMPTZ DEFAULT NOW(),
    UNIQUE(team_id, user_id) -- Prevent duplicate pending invites? Logic says "Pending davet varsa...". So unique constraint helps.
);

-- Team Members Table
CREATE TABLE team_members (
    team_id UUID REFERENCES users(id) ON DELETE CASCADE NOT NULL,
    user_id UUID REFERENCES users(id) ON DELETE CASCADE NOT NULL,
    joined_at TIMESTAMPTZ DEFAULT NOW(),
    PRIMARY KEY (team_id, user_id)
);

-- Blocked Users Table
CREATE TABLE blocked_users (
    user_id UUID REFERENCES users(id) ON DELETE CASCADE,
    blocked_user_id UUID REFERENCES users(id) ON DELETE CASCADE,
    created_at TIMESTAMPTZ DEFAULT NOW(),
    PRIMARY KEY (user_id, blocked_user_id),
    CONSTRAINT no_self_block CHECK (user_id != blocked_user_id)
);

-- RLS Policies (Basic Setup - to be refined)
ALTER TABLE users ENABLE ROW LEVEL SECURITY;
ALTER TABLE interests ENABLE ROW LEVEL SECURITY;
ALTER TABLE user_interests ENABLE ROW LEVEL SECURITY;
ALTER TABLE posts ENABLE ROW LEVEL SECURITY;
ALTER TABLE post_tags ENABLE ROW LEVEL SECURITY;
ALTER TABLE comments ENABLE ROW LEVEL SECURITY;
ALTER TABLE votes ENABLE ROW LEVEL SECURITY;
ALTER TABLE saved_posts ENABLE ROW LEVEL SECURITY;
ALTER TABLE saved_users ENABLE ROW LEVEL SECURITY;
ALTER TABLE messages ENABLE ROW LEVEL SECURITY;
ALTER TABLE invitations ENABLE ROW LEVEL SECURITY;
ALTER TABLE team_members ENABLE ROW LEVEL SECURITY;
ALTER TABLE blocked_users ENABLE ROW LEVEL SECURITY;

-- Public read access for most things
CREATE POLICY "Public profiles are viewable by everyone" ON users FOR SELECT USING (true);
CREATE POLICY "Users can update own profile" ON users FOR UPDATE USING (auth.uid() = id);

CREATE POLICY "Interests are viewable by everyone" ON interests FOR SELECT USING (true);

CREATE POLICY "User interests are viewable by everyone" ON user_interests FOR SELECT USING (true);
CREATE POLICY "Users can manage own interests" ON user_interests FOR ALL USING (auth.uid() = user_id);

CREATE POLICY "Posts are viewable by everyone" ON posts FOR SELECT USING (true);
CREATE POLICY "Users can create posts" ON posts FOR INSERT WITH CHECK (auth.uid() = user_id);
CREATE POLICY "Users can delete own posts" ON posts FOR DELETE USING (auth.uid() = user_id);

CREATE POLICY "Comments are viewable by everyone" ON comments FOR SELECT USING (true);
CREATE POLICY "Users can create comments" ON comments FOR INSERT WITH CHECK (auth.uid() = user_id);
CREATE POLICY "Users can delete own comments" ON comments FOR DELETE USING (auth.uid() = user_id);

-- Storage Buckets (to be created in dashboard, but policies here)
-- Bucket: 'avatars', 'post_images'

-- Trigger to create public user profile on signup
CREATE OR REPLACE FUNCTION public.handle_new_user()
RETURNS TRIGGER AS $$
BEGIN
  INSERT INTO public.users (id, email, full_name, username, role, avatar_url, avatar_type, avatar_gender, avatar_bg_color)
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
  RETURN new;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

CREATE TRIGGER on_auth_user_created
  AFTER INSERT ON auth.users
  FOR EACH ROW EXECUTE PROCEDURE public.handle_new_user();

