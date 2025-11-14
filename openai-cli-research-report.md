# Comprehensive OpenAI CLI Research Report
**Research Date:** November 14, 2025
**Focus:** Command-line interfaces for OpenAI API access

---

## Table of Contents
1. [OpenAI API Pricing & Free Tier Details](#openai-api-pricing--free-tier-details)
2. [Official OpenAI CLIs](#official-openai-clis)
3. [Community OpenAI CLIs](#community-openai-clis)
4. [Multi-LLM CLIs with OpenAI Support](#multi-llm-clis-with-openai-support)
5. [Summary Comparison Table](#summary-comparison-table)

---

## OpenAI API Pricing & Free Tier Details

### Free Trial Credits
**[CONFIRMED]** OpenAI offers **$5 in free credits** to all new users when they sign up for API access.
- **Expiration:** 3 months from account creation
- **Limitation:** One-time introductory offer (only for first account associated with your phone number)
- **Sources:**
  - https://blog.laozhang.ai/ai/chatgpt-plus-free-trial-guide-2025/
  - https://www.byteplus.com/en/topic/538002

**Important Note:** As of late 2024/early 2025, the automatic granting of these credits has become less consistent, with some users needing to add a payment method to begin using the API.

### Free Tier Rate Limits
**[CONFIRMED]** The free tier has the following restrictions:

| Metric | Limit | Per Unit |
|--------|-------|----------|
| **Requests** | 3 | per minute (RPM) |
| **Requests** | 200 | per day (RPD) |
| **Maximum Credit** | $100 | total |

**Model Access (Free Tier):**
- Limited access to GPT-3.5 Turbo (older model)
- Very restrictive for practical use

**Sources:**
- https://www.scriptbyai.com/rate-limits-openai-api/
- https://community.openai.com/t/new-account-free-tier-and-rpm-limits/927156

### OpenAI Usage Tiers & Rate Limits

OpenAI automatically adjusts rate limits based on spending and usage history:

#### **Tier 1** - Entry Level Paid
**[CONFIRMED]** Qualification: $5 paid
**[CONFIRMED]** Monthly usage limit: $100/month

**Model-Specific Rate Limits:**
| Model | RPM | RPD | TPM |
|-------|-----|-----|-----|
| GPT-3.5 Turbo | 3,500 | 10,000 | 60,000 |
| GPT-4 | 500 | - | 10,000 |
| GPT-4o Mini | 500 | - | 200,000 |
| GPT-4o | 500 | - | 30,000 |

**Sources:**
- https://muneebdev.com/openai-api-rate-limits-guide/
- https://www.scriptbyai.com/rate-limits-openai-api/

#### **Tier 2** - Intermediate
**[CONFIRMED]** Qualification: $50 paid + 7 days since first successful payment
**[CONFIRMED]** Monthly usage limit: $500/month

**Sources:**
- https://community.openai.com/t/what-do-usage-limits-look-like-per-tier/1248506

#### **Tier 3** - Advanced
**[CONFIRMED]** Qualification: $100 spent + 14 days since first successful payment
**[DERIVED]** Monthly usage limit: Estimated $1,000-$2,500/month

#### **Tier 4** - Professional
**[CONFIRMED]** Qualification: $250 spent + 14 days since first successful payment
**[DERIVED]** Monthly usage limit: Estimated $5,000/month

#### **Tier 5** - Enterprise
**[CONFIRMED]** Qualification: $1,000 spent + 30 days since first successful payment
**[CONFIRMED]** Monthly usage limit: $10,000/month

**Sources:**
- https://medium.com/prompt-engineering/understanding-openai-rate-limits-and-available-tiers-10caeb79d120

### Model Pricing (Per Million Tokens)

#### **GPT-4o** (Latest Flagship Model)
**[CONFIRMED]**
- **Input:** $2.50 / 1M tokens
- **Output:** $10.00 / 1M tokens
- **Context Window:** 128K tokens
- **Performance:** Superior to GPT-4 Turbo at 75% lower price

**Sources:**
- https://blog.laozhang.ai/ai/openai-gpt-4o-api-pricing-guide/
- https://www.ptolemay.com/post/how-much-does-chatgpt-integration-cost-and-pay-off

#### **GPT-4o Mini** (Most Cost-Efficient)
**[CONFIRMED]**
- **Input:** $0.15 / 1M tokens
- **Output:** $0.60 / 1M tokens
- **Context Window:** 128K tokens
- **Performance:** 60%+ cheaper than GPT-3.5 Turbo with better capabilities

**Sources:**
- https://openai.com/index/gpt-4o-mini-advancing-cost-efficient-intelligence/

#### **GPT-4 Turbo** (Legacy)
**[CONFIRMED]**
- **Input:** $10.00 / 1M tokens
- **Output:** $30.00 / 1M tokens
- **Note:** Still available for legacy applications, but GPT-4o is recommended

**Sources:**
- https://artificialanalysis.ai/models/gpt-4-turbo

#### **GPT-3.5 Turbo** (Budget Option)
**[CONFIRMED]**
- **Input:** $0.50 / 1M tokens
- **Output:** $1.50 / 1M tokens
- **Note:** Older model with limited capabilities

**Sources:**
- https://openai.com/api/pricing/

#### **o1-preview** (Advanced Reasoning)
**[CONFIRMED]**
- **Input:** $15.00 / 1M tokens
- **Output:** $60.00 / 1M tokens
- **Use Case:** Complex multi-step tasks, STEM problems

**Sources:**
- https://medium.com/towards-agi/openai-o1-api-pricing-explained-everything-you-need-to-know-cbab89e5200d

#### **o1-mini** (Reasoning - Cost Efficient)
**[CONFIRMED]**
- **Input:** $1.10 / 1M tokens (approximation from source: $1.10)
- **Output:** $4.40 / 1M tokens
- **Use Case:** Faster, cheaper reasoning tasks

**Sources:**
- https://artificialanalysis.ai/models/o1-mini

### Cost Estimates for $5 Free Trial Credit

**[DERIVED]** Based on model pricing:
- **GPT-4o-mini:** ~33,333 input tokens (~25,000 words) OR 8,333 output tokens
- **GPT-3.5 Turbo:** ~10,000 input tokens (~7,500 words) OR 3,333 output tokens
- **GPT-4o:** ~2,000 input tokens (~1,500 words) OR 500 output tokens
- **GPT-4 Turbo:** ~500 input tokens (~375 words) OR 166 output tokens

---

## Official OpenAI CLIs

### 1. OpenAI Codex CLI

**Status:** Official OpenAI Product
**Launch Date:** April 16, 2025
**Repository:** https://github.com/openai/codex
**Stars:** ~50.5k ⭐
**Forks:** ~6.3k

#### Basic Profile

**Description:** OpenAI's first official command-line tool - a lightweight, open-source coding agent that runs in your terminal.

**Maintainer:** OpenAI (Official)

**Last Update:** Actively maintained (as of November 2025)

**Supported Models:**
- GPT-5 Codex (o3 and o4-mini models fine-tuned for software engineering)
- Access to reasoning capabilities of o3 and o4-mini

**Platform Support:**
- ✅ macOS (Official)
- ✅ Linux (Official)
- ⚠️ Windows (Experimental - requires WSL)

**Installation Methods:**
```bash
# npm (Recommended)
npm install -g @openai/codex

# Homebrew
brew install codex

# Manual binary download from GitHub Releases
```

**Sources:**
- https://github.com/openai/codex
- https://developers.openai.com/codex/cli/
- https://www.kevinleary.net/blog/using-official-openai-chatgpt-cli/

#### Technical Capabilities

**Core Features:**
- 🤖 **Coding Agent:** Can read, modify, and run code on your local machine
- 🖼️ **Multimodal Input:** Supports text, screenshots, and diagrams
- 🔒 **Privacy-First:** All file operations happen locally; only prompts and diff summaries sent to API
- 🎛️ **Approval Modes:**
  - **Suggest:** Review before any action
  - **Auto Edit:** Automatic file edits, manual command execution
  - **Full Auto:** Complete automation
- 🔧 **MCP Support:** Model Context Protocol for third-party tools and context
- 📜 **Scriptable:** Automate workflows with the `exec` command
- 🦀 **Built in Rust:** Fast and efficient

**Architecture:** Open-source, Rust-based

**Sources:**
- https://developers.openai.com/codex/cli/reference/
- https://apidog.com/blog/openai-codex-cli/

#### Real-World Quality & User Sentiment

**What Users Love:**
- "Easy setup with only two commands once your OpenAI API key is ready" (source: getstream.io)
- Powerful multimodal input capabilities
- Privacy-focused local execution
- Official support from OpenAI

**Common Complaints:**
- **Performance:** Ranked 19th on Terminal Bench, performing worse than Claude Code and other competitors
- **UX Issues:** Community feedback on GitHub includes requests for:
  - Ability to resume previous sessions (described as "a very critical requirement")
  - Better control over thinking view (hide, snapshots, full process)
  - Pasting issues where multi-paragraph text only inserts first paragraph
  - MCP server management needs improvement
- **Windows Support:** Experimental, requires WSL

**Community Reception:**
- Hacker News discussion: Mixed reviews - praised for "translating conversational inputs into executable code" but noted as needing more development to compete with Claude Code
- Some called it "a big step" but suggested more work needed
- Open-source alternative "Open Codex" created by community for use with local LLMs

**GitHub Issues:**
- Issue #6280: Problems with version 0.55.0 working without user feedback indication
- Issue #2609: Multiple UX improvement recommendations
- Active issue tracking with OpenAI team responding and working on Rust rewrite

**Sources:**
- https://github.com/openai/codex/issues
- https://news.ycombinator.com/item?id=43708025
- https://getstream.io/blog/agentic-cli-tools/
- https://research.aimultiple.com/agentic-cli/

#### Pricing & Free Tier

**API Credits:**
- **ChatGPT Plus users:** $5 in API credits
- **ChatGPT Pro users:** $50 in API credits
- Standard API rates apply for usage beyond credits

**Cost Structure:** Pay-per-use based on OpenAI API pricing (see pricing section above)

**Sources:**
- https://www.codeant.ai/blogs/claude-code-cli-vs-codex-cli-vs-gemini-cli-best-ai-cli-tool-for-developers-in-2025

---

### 2. openai-python CLI

**Status:** Official OpenAI Library
**Repository:** https://github.com/openai/openai-python
**Package:** `openai` on PyPI

#### Basic Profile

**Description:** The official OpenAI Python library includes a basic CLI for direct API interaction.

**Maintainer:** OpenAI (Official)

**Last Update:** Actively maintained

**Supported Models:** All OpenAI models (GPT-4o, GPT-4, GPT-3.5 Turbo, o1, DALL-E, Whisper, etc.)

**Platform Support:**
- ✅ Linux
- ✅ macOS
- ✅ Windows

**Installation:**
```bash
pip install openai
# or
pip install --upgrade openai
```

**Sources:**
- https://github.com/openai/openai-python
- https://medium.com/internet-of-technology/how-to-operate-with-openai-command-line-client-b8174746f730

#### Technical Capabilities

**Core Features:**
- Direct API access through command line
- Python API client for programmatic calls
- Basic chat completions interface

**Example Usage:**
```bash
openai api chat.completions.create -g user "Your prompt here"
```

**Limitations:**
- Basic functionality compared to specialized CLIs
- Primarily designed as a Python library, CLI is secondary
- Less user-friendly for day-to-day terminal use

**Sources:**
- https://www.kevinleary.net/blog/using-official-openai-chatgpt-cli/

---

## Community OpenAI CLIs

### 3. Shell-GPT (sgpt)

**Status:** Community Project (Most Popular Pure OpenAI CLI)
**Repository:** https://github.com/TheR1D/shell_gpt
**Stars:** 11.5k ⭐
**Forks:** 929
**PyPI:** https://pypi.org/project/shell-gpt/

#### Basic Profile

**Description:** A command-line productivity tool powered by AI large language models like GPT-4, designed to help accomplish tasks faster and more efficiently.

**Maintainer:** TheR1D (Community Developer)

**Last Update:** Version 1.4.5 (Latest as of November 2025)

**Supported Models:**
- GPT-4o
- GPT-4
- GPT-3.5 Turbo
- GPT-4 Vision API (for image analysis)
- All LiteLLM supported models (via integration)
- Local models through Ollama

**Platform Support:**
- ✅ Linux
- ✅ macOS
- ✅ Windows (PowerShell, CMD)
- ✅ WSL
- Supports: Bash, Zsh, Fish, PowerShell, CMD

**Installation:**
```bash
# pip
pip install shell-gpt

# pipx (recommended)
pipx install shell-gpt
pipx upgrade shell-gpt
```

**Sources:**
- https://github.com/TheR1D/shell_gpt
- https://pypi.org/project/shell-gpt/

#### Technical Capabilities

**Core Features:**
- 🎯 **Command Generation & Execution:** Generate shell commands with `--shell` flag
- ⚡ **Direct Execution:** Use `--execute` with `--shell` to run commands immediately
- 💬 **Chat Functionality:** Interactive conversations with `--chat` flag and session management
- 🖼️ **Vision Support:** Analyze images with GPT-4 Vision API
- ⚡ **Local Caching:** Instant results for repeated queries
- 🔥 **Shell Integration:** Hotkey support for Bash and ZSH (puts completions in terminal buffer for editing)
- 🧠 **Memory:** REPL and chat modes for context retention
- 🌐 **Multi-Provider:** Support for OpenAI and local models (Ollama)

**Automation-Friendly:** Excellent for scripting and automation

**Sources:**
- https://github.com/tbckr/sgpt
- https://4sysops.com/archives/shellgpt-an-ai-assistant-for-the-command-line/

#### Real-World Quality & User Sentiment

**What Users Love:**
- **"How SHELL-GPT Revolutionized My Workflow"** - User reported productivity "skyrocketed" (source: dev.to)
- **"A Game-Changer for My Terminal Workflow"** - Quick coding answers, code generation, proofreading (source: nickmccomb.net)
- "Forget about cheat sheets and notes, with this tool you can get accurate answers right in your terminal" (source: multiple sources)
- **Powerful feature:** One user was "astounded" by coding a fully functional Python Reflex web app with a single command
- **Ease of use:** Even non-coding experts find it accessible
- **Time-saving:** Reduces daily Google searches significantly

**Common Complaints:**
- **Too many requests error:** GitHub Issue #311 reported persistent "Too many request" errors even after reinstall
- **Potential safety risks:** IT security article warned about automatic command execution without review - example: "Make all files read-only" translated to `chmod -R a-w .` which could have unintended consequences
- **API costs:** Uses OpenAI API, so costs can accumulate with heavy use

**Community Reception:**
- Multiple blog posts praising the tool (DEV Community, Medium, LinkedIn)
- Generally positive sentiment across tech communities
- Used in production by developers for months
- Active GitHub repository with regular updates

**Sources:**
- https://dev.to/karleeov/how-shell-gpt-revolutionized-my-workflow-4o88
- https://nickmccomb.net/homelab/shell_gpt/
- https://github.com/TheR1D/shell_gpt/issues/311
- https://itsfoss.community/t/risks-of-applying-chatgpt-large-language-models-to-the-linux-shell/10500

#### Pricing & Free Tier

**Cost Structure:** Uses OpenAI API directly
- Requires OpenAI API key
- Subject to standard OpenAI API pricing and rate limits (see pricing section)
- Can use local models (Ollama) for free alternative

---

### 4. chatgpt-cli (kardolus)

**Status:** Community Project (Most Versatile Multi-Provider)
**Repository:** https://github.com/kardolus/chatgpt-cli
**Stars:** 829 ⭐
**Forks:** 51
**Language:** Go

#### Basic Profile

**Description:** A versatile tool for interacting with LLMs through OpenAI, Azure, and other popular providers, supporting prompt files, history tracking, and live data injection via MCP.

**Maintainer:** Guillermo Kardolus (Community Developer)

**Last Update:** v1.8.11 (Latest release)

**Supported Models:**
- OpenAI (GPT-4o, GPT-4, GPT-3.5 Turbo)
- Azure OpenAI
- Anthropic Claude
- Google Gemini
- Perplexity AI
- Llama

**Platform Support:**
- ✅ macOS (Intel and M1/arm64)
- ✅ Linux (amd64, arm64, 386)
- ✅ Windows (amd64)
- ✅ FreeBSD

**Installation:**
```bash
# Homebrew
brew tap kardolus/chatgpt-cli
brew install chatgpt-cli

# Direct binary download (example for macOS arm64)
curl -L https://github.com/kardolus/chatgpt-cli/releases/download/vX.X.X/chatgpt-cli_Darwin_arm64.tar.gz | tar xz
```

**Shell Autocompletion:** Bash, Zsh, Fish, PowerShell

**Sources:**
- https://github.com/kardolus/chatgpt-cli
- https://medium.com/@kardolus/introducing-chatgpt-cli-a-powerful-command-line-interface-for-openais-chatgpt-107b507d07e8

#### Technical Capabilities

**Core Features:**
- 🌊 **Streaming Mode:** Real-time interaction with GPT models
- 💬 **Interactive Mode:** Conversational experience
- 🔍 **Query Mode:** Single input-output interactions
- 🧵 **Thread-based Context:** Individualized context per thread with separate histories
- 🪟 **Sliding Window History:** Automatic history trimming to stay within token limits
- 📝 **Prompt Files:** Support for loading prompts from files
- 🔌 **MCP Support:** Model Context Protocol for live data injection
- 📊 **Usage Tracking:** Token count and price information
- 🎯 **Multi-Provider:** Unified interface for multiple LLM providers

**Configuration:** YAML-based configuration files

**Automation-Friendly:** Suitable for both interactive and scripted use

**Sources:**
- https://github.com/kardolus/chatgpt-cli/blob/main/README.md
- https://toolerific.ai/ai-tools/opensource/kardolus-chatgpt-cli

#### Real-World Quality & User Sentiment

**What Users Love:**
- **Most versatile third-party option:** Supporting multiple LLM providers through unified interface
- Released in 2023 and continuously updated
- Clean Go implementation
- Good documentation

**Common Complaints:**
- Smaller community compared to Shell-GPT
- Less specialized for shell command generation

**Community Reception:**
- Solid GitHub star count (829+)
- Available through multiple distribution channels (Homebrew, binaries, Go packages)
- Active development with regular releases

**Sources:**
- https://fastgptplus.com/en/posts/chatgpt-cli

#### Pricing & Free Tier

**Cost Structure:** Uses provider APIs directly
- OpenAI API key required for OpenAI models
- Subject to standard OpenAI API pricing (see pricing section)
- Can use alternative providers (Azure, Claude, etc.)

---

### 5. chatgpt-cli (marcolardera)

**Status:** Community Project (Simple & Effective)
**Repository:** https://github.com/marcolardera/chatgpt-cli
**Language:** Python
**Focus:** Simplicity and markdown rendering

#### Basic Profile

**Description:** Simple yet effective command line client for chatting with ChatGPT using the official API.

**Maintainer:** Marco Lardera (Community Developer)

**Supported Models:**
- GPT-4o
- GPT-4
- GPT-3.5 Turbo
- GPT models with JSON mode support

**Platform Support:**
- ✅ Linux
- ✅ macOS
- ✅ Windows (via Python)

**Installation:**
```bash
pip install chatgpt-cli
```

**Sources:**
- https://github.com/marcolardera/chatgpt-cli

#### Technical Capabilities

**Core Features:**
- 📝 **Markdown Rendering:** Automatic markdown formatting with syntax highlighting
- 📋 **Table Support:** Correctly renders tables
- 💾 **Session History:** Saves conversations with context and token usage
- 🔄 **Session Restore:** Resume previous sessions with `--restore <YYYYMMDD-hhmmss>`
- 🔌 **Non-Interactive Mode:** UNIX pipeline support for scripting (`--non-interactive` or `-n`)
- 📦 **JSON Mode:** Force JSON responses with `--json` or `-j` flag
- ⚙️ **Configurable:** YAML configuration file

**Philosophy:** "At maximum speed, at a fraction of the cost of a full ChatGPT Plus subscription"

**Sources:**
- https://github.com/marcolardera/chatgpt-cli/blob/main/README.md

#### Real-World Quality & User Sentiment

**What Users Love:**
- Simple, straightforward interface
- Good markdown rendering
- UNIX-friendly design
- Cost-effective alternative to ChatGPT Plus

**Common Complaints:**
- Smaller feature set compared to Shell-GPT
- Less active community

**Sources:**
- GitHub repository discussions

#### Pricing & Free Tier

**Cost Structure:** Uses OpenAI API directly
- Requires OpenAI API key
- Subject to standard OpenAI API pricing (see pricing section)

---

### 6. chatgpt-cli (efJerryYang)

**Status:** Community Project (Markdown-Focused)
**Repository:** https://github.com/efJerryYang/chatgpt-cli
**Language:** Python

#### Basic Profile

**Description:** A markdown-supported command-line interface tool that connects to ChatGPT using OpenAI's API key.

**Maintainer:** efJerryYang (Community Developer)

**Supported Models:**
- OpenAI GPT models via API

**Platform Support:**
- ✅ Linux
- ✅ macOS
- ✅ Windows

**Requirements:**
- Python 3.8+
- OpenAI API key

**Installation:**
```bash
pip install chatgpt-cli
```

**Sources:**
- https://github.com/efJerryYang/chatgpt-cli

#### Technical Capabilities

**Core Features:**
- 📝 **Markdown Support:** Structure inputs in readable format
- 💾 **Conversation Management:** Save conversations in JSON format
- 📂 **Session Loading:** Load previous conversations with `!load` command
- 🖥️ **Command-Line Experience:** Similar to official web client

**Sources:**
- https://github.com/efJerryYang/chatgpt-cli/blob/main/README.md

#### Pricing & Free Tier

**Cost Structure:** Uses OpenAI API directly
- Subject to standard OpenAI API pricing

---

### 7. openai-cli (peterdemin)

**Status:** Community Project (Developer-Focused)
**Repository:** https://github.com/peterdemin/openai-cli
**Stars:** 189 ⭐
**Forks:** 31
**Language:** Python

#### Basic Profile

**Description:** Command-line client for OpenAI APIs with focus on code generation and manipulation.

**Maintainer:** peterdemin (Community Developer)

**Supported Models:**
- Text completion API (currently)

**Platform Support:**
- ✅ Linux
- ✅ macOS
- ✅ Windows

**Installation:**
```bash
pip install openai-cli
```

**Sources:**
- https://github.com/peterdemin/openai-cli

#### Technical Capabilities

**Core Features:**
- 🔧 **Code Generation:** Generate Python functions from natural language
- 🧪 **Test Generation:** Generate unit tests for existing code
- 📝 **Type Annotations:** Add type hints to Python code
- 🐛 **Code Fixing:** Fix mypy warnings
- 🔄 **UNIX Pipes:** Works well with pipes and tools like `black`
- 💻 **Interactive REPL:** Continuous interaction mode (Ctrl+C to exit)
- 🎯 **Complete Mode:** Process text input and return completions

**Authentication:**
- Command-line argument: `-t/--token <TOKEN>`
- Environment variable: `OPENAI_API_KEY`

**Example Usage:**
```bash
echo "Are cats faster than dogs?" | openai complete -
```

**Sources:**
- https://github.com/peterdemin/openai-cli

#### Pricing & Free Tier

**Cost Structure:** Uses OpenAI API directly
- Subject to standard OpenAI API pricing

---

### 8. openai-cli (janlay)

**Status:** Community Project (Universal & BASH-based)
**Repository:** https://github.com/janlay/openai-cli
**Language:** BASH
**Focus:** OpenAI-compatible API support

#### Basic Profile

**Description:** A universal CLI for OpenAI, written in BASH, supporting any AI services that provide OpenAI-compatible APIs.

**Maintainer:** Janlay Wu (Community Developer)

**Supported Models:**
- OpenAI models
- Any OpenAI-compatible API providers (DeepSeek, etc.)

**Platform Support:**
- ✅ Linux
- ✅ macOS
- ✅ Any UNIX-like system with BASH

**Installation:**
```bash
# Clone and add to PATH
git clone https://github.com/janlay/openai-cli.git
cd openai-cli
# Add to PATH
```

**Sources:**
- https://github.com/janlay/openai-cli

#### Technical Capabilities

**Core Features:**
- 🌐 **Universal API Support:** Works with OpenAI-compatible APIs
- 🏗️ **Scalable Architecture:** Continuous support for new APIs
- 🧪 **Dry-run Mode:** Debug APIs without making actual calls (saves costs)
- 🔧 **Customizable:** Custom API name, version, and properties
- 📥 **stdin Input:** Reads prompts from standard input

**Multi-Provider Configuration:**
Set environment variables for different providers:
```bash
export OPENAI_COMPATIBLE_PROVIDER=DEEPSEEK
export DEEPSEEK_API_ENDPOINT=...
export DEEPSEEK_API_KEY=...
export DEEPSEEK_API_MODEL=...
```

**Default Behavior:**
- API: chat/completions
- Schema version: v1
- Reads from stdin

**Sources:**
- https://github.com/janlay/openai-cli

#### Pricing & Free Tier

**Cost Structure:** Depends on API provider used
- OpenAI: Standard OpenAI pricing
- Other compatible providers: Provider-specific pricing

---

### 9. gpt-cli (kharvd)

**Status:** Community Project (Multi-Provider)
**Repository:** https://github.com/kharvd/gpt-cli
**Language:** Python

#### Basic Profile

**Description:** Command-line interface for ChatGPT, Claude and Gemini (formerly Bard).

**Maintainer:** kharvd (Community Developer)

**Supported Models:**
- OpenAI (GPT-4o, GPT-4, GPT-3.5 Turbo)
- Anthropic Claude (with Extended Thinking Mode support)
- Google Gemini (Bard was removed in v0.2.0)
- OpenAI-compatible services (e.g., together.xyz)

**Platform Support:**
- ✅ Linux
- ✅ macOS
- ✅ Windows

**Installation:**
```bash
pip install gpt-cli
```

**Sources:**
- https://github.com/kharvd/gpt-cli

#### Technical Capabilities

**Core Features:**
- 💬 **Command-Line Interface:** Interact with multiple AI providers
- 📝 **Multi-Line Input:** Complex queries and conversations
- 🧠 **Extended Thinking Mode:** See Claude 3.7's reasoning process
- 📊 **Usage Tracking:** Token count and pricing information
- ⚙️ **YAML Configuration:** Set API keys for multiple providers
- 🔄 **Session Management:** Maintain conversation context

**Unique Features:**
- Extended Thinking Mode for Claude (complex problem-solving)
- Support for OpenAI-compatible endpoints

**Sources:**
- https://github.com/kharvd/gpt-cli/blob/main/README.md

#### Real-World Quality & User Sentiment

**Known Issues:**
- Issue #87: "Overloaded Claude breaks Session" when Claude API is under heavy load

**Sources:**
- https://github.com/kharvd/gpt-cli/issues/87

#### Pricing & Free Tier

**Cost Structure:** Uses provider APIs directly
- OpenAI: Standard OpenAI API pricing
- Claude: Anthropic API pricing
- Gemini: Google API pricing

---

## Multi-LLM CLIs with OpenAI Support

These CLIs support multiple LLM providers including OpenAI, but are designed as multi-provider tools rather than OpenAI-specific CLIs.

### 10. mods (Charmbracelet)

**Status:** Community Project (Multi-Provider with Pipeline Focus)
**Repository:** https://github.com/charmbracelet/mods
**Stars:** 4.3k ⭐
**Language:** Go

#### Basic Profile

**Description:** "AI on the command line" - Add AI to command-line pipelines and make them artificially intelligent.

**Maintainer:** Charmbracelet (Community Organization)

**Last Update:** v1.8.1 (July 10, 2024)

**Supported Providers:**
- OpenAI (GPT-4 by default)
- Cohere
- Groq
- Azure OpenAI
- Google Gemini
- LocalAI (local models)
- Ollama (local models)

**Platform Support:**
- ✅ Linux
- ✅ macOS
- ✅ Windows

**Installation:**
```bash
# Homebrew
brew install charmbracelet/tap/mods

# Winget (Windows)
winget install charmbracelet.mods

# Arch Linux
yay -S mods

# Nix
nix-shell -p mods

# APT/YUM packages also available
```

**Sources:**
- https://github.com/charmbracelet/mods
- https://dev.to/timesurgelabs/command-line-power-ups-boost-your-workflow-with-mods-and-freeze-407j

#### Technical Capabilities

**Core Features:**
- 🔄 **Pipeline Integration:** Read stdin, add AI processing, output results
- 📝 **Markdown Formatting:** Optionally format responses as Markdown
- 💾 **Local Conversations:** Save all conversations with SHA-1 identifiers (git-like)
- 🎭 **Roles:** Set system prompts for different use cases
- 🔌 **MCP Support:** Model Context Protocol (added in v1.8.0)
- 🐚 **Shell Completions:** Bash, ZSH, Fish, PowerShell

**Philosophy:** Designed for UNIX pipeline integration, perfect for data processing workflows

**Example:**
```bash
cat document.txt | mods "summarize this"
```

**Sources:**
- https://github.com/charmbracelet/mods/blob/main/README.md

#### Real-World Quality & User Sentiment

**What Users Love:**
- "Huge fan of Charmbracelet's mods. I've been using it for months now and it works..." (Hacker News)
- Excellent for command-line power users
- Great pipeline integration
- Local conversation storage

**Sources:**
- https://news.ycombinator.com/item?id=41138575

#### Pricing & Free Tier

**Cost Structure:** Depends on provider
- OpenAI: Standard OpenAI API pricing
- Local models (LocalAI, Ollama): Free
- Other providers: Provider-specific pricing

---

### 11. llm (Simon Willison)

**Status:** Community Project (Plugin-based Multi-Provider)
**Repository:** https://github.com/simonw/llm
**Creator:** Simon Willison (Datasette creator)

#### Basic Profile

**Description:** CLI tool and Python library for interacting with OpenAI, Claude, Gemini, Llama and dozens of other LLMs via remote APIs and local models.

**Maintainer:** Simon Willison (well-known developer, Datasette creator)

**Supported Providers (via plugins):**
- OpenAI (default, ships with LLM)
- Anthropic Claude (llm-anthropic plugin)
- Google Gemini (llm-gemini plugin)
- Ollama (llm-ollama plugin)
- GPT4All (llm-gpt4all plugin - 17 local models)
- Many more via plugin ecosystem

**Platform Support:**
- ✅ Linux
- ✅ macOS
- ✅ Windows

**Installation:**
```bash
pip install llm

# Install plugins
llm install llm-openai  # for o1-pro support
llm install llm-anthropic
llm install llm-gemini
```

**Sources:**
- https://github.com/simonw/llm
- https://simonwillison.net/2025/Apr/7/long-context-llm/

#### Technical Capabilities

**Core Features:**
- 🔌 **Plugin System:** Extensive plugin ecosystem for different providers
- 🛠️ **Tool Plugins:** Add new capabilities to any model (v0.26+)
- 📚 **Long Context Support:** Fragments and template plugins (v0.24+)
- 💾 **Conversation Storage:** Local conversation management
- 🔑 **API Key Management:** Secure key storage
- 🐚 **UNIX Philosophy:** Integrates well with standard UNIX tools

**OpenAI Integration:**
- Ships with OpenAI support by default
- Separate llm-openai plugin for newer features (o1-pro)
- Uses Chat Completions API

**Recent Features:**
- v0.26: Tool support - LLMs can run tools in your terminal
- v0.24: Long context support using fragments

**Sources:**
- https://github.com/simonw/llm-openai-plugin
- https://simonw.substack.com/p/large-language-models-can-run-tools

#### Real-World Quality & User Sentiment

**What Users Love:**
- Created by Simon Willison (highly respected in developer community)
- Excellent documentation
- Active development
- UNIX-friendly design
- Extensive plugin ecosystem

**Community Reception:**
- High-quality tool from respected developer
- Active blog posts and documentation from creator
- Well-integrated with data analysis workflows (Datasette)

**Sources:**
- https://simonwillison.net/ (creator's blog with extensive CLI coverage)

#### Pricing & Free Tier

**Cost Structure:** Depends on provider and model
- OpenAI: Standard OpenAI API pricing
- Local models: Free
- Other providers: Provider-specific pricing

---

### 12. aichat (sigoden)

**Status:** Community Project (All-in-One Multi-Provider)
**Repository:** https://github.com/sigoden/aichat
**Language:** Rust
**License:** MIT or Apache 2.0

#### Basic Profile

**Description:** All-in-one LLM CLI tool featuring Shell Assistant, Chat-REPL, RAG, AI Tools & Agents.

**Maintainer:** sigoden (Community Developer)

**Supported Providers:**
Over 20 LLM providers including:
- OpenAI
- Claude (Anthropic)
- Google (Gemini, VertexAI)
- Azure OpenAI
- GitHub Models
- Ollama (local)
- Groq
- Mistral
- Deepseek
- Perplexity
- Cohere
- AI21
- XAI Grok
- Cloudflare
- OpenRouter
- Ernie, Qianwen, Moonshot, ZhipuAI, Lingyiwanwu, MiniMax
- Any OpenAI-compatible API

**Platform Support:**
- ✅ macOS
- ✅ Linux
- ✅ Windows

**Installation:**
```bash
# Download pre-built binaries from GitHub Releases
# Add to $PATH
```

**Sources:**
- https://github.com/sigoden/aichat
- https://lib.rs/crates/aichat

#### Technical Capabilities

**Core Features:**
- 🐚 **Shell Assistant:** AI-powered terminal assistance
- 💬 **Chat-REPL:** Interactive chat mode
- 📚 **RAG Support:** Retrieval-Augmented Generation
- 🤖 **AI Agents:** Agent = Instructions + Tools + Documents
- 🌐 **Built-in Server:** Lightweight HTTP server
- 🦀 **Rust-based:** Fast and efficient
- 🔧 **Function Calling:** AI Tools support

**Configuration:** Via configuration files with multi-provider setup

**Sources:**
- https://github.com/sigoden/aichat/wiki/Configuration-Guide

#### Pricing & Free Tier

**Cost Structure:** Depends on provider
- OpenAI: Standard OpenAI API pricing
- Local models (Ollama): Free
- Other providers: Provider-specific pricing

---

## Summary Comparison Table

### OpenAI-Specific CLIs

| CLI | Type | Stars | Language | Best For | Platform Support | Latest Update |
|-----|------|-------|----------|----------|------------------|---------------|
| **OpenAI Codex CLI** | Official | 50.5k | Rust | Coding agent, software development | macOS, Linux, Windows (WSL) | Active (2025) |
| **openai-python CLI** | Official | - | Python | Direct API access, basic usage | All platforms | Active |
| **Shell-GPT** | Community | 11.5k | Python | Shell commands, general productivity | All platforms | v1.4.5 (2025) |
| **chatgpt-cli (kardolus)** | Community | 829 | Go | Multi-provider, versatility | All platforms | v1.8.11 |
| **chatgpt-cli (marcolardera)** | Community | - | Python | Simplicity, markdown rendering | All platforms | Active |
| **chatgpt-cli (efJerryYang)** | Community | - | Python | Markdown support | All platforms | Active |
| **openai-cli (peterdemin)** | Community | 189 | Python | Code generation, developer tools | All platforms | Active |
| **openai-cli (janlay)** | Community | - | BASH | Universal, OpenAI-compatible APIs | UNIX-like | Active |
| **gpt-cli (kharvd)** | Community | - | Python | Multi-provider (OpenAI, Claude, Gemini) | All platforms | Active |

### Multi-LLM CLIs with OpenAI Support

| CLI | Stars | Language | Providers | Best For | Platform Support |
|-----|-------|----------|-----------|----------|------------------|
| **mods** | 4.3k | Go | 6+ | Pipeline integration, UNIX workflows | All platforms |
| **llm** | - | Python | 20+ (via plugins) | Plugin ecosystem, data analysis | All platforms |
| **aichat** | - | Rust | 20+ | All-in-one, Shell Assistant, RAG, Agents | All platforms |

---

## Key Findings & Recommendations

### For Different Use Cases:

1. **Official OpenAI Experience + Coding:**
   - **Recommended:** OpenAI Codex CLI
   - **Pros:** Official support, multimodal input, coding-focused
   - **Cons:** UX still maturing, performance behind competitors
   - **Cost:** $5-$50 API credits for ChatGPT Plus/Pro users

2. **Shell Command Generation & Productivity:**
   - **Recommended:** Shell-GPT (sgpt)
   - **Pros:** Most popular pure OpenAI CLI, excellent shell integration, caching
   - **Cons:** API costs can accumulate
   - **Community:** Largest community, best documentation for this use case

3. **Multi-Provider Flexibility:**
   - **Recommended:** kardolus/chatgpt-cli or llm (Simon Willison)
   - **Pros:** Switch between OpenAI, Claude, Gemini easily
   - **Cons:** Not specialized for any single use case

4. **UNIX Pipeline Integration:**
   - **Recommended:** mods (Charmbracelet)
   - **Pros:** Built for pipes, Markdown formatting, local conversation storage
   - **Cons:** Learning curve for pipeline usage

5. **All-in-One Solution:**
   - **Recommended:** aichat
   - **Pros:** RAG, Agents, Shell Assistant, 20+ providers
   - **Cons:** May be overwhelming for simple use cases

6. **Budget-Conscious Users:**
   - **Strategy:** Use OpenAI free tier ($5 credit) + GPT-4o-mini model
   - **Estimated usage:** ~33,000 input tokens with GPT-4o-mini
   - **Alternative:** Use local models (Ollama) with Shell-GPT, mods, or aichat

### Cost Optimization Tips:

1. **Use GPT-4o-mini** instead of GPT-4o for most tasks (83% cheaper: $0.15 vs $2.50 per 1M input tokens)
2. **Cache results** where possible (Shell-GPT has built-in caching)
3. **Start with Tier 1** ($5 payment) for reasonable rate limits:
   - GPT-3.5 Turbo: 3,500 RPM, 60,000 TPM
   - GPT-4o: 500 RPM, 30,000 TPM
4. **Monitor usage** to avoid hitting monthly limits
5. **Consider local models** (via Ollama) for privacy and cost savings

### Rate Limit Considerations:

- **Free Tier:** Essentially unusable (3 RPM, 200 RPD) - plan to pay at least $5
- **Tier 1 ($5):** Adequate for individual developers
- **Tier 2 ($50):** Recommended for teams or heavy users
- **Higher Tiers:** Automatic upgrade based on spending and time

---

## Sources Summary

### Official OpenAI Documentation:
- https://platform.openai.com/docs/guides/rate-limits
- https://openai.com/api/pricing/
- https://developers.openai.com/codex/cli/
- https://help.openai.com/en/articles/11096431-openai-codex-cli-getting-started

### GitHub Repositories:
- https://github.com/openai/codex
- https://github.com/TheR1D/shell_gpt
- https://github.com/kardolus/chatgpt-cli
- https://github.com/marcolardera/chatgpt-cli
- https://github.com/efJerryYang/chatgpt-cli
- https://github.com/peterdemin/openai-cli
- https://github.com/janlay/openai-cli
- https://github.com/kharvd/gpt-cli
- https://github.com/charmbracelet/mods
- https://github.com/simonw/llm
- https://github.com/sigoden/aichat

### Community Discussions:
- Hacker News: https://news.ycombinator.com/item?id=43708025
- OpenAI Community: https://community.openai.com/
- Medium, DEV Community, various tech blogs

### Pricing & Rate Limits:
- https://blog.laozhang.ai/ai/openai-gpt-4o-api-pricing-guide/
- https://www.scriptbyai.com/rate-limits-openai-api/
- https://medium.com/prompt-engineering/understanding-openai-rate-limits-and-available-tiers-10caeb79d120
- https://muneebdev.com/openai-api-rate-limits-guide/

---

**Report compiled:** November 14, 2025
**Research methodology:** Web search across official docs, GitHub repositories, community forums, tech blogs, and Hacker News discussions
**Confidence levels marked:** [CONFIRMED], [DERIVED], [UNKNOWN] throughout document
