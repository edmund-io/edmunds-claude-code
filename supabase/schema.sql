-- AI CLI Orchestrator V2 - Complete Database Schema
-- Deploy this in Supabase SQL Editor
-- https://app.supabase.com/project/_/sql

-- Enable UUID extension
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";

-- Enable Row Level Security
ALTER DATABASE postgres SET "app.jwt_secret" TO 'your-jwt-secret';

-- ============================================================================
-- TABLES
-- ============================================================================

-- Accounts table
CREATE TABLE IF NOT EXISTS accounts (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  user_id UUID REFERENCES auth.users(id) ON DELETE CASCADE,
  provider TEXT NOT NULL CHECK (provider IN ('chatgpt', 'claude', 'gemini', 'deepseek')),
  email TEXT NOT NULL,
  status TEXT NOT NULL DEFAULT 'pending' CHECK (status IN ('pending', 'active', 'expired', 'quota_exceeded', 'error')),
  last_used_at TIMESTAMPTZ,
  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW(),

  UNIQUE(user_id, provider, email)
);

CREATE INDEX IF NOT EXISTS idx_accounts_user_id ON accounts(user_id);
CREATE INDEX IF NOT EXISTS idx_accounts_provider ON accounts(provider);
CREATE INDEX IF NOT EXISTS idx_accounts_status ON accounts(status);

-- Browser sessions table
CREATE TABLE IF NOT EXISTS browser_sessions (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  account_id UUID REFERENCES accounts(id) ON DELETE CASCADE,
  cookies JSONB NOT NULL,
  local_storage JSONB,
  session_storage JSONB,
  expires_at TIMESTAMPTZ NOT NULL,
  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW(),

  UNIQUE(account_id)
);

CREATE INDEX IF NOT EXISTS idx_browser_sessions_expires_at ON browser_sessions(expires_at);

-- Quotas table
CREATE TABLE IF NOT EXISTS quotas (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  account_id UUID REFERENCES accounts(id) ON DELETE CASCADE,
  provider TEXT NOT NULL,
  daily_limit INTEGER NOT NULL,
  daily_used INTEGER NOT NULL DEFAULT 0,
  monthly_limit INTEGER,
  monthly_used INTEGER DEFAULT 0,
  reset_daily_at TIMESTAMPTZ NOT NULL,
  reset_monthly_at TIMESTAMPTZ,
  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW(),

  UNIQUE(account_id, provider)
);

CREATE INDEX IF NOT EXISTS idx_quotas_account_id ON quotas(account_id);
CREATE INDEX IF NOT EXISTS idx_quotas_provider ON quotas(provider);

-- Usage logs table
CREATE TABLE IF NOT EXISTS usage_logs (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  account_id UUID REFERENCES accounts(id) ON DELETE CASCADE,
  provider TEXT NOT NULL,
  request_id TEXT,
  tokens_used INTEGER,
  estimated_cost DECIMAL(10,6),
  latency_ms INTEGER,
  status TEXT CHECK (status IN ('success', 'error', 'timeout')),
  error_message TEXT,
  created_at TIMESTAMPTZ DEFAULT NOW()
);

CREATE INDEX IF NOT EXISTS idx_usage_logs_account_id ON usage_logs(account_id);
CREATE INDEX IF NOT EXISTS idx_usage_logs_created_at ON usage_logs(created_at DESC);
CREATE INDEX IF NOT EXISTS idx_usage_logs_provider ON usage_logs(provider);

-- Requests table
CREATE TABLE IF NOT EXISTS requests (
  id TEXT PRIMARY KEY,
  user_id UUID REFERENCES auth.users(id) ON DELETE CASCADE,
  api_key_id UUID,
  prompt TEXT NOT NULL,
  provider_requested TEXT,
  provider_used TEXT,
  account_id UUID REFERENCES accounts(id),
  status TEXT NOT NULL DEFAULT 'queued' CHECK (status IN ('queued', 'processing', 'completed', 'failed')),
  priority INTEGER DEFAULT 5,
  response TEXT,
  tokens_used INTEGER,
  latency_ms INTEGER,
  error_message TEXT,
  created_at TIMESTAMPTZ DEFAULT NOW(),
  completed_at TIMESTAMPTZ
);

CREATE INDEX IF NOT EXISTS idx_requests_user_id ON requests(user_id);
CREATE INDEX IF NOT EXISTS idx_requests_status ON requests(status);
CREATE INDEX IF NOT EXISTS idx_requests_created_at ON requests(created_at DESC);

