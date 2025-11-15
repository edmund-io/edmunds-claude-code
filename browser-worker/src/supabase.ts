import { createClient } from '@supabase/supabase-js'
import { config } from './config.js'

export const supabase = createClient(config.supabase.url, config.supabase.serviceKey, {
  auth: {
    autoRefreshToken: false,
    persistSession: false,
  },
})

// Database types
export interface BrowserSession {
  id: string
  account_id: string
  cookies: any[]
  local_storage: Record<string, string>
  session_storage?: Record<string, string>
  expires_at: string
  created_at: string
  updated_at: string
}

export interface Account {
  id: string
  user_id: string
  provider: string
  email: string
  status: string
  last_used_at: string | null
  created_at: string
  updated_at: string
}

// Helper functions
export async function loadSession(accountId: string): Promise<BrowserSession | null> {
  const { data, error } = await supabase
    .from('browser_sessions')
    .select('*')
    .eq('account_id', accountId)
    .single()

  if (error) {
    if (error.code === 'PGRST116') return null // Not found
    throw error
  }

  return data
}

export async function saveSession(
  accountId: string,
  cookies: any[],
  localStorage: string,
  expiresAt: Date
) {
  const { error } = await supabase.from('browser_sessions').upsert({
    account_id: accountId,
    cookies,
    local_storage: JSON.parse(localStorage),
    expires_at: expiresAt.toISOString(),
    updated_at: new Date().toISOString(),
  })

  if (error) throw error
}

export async function updateAccountStatus(accountId: string, status: string) {
  const { error } = await supabase
    .from('accounts')
    .update({
      status,
      updated_at: new Date().toISOString(),
    })
    .eq('id', accountId)

  if (error) throw error
}

export async function updateQuota(accountId: string, provider: string, tokensUsed: number) {
  const { error } = await supabase.rpc('update_quota_usage', {
    p_account_id: accountId,
    p_provider: provider,
    p_tokens_used: tokensUsed,
  })

  if (error) throw error
}

export async function logUsage(
  accountId: string,
  provider: string,
  requestId: string | null,
  tokensUsed: number,
  latencyMs: number,
  status: string,
  errorMessage: string | null = null
) {
  const { error } = await supabase.from('usage_logs').insert({
    account_id: accountId,
    provider,
    request_id: requestId,
    tokens_used: tokensUsed,
    estimated_cost: calculateCost(provider, tokensUsed),
    latency_ms: latencyMs,
    status,
    error_message: errorMessage,
  })

  if (error) throw error
}

function calculateCost(provider: string, tokens: number): number {
  // Web-based usage is free, but we track estimated API equivalent cost
  const rates: Record<string, number> = {
    chatgpt: 0.0015 / 1000, // GPT-4o-mini equivalent
    claude: 0.003 / 1000, // Claude 3.5 Sonnet equivalent
    gemini: 0, // Free
    deepseek: 0.00027 / 1000, // DeepSeek-V3
  }

  return (rates[provider] || 0) * tokens
}
