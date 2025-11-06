-- =============================================================================
-- Database Initialization Script
-- =============================================================================
-- Creates tables for conversation history and analytics
-- =============================================================================

-- Create messages table
CREATE TABLE IF NOT EXISTS messages (
    id SERIAL PRIMARY KEY,
    chat_id VARCHAR(50) NOT NULL,
    role VARCHAR(20) NOT NULL CHECK (role IN ('user', 'assistant')),
    content TEXT NOT NULL,
    timestamp TIMESTAMP DEFAULT NOW(),
    metadata JSONB DEFAULT '{}'::jsonb
);

-- Create indexes for performance
CREATE INDEX IF NOT EXISTS idx_messages_chat_id ON messages(chat_id);
CREATE INDEX IF NOT EXISTS idx_messages_timestamp ON messages(timestamp DESC);
CREATE INDEX IF NOT EXISTS idx_messages_chat_id_timestamp ON messages(chat_id, timestamp DESC);

-- Create analytics table (optional)
CREATE TABLE IF NOT EXISTS analytics (
    id SERIAL PRIMARY KEY,
    chat_id VARCHAR(50) NOT NULL,
    event_type VARCHAR(50) NOT NULL,
    event_data JSONB DEFAULT '{}'::jsonb,
    timestamp TIMESTAMP DEFAULT NOW()
);

CREATE INDEX IF NOT EXISTS idx_analytics_chat_id ON analytics(chat_id);
CREATE INDEX IF NOT EXISTS idx_analytics_timestamp ON analytics(timestamp DESC);
CREATE INDEX IF NOT EXISTS idx_analytics_event_type ON analytics(event_type);

-- Insert initial data (optional)
INSERT INTO analytics (chat_id, event_type, event_data)
VALUES ('system', 'database_initialized', '{"version": "1.0.0"}'::jsonb)
ON CONFLICT DO NOTHING;