-- API keys table
CREATE TABLE IF NOT EXISTS api_keys (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  user_id UUID REFERENCES auth.users(id) ON DELETE CASCADE,
  name TEXT NOT NULL,
  key_hash TEXT NOT NULL UNIQUE,
  key_prefix TEXT NOT NULL,
  permissions JSONB DEFAULT '{}',
  rate_limit_per_minute INTEGER DEFAULT 100,
  rate_limit_per_day INTEGER DEFAULT 10000,
  revoked BOOLEAN DEFAULT FALSE,
  last_used_at TIMESTAMPTZ,
  created_at TIMESTAMPTZ DEFAULT NOW(),
  expires_at TIMESTAMPTZ
);

CREATE INDEX IF NOT EXISTS idx_api_keys_user_id ON api_keys(user_id);
CREATE INDEX IF NOT EXISTS idx_api_keys_key_hash ON api_keys(key_hash);

-- Alerts table (for notifications)
CREATE TABLE IF NOT EXISTS alerts (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  type TEXT NOT NULL,
  account_id UUID REFERENCES accounts(id) ON DELETE CASCADE,
  provider TEXT,
  data JSONB,
  read BOOLEAN DEFAULT FALSE,
  created_at TIMESTAMPTZ DEFAULT NOW()
);

CREATE INDEX IF NOT EXISTS idx_alerts_account_id ON alerts(account_id);
CREATE INDEX IF NOT EXISTS idx_alerts_created_at ON alerts(created_at DESC);

-- ============================================================================
-- ROW LEVEL SECURITY POLICIES
-- ============================================================================

-- Accounts
ALTER TABLE accounts ENABLE ROW LEVEL SECURITY;

CREATE POLICY IF NOT EXISTS "Users can view their own accounts"
  ON accounts FOR SELECT
  USING (auth.uid() = user_id);

CREATE POLICY IF NOT EXISTS "Users can insert their own accounts"
  ON accounts FOR INSERT
  WITH CHECK (auth.uid() = user_id);

CREATE POLICY IF NOT EXISTS "Users can update their own accounts"
  ON accounts FOR UPDATE
  USING (auth.uid() = user_id);

CREATE POLICY IF NOT EXISTS "Users can delete their own accounts"
  ON accounts FOR DELETE
  USING (auth.uid() = user_id);

-- Quotas
ALTER TABLE quotas ENABLE ROW LEVEL SECURITY;

CREATE POLICY IF NOT EXISTS "Users can view quotas for their accounts"
  ON quotas FOR SELECT
  USING (
    account_id IN (
      SELECT id FROM accounts WHERE user_id = auth.uid()
    )
  );

-- Usage logs
ALTER TABLE usage_logs ENABLE ROW LEVEL SECURITY;

CREATE POLICY IF NOT EXISTS "Users can view logs for their accounts"
  ON usage_logs FOR SELECT
  USING (
    account_id IN (
      SELECT id FROM accounts WHERE user_id = auth.uid()
    )
  );

-- Requests
ALTER TABLE requests ENABLE ROW LEVEL SECURITY;

CREATE POLICY IF NOT EXISTS "Users can view their own requests"
  ON requests FOR SELECT
  USING (auth.uid() = user_id);

CREATE POLICY IF NOT EXISTS "Users can insert their own requests"
  ON requests FOR INSERT
  WITH CHECK (auth.uid() = user_id);

-- API Keys
ALTER TABLE api_keys ENABLE ROW LEVEL SECURITY;

CREATE POLICY IF NOT EXISTS "Users can view their own API keys"
  ON api_keys FOR SELECT
  USING (auth.uid() = user_id);

CREATE POLICY IF NOT EXISTS "Users can create API keys"
  ON api_keys FOR INSERT
  WITH CHECK (auth.uid() = user_id);

CREATE POLICY IF NOT EXISTS "Users can revoke their API keys"
  ON api_keys FOR UPDATE
  USING (auth.uid() = user_id);

-- Alerts
ALTER TABLE alerts ENABLE ROW LEVEL SECURITY;

CREATE POLICY IF NOT EXISTS "Users can view alerts for their accounts"
  ON alerts FOR SELECT
  USING (
    account_id IN (
      SELECT id FROM accounts WHERE user_id = auth.uid()
    )
  );

-- ============================================================================
-- FUNCTIONS
-- ============================================================================

-- Update quota usage
CREATE OR REPLACE FUNCTION update_quota_usage(
  p_account_id UUID,
  p_provider TEXT,
  p_tokens_used INTEGER
)
RETURNS VOID AS $$
BEGIN
  -- Update quota
  UPDATE quotas
  SET
    daily_used = daily_used + p_tokens_used,
    monthly_used = COALESCE(monthly_used, 0) + p_tokens_used,
    updated_at = NOW()
  WHERE account_id = p_account_id
    AND provider = p_provider;

  -- Reset if past daily reset time
  UPDATE quotas
  SET
    daily_used = p_tokens_used,
    reset_daily_at = reset_daily_at + INTERVAL '1 day'
  WHERE account_id = p_account_id
    AND provider = p_provider
    AND NOW() > reset_daily_at;

  -- Reset if past monthly reset time
  UPDATE quotas
  SET
    monthly_used = p_tokens_used,
    reset_monthly_at = reset_monthly_at + INTERVAL '1 month'
  WHERE account_id = p_account_id
    AND provider = p_provider
    AND monthly_limit IS NOT NULL
    AND NOW() > reset_monthly_at;
