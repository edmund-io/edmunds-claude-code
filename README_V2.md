# AI CLI Orchestrator V2 - OAuth & Browser Automation Edition

**Maximum Free-Tier AI API System with Web Login Automation**

Orchestrate 100K+ free AI requests per month by combining browser automation with multi-account management, intelligent quota tracking, and a production-ready API gateway.

---

## 🚀 What's New in V2

### V1 vs V2 Comparison

| Feature | V1 (API Keys) | V2 (Browser Automation) |
|---------|---------------|-------------------------|
| **Daily Capacity** | ~10,000 requests | **~100,000+ requests** |
| **Cost** | $0-43/month | **$13-20/month** |
| **Free Tier Access** | API limits only | **Web + API limits** |
| **Providers** | 7 API-based | **12+ (web + API)** |
| **Account Management** | Manual | **Automated with rotation** |
| **Real-time Monitoring** | No | **Yes (Supabase Realtime)** |
| **External API** | No | **Yes (REST + WebSocket)** |
| **Session Management** | N/A | **Persistent across restarts** |
| **2FA Support** | N/A | **Yes (user input)** |
| **Production Ready** | No | **Yes (Docker + monitoring)** |

**Result: 10x more capacity at lower cost!**

---

## 📊 Free Tier Capacity

| Provider | Free Tier | Monthly Capacity | Cost |
|----------|-----------|------------------|------|
| **DeepSeek** | Unlimited (fair-use) | 100,000+ | $0 |
| **ChatGPT Web** | 10-60 msg/5hr × 5 accounts | 15,000 | $0 |
| **Claude Web** | 40 msg/day × 5 accounts | 6,000 | $0 |
| **Gemini Web** | 15 msg × 5 accounts | 2,250 | $0 |
| **Gemini API** | 1M tokens/day | 30,000 | $0 |
| **Groq API** | 14.4K req/day | 14,400 | $0 |
| **Total** | - | **~150,000/month** | **$0** |

With paid APIs as backup: Add $10-20/month for overflow.

**Infrastructure cost:** $13-30/month (VPS + Supabase free tier)

**Total: 150K requests/month at $13-30/month**

---

## 🏗️ Architecture

```
External Apps → API Gateway → Redis Queue → Browser Workers → AI Providers
                      ↓                             ↓
                 Supabase DB ←─────────────────────┘
                 (sessions, quotas, logs)
                      ↓
                React Webapp (account management)
```

### Components

1. **React Webapp** - Account management, quota dashboard, 2FA input
2. **Supabase Backend** - PostgreSQL, Auth, Realtime, Storage
3. **API Gateway** - REST endpoints with auth & rate limiting
4. **Redis Queue** - BullMQ job queue for async processing
5. **Browser Workers** - Playwright automation (3 instances)
6. **Quota Tracker** - Real-time monitoring & auto-reset

---

## 🎯 Key Features

### 1. Browser Automation
- ✅ Headless Chrome with Playwright
- ✅ Session persistence (cookies + localStorage)
- ✅ Anti-bot evasion (stealth mode)
- ✅ Screenshot on error
- ✅ Video recording (optional)

### 2. Multi-Account Management
- ✅ Add unlimited accounts per provider
- ✅ Automatic rotation (least-used first)
- ✅ Session expiration tracking
- ✅ Auto-reactivation after quota reset

### 3. Intelligent Routing
- ✅ Auto provider selection (cheapest first)
- ✅ Quota-aware load balancing
- ✅ Fallback chains
- ✅ Priority queue support

### 4. Real-Time Monitoring
- ✅ Live quota updates (Supabase Realtime)
- ✅ Request status tracking
- ✅ Usage logs & analytics
- ✅ Alert system (quota warnings)

### 5. External API
- ✅ RESTful endpoints
- ✅ API key authentication
- ✅ Rate limiting (100 req/min)
- ✅ WebSocket for real-time updates

---

## 📦 Quick Start

### Prerequisites

- Docker & Docker Compose
- Supabase account (free tier)
- VPS with 4GB RAM (e.g., Hetzner CPX31 @ $13/mo)

### 1. Clone Repository

```bash
git clone https://github.com/your-username/ai-cli-orchestrator.git
cd ai-cli-orchestrator
```

### 2. Deploy Database

1. Create Supabase project at https://app.supabase.com
2. Open SQL Editor
3. Copy & run `supabase/schema.sql`
4. Enable Realtime for: `accounts`, `quotas`, `requests`, `alerts`

### 3. Configure Environment

```bash
cp .env.v2.example .env
nano .env
```

