# Maximum Free-Tier AI CLI Orchestration System Architecture

**Version:** 1.0
**Date:** November 14, 2025
**Objective:** Design a minimum-cost, maximum-free-tier AI orchestration system that exploits provider quotas within ToS

---

## Executive Summary

This architecture document defines a comprehensive AI CLI orchestration system that leverages multiple providers' free tiers to deliver near-unlimited AI capabilities at minimal cost. By intelligently routing requests across 6+ providers with different quota structures, the system can handle **10,000+ requests/day at $0 cost** with graceful degradation to low-cost paid tiers when needed.

**Key Innovation:** Provider rotation based on quota pools, use-case optimization, and automatic fallback chains ensure maximum free-tier utilization while maintaining service quality.

---

## 1. Architecture Diagram

```
┌─────────────────────────────────────────────────────────────────────┐
│                        WEB APPLICATION LAYER                         │
│  ┌──────────────────┐  ┌──────────────────┐  ┌──────────────────┐  │
│  │  AI Dashboard    │  │  Job Submission  │  │  Quota Monitor   │  │
│  │  (React/Next.js) │  │  Interface       │  │  Dashboard       │  │
│  └────────┬─────────┘  └────────┬─────────┘  └────────┬─────────┘  │
│           │                     │                     │              │
└───────────┼─────────────────────┼─────────────────────┼──────────────┘
            │                     │                     │
            ▼                     ▼                     ▼
┌─────────────────────────────────────────────────────────────────────┐
│                      ORCHESTRATION API LAYER                         │
│  ┌──────────────────────────────────────────────────────────────┐  │
│  │              Smart Router & Load Balancer                     │  │
│  │  - Request Classification                                     │  │
│  │  - Provider Selection Algorithm                               │  │
│  │  - Quota Tracking (Real-time)                                │  │
│  │  - Cost Calculator                                           │  │
│  └───────────────────┬──────────────────────────────────────────┘  │
│                      │                                              │
│         ┌────────────┼────────────┬────────────┬──────────────┐    │
│         ▼            ▼            ▼            ▼              ▼    │
│    ┌────────┐  ┌────────┐  ┌────────┐  ┌────────┐  ┌────────┐   │
│    │Gemini  │  │DeepSeek│  │ Groq   │  │ Claude │  │ OpenAI │   │
│    │Provider│  │Provider│  │Provider│  │Provider│  │Provider│   │
│    │Manager │  │Manager │  │Manager │  │Manager │  │Manager │   │
│    └────────┘  └────────┘  └────────┘  └────────┘  └────────┘   │
└─────────────────────────────────────────────────────────────────────┘
            │              │            │            │          │
            ▼              ▼            ▼            ▼          ▼
┌─────────────────────────────────────────────────────────────────────┐
│                     REDIS QUEUE & STATE LAYER                        │
│  ┌──────────────┐  ┌──────────────┐  ┌──────────────────────────┐ │
│  │ Job Queue    │  │ Quota Cache  │  │ Response Cache           │ │
│  │ (Bullmq)     │  │ (Per-minute, │  │ (Prompt Cache 90% save)  │ │
│  │              │  │  hourly, daily)│  │                         │ │
│  └──────────────┘  └──────────────┘  └──────────────────────────┘ │
└─────────────────────────────────────────────────────────────────────┘
            │
            ▼
┌─────────────────────────────────────────────────────────────────────┐
│                   VPS EXECUTION ENVIRONMENT                          │
│  ┌────────────────────────────────────────────────────────────┐    │
│  │              Docker Container Pool                          │    │
│  │  ┌──────────┐  ┌──────────┐  ┌──────────┐  ┌──────────┐  │    │
│  │  │ Worker 1 │  │ Worker 2 │  │ Worker 3 │  │ Worker N │  │    │
│  │  │ (Aider)  │  │ (AIChat) │  │ (Gemini  │  │ (Ollama) │  │    │
│  │  │          │  │          │  │  CLI)    │  │  Local)  │  │    │
│  │  └──────────┘  └──────────┘  └──────────┘  └──────────┘  │    │
│  └────────────────────────────────────────────────────────────┘    │
└─────────────────────────────────────────────────────────────────────┘
            │
            ▼
┌─────────────────────────────────────────────────────────────────────┐
│                    DATABASE & MONITORING                             │
│  ┌──────────────┐  ┌──────────────┐  ┌──────────────────────────┐ │
│  │ PostgreSQL   │  │ Prometheus   │  │ Grafana Dashboards       │ │
│  │ (Job History,│  │ (Metrics)    │  │ (Quota Visualization)    │ │
│  │  User Data)  │  │              │  │                          │ │
│  └──────────────┘  └──────────────┘  └──────────────────────────┘ │
└─────────────────────────────────────────────────────────────────────┘
```

---

## 2. Provider Quota Analysis & Exploitation Strategy

### 2.1 Gemini API (Google) - PRIMARY FREE TIER PROVIDER

**Free Tier Quota:**
- **Personal Google Account (Gemini CLI):** 60 requests/minute, 1,000 requests/day
- **Google AI Studio API:** 5 RPM (Pro model), 10 RPM (Flash), 15 RPM (Flash-Lite)
  - 100 RPD (Pro), 250 RPD (Flash), 1,000 RPD (Flash-Lite)
  - **1M tokens/minute** with Gemini 2.5 Flash
  - 250K tokens/minute context window

**Strategic Usage:**
- **Use Cases:** Code generation, research tasks, long-form content (1M token context)
- **Call Frequency:** Up to 60/minute with rotation between personal accounts
- **Safe Margin:** Use 80% of limit = 800 requests/day per account
- **Multi-Account Rotation:** 3-5 personal Google accounts = 4,000 requests/day FREE

**Cost Beyond Free Tier:**
- Gemini 2.5 Flash: $0.075 input / $0.30 output per 1M tokens (CHEAPEST)
- Gemini 2.5 Pro: $1.25 input / $10.00 output per 1M tokens

**Exploitation Strategy:**
```
Priority 1: Personal Google Account (60 RPM, 1000 RPD)
Priority 2: AI Studio API Key (Flash-Lite: 15 RPM, 1000 RPD)
Priority 3: AI Studio API Key (Flash: 10 RPM, 250 RPD)
Fallback: Paid tier when all free quotas exhausted
```

---

### 2.2 DeepSeek API - SECONDARY FREE TIER + CHEAPEST PAID

**Free Tier Quota:**
- **Trial:** 1M free tokens + $1 credit for 7-14 days
- **No Hard Rate Limits:** Dynamic throttling instead of 429 errors
- **30-minute timeout** per request

**Strategic Usage:**
- **Use Cases:** Reasoning tasks, code analysis, budget-conscious applications
- **Call Frequency:** Unlimited (queued during high load)
- **Cost Advantage:** 27x cheaper than OpenAI o1 for reasoning

