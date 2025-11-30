-- Fix RLS Policies for Votes, Saved Posts, and Saved Users

-- Votes Table Policies
-- Allow users to view all votes (needed for counting/displaying)
CREATE POLICY "Votes are viewable by everyone" ON votes FOR SELECT USING (true);

-- Allow users to insert, update, and delete their own votes
CREATE POLICY "Users can manage own votes" ON votes FOR ALL USING (auth.uid() = user_id);


-- Saved Posts Table Policies
-- Allow users to view only their own saved posts (privacy)
CREATE POLICY "Users can view own saved posts" ON saved_posts FOR SELECT USING (auth.uid() = user_id);

-- Allow users to manage their own saved posts
CREATE POLICY "Users can manage own saved posts" ON saved_posts FOR ALL USING (auth.uid() = user_id);


-- Saved Users Table Policies
-- Allow users to view only their own saved users
CREATE POLICY "Users can view own saved users" ON saved_users FOR SELECT USING (auth.uid() = user_id);

-- Allow users to manage their own saved users
CREATE POLICY "Users can manage own saved users" ON saved_users FOR ALL USING (auth.uid() = user_id);
