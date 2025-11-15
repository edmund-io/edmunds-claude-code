// AI CLI Orchestrator - Quotas API Endpoint
// GET /api/v1/quotas

import { serve } from 'https://deno.land/std@0.177.0/http/server.ts'
import { createClient } from 'https://esm.sh/@supabase/supabase-js@2'

const supabase = createClient(
  Deno.env.get('SUPABASE_URL') ?? '',
  Deno.env.get('SUPABASE_SERVICE_ROLE_KEY') ?? ''
)

serve(async (req) => {
  // CORS headers
  if (req.method === 'OPTIONS') {
    return new Response(null, {
      headers: {
        'Access-Control-Allow-Origin': '*',
        'Access-Control-Allow-Methods': 'GET, OPTIONS',
        'Access-Control-Allow-Headers': 'authorization, x-client-info, apikey, content-type',
      },
    })
  }

  try {
    // Validate API key
    const apiKey = req.headers.get('Authorization')?.replace('Bearer ', '')
    if (!apiKey) {
      throw new Error('Missing API key')
    }

    const keyHash = await hashAPIKey(apiKey)

    const { data: keyData, error: keyError } = await supabase
      .from('api_keys')
      .select('*')
      .eq('key_hash', keyHash)
      .eq('revoked', false)
      .single()

    if (keyError || !keyData) {
      throw new Error('Invalid API key')
    }

    // Get all quotas for user
    const { data: quotas, error: quotasError } = await supabase
      .from('quotas')
      .select('*, accounts(*)')
      .eq('accounts.user_id', keyData.user_id)

    if (quotasError) throw quotasError

    // Format response
    const providers: Record<string, any> = {}

    quotas?.forEach((quota) => {
      const dailyRemaining = Math.max(0, quota.daily_limit - quota.daily_used)
      const monthlyRemaining = quota.monthly_limit
        ? Math.max(0, quota.monthly_limit - quota.monthly_used)
        : null

      const status =
        quota.daily_used >= quota.daily_limit
          ? 'quota_exceeded'
          : quota.daily_used / quota.daily_limit >= 0.9
          ? 'limited'
          : 'available'

      if (!providers[quota.provider]) {
        providers[quota.provider] = {
          daily: {
            used: 0,
            limit: 0,
            remaining: 0,
          },
          monthly: null,
          reset_daily_at: quota.reset_daily_at,
          reset_monthly_at: quota.reset_monthly_at,
          status: 'available',
        }
      }

      // Aggregate across accounts
      providers[quota.provider].daily.used += quota.daily_used
      providers[quota.provider].daily.limit += quota.daily_limit
      providers[quota.provider].daily.remaining += dailyRemaining

      if (quota.monthly_limit && monthlyRemaining !== null) {
        if (!providers[quota.provider].monthly) {
          providers[quota.provider].monthly = {
            used: 0,
            limit: 0,
            remaining: 0,
          }
        }
        providers[quota.provider].monthly.used += quota.monthly_used
        providers[quota.provider].monthly.limit += quota.monthly_limit
        providers[quota.provider].monthly.remaining += monthlyRemaining
      }

      // Worst status wins
      if (
        status === 'quota_exceeded' ||
        (providers[quota.provider].status !== 'quota_exceeded' && status === 'limited')
      ) {
        providers[quota.provider].status = status
      }
    })

    // Count accounts
    const { data: accounts } = await supabase
      .from('accounts')
      .select('status')
      .eq('user_id', keyData.user_id)

    const totalAccounts = accounts?.length || 0
    const activeAccounts = accounts?.filter((a) => a.status === 'active').length || 0
    const expiredSessions = accounts?.filter((a) => a.status === 'expired').length || 0

    return new Response(
      JSON.stringify({
        providers,
        total_accounts: totalAccounts,
        active_accounts: activeAccounts,
        expired_sessions: expiredSessions,
      }),
      {
        status: 200,
        headers: {
          'Content-Type': 'application/json',
          'Access-Control-Allow-Origin': '*',
        },
      }
    )
  } catch (error) {
    return new Response(JSON.stringify({ error: (error as Error).message }), {
      status: 400,
      headers: {
        'Content-Type': 'application/json',
        'Access-Control-Allow-Origin': '*',
      },
    })
  }
})

async function hashAPIKey(key: string): Promise<string> {
  const encoder = new TextEncoder()
  const data = encoder.encode(key)
  const hash = await crypto.subtle.digest('SHA-256', data)
  return Array.from(new Uint8Array(hash))
    .map((b) => b.toString(16).padStart(2, '0'))
    .join('')
}