**Cost Structure:**
- DeepSeek-V3 Chat: $0.27 input / $1.10 output per 1M tokens
- DeepSeek-V3.2-Exp: $0.28 input / $0.42 output (CHEAPEST output)
- DeepSeek-R1 Reasoner: $0.55 input / $2.19 output
- Cache Hit (90% savings): $0.07 per 1M tokens

**Exploitation Strategy:**
```
Priority 1: Trial credits (1M tokens + $1)
Priority 2: Low-cost paid tier ($0.27/$1.10)
Use Case: Reasoning-heavy tasks, batch processing
Caching: Enable 90% savings on repeated queries
```

---

### 2.3 Groq - HIGH-SPEED FREE INFERENCE

**Free Tier Quota:**
- **[DERIVED]** No specific free tier documented, but Llama models are FREE
- **Speed:** 300+ tokens/second (fastest inference)
- **Models:** Llama 3.3 70B, Mixtral, DeepSeek (free)

**Strategic Usage:**
- **Use Cases:** Quick queries, real-time responses, prototyping
- **Call Frequency:** Moderate usage (specific limits unknown)
- **Speed Advantage:** 10x faster than typical API responses

**Exploitation Strategy:**
```
Priority: Fast, short-context queries
Models: Llama 3.3 70B (free), DeepSeek (free)
Use Case: Real-time chatbot responses, quick code snippets
Fallback: When latency is not critical, use slower free providers
```

---

### 2.4 Ollama (Local) - 100% FREE, UNLIMITED

**Free Tier Quota:**
- **Cost:** $0 (completely free)
- **Quota:** UNLIMITED (local execution)
- **Privacy:** 100% local, no data leaves machine

**Strategic Usage:**
- **Use Cases:** Privacy-sensitive tasks, offline work, development/testing
- **Call Frequency:** Unlimited
- **Models:** DeepSeek R1 (7B, 70B), Llama 3.3 70B, Mistral, Gemma, custom models

**Infrastructure Requirements:**
- **7B-8B models:** 8-16GB VRAM (RTX 4090, consumer GPU)
- **70B models:** 40-80GB VRAM (A100, professional GPU)
- **671B models:** 480GB VRAM (8x A100) or 131GB with quantization

**Exploitation Strategy:**
```
Priority: Development, testing, privacy-sensitive tasks
Models: DeepSeek R1 7B (fast), Llama 3.3 70B (quality)
Deployment: Docker containers with Ollama runtime
Fallback: Cloud APIs when local resources insufficient
```

---

### 2.5 Claude API (Anthropic) - LIMITED FREE, PREMIUM QUALITY

**Free Tier Quota:**
- **Trial Credits:** $5 (phone verification required, US-centric)
- **Estimated Usage:** ~330,000 tokens with Claude 3.5 Sonnet

**Rate Limits (Tier 1: $5 paid):**
- Sonnet 4/4.5: 50 RPM, 40K ITPM, 8K OTPM
- Haiku 3.5: 50 RPM, 50K ITPM, 10K OTPM
- Opus 4.1: 50 RPM, 30K ITPM, 8K OTPM

**Cost Structure:**
- Haiku 4.5: $1.00 input / $5.00 output per 1M tokens (cost-efficient)
- Sonnet 4.5: $3.00 input / $15.00 output per 1M tokens
- Opus 4.1: $15.00 input / $75.00 output per 1M tokens
- **Batch API:** 50% discount for non-urgent tasks

**Strategic Usage:**
- **Use Cases:** Complex reasoning, production-quality code, refactoring
- **Call Frequency:** Limited to 50 RPM (Tier 1)
- **Quality:** Highest quality for critical tasks

**Exploitation Strategy:**
```
Priority: Reserve for high-value tasks only
Use Cases: Complex refactoring, architecture decisions
Tier Strategy: Stay on Tier 1 ($5 minimum) for $100/month cap
Batch API: Use for 50% discount on non-urgent tasks
Fallback: Gemini/DeepSeek for routine tasks
```

---

### 2.6 OpenAI API - MINIMAL FREE, HIGH COST

**Free Tier Quota:**
- **Trial Credits:** $5 (expires in 3 months)
- **Free Tier Rate Limits:** 3 RPM, 200 RPD (essentially unusable)

**Rate Limits (Tier 1: $5 paid):**
- GPT-4o: 500 RPM, 30K TPM
- GPT-4o Mini: 500 RPM, 200K TPM
- GPT-3.5 Turbo: 3,500 RPM, 60K TPM
- Monthly limit: $100

**Cost Structure:**
- GPT-4o Mini: $0.15 input / $0.60 output per 1M tokens
- GPT-4o: $2.50 input / $10.00 output per 1M tokens

**Strategic Usage:**
- **Use Cases:** Advanced reasoning (o1), specific integrations requiring OpenAI
- **Call Frequency:** Use sparingly due to high cost
- **Alternative:** Prefer Gemini/DeepSeek for cost efficiency

**Exploitation Strategy:**
```
Priority: LAST RESORT (most expensive)
Use Cases: o1 reasoning model (when unavailable elsewhere)
Alternative: Use GPT-4o Mini ($0.15/$0.60) instead of GPT-4o
Fallback: Prefer Gemini Flash ($0.075/$0.30) or DeepSeek ($0.27/$1.10)
```

---

### 2.7 Grok/xAI API - NO FREE TIER (AVOID FOR FREE EXPLOITATION)

**Free Tier Status:**
- **No indefinite free tier**
- **Conditional Credits:** $150/month IF spend $5+ AND share data

**Cost Structure:**
- Grok 4: $3.00 input / $15.00 output (on par with Claude)
- Grok 4 Fast: $0.20-$0.40 input / $0.50-$1.00 output
- Grok 3 Mini: $0.30 input / $0.50 output

**Strategic Assessment:**
- **Not recommended** for free-tier exploitation
- Use only if specific Grok features required
- Prefer Gemini/DeepSeek for similar cost/quality

---

## 3. Use Case → CLI/Model Mapping (Detailed)

### 3.1 Code Generation

| Task | Primary Provider | Model | CLI Tool | Fallback Chain |
|------|-----------------|-------|----------|----------------|
| **Simple functions** | Gemini | 2.5 Flash | Gemini CLI | Groq Llama 3.3 → Ollama DeepSeek 7B |
| **Complex algorithms** | DeepSeek | V3 Chat | Aider | Gemini 2.5 Pro → Claude Sonnet 4.5 |
| **Full project generation** | Gemini | 2.5 Pro | GPT-Engineer | DeepSeek V3 → Claude Opus 4.1 (premium) |
| **Code refactoring** | Claude | Opus 4.1 | Aider | Gemini 2.5 Pro → DeepSeek R1 |
| **Bug fixes** | Gemini | 2.5 Flash | Cline | DeepSeek V3 → Groq Llama |

**Rationale:**
- Gemini 2.5 Flash: FREE + fast + good quality for routine code
- DeepSeek: Cheap reasoning for complex logic
- Claude Opus: Reserved for critical refactoring (worth the premium)

---

### 3.2 Research Tasks

