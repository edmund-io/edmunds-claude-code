// AI CLI Orchestrator - Chat API Endpoint
// POST /api/v1/chat

import { serve } from 'https://deno.land/std@0.177.0/http/server.ts'
import { createClient } from 'https://esm.sh/@supabase/supabase-js@2'
import { Redis } from 'https://esm.sh/ioredis@5'

const supabase = createClient(
  Deno.env.get('SUPABASE_URL') ?? '',
  Deno.env.get('SUPABASE_SERVICE_ROLE_KEY') ?? ''
)

const redis = new Redis(Deno.env.get('REDIS_URL') ?? 'redis://redis:6379')

interface ChatRequest {
  prompt: string
  provider?: string
  priority?: 'high' | 'normal' | 'low'
  max_tokens?: number
  temperature?: number
}

serve(async (req) => {
  // CORS headers
  if (req.method === 'OPTIONS') {
    return new Response(null, {
      headers: {
        'Access-Control-Allow-Origin': '*',
        'Access-Control-Allow-Methods': 'POST, OPTIONS',
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

    // Check rate limit
    const rateLimit = await checkRateLimit(keyData.id, 100, 60) // 100 per minute
    if (rateLimit.exceeded) {
      return new Response(JSON.stringify({ error: 'Rate limit exceeded' }), {
        status: 429,
        headers: {
          'Content-Type': 'application/json',
          'X-RateLimit-Limit': '100',
          'X-RateLimit-Remaining': '0',
          'X-RateLimit-Reset': rateLimit.resetAt.toISOString(),
        },
      })
    }

    // Parse request
    const body: ChatRequest = await req.json()

    if (!body.prompt || body.prompt.length === 0) {
      throw new Error('Missing prompt')
    }

    if (body.prompt.length > 10000) {
      throw new Error('Prompt too long (max 10,000 characters)')
    }

    // Get user ID from API key
    const userId = keyData.user_id

    // Select best account
    const provider = body.provider || 'auto'
    const { accountId, actualProvider } = await selectBestAccount(userId, provider)

    if (!accountId) {
      throw new Error('No available accounts - all quotas exceeded or no accounts configured')
    }

    // Create request record
    const requestId = `req_${crypto.randomUUID().replace(/-/g, '').substring(0, 16)}`

    const { error: insertError } = await supabase.from('requests').insert({
      id: requestId,
      user_id: userId,
      api_key_id: keyData.id,
      prompt: body.prompt,
      provider_requested: provider === 'auto' ? null : provider,
      provider_used: null,
      account_id: accountId,
      status: 'queued',
      priority: body.priority === 'high' ? 1 : body.priority === 'low' ? 10 : 5,
    })

    if (insertError) throw insertError

    // Enqueue job in Redis
    await redis.lpush(
      'bullmq:chat-requests:wait',
      JSON.stringify({
        name: requestId,
        data: {
          type: 'chat-request',
          request_id: requestId,
          account_id: accountId,
          provider: actualProvider,
          prompt: body.prompt,
          priority: body.priority === 'high' ? 1 : body.priority === 'low' ? 10 : 5,
        },
        opts: {
          priority: body.priority === 'high' ? 1 : body.priority === 'low' ? 10 : 5,
        },
      })
    )

    // Get current quotas
    const { data: quotas } = await supabase
      .from('quotas')
      .select('provider, daily_used, daily_limit')
      .in('account_id', await getAccountIds(userId))

    const quotaRemaining: Record<string, number> = {}
    quotas?.forEach((q) => {
      quotaRemaining[q.provider] = q.daily_limit - q.daily_used
    })

    // Update API key last used
    await supabase
      .from('api_keys')
      .update({ last_used_at: new Date().toISOString() })
      .eq('id', keyData.id)

    return new Response(
      JSON.stringify({
        id: requestId,
        status: 'queued',
        provider_used: actualProvider,
        estimated_wait: 5,
        quota_remaining: quotaRemaining,
      }),
      {
        status: 202,
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

async function checkRateLimit(
  apiKeyId: string,
  limit: number,
  windowSeconds: number
): Promise<{ exceeded: boolean; remaining: number; resetAt: Date }> {
  const now = Math.floor(Date.now() / 1000)
  const window = Math.floor(now / windowSeconds)
  const key = `ratelimit:${apiKeyId}:${window}`

  const count = parseInt((await redis.get(key)) || '0')

  if (count === 0) {
    await redis.setex(key, windowSeconds, '1')
    return { exceeded: false, remaining: limit - 1, resetAt: new Date((window + 1) * windowSeconds * 1000) }
  }

  if (count >= limit) {
    return { exceeded: true, remaining: 0, resetAt: new Date((window + 1) * windowSeconds * 1000) }
  }

  await redis.incr(key)

  return { exceeded: false, remaining: limit - count - 1, resetAt: new Date((window + 1) * windowSeconds * 1000) }
}

async function selectBestAccount(
  userId: string,
  provider: string
): Promise<{ accountId: string | null; actualProvider: string }> {
  if (provider !== 'auto') {
    // Specific provider requested
    const { data: accountId } = await supabase.rpc('get_available_account', {
      p_provider: provider,
      p_user_id: userId,
    })

    return { accountId, actualProvider: provider }
  }

  // Auto mode: try providers in order
  const providerOrder = ['deepseek', 'gemini', 'chatgpt', 'claude']

  for (const p of providerOrder) {
    const { data: accountId } = await supabase.rpc('get_available_account', {
      p_provider: p,
      p_user_id: userId,
    })

    if (accountId) {
      return { accountId, actualProvider: p }
    }
  }

  return { accountId: null, actualProvider: 'none' }
}

async function getAccountIds(userId: string): Promise<string[]> {
  const { data: accounts } = await supabase
    .from('accounts')
    .select('id')
    .eq('user_id', userId)

  return accounts?.map((a) => a.id) || []
}
