-- Create indexes for better query performance
CREATE INDEX idx_games_publisher ON games(publisher_id);
CREATE INDEX idx_games_developer ON games(developer_id);
CREATE INDEX idx_reviews_game ON reviews(game_id);
CREATE INDEX idx_reviews_user ON reviews(user_id);