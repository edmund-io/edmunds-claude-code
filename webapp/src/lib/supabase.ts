import { createClient } from '@supabase/supabase-js'

const supabaseUrl = import.meta.env.VITE_SUPABASE_URL
const supabaseAnonKey = import.meta.env.VITE_SUPABASE_ANON_KEY

if (!supabaseUrl || !supabaseAnonKey) {
  throw new Error('Missing Supabase environment variables')
}

export const supabase = createClient(supabaseUrl, supabaseAnonKey)

// Database types
export interface Account {
  id: string
  user_id: string
  provider: 'chatgpt' | 'claude' | 'gemini' | 'deepseek'
  email: string
  status: 'pending' | 'active' | 'expired' | 'quota_exceeded' | 'error'
  last_used_at: string | null
  created_at: string
  updated_at: string
}

export interface Quota {
  id: string
  account_id: string
  provider: string
  daily_limit: number
  daily_used: number
  monthly_limit: number | null
  monthly_used: number
  reset_daily_at: string
  reset_monthly_at: string | null
  created_at: string
  updated_at: string
  accounts?: Account
}

export interface UsageLog {
  id: string
  account_id: string
  provider: string
  request_id: string | null
  tokens_used: number | null
  estimated_cost: number | null
  latency_ms: number | null
  status: 'success' | 'error' | 'timeout'
  error_message: string | null
  created_at: string
}

export interface Request {
  id: string
  user_id: string
  api_key_id: string | null
  prompt: string
  provider_requested: string | null
  provider_used: string | null
  account_id: string | null
  status: 'queued' | 'processing' | 'completed' | 'failed'
  priority: number
  response: string | null
  tokens_used: number | null
  latency_ms: number | null
  error_message: string | null
  created_at: string
  completed_at: string | null
}

export interface APIKey {
  id: string
  user_id: string
  name: string
  key_hash: string
  key_prefix: string
  permissions: Record<string, any>
  rate_limit_per_minute: number
  rate_limit_per_day: number
  revoked: boolean
  last_used_at: string | null
  created_at: string
  expires_at: string | null
}