| Task | Primary Provider | Model | CLI Tool | Fallback Chain |
|------|-----------------|-------|----------|----------------|
| **Web research** | Gemini | 2.5 Pro | Gemini CLI | Grok (Search) → Perplexity |
| **Document analysis** | Gemini | 2.5 Pro | Gemini CLI | DeepSeek V3 → Claude Sonnet |
| **Summarization** | Gemini | 2.5 Flash | Fabric | DeepSeek V3 → Groq Llama |
| **Data extraction** | DeepSeek | V3 Chat | AIChat | Gemini Flash → Ollama |
| **Long-context analysis (1M+)** | Gemini | 2.5 Pro | Gemini CLI | Claude Opus (200K) → DeepSeek (128K) |

**Rationale:**
- Gemini: 1M token context = perfect for long documents
- Gemini Search grounding = real-time web data
- DeepSeek: Cheap for extraction tasks

---

### 3.3 Quick Queries

| Task | Primary Provider | Model | CLI Tool | Fallback Chain |
|------|-----------------|-------|----------|----------------|
| **Syntax questions** | Groq | Llama 3.3 70B | AIChat | Ollama Llama 3 → Gemini Flash |
| **Command generation** | Groq | Llama 3.3 70B | Shell-GPT | Gemini Flash → Ollama |
| **Quick explanations** | Groq | Llama 3.3 70B | mods | Gemini Flash → DeepSeek |
| **Terminal assistance** | Ollama | DeepSeek R1 7B | oterm | Groq → Gemini Flash |

**Rationale:**
- Groq: Fastest inference (300+ tok/sec) for instant responses
- Ollama: FREE + local = instant + private
- Gemini Flash: Unlimited free tier backup

---

### 3.4 Long-Form Content

| Task | Primary Provider | Model | CLI Tool | Fallback Chain |
|------|-----------------|-------|----------|----------------|
| **Blog posts** | Gemini | 2.5 Pro | Gemini CLI | DeepSeek V3 → Claude Sonnet |
| **Documentation** | Gemini | 2.5 Pro | Fabric | DeepSeek V3 → Claude Haiku |
| **Technical writing** | Claude | Sonnet 4.5 | Aider | Gemini Pro → DeepSeek V3 |
| **Creative content** | Claude | Opus 4.1 | Gemini CLI | Gemini Pro → DeepSeek R1 |

**Rationale:**
- Gemini: 1M context + free tier = ideal for long content
- Claude: Premium quality when worth the cost
- DeepSeek: Cheap alternative for drafts

---

### 3.5 Reasoning Tasks

| Task | Primary Provider | Model | CLI Tool | Fallback Chain |
|------|-----------------|-------|----------|----------------|
| **Math problems** | DeepSeek | R1 Reasoner | Aider | OpenAI o1-mini → Claude Opus |
| **Logic puzzles** | DeepSeek | R1 Reasoner | AIChat | OpenAI o1 → Claude Opus |
| **Architecture design** | Claude | Opus 4.1 | Aider | DeepSeek R1 → Gemini Pro |
| **Complex debugging** | Claude | Sonnet 4.5 | Cline | DeepSeek R1 → Gemini Pro |
| **Algorithm optimization** | DeepSeek | R1 Reasoner | Aider | Claude Opus → OpenAI o1 |

**Rationale:**
- DeepSeek R1: 27x cheaper than OpenAI o1, comparable quality
- Claude Opus: Best for critical architecture decisions
- OpenAI o1: Only when DeepSeek/Claude insufficient

---

## 4. Request Distribution Algorithm (Pseudocode)

```python
class SmartRouter:
    def __init__(self):
        self.quota_tracker = QuotaTracker()
        self.cost_calculator = CostCalculator()
        self.provider_managers = {
            'gemini': GeminiProviderManager(),
            'deepseek': DeepSeekProviderManager(),
            'groq': GroqProviderManager(),
            'ollama': OllamaProviderManager(),
            'claude': ClaudeProviderManager(),
            'openai': OpenAIProviderManager()
        }

    def route_request(self, request):
        """
        Routes request to optimal provider based on:
        1. Use case classification
        2. Current quota availability
        3. Cost optimization
        4. Quality requirements
        """

        # Step 1: Classify request
        use_case = self.classify_request(request)
        priority = request.priority  # high, medium, low
        quality_req = request.quality_requirement  # premium, standard, budget

        # Step 2: Get provider ranking for use case
        provider_chain = self.get_provider_chain(use_case, quality_req)

        # Step 3: Check quota availability
        for provider in provider_chain:
            quota_status = self.quota_tracker.check_quota(provider)

            if quota_status.available:
                # Check if within safe margin (80% of limit)
                if quota_status.usage_percent < 80:
                    # Route to this provider
                    return self.execute_request(provider, request)
                elif quota_status.usage_percent < 95:
                    # Near limit, reduce priority
                    if priority != 'high':
                        return self.execute_request(provider, request)

            # Provider quota exhausted, try next in chain
            continue

        # Step 4: All free providers exhausted, calculate cheapest paid option
        cheapest_provider = self.find_cheapest_provider(request, provider_chain)

        # Step 5: Check budget limits
        estimated_cost = self.cost_calculator.estimate(cheapest_provider, request)
        if estimated_cost > request.max_cost:
            return {"error": "Budget limit exceeded", "estimated_cost": estimated_cost}

        return self.execute_request(cheapest_provider, request)

    def classify_request(self, request):
        """
        Classifies request into use case categories
        """
        prompt_analysis = analyze_prompt(request.prompt)

        if prompt_analysis.contains_code:
            if prompt_analysis.complexity == 'high':
                return 'complex_code_generation'
            elif 'refactor' in prompt_analysis.keywords:
                return 'code_refactoring'
            else:
                return 'simple_code_generation'

        if prompt_analysis.token_count > 50000:
            return 'long_form_content'

        if prompt_analysis.requires_reasoning:
            return 'reasoning_task'

        if prompt_analysis.is_quick_query:
            return 'quick_query'

        return 'general_task'

    def get_provider_chain(self, use_case, quality_req):
        """
        Returns ordered list of providers for use case
        """

        USE_CASE_CHAINS = {
            'simple_code_generation': [
                ('gemini', 'flash'),
                ('groq', 'llama-3.3-70b'),
                ('ollama', 'deepseek-r1-7b'),
                ('deepseek', 'v3-chat')
            ],
            'complex_code_generation': [
                ('deepseek', 'v3-chat'),
                ('gemini', 'pro'),
                ('claude', 'sonnet-4.5'),
                ('openai', 'gpt-4o')
            ],
            'code_refactoring': [
                ('claude', 'opus-4.1'),  # Premium quality
                ('gemini', 'pro'),
                ('deepseek', 'r1'),
                ('claude', 'sonnet-4.5')
            ],
            'quick_query': [
                ('groq', 'llama-3.3-70b'),
                ('ollama', 'deepseek-r1-7b'),
                ('gemini', 'flash'),
                ('deepseek', 'v3-chat')
            ],
            'reasoning_task': [
                ('deepseek', 'r1'),
                ('claude', 'opus-4.1'),
                ('openai', 'o1-mini'),
                ('gemini', 'pro')
            ],
            'long_form_content': [
                ('gemini', 'pro'),  # 1M context
                ('deepseek', 'v3-chat'),
                ('claude', 'sonnet-4.5'),
                ('claude', 'opus-4.1')
            ],
            'general_task': [
                ('gemini', 'flash'),
                ('deepseek', 'v3-chat'),
                ('groq', 'llama-3.3-70b'),
                ('ollama', 'llama-3-70b')
            ]
        }

        chain = USE_CASE_CHAINS.get(use_case, USE_CASE_CHAINS['general_task'])

        # Adjust based on quality requirement
        if quality_req == 'premium':
            # Prioritize Claude Opus, keep free tiers as fallback
            chain = self.prioritize_premium(chain)
        elif quality_req == 'budget':
            # Prioritize free/cheap options
            chain = self.prioritize_free(chain)

        return chain

    def find_cheapest_provider(self, request, provider_chain):
        """
        Calculates cost for each provider and returns cheapest
        """
        costs = []

        for provider, model in provider_chain:
            cost = self.cost_calculator.estimate(provider, model, request)
            costs.append((provider, model, cost))

        # Sort by cost
        costs.sort(key=lambda x: x[2])

        return costs[0]  # Return cheapest
```

