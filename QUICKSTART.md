# 🚀 AI CLI ORCHESTRATOR - QUICKSTART GUIDE

**Get started in 5 minutes with FREE AI command-line tools!**

---

## 📋 What You'll Get

After following this guide, you'll have:

✅ **5+ AI CLIs installed** (Gemini, Aider, Shell-GPT, AIChat, mods, Ollama)
✅ **$0/month operation** using free tiers (or $10-40/month for premium)
✅ **10,000+ requests/day capacity**
✅ **Simple `ai` command** that auto-routes to best provider
✅ **Example scripts** to get started immediately

---

## 🎯 30-Second Installation (Automated)

### macOS / Linux / WSL

```bash
curl -fsSL https://raw.githubusercontent.com/YubenTT/edmunds-claude-code/main/install.sh | bash
```

Or clone and run locally:

```bash
git clone https://github.com/YubenTT/edmunds-claude-code.git
cd edmunds-claude-code
chmod +x install.sh
./install.sh
```

### What the installer does:

1. ✅ Installs Node.js, Python, Git (if needed)
2. ✅ Installs 6+ AI CLIs (Gemini, Aider, Shell-GPT, AIChat, mods, Ollama)
3. ✅ Runs interactive API key wizard
4. ✅ Creates `ai` command wrapper
5. ✅ Adds to your PATH
6. ✅ Creates example scripts

**Total time:** ~5-10 minutes (depending on your internet speed)

---

## 🔑 Get FREE API Keys (Pick At Least One)

### 🏆 Google Gemini (HIGHLY RECOMMENDED - BEST FREE TIER)

**Free tier:** 1 MILLION tokens/day (~$200/month value)
**Duration:** Indefinite (free forever)

1. Go to: https://aistudio.google.com/app/apikey
2. Sign in with Google account
3. Click "Create API Key"
4. Copy the key

**Why start here:** Largest free tier, great quality, no credit card needed!

---

### ⚡ Groq (FASTEST - FREE FOREVER)

**Free tier:** 14,400 requests/day, 300+ tokens/second
**Duration:** Indefinite

1. Go to: https://console.groq.com/keys
2. Sign up (free, no credit card)
3. Create API key
4. Copy the key

**Why this:** Fastest inference in the industry, completely free!

---

### 🤖 OpenAI (Optional - $5 Trial)

**Free tier:** $5 credits (expires in 3 months)
**Models:** GPT-4o, GPT-4o-mini, o1

1. Go to: https://platform.openai.com/api-keys
2. Sign up
3. Create API key
4. Get $5 free credits

---

### 🧠 Anthropic Claude (Optional - $5 Trial)

**Free tier:** $5 credits (one-time)
**Models:** Claude Sonnet 4.5, Haiku 4.5, Opus 4.1

1. Go to: https://console.anthropic.com/settings/keys
2. Sign up (requires US phone verification)
3. Create API key
4. Get $5 free credits

---

### 💰 DeepSeek (Optional - Cheapest After Trial)

**Free tier:** 1M tokens + $1 credit trial
**Pricing:** $0.27/$1.10 per 1M tokens (27x cheaper than OpenAI o1)

1. Go to: https://platform.deepseek.com/api_keys
2. Sign up
3. Create API key
4. Get 1M free tokens

---

## 💻 First Commands

After installation, reload your shell:

```bash
source ~/.bashrc  # or ~/.zshrc
```

### Test Your Setup

```bash
# Check installation status
ai-status

# Output example:
# Configured Providers:
#   ✓ Google Gemini (1M tokens/day FREE)
#   ✓ Groq (FREE forever)
#   ✓ Ollama (local)
```

### Your First AI Command

```bash
ai "What is recursion in programming?"
```

That's it! The `ai` command will:
1. Check which providers you have configured
2. Route to the best available option (Gemini → Groq → Ollama)
3. Return the AI response

---