Fill in:
```env
SUPABASE_URL=https://your-project.supabase.co
SUPABASE_ANON_KEY=eyJ...
SUPABASE_SERVICE_KEY=eyJ...
```

### 4. Start Services

```bash
docker compose -f docker-compose.v2.yml up -d
```

### 5. Access Webapp

```
http://localhost:3000
```

Sign up, add accounts, start using!

---

## 🔧 Configuration

### Supported Providers

**Web Login (Browser Automation):**
- ChatGPT (chat.openai.com)
- Claude (claude.ai)
- Gemini (gemini.google.com)
- DeepSeek (chat.deepseek.com)

**API-Based (V1 compatibility):**
- Gemini API
- Groq
- OpenAI (trial credits)
- Anthropic Claude (trial credits)

### Environment Variables

**Required:**
```env
SUPABASE_URL=...
SUPABASE_ANON_KEY=...
SUPABASE_SERVICE_KEY=...
```

**Optional:**
```env
WORKER_CONCURRENCY=2        # Browsers per worker
HEADLESS_MODE=true          # Set false for debugging
SCREENSHOT_ON_ERROR=true    # Save screenshots on errors
VIDEO_RECORDING=false       # Record browser sessions
SESSION_TIMEOUT=300000      # 5 minutes
QUOTA_CHECK_INTERVAL=60000  # Check quotas every 60s
```

---

## 📚 Documentation

- **[SYSTEM_ARCHITECTURE_V2_OAUTH.md](SYSTEM_ARCHITECTURE_V2_OAUTH.md)** - Complete architecture (2,000+ lines)
- **[DEPLOYMENT_GUIDE.md](DEPLOYMENT_GUIDE.md)** - Step-by-step deployment
- **[BROWSER_AUTOMATION_RESEARCH.md](BROWSER_AUTOMATION_RESEARCH.md)** - Playwright automation guide
- **[OAUTH_FREE_TIER_RESEARCH.md](OAUTH_FREE_TIER_RESEARCH.md)** - Free tier analysis

### Component READMEs

- `webapp/README.md` - React webapp
- `browser-worker/README.md` - Playwright workers
- `quota-tracker/README.md` - Quota monitoring
- `supabase/README.md` - API gateway

---

## 🧪 API Usage

### Submit Chat Request

```bash
curl -X POST http://localhost:3001/api/v1/chat \
  -H "Authorization: Bearer YOUR_API_KEY" \
  -H "Content-Type: application/json" \
  -d '{
    "prompt": "Explain quantum computing",
    "provider": "auto",
    "priority": "normal"
  }'
```

**Response:**
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

### Check Status

```bash
curl http://localhost:3001/api/v1/status/req_abc123 \
  -H "Authorization: Bearer YOUR_API_KEY"
```

**Response:**
```json
{
  "id": "req_abc123",
  "status": "completed",
  "provider_used": "chatgpt",
  "response": "Quantum computing uses quantum bits...",
  "tokens_used": 245,
  "latency_ms": 3420
}
```

### Get Quotas

```bash
curl http://localhost:3001/api/v1/quotas \
  -H "Authorization: Bearer YOUR_API_KEY"
```

---

## 🎬 Use Cases

### 1. AI-Powered Applications

Build apps that need AI without paying for API keys:

```javascript
import axios from 'axios'

const ai = axios.create({
  baseURL: 'http://your-server:3001/api/v1',
  headers: { Authorization: 'Bearer YOUR_API_KEY' }
})

async function chat(prompt) {
  const { data } = await ai.post('/chat', { prompt })

  // Poll for result
  while (true) {
    const status = await ai.get(`/status/${data.id}`)
    if (status.data.status === 'completed') {
      return status.data.response
    }
    await new Promise(r => setTimeout(r, 1000))
  }
}

const answer = await chat("What is recursion?")
console.log(answer)
```

### 2. Batch Processing

Process thousands of prompts using the free tier:

```python
import requests
import time

API_KEY = "YOUR_API_KEY"
BASE_URL = "http://your-server:3001/api/v1"

def process_batch(prompts):
    # Submit all requests
    request_ids = []
    for prompt in prompts:
        r = requests.post(
            f"{BASE_URL}/chat",
            headers={"Authorization": f"Bearer {API_KEY}"},
            json={"prompt": prompt, "provider": "auto"}
        )
        request_ids.append(r.json()["id"])

    # Collect results
    results = []
    for req_id in request_ids:
        while True:
            r = requests.get(
                f"{BASE_URL}/status/{req_id}",
                headers={"Authorization": f"Bearer {API_KEY}"}
            )
            if r.json()["status"] == "completed":
                results.append(r.json()["response"])
                break
            time.sleep(1)

    return results

prompts = ["What is AI?", "Explain ML", ...] * 100
results = process_batch(prompts)  # 100+ prompts at $0 cost
```