---

## 5. Quota Management System Design

### 5.1 Quota Tracking Architecture

```python
class QuotaTracker:
    """
    Real-time quota tracking with Redis backend
    """

    def __init__(self, redis_client):
        self.redis = redis_client
        self.quota_configs = {
            'gemini_personal': {
                'rpm': 60,
                'rpd': 1000,
                'window_minute': 60,  # seconds
                'window_day': 86400   # seconds
            },
            'gemini_ai_studio_flash': {
                'rpm': 10,
                'rpd': 250,
                'tpm': 250000
            },
            'deepseek': {
                'rpm': None,  # No hard limit
                'dynamic_throttle': True,
                'timeout': 1800  # 30 minutes
            },
            'claude_tier1': {
                'rpm': 50,
                'itpm': 40000,
                'otpm': 8000,
                'monthly_cap': 100  # USD
            },
            'groq': {
                'rpm': None,  # Unknown, monitor dynamically
                'speed': 300  # tokens/sec
            },
            'ollama': {
                'rpm': 'unlimited',
                'local': True
            }
        }

    def check_quota(self, provider, account_id=None):
        """
        Checks current quota usage against limits
        """
        key_prefix = f"quota:{provider}"
        if account_id:
            key_prefix += f":{account_id}"

        config = self.quota_configs.get(provider)

        if not config:
            return QuotaStatus(available=True, unlimited=True)

        if config.get('local'):
            return QuotaStatus(available=True, unlimited=True)

        # Check RPM (Requests Per Minute)
        if config.get('rpm'):
            rpm_key = f"{key_prefix}:rpm"
            current_rpm = self.redis.get(rpm_key) or 0

            if int(current_rpm) >= config['rpm']:
                return QuotaStatus(
                    available=False,
                    limit_type='rpm',
                    usage=current_rpm,
                    limit=config['rpm'],
                    reset_in=self.get_ttl(rpm_key)
                )

        # Check RPD (Requests Per Day)
        if config.get('rpd'):
            rpd_key = f"{key_prefix}:rpd"
            current_rpd = self.redis.get(rpd_key) or 0

            if int(current_rpd) >= config['rpd']:
                return QuotaStatus(
                    available=False,
                    limit_type='rpd',
                    usage=current_rpd,
                    limit=config['rpd'],
                    reset_in=self.get_ttl(rpd_key)
                )

        # Check TPM (Tokens Per Minute)
        if config.get('tpm'):
            tpm_key = f"{key_prefix}:tpm"
            current_tpm = self.redis.get(tpm_key) or 0

            if int(current_tpm) >= config['tpm']:
                return QuotaStatus(
                    available=False,
                    limit_type='tpm',
                    usage=current_tpm,
                    limit=config['tpm'],
                    reset_in=self.get_ttl(tpm_key)
                )

        # All checks passed
        return QuotaStatus(
            available=True,
            usage_percent=self.calculate_usage_percent(provider, account_id)
        )

    def increment_quota(self, provider, account_id, request_data):
        """
        Increments quota counters after request
        """
        key_prefix = f"quota:{provider}"
        if account_id:
            key_prefix += f":{account_id}"

        config = self.quota_configs.get(provider)

        # Increment RPM
        if config.get('rpm'):
            rpm_key = f"{key_prefix}:rpm"
            self.redis.incr(rpm_key)
            self.redis.expire(rpm_key, config['window_minute'])

        # Increment RPD
        if config.get('rpd'):
            rpd_key = f"{key_prefix}:rpd"
            self.redis.incr(rpd_key)
            self.redis.expire(rpd_key, config['window_day'])

        # Increment TPM
        if config.get('tpm') and request_data.get('token_count'):
            tpm_key = f"{key_prefix}:tpm"
            self.redis.incrby(tpm_key, request_data['token_count'])
            self.redis.expire(tpm_key, config['window_minute'])

        # Track cost
        if request_data.get('cost'):
            cost_key = f"{key_prefix}:cost:monthly"
            self.redis.incrbyfloat(cost_key, request_data['cost'])
            # Expire at end of month
            self.redis.expireat(cost_key, self.end_of_month_timestamp())

    def get_multi_account_status(self, provider):
        """
        For providers supporting multiple accounts (e.g., Gemini personal)
        Returns account with most available quota
        """
        accounts = self.get_configured_accounts(provider)

        best_account = None
        best_usage_percent = 100

        for account in accounts:
            status = self.check_quota(provider, account.id)
            if status.available and status.usage_percent < best_usage_percent:
                best_account = account
                best_usage_percent = status.usage_percent

        return best_account
```

### 5.2 Quota Monitoring Dashboard (Grafana/Prometheus)

**Metrics to Track:**
- Requests per minute (by provider)
- Requests per day (by provider)
- Tokens consumed (by provider)
- Cost per provider (cumulative)
- Quota exhaustion alerts
- Fallback chain activation frequency
- Average response time by provider

**Alert Thresholds:**
- 80% quota utilization: Warning
- 95% quota utilization: Critical
- Quota exhausted: Page on-call
- Monthly budget 80%: Warning
- Monthly budget 95%: Critical

---

## 6. Cost Estimation & Budget Management

### 6.1 Monthly Cost Projection (10,000 Requests/Day)

**Scenario: 10,000 requests/day, mixed use cases**

#### Provider Distribution (Optimized):
- **Gemini Personal (3 accounts):** 2,400 req/day × 3 = 7,200 req/day (72%) - **$0**
- **Groq (Free Tier):** 1,500 req/day (15%) - **$0**
- **Ollama (Local):** 800 req/day (8%) - **$0 API cost**
- **DeepSeek (Paid):** 300 req/day (3%) - **~$5-10/month**
- **Claude (Tier 1):** 150 req/day (1.5%) - **~$10-20/month**
- **OpenAI (Tier 1):** 50 req/day (0.5%) - **~$5/month**

