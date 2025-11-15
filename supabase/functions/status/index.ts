// AI CLI Orchestrator - Status API Endpoint
// GET /api/v1/status/{request_id}

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

    // Get request ID from URL
    const url = new URL(req.url)
    const requestId = url.pathname.split('/').pop()

    if (!requestId) {
      throw new Error('Missing request ID')
    }

    // Fetch request
    const { data: request, error: requestError } = await supabase
      .from('requests')
      .select('*')
      .eq('id', requestId)
      .eq('user_id', keyData.user_id)
      .single()

    if (requestError || !request) {
      throw new Error('Request not found')
    }

    return new Response(
      JSON.stringify({
        id: request.id,
        status: request.status,
        provider_requested: request.provider_requested,
        provider_used: request.provider_used,
        response: request.response,
        tokens_used: request.tokens_used,
        latency_ms: request.latency_ms,
        error_message: request.error_message,
        created_at: request.created_at,
        completed_at: request.completed_at,
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