### 3. Research & Analysis

Analyze large datasets with multiple AI providers:

```bash
# Process 1000 research papers
for paper in papers/*.txt; do
  curl -X POST http://localhost:3001/api/v1/chat \
    -H "Authorization: Bearer $API_KEY" \
    -d "{\"prompt\": \"Summarize: $(cat $paper)\"}"
done
```

---

## 💰 Cost Analysis

### Infrastructure Costs

| Component | Provider | Cost |
|-----------|----------|------|
| VPS (4GB, 2vCPU) | Hetzner CPX31 | $13/mo |
| Database | Supabase Free | $0 |
| **Total** | - | **$13/mo** |

### Capacity vs Cost

| Tier | Requests/Month | Cost | Cost per 1K |
|------|----------------|------|-------------|
| **Free Tier Only** | 150,000 | $13 | $0.09 |
| **+ DeepSeek API** | 200,000 | $20 | $0.10 |
| **+ Paid APIs** | 500,000 | $50 | $0.10 |

Compare to pure API approach:
- OpenAI GPT-4o-mini: $0.15 per 1K input tokens = **$75** for 500K requests
- Claude Sonnet: $3 per 1M tokens = **$150** for 500K requests

**Savings: 80-95% cheaper!**

---

## 🔒 Security

- ✅ Row-Level Security (RLS) on all tables
- ✅ API key hashing (SHA-256)
- ✅ Session encryption (AES-256-GCM)
- ✅ Rate limiting per API key
- ✅ Input validation (Zod schemas)
- ✅ HTTPS recommended (Let's Encrypt)

---

## 📈 Scaling

### Horizontal Scaling

Add more browser workers:

```yaml
# docker-compose.v2.yml
browser-worker-4:
  build: ./browser-worker
  environment:
    - WORKER_ID=4
    - CONCURRENCY=2
```

### Vertical Scaling

Increase worker concurrency:

```env
WORKER_CONCURRENCY=4  # up from 2
```

### Expected Performance

| Workers | Concurrency | Parallel Requests | Requests/Min |
|---------|-------------|-------------------|--------------|
| 3 | 2 | 6 | 10-30 |
| 5 | 2 | 10 | 20-50 |
| 5 | 4 | 20 | 40-100 |

---

## 🐛 Troubleshooting

### Common Issues

**1. Session expired errors**

Check `browser-worker` logs:
```bash
docker compose -f docker-compose.v2.yml logs -f browser-worker-1
```

Solution: Re-login via webapp

**2. Quota not resetting**

Check `quota-tracker` logs:
```bash
docker compose -f docker-compose.v2.yml logs -f quota-tracker
```

Manual reset:
```sql
UPDATE quotas SET daily_used = 0;
```

**3. Workers crashing**

Increase memory:
```yaml
deploy:
  resources:
    limits:
      memory: 2G  # up from 1G
```

---

## 🤝 Contributing

We welcome contributions! Please read:
1. Fork repository
2. Create feature branch
3. Make changes
4. Submit pull request

---

## 📜 License

MIT License - See LICENSE file

---

## 🙏 Acknowledgments

Built on:
- [Playwright](https://playwright.dev/) - Browser automation
- [Supabase](https://supabase.com/) - Backend platform
- [BullMQ](https://docs.bullmq.io/) - Job queue
- [React](https://react.dev/) - Frontend framework

Research based on:
- 70+ AI CLI tools analyzed
- 12+ AI providers evaluated
- 250+ documentation sources

---

## 📞 Support

- **Documentation:** See `/docs` directory
- **Issues:** GitHub Issues
- **Discussions:** GitHub Discussions

---

## 🗺️ Roadmap

- [x] V2.0: Browser automation with OAuth
- [x] Multi-account management
- [x] Real-time quota tracking
- [x] External API gateway
- [ ] V2.1: Automated 2FA handling
- [ ] V2.2: Session auto-refresh
- [ ] V2.3: Advanced analytics dashboard
- [ ] V3.0: Kubernetes deployment
- [ ] V3.1: Multi-region support

---

## ⭐ Star History

If this project helps you, please give it a star! ⭐

---

**AI CLI Orchestrator V2** - Built with ❤️ by the open source community

*Last updated: 2025-11-15*