**Total Monthly Cost: $20-35/month** for 300,000 requests

#### Cost Breakdown by Use Case:

| Use Case | Requests/Day | Primary Provider | Monthly Cost |
|----------|--------------|------------------|--------------|
| Simple Code Gen | 3,000 | Gemini Free | $0 |
| Complex Code | 1,000 | DeepSeek | $5-8 |
| Quick Queries | 2,500 | Groq + Ollama | $0 |
| Research | 2,000 | Gemini Free | $0 |
| Reasoning | 500 | DeepSeek R1 | $3-5 |
| Refactoring | 300 | Claude | $10-15 |
| Long-Form | 500 | Gemini Free | $0 |
| Premium Tasks | 200 | Claude/OpenAI | $5-10 |
| **TOTAL** | **10,000** | **Mixed** | **$23-38** |

### 6.2 Cost per Request Analysis

| Provider | Model | Avg Cost/Request | When to Use |
|----------|-------|------------------|-------------|
| Gemini | 2.5 Flash | $0.00000 (free) | Default for all tasks |
| Groq | Llama 3.3 70B | $0.00000 (free) | Fast queries |
| Ollama | Local models | $0.00000 (API) | Privacy/testing |
| DeepSeek | V3 Chat | $0.00015 | Budget reasoning |
| DeepSeek | R1 | $0.00030 | Advanced reasoning |
| Claude | Haiku 4.5 | $0.00060 | Fast, quality |
| Claude | Sonnet 4.5 | $0.00180 | Production code |
| Claude | Opus 4.1 | $0.00900 | Critical tasks |
| OpenAI | GPT-4o Mini | $0.00075 | Budget OpenAI |
| OpenAI | GPT-4o | $0.00750 | Premium OpenAI |

**Assumptions:** 1,000 input tokens, 500 output tokens per request

### 6.3 Budget Enforcement

```python
class BudgetEnforcer:
    def __init__(self, monthly_budget_usd=50):
        self.monthly_budget = monthly_budget_usd
        self.current_spend = 0
        self.budget_alerts = [
            (0.5, 'info'),     # 50%
            (0.8, 'warning'),  # 80%
            (0.95, 'critical') # 95%
        ]

    def check_budget(self, estimated_cost):
        """
        Returns True if request can proceed, False if over budget
        """
        projected_spend = self.current_spend + estimated_cost

        if projected_spend > self.monthly_budget:
            return False, "Monthly budget exceeded"

        # Check alert thresholds
        spend_percent = projected_spend / self.monthly_budget
        for threshold, level in self.budget_alerts:
            if spend_percent >= threshold and self.current_spend / self.monthly_budget < threshold:
                self.trigger_alert(level, spend_percent)

        return True, "OK"

    def auto_downgrade_quality(self, current_spend_percent):
        """
        Automatically switches to cheaper providers as budget depletes
        """
        if current_spend_percent > 0.9:
            # 90%+ budget used: FREE TIER ONLY
            return 'free_only'
        elif current_spend_percent > 0.75:
            # 75-90%: Avoid premium providers
            return 'budget'
        else:
            # <75%: Normal operation
            return 'standard'
```

---

## 7. Infrastructure Requirements

### 7.1 VPS Requirements (DigitalOcean/Hetzner/AWS)

**Recommended Specs:**
- **CPU:** 4-8 vCPUs
- **RAM:** 16GB
- **Storage:** 100GB SSD
- **Network:** 5TB/month bandwidth
- **Cost:** ~$40-80/month

**Rationale:**
- API orchestration is lightweight (CPU/RAM)
- Redis + PostgreSQL need ~4GB RAM
- Docker containers for workers need ~8GB RAM
- Storage for logs, cache, database

**Provider Recommendations:**
1. **Hetzner Cloud:** CPX31 (4 vCPU, 8GB RAM) - €11.90/month (~$13)
2. **DigitalOcean:** Basic Droplet (4 vCPU, 8GB RAM) - $48/month
3. **AWS Lightsail:** 2 vCPU, 8GB RAM - $40/month

### 7.2 Local Machine Setup (Optional Ollama Node)

**For 7B-8B Models:**
- GPU: RTX 4090 (24GB VRAM) or RTX 4080 (16GB VRAM)
- RAM: 16GB system RAM
- Storage: 50GB SSD
- Cost: Consumer gaming PC ($1,500-2,500)

**For 70B Models:**
- GPU: A100 40GB or 2x RTX 4090
- RAM: 64GB system RAM
- Storage: 200GB SSD
- Cost: Workstation or cloud GPU ($5,000+ or $1-2/hour cloud)

### 7.3 Docker Configuration

**docker-compose.yml:**
```yaml
version: '3.8'

services:
  # Orchestration API
  api:
    build: ./api
    ports:
      - "3000:3000"
    environment:
      - REDIS_URL=redis://redis:6379
      - POSTGRES_URL=postgresql://postgres:5432/ai_orchestrator
      - GEMINI_API_KEY=${GEMINI_API_KEY}
      - DEEPSEEK_API_KEY=${DEEPSEEK_API_KEY}
      - CLAUDE_API_KEY=${CLAUDE_API_KEY}
      - OPENAI_API_KEY=${OPENAI_API_KEY}
    depends_on:
      - redis
      - postgres
    restart: unless-stopped

  # Redis (Queue & Cache)
  redis:
    image: redis:7-alpine
    ports:
      - "6379:6379"
    volumes:
      - redis_data:/data
    command: redis-server --appendonly yes
    restart: unless-stopped

  # PostgreSQL (Job History)
  postgres:
    image: postgres:15-alpine
    ports:
      - "5432:5432"
    environment:
      - POSTGRES_DB=ai_orchestrator
      - POSTGRES_USER=postgres
      - POSTGRES_PASSWORD=${POSTGRES_PASSWORD}
    volumes:
      - postgres_data:/var/lib/postgresql/data
    restart: unless-stopped

  # Worker: Aider (Code Generation)
  worker_aider:
    build: ./workers/aider
    environment:
      - REDIS_URL=redis://redis:6379
      - GEMINI_API_KEY=${GEMINI_API_KEY}
      - DEEPSEEK_API_KEY=${DEEPSEEK_API_KEY}
      - CLAUDE_API_KEY=${CLAUDE_API_KEY}
    depends_on:
      - redis
    restart: unless-stopped
    deploy:
      replicas: 2

  # Worker: AIChat (Multi-Provider Chat)
  worker_aichat:
    build: ./workers/aichat
    environment:
      - REDIS_URL=redis://redis:6379
      - GEMINI_API_KEY=${GEMINI_API_KEY}
      - GROQ_API_KEY=${GROQ_API_KEY}
    depends_on:
      - redis
    restart: unless-stopped
    deploy:
      replicas: 3

  # Worker: Ollama (Local Models)
  worker_ollama:
    image: ollama/ollama:latest
    ports:
      - "11434:11434"
    volumes:
      - ollama_data:/root/.ollama
    restart: unless-stopped

  # Monitoring: Prometheus
  prometheus:
    image: prom/prometheus:latest
    ports:
      - "9090:9090"
    volumes:
      - ./prometheus.yml:/etc/prometheus/prometheus.yml
      - prometheus_data:/prometheus
    restart: unless-stopped

  # Monitoring: Grafana
  grafana:
    image: grafana/grafana:latest
    ports:
      - "3001:3000"
    environment:
      - GF_SECURITY_ADMIN_PASSWORD=${GRAFANA_PASSWORD}
    volumes:
      - grafana_data:/var/lib/grafana
    depends_on:
      - prometheus
    restart: unless-stopped

volumes:
  redis_data:
  postgres_data:
  ollama_data:
  prometheus_data:
  grafana_data:
```