## 🎨 Usage Examples

### 1. General Chat

```bash
ai "Explain quantum computing in simple terms"
ai chat "What are the benefits of TypeScript?"
```

### 2. Code Generation

```bash
ai code "Create a REST API in Express.js with user authentication"
ai code "Write a Python script to analyze CSV files"
```

### 3. Shell Commands

```bash
ai shell "Find all files larger than 100MB"
ai shell "How to recursively delete node_modules folders?"
```

### 4. Local & Private (No API calls)

```bash
ai local "Explain this sensitive data without sending to cloud"
```

### 5. Specific Providers

```bash
# Use Gemini directly (FREE 1M tokens/day)
gemini "Your prompt here"

# Use Aider for coding (best for serious projects)
aider --message "Add authentication to my Express app"

# Use AIChat with specific model
aichat -m groq:llama-3.3-70b "Fast inference question"

# Use Ollama locally (100% free, private)
ollama run llama3.2:3b "Local processing question"
```

---

## 📚 Example Scripts

The installer creates ready-to-run examples in `~/.ai-cli-orchestrator/examples/`:

```bash
# List examples
ls ~/.ai-cli-orchestrator/examples/

# Run them:
~/.ai-cli-orchestrator/examples/01-simple-chat.sh
~/.ai-cli-orchestrator/examples/02-code-generation.sh
~/.ai-cli-orchestrator/examples/03-shell-commands.sh
~/.ai-cli-orchestrator/examples/04-provider-rotation.sh
~/.ai-cli-orchestrator/examples/05-batch-processing.sh
```

---

## 🛠️ Configuration

### Add/Update API Keys

```bash
# Re-run the configuration wizard
ai-setup

# Or manually edit:
nano ~/.ai-cli-orchestrator/.env
```

### View Current Config

```bash
cat ~/.ai-cli-orchestrator/.env
```

### Check Quota Usage

```bash
# View system status
ai-status

# Check logs
cat ~/.ai-cli-orchestrator/logs/quota.log
```

---

## 🎯 Cost Optimization Strategies

### Strategy 1: Pure Free ($0/month)

**Use:** Gemini + Groq + Ollama

```bash
# Gemini handles most requests (1M tokens/day free)
ai "Your general questions"

# Groq for speed-critical tasks (14.4K req/day free)
aichat -m groq:llama-3.3-70b "Fast question"

# Ollama for private/unlimited local
ollama run llama3.2:3b "Private question"
```

**Expected capacity:** 10,000+ requests/day at $0 cost

---

### Strategy 2: Budget Power User ($20-30/month)

**Use:** Gemini (free) + DeepSeek (paid) + Aider

```bash
# Gemini for most tasks (free)
ai "Regular questions"

# DeepSeek for reasoning (27x cheaper than OpenAI o1)
aichat -m deepseek:deepseek-r1 "Complex reasoning task"

# Aider for serious coding
aider --message "Implement OAuth2 authentication"
```

**Expected capacity:** 50,000+ requests/day at $20-30/month

---

### Strategy 3: Premium Quality ($30-50/month)

**Use:** Gemini (free) + Claude Code Pro

```bash
# Gemini for general use (free)
ai "Regular questions"

# Claude for premium coding (subscription)
aider --model claude-sonnet-4.5 "Complex refactoring"
```

**Expected capacity:** Best quality coding at $30-50/month

---

## 🔧 Advanced Usage

### Provider Rotation (Automatic Fallback)

The `ai` command automatically tries providers in order:

```
1. Gemini (if API key configured) → FREE 1M tokens/day
2. Groq (if API key configured) → FREE 14.4K req/day
3. Ollama (if installed) → FREE unlimited local
4. DeepSeek (if API key) → Paid ($0.27/$1.10 per 1M)
5. OpenAI/Claude → Paid (last resort)
```

### Manual Provider Selection

