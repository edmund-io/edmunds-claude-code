# Quota Tracker Service

Automated quota monitoring and reset service for AI CLI Orchestrator V2.

## Features

- **Automatic Quota Reset** - Daily/monthly quota resets based on schedule
- **Usage Monitoring** - Track quota usage in real-time
- **Alert System** - Notify when approaching or exceeding limits
- **Session Monitoring** - Alert when sessions are expiring
- **Health Checks** - HTTP endpoint for monitoring

## Environment Variables

```env
SUPABASE_URL=https://your-project.supabase.co
SUPABASE_SERVICE_KEY=eyJ...
REDIS_URL=redis://localhost:6379
CHECK_INTERVAL=60000          # 60 seconds
ALERT_THRESHOLD=0.9           # 90%
LOG_LEVEL=info
```

## Development

```bash
# Install dependencies
npm install

# Start service
npm run dev
```

## Docker

```bash
# Build
docker build -t quota-tracker .

# Run
docker run -d \
  --name quota-tracker \
  -e SUPABASE_URL=... \
  -e SUPABASE_SERVICE_KEY=... \
  -e REDIS_URL=redis://redis:6379 \
  quota-tracker
```

## How It Works

1. **Quota Checks** - Runs every 60 seconds (configurable)
   - Checks all active accounts
   - Resets quotas if past reset time
   - Alerts if approaching/exceeding limits

2. **Session Checks** - Runs daily
   - Finds sessions expiring within 7 days
   - Sends alerts for manual re-login

3. **Alerts** - Published to Redis and stored in database
   - `quota_warning` - 90% usage reached
   - `quota_exceeded` - 100% usage reached
   - `session_expiring` - Session expires within 7 days

## Health Check

```bash
curl http://localhost:8080/health
```

Response:
```json
{
  "status": "healthy",
  "uptime": 12345,
  "lastCheck": "2025-11-15T10:30:00Z"
}
```