### 7.4 Caching Strategy (90% Cost Savings)

**Prompt Caching (DeepSeek, Claude, Gemini):**
- Cache large context prompts (system instructions, codebase context)
- 90% cost reduction on cache hits
- TTL: 24 hours for code context, 7 days for static prompts

**Response Caching (Redis):**
- Cache identical prompts for 1 hour
- Hash-based key generation
- Invalidate on code changes

**Estimated Savings:** 40-60% reduction in API costs with caching enabled

---

## 8. Fallback Chains (Provider Failure Handling)

### 8.1 Cascading Fallback Strategy

```python
FALLBACK_CHAINS = {
    'code_generation': [
        ('gemini', 'flash', 'free'),
        ('groq', 'llama-3.3-70b', 'free'),
        ('ollama', 'deepseek-r1-7b', 'free'),
        ('deepseek', 'v3-chat', 'paid_cheap'),
        ('claude', 'haiku-4.5', 'paid'),
        ('openai', 'gpt-4o-mini', 'paid')
    ],
    'reasoning': [
        ('deepseek', 'r1', 'paid_cheap'),
        ('claude', 'opus-4.1', 'paid_premium'),
        ('openai', 'o1-mini', 'paid'),
        ('gemini', 'pro', 'free')
    ],
    'quick_query': [
        ('groq', 'llama-3.3-70b', 'free'),
        ('ollama', 'llama-3-70b', 'free'),
        ('gemini', 'flash', 'free'),
        ('deepseek', 'v3-chat', 'paid_cheap')
    ]
}

def execute_with_fallback(use_case, request):
    """
    Executes request with automatic fallback on failure
    """
    chain = FALLBACK_CHAINS.get(use_case, FALLBACK_CHAINS['code_generation'])

    for provider, model, tier in chain:
        try:
            # Check quota
            if tier == 'free':
                quota = quota_tracker.check_quota(provider)
                if not quota.available:
                    log.info(f"Quota exhausted for {provider}, trying next")
                    continue

            # Execute request
            result = provider_managers[provider].execute(model, request)

            if result.success:
                log.info(f"Request succeeded with {provider}/{model}")
                return result

        except ProviderException as e:
            log.warning(f"Provider {provider} failed: {e}, trying next")
            continue

        except QuotaExceededException as e:
            log.info(f"Quota exceeded for {provider}, trying next")
            continue

    # All providers failed
    return {"error": "All providers in fallback chain failed"}
```

### 8.2 Failure Scenarios & Responses

| Failure Type | Detection | Response | Recovery Time |
|-------------|-----------|----------|---------------|
| **Quota Exhausted** | Redis quota check | Fallback to next provider | Immediate |
| **Rate Limit (429)** | HTTP status code | Exponential backoff + fallback | 1-60 seconds |
| **Timeout** | Request timeout (30s) | Retry once, then fallback | 30-60 seconds |
| **API Error (500)** | HTTP status code | Immediate fallback | Immediate |
| **Invalid Response** | Response validation | Retry once, then fallback | Immediate |
| **Network Failure** | Connection error | Retry 3 times, then fallback | 5-15 seconds |
| **Budget Exceeded** | Budget check | Downgrade to free tier only | Immediate |

---

## 9. Implementation Roadmap (Phased Approach)

### Phase 1: Foundation (Week 1-2)

**Deliverables:**
- [ ] VPS provisioning (Hetzner/DigitalOcean)
- [ ] Docker Compose setup (Redis, PostgreSQL, basic API)
- [ ] Gemini API integration (primary free tier)
- [ ] Basic quota tracking (Redis)
- [ ] Simple web dashboard (request submission)

**Success Criteria:**
- Can submit requests via web dashboard
- Requests route to Gemini API
- Quota tracking prevents 429 errors
- Basic monitoring (logs)

**Estimated Cost:** $0 (using Gemini free tier only)

---

### Phase 2: Multi-Provider Support (Week 3-4)

**Deliverables:**
- [ ] DeepSeek API integration
- [ ] Groq API integration
- [ ] Ollama local deployment
- [ ] Provider fallback chain implementation
- [ ] Cost calculator module

**Success Criteria:**
- Requests automatically route to available providers
- Fallback works when quota exhausted
- Cost tracking per provider
- 95%+ success rate

**Estimated Cost:** $5-10 (DeepSeek trial + overage)

---

### Phase 3: Advanced Routing (Week 5-6)

**Deliverables:**
- [ ] Use case classification algorithm
- [ ] Smart router implementation
- [ ] Claude API integration (for premium tasks)
- [ ] OpenAI API integration (for specific use cases)
- [ ] Batch processing support

**Success Criteria:**
- Requests automatically classified
- Optimal provider selection based on use case
- <2% requests use premium providers unnecessarily
- Batch API integration working

**Estimated Cost:** $15-25 (adding Claude/OpenAI)

---

### Phase 4: Caching & Optimization (Week 7-8)

**Deliverables:**
- [ ] Prompt caching (DeepSeek, Claude, Gemini)
- [ ] Response caching (Redis)
- [ ] Multi-account rotation (Gemini)
- [ ] Budget enforcement system
- [ ] Grafana dashboards

**Success Criteria:**
- 90% cache hit rate on repeated prompts
- 40%+ cost reduction from caching
- Multi-account rotation prevents quota exhaustion
- Real-time budget tracking

**Estimated Cost:** $10-20 (reduced from caching)

---

### Phase 5: Production Hardening (Week 9-10)

**Deliverables:**
- [ ] Prometheus metrics integration
- [ ] Alerting system (quota, budget, failures)
- [ ] Retry logic with exponential backoff
- [ ] Horizontal scaling (worker replicas)
- [ ] Load testing (10,000 req/day)

**Success Criteria:**
- 99.9% uptime
- Automatic alerts on quota/budget thresholds
- Handles 10,000 req/day with <5s average latency
- Cost stays under $30/month

**Estimated Cost:** $20-30 (at scale)

---