```bash
# Force use of Gemini
PROVIDER=gemini ai "Your prompt"

# Force local Ollama
PROVIDER=ollama ai "Your prompt"

# Use specific AIChat model
aichat -m groq:llama-3.3-70b "Prompt"
aichat -m openai:gpt-4o "Prompt"
aichat -m deepseek:deepseek-r1 "Prompt"
```

### Batch Processing

```bash
# Process multiple prompts with rate limiting
cat prompts.txt | while read prompt; do
    ai "$prompt"
    sleep 2  # Respect rate limits
done
```

### Pipe Integration

```bash
# Summarize file contents
cat long-document.txt | ai "Summarize this document"

# Generate commit messages
git diff | ai "Generate a commit message for these changes"

# Code review
cat my-script.py | ai "Review this code for bugs and improvements"
```

---

## 🐳 Docker Alternative (Optional)

If you prefer containerized installation:

```bash
# Build Docker image
docker build -t ai-cli-orchestrator .

# Run interactively
docker run -it --env-file .env ai-cli-orchestrator ai "Your prompt"

# Or use docker-compose
docker-compose up -d
docker-compose exec ai ai "Your prompt"
```

See `docker-compose.yml` for full configuration.

---

## 📊 Expected Performance

### With FREE Tier Only ($0/month):

| Metric | Capacity |
|--------|----------|
| **Daily Requests** | 10,000+ |
| **Daily Tokens** | 1M+ (Gemini) |
| **Speed** | 300+ tok/sec (Groq) |
| **Local** | Unlimited (Ollama) |
| **Monthly Cost** | $0 |

### With Hybrid Setup ($20-30/month):

| Metric | Capacity |
|--------|----------|
| **Daily Requests** | 50,000+ |
| **Cost per Request** | $0.001-0.002 |
| **Free Coverage** | 60-70% |
| **Monthly Cost** | $20-30 |

---

## 🆘 Troubleshooting

### Command not found

```bash
# Reload shell
source ~/.bashrc  # or ~/.zshrc

# Or manually add to PATH
export PATH="$HOME/.ai-cli-orchestrator/bin:$PATH"
```

### API key errors

```bash
# Verify configuration
cat ~/.ai-cli-orchestrator/.env

# Re-run setup wizard
ai-setup
```

### Provider unavailable

```bash
# Check status
ai-status

# Try different provider
aichat -m groq:llama-3.3-70b "Your prompt"  # Try Groq
ollama run llama3.2:3b "Your prompt"        # Try local
```

### Update tools

```bash
# Update all AI CLIs
ai-update
```

### Rate limit errors

```bash
# Use different provider
PROVIDER=groq ai "Your prompt"

# Or use local
PROVIDER=ollama ai "Your prompt"

# Add delay between requests
for i in {1..10}; do
    ai "Prompt $i"
    sleep 3
done
```

---

## 📖 Learn More

### Full Documentation

- **Master Research Report:** `AI_CLI_MASTER_RESEARCH_REPORT.md`
- **System Architecture:** `SYSTEM_ARCHITECTURE_MAX_FREE_TIER.md`
- **Quota Matrix:** `FREE_TIER_QUOTA_MATRIX.md`
- **CLI Rankings:** `CLI_RANKING_SYSTEM.md`

### Provider-Specific Guides

- Claude: `CLAUDE_CLI_COMPREHENSIVE_RESEARCH_REPORT.md`
- OpenAI: `openai-cli-research-report.md`
- Gemini: `gemini-cli-research-report.md`
- DeepSeek: `deepseek-cli-research-report.md`
- Grok: `grok-xai-cli-research-report.md`

### Configuration

- Machine-readable: `quota-config.yaml`
- Environment: `~/.ai-cli-orchestrator/.env`

---

## 🎯 Quick Reference Card

