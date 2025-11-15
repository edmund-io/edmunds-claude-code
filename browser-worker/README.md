# Browser Worker - Playwright Automation

Automated browser worker for web-based AI providers using Playwright.

## Features

- **Playwright Automation** - Headless Chrome automation for ChatGPT, Claude, Gemini, DeepSeek
- **Session Persistence** - Save/restore cookies and localStorage across restarts
- **Job Queue** - BullMQ integration for reliable job processing
- **Error Handling** - Screenshots on error, automatic retry
- **Real-time Logging** - Structured logging with Winston
- **Health Checks** - HTTP health endpoint for monitoring

## Supported Providers

- ChatGPT (chat.openai.com)
- Claude (claude.ai)
- Gemini (gemini.google.com)
- DeepSeek (chat.deepseek.com)

## Environment Variables

```env
WORKER_ID=1
WORKER_NAME=browser-worker-1
REDIS_URL=redis://localhost:6379
SUPABASE_URL=https://your-project.supabase.co
SUPABASE_SERVICE_KEY=eyJ...
CONCURRENCY=2
HEADLESS=true
SCREENSHOT_ON_ERROR=true
VIDEO_RECORDING=false
SESSION_TIMEOUT=300000
```

## Development

```bash
# Install dependencies
npm install

# Install Playwright browsers
npx playwright install chromium

# Start worker
npm run dev
```

## Docker

```bash
# Build
docker build -t browser-worker .

# Run
docker run -d \
  --name browser-worker-1 \
  -e WORKER_ID=1 \
  -e REDIS_URL=redis://redis:6379 \
  -e SUPABASE_URL=... \
  -e SUPABASE_SERVICE_KEY=... \
  --shm-size=2gb \
  browser-worker
```

## Job Structure

```typescript
{
  "type": "chat-request",
  "request_id": "req_abc123",
  "account_id": "acc_xyz789",
  "provider": "chatgpt",
  "prompt": "What is recursion?",
  "priority": 5
}
```

## Health Check

```bash
curl http://localhost:8080/health
```

## Architecture

```
index.ts → worker.ts → browser.ts → providers/
                                    ├── chatgpt.ts
                                    ├── claude.ts
                                    ├── gemini.ts
                                    └── deepseek.ts
```