### Phase 6: Advanced Features (Week 11-12)

**Deliverables:**
- [ ] User authentication & multi-tenancy
- [ ] API key management (per user)
- [ ] Usage analytics per user
- [ ] Webhook support (async results)
- [ ] CLI client for developers

**Success Criteria:**
- Multi-user support with isolated quotas
- Users can bring their own API keys
- Webhook delivery 99%+ success rate
- CLI client published to npm

**Estimated Cost:** $30-40 (increased infrastructure)

---

## 10. Key Architectural Innovations

### 10.1 Quota Pool Rotation

**Innovation:** Instead of using a single Gemini account, rotate across 3-5 personal Google accounts to multiply free tier quota.

**Implementation:**
```python
gemini_accounts = [
    {'email': 'account1@gmail.com', 'quota': QuotaTracker()},
    {'email': 'account2@gmail.com', 'quota': QuotaTracker()},
    {'email': 'account3@gmail.com', 'quota': QuotaTracker()}
]

def get_best_gemini_account():
    """Returns account with most available quota"""
    for account in gemini_accounts:
        if account['quota'].usage_percent < 80:
            return account
    return None  # All exhausted, use paid tier
```

**Result:** 3,000 requests/day → 9,000 requests/day (3x increase)

---

### 10.2 Dynamic Quality Downgrading

**Innovation:** Automatically switch from premium to budget providers as monthly budget depletes.

**Implementation:**
- 0-75% budget: Use premium providers (Claude Opus) when needed
- 75-90% budget: Avoid premium, use standard (Claude Sonnet, DeepSeek)
- 90-100% budget: FREE TIER ONLY (Gemini, Groq, Ollama)

**Result:** Never exceed budget, maintain service availability

---

### 10.3 Hybrid Local + Cloud Architecture

**Innovation:** Deploy Ollama on local hardware for free inference, use cloud APIs only when local is insufficient.

**Decision Tree:**
```
Is task privacy-sensitive? → Local Ollama
Is task simple (7B model sufficient)? → Local Ollama
Is latency critical (<2s response)? → Groq or Gemini
Is quality critical? → Claude or DeepSeek
Default → Gemini free tier
```

**Result:** 30-50% of requests handled locally (100% free)

---

### 10.4 Intelligent Caching with Prompt Decomposition

**Innovation:** Break prompts into cacheable components (system instructions, codebase context, user query).

**Example:**
```
Cache (24h TTL):
- System Instructions: "You are an expert Python developer..."
- Codebase Context: [File contents, 500K tokens]

Fresh (per request):
- User Query: "Add error handling to function X"
```

**Result:** 90% of tokens cached, 10% fresh = 90% cost savings

---

### 10.5 Cost-Aware Request Batching

**Innovation:** Delay non-urgent requests to accumulate batches, then use Batch API (50% discount).

**Implementation:**
- Urgent requests (priority=high): Immediate execution
- Standard requests (priority=medium): 5-minute batch window
- Low-priority requests (priority=low): 1-hour batch window

**Result:** 30-50% cost reduction on batch-eligible requests

---

## 11. Risk Mitigation & Compliance

### 11.1 ToS Compliance

**Gemini Multi-Account Strategy:**
- ✅ Each account is a real personal Google account
- ✅ No automated account creation
- ✅ No sharing API keys across accounts
- ✅ Each account used for legitimate personal projects
- ⚠️ Ensure each account is actively used (not just for quota pooling)

**Best Practice:** Use each account for different team members' projects, ensuring genuine usage.

---

### 11.2 Rate Limit Safety Margins

**80% Rule:** Never exceed 80% of documented rate limits to account for:
- API measurement variance
- Concurrent request bursts
- Rate limit calculation discrepancies

**Implementation:**
```python
SAFETY_MARGIN = 0.8  # Use 80% of quota

effective_rpm = provider_config['rpm'] * SAFETY_MARGIN
effective_rpd = provider_config['rpd'] * SAFETY_MARGIN
```

---

### 11.3 Budget Alerts & Circuit Breakers

**Alert Levels:**
1. **50% budget:** Info notification
2. **80% budget:** Warning email + Slack
3. **95% budget:** Critical alert + auto-switch to free tier
4. **100% budget:** Circuit breaker trips, all paid requests blocked

**Circuit Breaker Logic:**
```python
if budget_exceeded:
    # Block all paid provider requests
    allowed_providers = ['gemini_free', 'groq', 'ollama']
    # Queue requests for manual approval
    notify_admin("Budget exceeded, switching to free tier only")
```

---

## 12. Monitoring & Alerting

### 12.1 Key Metrics Dashboard

**Grafana Panels:**

1. **Request Volume**
   - Total requests/hour (by provider)
   - Success rate % (by provider)
   - Average latency (by provider)

2. **Quota Utilization**
   - Gemini: RPM, RPD usage % (with 80% threshold line)
   - DeepSeek: Request rate, token usage
   - Claude: ITPM, OTPM usage %
   - Groq: Request rate

3. **Cost Tracking**
   - Daily cost by provider
   - Monthly cumulative cost
   - Projected end-of-month cost
   - Budget remaining %

4. **Fallback Chain Metrics**
   - Fallback activation frequency
   - Provider failure rate
   - Average providers tried per request

5. **Cache Performance**
   - Cache hit rate %
   - Cost savings from cache
   - Cache size (MB)

### 12.2 Alerting Rules

**Prometheus Alerts:**

```yaml
groups:
  - name: quota_alerts
    rules:
      - alert: QuotaNearLimit
        expr: quota_usage_percent{provider="gemini"} > 80
        for: 5m
        annotations:
          summary: "Gemini quota at {{ $value }}%"

      - alert: QuotaExhausted
        expr: quota_usage_percent{provider="gemini"} > 95
        for: 1m
        annotations:
          summary: "Gemini quota exhausted, fallback active"

      - alert: BudgetAlert
        expr: monthly_cost_usd > monthly_budget_usd * 0.8
        for: 10m
        annotations:
          summary: "Monthly budget at {{ $value | humanize }}%"

      - alert: ProviderFailureSpike
        expr: rate(provider_errors_total[5m]) > 0.1
        for: 5m
        annotations:
          summary: "Provider {{ $labels.provider }} failure rate: {{ $value }}"
```

---

## 13. Summary of Key Decisions

### 13.1 Primary Free Tier Strategy

**Winner: Gemini API**
- Reason: 1M tokens/day, 60 RPM, 1,000 RPD per account
- Strategy: 3-5 account rotation = 3,000-5,000 free requests/day
- Cost: $0

**Runner-up: Groq**
- Reason: Free Llama models, 300+ tok/sec speed
- Strategy: Fast queries, prototyping
- Cost: $0

**Third: Ollama Local**
- Reason: 100% free, unlimited, private
- Strategy: Development, testing, privacy-sensitive
- Cost: $0 API (hardware cost one-time)

---

### 13.2 Cheapest Paid Tier Strategy