```bash
# Basic usage
ai "prompt"                    # Auto-route to best provider
ai code "coding task"          # Use coding-optimized AI
ai shell "shell command"       # Get shell command help
ai chat "question"             # General conversation
ai local "private prompt"      # 100% local, no API

# System commands
ai-status                      # Show configured providers
ai-setup                       # Re-run configuration wizard
ai-update                      # Update all CLI tools

# Direct provider access
gemini "prompt"                # Google Gemini (FREE 1M tokens/day)
aider --message "code"         # Aider (best for coding)
sgpt "shell help"              # Shell-GPT (command generation)
aichat "prompt"                # AIChat (multi-provider)
mods "prompt"                  # mods (UNIX pipelines)
ollama run llama3.2:3b "p"     # Ollama (local, unlimited)

# Provider-specific models
aichat -m groq:llama-3.3-70b "prompt"      # Groq (fast, free)
aichat -m deepseek:deepseek-r1 "prompt"    # DeepSeek (cheap reasoning)
aichat -m openai:gpt-4o-mini "prompt"      # OpenAI (cheap)
aichat -m claude:sonnet-4.5 "prompt"       # Claude (quality)
```

---

## 💡 Pro Tips

### 1. Start with Gemini

Gemini offers the best free tier (1M tokens/day = ~$200/month value). Use it as your primary provider.

```bash
# Set Gemini as default
export AI_DEFAULT_PROVIDER=gemini
```

### 2. Use Ollama for Privacy

For sensitive data, use local Ollama (100% private, no API calls):

```bash
ai local "Process this confidential data..."
```

### 3. Cache Common Prompts

Create shell aliases for frequently used prompts:

```bash
# Add to ~/.bashrc or ~/.zshrc
alias explain='ai "Explain in simple terms:"'
alias review='ai code "Review this code:"'
alias commit='git diff | ai "Generate commit message:"'
```

Usage:
```bash
explain "quantum computing"
cat my-code.py | review
commit
```

### 4. Batch with Rate Limiting

When processing many requests, respect rate limits:

```bash
# Safe batch processing (stays under Gemini's 60 RPM)
for file in *.txt; do
    ai "Summarize: $(cat $file)"
    sleep 2  # 30 requests/minute = safe margin
done
```

### 5. Monitor Your Usage

Track quota consumption:

```bash
# Check daily usage
grep "$(date +%Y-%m-%d)" ~/.ai-cli-orchestrator/logs/quota.log | wc -l
```

---

## 🚀 Next Steps

1. **Install the system** (5 minutes)
   ```bash
   curl -fsSL https://raw.githubusercontent.com/YubenTT/edmunds-claude-code/main/install.sh | bash
   ```

2. **Get FREE Gemini API key** (2 minutes)
   - Visit: https://aistudio.google.com/app/apikey
   - Create key, add to config

3. **Try first command** (30 seconds)
   ```bash
   ai "What is recursion?"
   ```

4. **Explore examples** (10 minutes)
   ```bash
   ls ~/.ai-cli-orchestrator/examples/
   ```

5. **Read full documentation** (30 minutes)
   ```bash
   cat AI_CLI_MASTER_RESEARCH_REPORT.md
   ```

---

## 📞 Support & Community

- **GitHub Issues:** https://github.com/YubenTT/edmunds-claude-code/issues
- **Documentation:** See repository root
- **Updates:** Run `ai-update` regularly

---

## 🏆 Success Stories

**Expected results after setup:**

✅ **Instant AI access** from terminal
✅ **$0/month operation** with free tiers
✅ **10,000+ requests/day** capacity
✅ **5 providers** at your fingertips
✅ **Automatic fallback** when quotas hit
✅ **Privacy-first option** with Ollama

**Start now and join users exploiting free tiers maximally!** 🚀

---

**Installation time:** 5-10 minutes
**Cost:** $0/month (or $10-40 for premium)
**Difficulty:** Beginner-friendly
**Maintenance:** Minimal (run `ai-update` monthly)