END;
$$ LANGUAGE plpgsql;

-- Get available account for provider
CREATE OR REPLACE FUNCTION get_available_account(
  p_provider TEXT,
  p_user_id UUID
)
RETURNS UUID AS $$
DECLARE
  v_account_id UUID;
BEGIN
  SELECT a.id INTO v_account_id
  FROM accounts a
  LEFT JOIN quotas q ON a.id = q.account_id
  WHERE a.user_id = p_user_id
    AND a.provider = p_provider
    AND a.status = 'active'
    AND (q.id IS NULL OR q.daily_used < q.daily_limit)
    AND (q.monthly_limit IS NULL OR q.monthly_used < q.monthly_limit)
  ORDER BY COALESCE(q.daily_used, 0) ASC  -- Use least-used account
  LIMIT 1;

  RETURN v_account_id;
END;
$$ LANGUAGE plpgsql;

-- Trigger to create quota when account is created
CREATE OR REPLACE FUNCTION create_quota_for_account()
RETURNS TRIGGER AS $$
BEGIN
  -- Set default quotas based on provider
  INSERT INTO quotas (account_id, provider, daily_limit, monthly_limit, reset_daily_at, reset_monthly_at)
  VALUES (
    NEW.id,
    NEW.provider,
    CASE NEW.provider
      WHEN 'chatgpt' THEN 60        -- 60 messages per 5 hours ~ 288/day
      WHEN 'claude' THEN 40          -- 40 messages per day
      WHEN 'gemini' THEN 15          -- 15 messages per session
      WHEN 'deepseek' THEN 10000     -- Unlimited (set high limit)
      ELSE 100
    END,
    CASE NEW.provider
      WHEN 'chatgpt' THEN 1800       -- ~1800/month
      WHEN 'claude' THEN 1200        -- ~1200/month
      ELSE NULL
    END,
    NOW() + INTERVAL '1 day',
    CASE
      WHEN NEW.provider IN ('chatgpt', 'claude') THEN DATE_TRUNC('month', NOW()) + INTERVAL '1 month'
      ELSE NULL
    END
  );

  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER IF NOT EXISTS create_quota_on_account_insert
  AFTER INSERT ON accounts
  FOR EACH ROW
  EXECUTE FUNCTION create_quota_for_account();

-- ============================================================================
-- REALTIME
-- ============================================================================

-- Enable Realtime for relevant tables
ALTER PUBLICATION supabase_realtime ADD TABLE accounts;
ALTER PUBLICATION supabase_realtime ADD TABLE quotas;
ALTER PUBLICATION supabase_realtime ADD TABLE requests;
ALTER PUBLICATION supabase_realtime ADD TABLE alerts;

-- ============================================================================
-- STORAGE
-- ============================================================================

-- Create storage buckets
INSERT INTO storage.buckets (id, name, public) VALUES ('screenshots', 'screenshots', false) ON CONFLICT DO NOTHING;
INSERT INTO storage.buckets (id, name, public) VALUES ('videos', 'videos', false) ON CONFLICT DO NOTHING;

-- Storage policies
CREATE POLICY IF NOT EXISTS "Users can upload screenshots for their accounts"
  ON storage.objects FOR INSERT
  WITH CHECK (
    bucket_id = 'screenshots' AND
    auth.uid()::text = (storage.foldername(name))[1]
  );

CREATE POLICY IF NOT EXISTS "Users can view their own screenshots"
  ON storage.objects FOR SELECT
  USING (
    bucket_id = 'screenshots' AND
    auth.uid()::text = (storage.foldername(name))[1]
  );

-- ============================================================================
-- COMPLETE
-- ============================================================================

COMMENT ON TABLE accounts IS 'AI provider accounts linked to users';
COMMENT ON TABLE quotas IS 'Usage quotas and limits for each account';
COMMENT ON TABLE browser_sessions IS 'Stored browser sessions (cookies, localStorage)';
COMMENT ON TABLE usage_logs IS 'Historical usage tracking';
COMMENT ON TABLE requests IS 'Chat requests from external API';
COMMENT ON TABLE api_keys IS 'API keys for external applications';
COMMENT ON TABLE alerts IS 'System alerts and notifications';

-- Done!
SELECT 'Schema deployed successfully!' AS status;