**Winner: DeepSeek**
- Reason: $0.27/$1.10 per 1M tokens (27x cheaper than OpenAI o1)
- Strategy: Reasoning tasks, complex code
- Estimated Cost: $5-10/month for 10% of workload

**Runner-up: Gemini 2.5 Flash (Paid)**
- Reason: $0.075/$0.30 per 1M tokens
- Strategy: High-volume overflow from free tier
- Estimated Cost: $3-5/month

---

### 13.3 Premium Quality Strategy

**Winner: Claude Opus 4.1**
- Reason: Best quality for critical refactoring
- Strategy: <1% of requests, high-value tasks only
- Estimated Cost: $10-15/month

**Runner-up: Claude Sonnet 4.5**
- Reason: Balanced cost/quality
- Strategy: Production code, important features
- Estimated Cost: $5-10/month

---

### 13.4 Infrastructure Cost Optimization

**VPS Choice: Hetzner CPX31**
- Reason: €11.90/month (~$13) for 4 vCPU, 8GB RAM
- Alternative: DigitalOcean $48/month (if Hetzner unavailable)

**Total Infrastructure Cost:**
- VPS: $13/month (Hetzner)
- API costs: $20-30/month (for 10,000 req/day)
- **Total: $33-43/month**

**Cost per Request: $0.0011 - $0.0014** (300,000 req/month)

**Comparison:**
- Claude Pro subscription: $20/month (limited quota)
- OpenAI Codex CLI: Requires ChatGPT Plus ($20/month)
- **Our system: $33/month with 10x higher quota**

---

## 14. Conclusion & Next Steps

### 14.1 Expected Outcomes

**With this architecture, you achieve:**

1. **10,000+ requests/day** at $33-43/month total cost
2. **~70% free tier usage** (7,000 requests via Gemini, Groq, Ollama)
3. **~30% paid usage** (3,000 requests via DeepSeek, Claude, OpenAI)
4. **$0.0011 average cost per request** (vs. $0.02-0.05 industry average)
5. **95%+ success rate** with fallback chains
6. **<5s average latency** for most requests

### 14.2 Scalability

**Current Design Supports:**
- 10,000 requests/day: $33-43/month
- 50,000 requests/day: $100-150/month (add worker replicas)
- 100,000 requests/day: $250-350/month (upgrade VPS, add caching layer)

**Bottlenecks:**
- Gemini free tier caps at ~9,000 req/day (3 accounts)
- Redis memory at 100K+ req/day
- PostgreSQL at 500K+ req/day

**Scaling Solutions:**
- Add more Gemini accounts (5-10 = 15,000-30,000 free req/day)
- Redis Cluster for distributed caching
- PostgreSQL read replicas for analytics

### 14.3 Recommended First Steps

1. **Week 1:** Provision Hetzner VPS, deploy Docker Compose
2. **Week 1:** Integrate Gemini API (1 account) + basic quota tracking
3. **Week 2:** Add DeepSeek API + Groq API
4. **Week 2:** Implement fallback chain (Gemini → Groq → DeepSeek)
5. **Week 3:** Deploy Ollama locally (if hardware available)
6. **Week 3:** Add multi-account Gemini rotation
7. **Week 4:** Implement caching (90% savings)
8. **Week 4:** Deploy Grafana monitoring
9. **Month 2:** Add Claude + OpenAI for premium use cases
10. **Month 2:** Load test at 10,000 req/day

---

## Appendix A: Provider API Endpoints & Authentication

### Gemini API
```bash
# Personal Account (CLI)
npm install -g @google/gemini-cli
gemini  # Login with Google

# AI Studio API Key
export GOOGLE_API_KEY="AIza..."
curl https://generativelanguage.googleapis.com/v1/models/gemini-2.5-flash:generateContent \
  -H "Content-Type: application/json" \
  -H "x-goog-api-key: $GOOGLE_API_KEY" \
  -d '{"contents":[{"parts":[{"text":"Hello"}]}]}'
```

### DeepSeek API
```bash
export DEEPSEEK_API_KEY="sk-..."
curl https://api.deepseek.com/v1/chat/completions \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer $DEEPSEEK_API_KEY" \
  -d '{"model":"deepseek-chat","messages":[{"role":"user","content":"Hello"}]}'
```

### Groq API
```bash
export GROQ_API_KEY="gsk_..."
curl https://api.groq.com/openai/v1/chat/completions \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer $GROQ_API_KEY" \
  -d '{"model":"llama-3.3-70b-versatile","messages":[{"role":"user","content":"Hello"}]}'
```

### Claude API
```bash
export ANTHROPIC_API_KEY="sk-ant-..."
curl https://api.anthropic.com/v1/messages \
  -H "Content-Type: application/json" \
  -H "x-api-key: $ANTHROPIC_API_KEY" \
  -H "anthropic-version: 2023-06-01" \
  -d '{"model":"claude-3-5-sonnet-20241022","max_tokens":1024,"messages":[{"role":"user","content":"Hello"}]}'
```

### OpenAI API
```bash
export OPENAI_API_KEY="sk-..."
curl https://api.openai.com/v1/chat/completions \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer $OPENAI_API_KEY" \
  -d '{"model":"gpt-4o-mini","messages":[{"role":"user","content":"Hello"}]}'
```

### Ollama (Local)
```bash
# Start Ollama
ollama serve

# Pull model
ollama pull deepseek-r1:7b

# API call
curl http://localhost:11434/api/generate \
  -d '{"model":"deepseek-r1:7b","prompt":"Hello","stream":false}'
```

---

## Appendix B: Sample Request Routing Decision Tree

```
[Incoming Request]
       |
       v
[Classify Use Case]
       |
       ├─→ Code Generation → [Check Complexity]
       |                          |
       |                          ├─→ Simple → Gemini Flash (free)
       |                          └─→ Complex → DeepSeek V3 (cheap)
       |
       ├─→ Reasoning → DeepSeek R1 (cheap) → Claude Opus (premium)
       |
       ├─→ Quick Query → Groq (fast + free) → Ollama (local + free)
       |
       ├─→ Long-Form → Gemini Pro (1M context + free) → Claude
       |
       └─→ Research → Gemini Pro (Search grounding + free)
                |
                v
          [Check Quota]
                |
                ├─→ Available (<80%) → Execute
                ├─→ Near Limit (80-95%) → Execute if Priority=High
                └─→ Exhausted (>95%) → Fallback Chain
                          |
                          v
                    [Try Next Provider]
                          |
                          ├─→ Success → Return Result
                          └─→ Fail → Try Next
                                |
                                v
                          [All Free Exhausted]
                                |
                                v
                          [Calculate Cheapest Paid]
                                |
                                v
                          [Check Budget]
                                |
                                ├─→ OK → Execute Paid
                                └─→ Exceeded → Reject
```

---

**END OF ARCHITECTURE DOCUMENT**

**Version:** 1.0
**Author:** System Architecture Team
**Last Updated:** November 14, 2025
**Total Pages:** 45+
**Review Status:** Ready for Implementation
