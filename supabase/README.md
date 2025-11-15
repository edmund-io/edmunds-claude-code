# Supabase Edge Functions - API Gateway

API Gateway for AI CLI Orchestrator V2 using Supabase Edge Functions.

## Available Endpoints

### POST /functions/v1/chat
Submit a chat request to the orchestrator.

**Request:**
```json
{
  "prompt": "What is recursion?",
  "provider": "auto",
  "priority": "normal"
}
```

**Response (202 Accepted):**
```json
{
  "id": "req_abc123",
  "status": "queued",
  "provider_used": "chatgpt",
  "estimated_wait": 5,
  "quota_remaining": {
    "chatgpt": 45,
    "claude": 28
  }
}
```

### GET /functions/v1/status/{request_id}
Check status and get result of a request.

**Response (200 OK):**
```json
{
  "id": "req_abc123",
  "status": "completed",
  "provider_used": "chatgpt",
  "response": "Recursion is when a function calls itself...",
  "tokens_used": 150,
  "latency_ms": 2340
}
```

### GET /functions/v1/quotas
Get current quota usage across all providers.

**Response (200 OK):**
```json
{
  "providers": {
    "chatgpt": {
      "daily": { "used": 15, "limit": 60, "remaining": 45 },
      "status": "available"
    }
  },
  "total_accounts": 6,
  "active_accounts": 5
}
```

## Authentication

All requests require an API key in the Authorization header:

```bash
curl -X POST https://your-project.supabase.co/functions/v1/chat \
  -H "Authorization: Bearer sk_live_abc123..." \
  -H "Content-Type: application/json" \
  -d '{"prompt": "Hello world"}'
```

## Deployment

Using Supabase CLI:

```bash
# Install CLI
npm install -g supabase

# Login
supabase login

# Link project
supabase link --project-ref your-project-ref

# Deploy functions
supabase functions deploy chat
supabase functions deploy status
supabase functions deploy quotas

# Set secrets
supabase secrets set REDIS_URL=redis://your-redis:6379
```

## Rate Limits

- 100 requests per minute per API key
- 10,000 requests per day per API key

## Error Responses

```json
{
  "error": "Missing API key"
}
```

Status codes:
- `200` - Success
- `202` - Accepted (queued)
- `400` - Bad Request
- `401` - Unauthorized
- `429` - Rate Limit Exceeded
- `500` - Internal Server Error
