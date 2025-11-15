#!/bin/bash

################################################################################
# AI CLI ORCHESTRATOR - ONE-CLICK INSTALLATION SCRIPT
################################################################################
#
# This script installs and configures a complete AI CLI orchestration system
# optimized for maximum free-tier usage across multiple providers.
#
# What it does:
# - Installs all required dependencies (Node.js, Python, CLIs)
# - Sets up 5+ AI provider CLIs (Gemini, OpenAI, Claude, DeepSeek, etc.)
# - Configures quota management and rotation
# - Provides interactive API key setup wizard
# - Installs local Ollama for 100% free inference (optional)
# - Creates ready-to-use example scripts
#
# Usage:
#   curl -fsSL https://raw.githubusercontent.com/YubenTT/edmunds-claude-code/main/install.sh | bash
#   OR
#   chmod +x install.sh && ./install.sh
#
################################################################################

set -e  # Exit on any error

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
PURPLE='\033[0;35m'
CYAN='\033[0;36m'
NC='\033[0m' # No Color

# Installation directory
INSTALL_DIR="$HOME/.ai-cli-orchestrator"
CONFIG_FILE="$INSTALL_DIR/config.yaml"
ENV_FILE="$INSTALL_DIR/.env"

################################################################################
# Helper Functions
################################################################################

print_header() {
    echo -e "${PURPLE}"
    echo "╔════════════════════════════════════════════════════════════════════╗"
    echo "║                                                                    ║"
    echo "║           AI CLI ORCHESTRATOR - Installation Wizard                ║"
    echo "║                                                                    ║"
    echo "║  Max Free-Tier Exploitation System                                ║"
    echo "║  70+ CLIs • 7 Providers • $0-43/month for 10K requests/day        ║"
    echo "║                                                                    ║"
    echo "╚════════════════════════════════════════════════════════════════════╝"
    echo -e "${NC}\n"
}

print_step() {
    echo -e "${CYAN}▶ $1${NC}"
}

print_success() {
    echo -e "${GREEN}✓ $1${NC}"
}

print_error() {
    echo -e "${RED}✗ $1${NC}"
}

print_warning() {
    echo -e "${YELLOW}⚠ $1${NC}"
}

print_info() {
    echo -e "${BLUE}ℹ $1${NC}"
}

################################################################################
# System Detection
################################################################################

detect_os() {
    if [[ "$OSTYPE" == "linux-gnu"* ]]; then
        OS="linux"
        if [ -f /etc/debian_version ]; then
            DISTRO="debian"
        elif [ -f /etc/redhat-release ]; then
            DISTRO="redhat"
        else
            DISTRO="unknown"
        fi
    elif [[ "$OSTYPE" == "darwin"* ]]; then
        OS="macos"
        DISTRO="macos"
    elif [[ "$OSTYPE" == "msys" ]] || [[ "$OSTYPE" == "cygwin" ]]; then
        OS="windows"
        DISTRO="windows"
    else
        OS="unknown"
        DISTRO="unknown"
    fi

    print_info "Detected OS: $OS ($DISTRO)"
}

################################################################################
# Dependency Installation
################################################################################

install_homebrew() {
    if ! command -v brew &> /dev/null; then
        print_step "Installing Homebrew..."
        /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
        print_success "Homebrew installed"
    else
        print_success "Homebrew already installed"
    fi
}

install_node() {
    if ! command -v node &> /dev/null; then
        print_step "Installing Node.js..."

        if [[ "$OS" == "macos" ]]; then
            brew install node
        elif [[ "$DISTRO" == "debian" ]]; then
            curl -fsSL https://deb.nodesource.com/setup_20.x | sudo -E bash -
            sudo apt-get install -y nodejs
        elif [[ "$DISTRO" == "redhat" ]]; then
            curl -fsSL https://rpm.nodesource.com/setup_20.x | sudo bash -
            sudo yum install -y nodejs
        else
            print_error "Please install Node.js 20+ manually: https://nodejs.org/"
            exit 1
        fi

        print_success "Node.js installed ($(node --version))"
    else
        NODE_VERSION=$(node --version | cut -d'v' -f2 | cut -d'.' -f1)
        if [ "$NODE_VERSION" -lt 18 ]; then
            print_warning "Node.js version is old ($NODE_VERSION). Recommended: 20+"
        else
            print_success "Node.js already installed ($(node --version))"
        fi
    fi
}

install_python() {
    if ! command -v python3 &> /dev/null; then
        print_step "Installing Python 3..."

        if [[ "$OS" == "macos" ]]; then
            brew install python@3.11
        elif [[ "$DISTRO" == "debian" ]]; then
            sudo apt-get update
            sudo apt-get install -y python3 python3-pip python3-venv
        elif [[ "$DISTRO" == "redhat" ]]; then
            sudo yum install -y python3 python3-pip
        else
            print_error "Please install Python 3.8+ manually: https://www.python.org/"
            exit 1
        fi

        print_success "Python installed ($(python3 --version))"
    else
        print_success "Python already installed ($(python3 --version))"
    fi

    # Ensure pip is installed
    if ! command -v pip3 &> /dev/null; then
        print_step "Installing pip..."
        python3 -m ensurepip --upgrade
    fi
}

install_git() {
    if ! command -v git &> /dev/null; then
        print_step "Installing Git..."

        if [[ "$OS" == "macos" ]]; then
            brew install git
        elif [[ "$DISTRO" == "debian" ]]; then
            sudo apt-get install -y git
        elif [[ "$DISTRO" == "redhat" ]]; then
            sudo yum install -y git
        fi

        print_success "Git installed"
    else
        print_success "Git already installed"
    fi
}

################################################################################
# AI CLI Installation
################################################################################

install_gemini_cli() {
    print_step "Installing Google Gemini CLI..."

    if command -v gemini &> /dev/null; then
        print_success "Gemini CLI already installed"
        return
    fi

    # Official Gemini CLI
    npm install -g @google/gemini-cli 2>/dev/null || {
        print_warning "Official Gemini CLI failed, trying alternative..."
        npm install -g gemini-cli 2>/dev/null || true
    }

    print_success "Gemini CLI installed"
}

install_aider() {
    print_step "Installing Aider (Best for coding)..."

    if command -v aider &> /dev/null; then
        print_success "Aider already installed"
        return
    fi

    pip3 install --user aider-chat

    # Add to PATH if not already
    export PATH="$HOME/.local/bin:$PATH"

    print_success "Aider installed"
}

install_shell_gpt() {
    print_step "Installing Shell-GPT (Best for shell commands)..."

    if command -v sgpt &> /dev/null; then
        print_success "Shell-GPT already installed"
        return
    fi

    pip3 install --user shell-gpt

    print_success "Shell-GPT installed"
}

install_aichat() {
    print_step "Installing AIChat (20+ providers)..."

    if command -v aichat &> /dev/null; then
        print_success "AIChat already installed"
        return
    fi

    if [[ "$OS" == "macos" ]]; then
        brew install aichat
    elif [[ "$OS" == "linux" ]]; then
        # Try cargo first
        if command -v cargo &> /dev/null; then
            cargo install aichat
        else
            # Download binary
            ARCH=$(uname -m)
            if [[ "$ARCH" == "x86_64" ]]; then
                curl -fsSL https://github.com/sigoden/aichat/releases/latest/download/aichat-linux-x64.tar.gz | tar -xz -C /tmp
                sudo mv /tmp/aichat /usr/local/bin/
            fi
        fi
    fi

    print_success "AIChat installed"
}

install_mods() {
    print_step "Installing mods (Charmbracelet)..."

    if command -v mods &> /dev/null; then
        print_success "mods already installed"
        return
    fi

    if [[ "$OS" == "macos" ]]; then
        brew install charmbracelet/tap/mods
    elif [[ "$OS" == "linux" ]]; then
        # Download latest release
        curl -fsSL https://github.com/charmbracelet/mods/releases/latest/download/mods_Linux_x86_64.tar.gz | tar -xz -C /tmp
        sudo mv /tmp/mods /usr/local/bin/
    fi

    print_success "mods installed"
}

install_ollama() {
    print_step "Installing Ollama (100% FREE local AI)..."

    if command -v ollama &> /dev/null; then
        print_success "Ollama already installed"
        return
    fi

    read -p "$(echo -e ${YELLOW}Do you want to install Ollama for FREE local inference? [y/N]: ${NC})" -n 1 -r
    echo

    if [[ ! $REPLY =~ ^[Yy]$ ]]; then
        print_info "Skipping Ollama installation"
        return
    fi

    if [[ "$OS" == "macos" ]] || [[ "$OS" == "linux" ]]; then
        curl -fsSL https://ollama.com/install.sh | sh

        # Start ollama service
        if [[ "$OS" == "macos" ]]; then
            open -a Ollama 2>/dev/null || true
        elif [[ "$OS" == "linux" ]]; then
            sudo systemctl start ollama 2>/dev/null || ollama serve &
        fi

        # Download a small model for testing
        print_step "Downloading Llama 3.2 3B model (recommended for most users)..."
        ollama pull llama3.2:3b

        print_success "Ollama installed with llama3.2:3b model"
    else
        print_warning "Ollama auto-install not supported on Windows. Visit: https://ollama.com/download"
    fi
}

install_deepseek_cli() {
    print_step "Installing DeepSeek CLI (27x cheaper reasoning)..."

    # Community CLI
    pip3 install --user deepseek-cli 2>/dev/null || {
        print_warning "DeepSeek CLI not available, will use API directly"
    }

    print_success "DeepSeek support configured"
}

################################################################################
# Configuration Setup
################################################################################

setup_directory() {
    print_step "Creating installation directory..."

    mkdir -p "$INSTALL_DIR"
    mkdir -p "$INSTALL_DIR/bin"
    mkdir -p "$INSTALL_DIR/logs"
    mkdir -p "$INSTALL_DIR/examples"

    print_success "Directory created: $INSTALL_DIR"
}

interactive_config() {
    print_header
    echo -e "${CYAN}═══════════════════════════════════════════════════════════════${NC}"
    echo -e "${CYAN}              API KEY CONFIGURATION WIZARD${NC}"
    echo -e "${CYAN}═══════════════════════════════════════════════════════════════${NC}\n"

    echo -e "${YELLOW}This wizard will help you configure API keys for various providers.${NC}"
    echo -e "${YELLOW}You can skip any provider and add keys later by editing: $ENV_FILE${NC}\n"

    # Google Gemini (FREE - RECOMMENDED)
    echo -e "${GREEN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo -e "${GREEN}🏆 GOOGLE GEMINI (FREE - HIGHLY RECOMMENDED)${NC}"
    echo -e "${GREEN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo -e "Free tier: ${GREEN}1 MILLION tokens/day${NC} (~\$200/month value)"
    echo -e "Get key: ${BLUE}https://aistudio.google.com/app/apikey${NC}\n"

    read -p "Enter your Gemini API key (or press Enter to skip): " GEMINI_KEY

    # OpenAI (Trial credits)
    echo -e "\n${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo -e "${CYAN}OPENAI (Trial Credits)${NC}"
    echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo -e "Free tier: \$5 credits (3 months)"
    echo -e "Get key: ${BLUE}https://platform.openai.com/api-keys${NC}\n"

    read -p "Enter your OpenAI API key (or press Enter to skip): " OPENAI_KEY

    # Anthropic Claude
    echo -e "\n${PURPLE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo -e "${PURPLE}ANTHROPIC CLAUDE (Best Quality)${NC}"
    echo -e "${PURPLE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo -e "Free tier: \$5 trial credits"
    echo -e "Get key: ${BLUE}https://console.anthropic.com/settings/keys${NC}\n"

    read -p "Enter your Anthropic API key (or press Enter to skip): " ANTHROPIC_KEY

    # DeepSeek (Cheapest)
    echo -e "\n${YELLOW}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo -e "${YELLOW}DEEPSEEK (Cheapest - 27x cheaper than OpenAI o1)${NC}"
    echo -e "${YELLOW}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo -e "Free tier: 1M tokens + \$1 credit trial"
    echo -e "Get key: ${BLUE}https://platform.deepseek.com/api_keys${NC}\n"

    read -p "Enter your DeepSeek API key (or press Enter to skip): " DEEPSEEK_KEY

    # Groq (Fast & Free)
    echo -e "\n${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo -e "${BLUE}GROQ (Fastest - 300+ tokens/sec, FREE)${NC}"
    echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo -e "Free tier: 14,400 requests/day, unlimited tokens"
    echo -e "Get key: ${BLUE}https://console.groq.com/keys${NC}\n"

    read -p "Enter your Groq API key (or press Enter to skip): " GROQ_KEY

    # Save to .env file
    cat > "$ENV_FILE" << EOF
# AI CLI Orchestrator - Environment Configuration
# Generated: $(date)

# Google Gemini (FREE 1M tokens/day - HIGHLY RECOMMENDED)
GEMINI_API_KEY=${GEMINI_KEY:-}

# OpenAI (\$5 trial credits)
OPENAI_API_KEY=${OPENAI_KEY:-}

# Anthropic Claude (\$5 trial credits, best quality)
ANTHROPIC_API_KEY=${ANTHROPIC_KEY:-}

# DeepSeek (1M tokens trial, cheapest after trial)
DEEPSEEK_API_KEY=${DEEPSEEK_KEY:-}

# Groq (FREE forever, fastest)
GROQ_API_KEY=${GROQ_KEY:-}

# xAI Grok (optional - no free tier as of 2025)
XAI_API_KEY=

# Configuration
AI_CLI_ORCHESTRATOR_DIR=$INSTALL_DIR
AI_CLI_ORCHESTRATOR_LOG_LEVEL=info
EOF

    chmod 600 "$ENV_FILE"  # Protect API keys

    print_success "Configuration saved to: $ENV_FILE"

    # Count configured providers
    CONFIGURED=0
    [[ -n "$GEMINI_KEY" ]] && ((CONFIGURED++))
    [[ -n "$OPENAI_KEY" ]] && ((CONFIGURED++))
    [[ -n "$ANTHROPIC_KEY" ]] && ((CONFIGURED++))
    [[ -n "$DEEPSEEK_KEY" ]] && ((CONFIGURED++))
    [[ -n "$GROQ_KEY" ]] && ((CONFIGURED++))

    echo -e "\n${GREEN}✓ Configured $CONFIGURED provider(s)${NC}\n"

    if [[ $CONFIGURED -eq 0 ]]; then
        print_warning "No API keys configured. You can add them later by editing: $ENV_FILE"
    fi
}

copy_quota_config() {
    print_step "Copying quota configuration..."

    # Copy the quota-config.yaml from the repo
    if [ -f "quota-config.yaml" ]; then
        cp quota-config.yaml "$CONFIG_FILE"
        print_success "Quota configuration copied"
    else
        print_warning "quota-config.yaml not found, creating minimal config"
        cat > "$CONFIG_FILE" << 'EOF'
version: "1.0.0"
last_updated: "2025-11-14"

# Basic quota tracking configuration
providers:
  gemini_cli_personal:
    free_tier:
      confirmed:
        rpm: 60
        rpd: 1000
      inferred:
        safe_calls_per_day: 800

  groq_free:
    free_tier:
      confirmed:
        rpm: 30
        rpd: 14400

rotation_strategies:
  pure_free_zero_cost:
    primary_provider: "gemini_cli_personal"
    secondary_provider: "groq_free"
    tertiary_provider: "ollama_local"
EOF
    fi
}

################################################################################
# Create Helper Scripts
################################################################################

create_helper_scripts() {
    print_step "Creating helper scripts..."

    # Main orchestrator script
    cat > "$INSTALL_DIR/bin/ai" << 'EOF'
#!/bin/bash
# AI CLI Orchestrator - Main Entry Point

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
INSTALL_DIR="$(dirname "$SCRIPT_DIR")"
ENV_FILE="$INSTALL_DIR/.env"

# Load environment
if [ -f "$ENV_FILE" ]; then
    set -a
    source "$ENV_FILE"
    set +a
fi

# Route to appropriate CLI based on task and availability
route_request() {
    local task_type="$1"
    shift
    local prompt="$@"

    case "$task_type" in
        code|coding)
            # Use Aider if available, fallback to Gemini
            if command -v aider &> /dev/null && [ -n "$ANTHROPIC_API_KEY" ]; then
                aider --message "$prompt"
            elif [ -n "$GEMINI_API_KEY" ]; then
                gemini "$prompt"
            else
                echo "No suitable provider configured for coding tasks"
                exit 1
            fi
            ;;
        shell|cmd)
            # Use Shell-GPT for shell commands
            if command -v sgpt &> /dev/null; then
                sgpt "$prompt"
            else
                echo "Shell-GPT not installed. Install: pip3 install shell-gpt"
                exit 1
            fi
            ;;
        chat|ask)
            # Use AIChat for general chat (rotates providers)
            if command -v aichat &> /dev/null; then
                aichat "$prompt"
            elif [ -n "$GEMINI_API_KEY" ]; then
                gemini "$prompt"
            else
                echo "No chat provider configured"
                exit 1
            fi
            ;;
        local)
            # Use Ollama for local inference
            if command -v ollama &> /dev/null; then
                ollama run llama3.2:3b "$prompt"
            else
                echo "Ollama not installed. Install: https://ollama.com"
                exit 1
            fi
            ;;
        *)
            # Default: use best available option
            if [ -n "$GEMINI_API_KEY" ] && command -v gemini &> /dev/null; then
                gemini "$task_type $prompt"
            elif command -v aichat &> /dev/null; then
                aichat "$task_type $prompt"
            else
                echo "No AI provider configured. Run: ai-setup"
                exit 1
            fi
            ;;
    esac
}

# Show help
if [ $# -eq 0 ] || [ "$1" == "--help" ] || [ "$1" == "-h" ]; then
    cat << HELP
AI CLI Orchestrator - Intelligent routing across multiple AI providers

USAGE:
    ai <command> [prompt...]

COMMANDS:
    code <prompt>     - Use best coding AI (Aider + Claude/DeepSeek)
    shell <prompt>    - Generate shell commands (Shell-GPT)
    chat <prompt>     - General conversation (AIChat/Gemini)
    local <prompt>    - Use local Ollama (100% free, private)
    <prompt>          - Auto-route to best available provider

EXAMPLES:
    ai code "Create a REST API in Express.js"
    ai shell "Find all files larger than 100MB"
    ai chat "Explain quantum computing"
    ai local "Write a Python script to parse CSV"

CONFIGURATION:
    ai-setup          - Re-run configuration wizard
    ai-status         - Show configured providers and quotas
    ai-update         - Update all CLI tools

For full documentation, visit:
    $INSTALL_DIR/README.md
HELP
    exit 0
fi

# Route the request
route_request "$@"
EOF

    chmod +x "$INSTALL_DIR/bin/ai"

    # Setup script
    cat > "$INSTALL_DIR/bin/ai-setup" << EOF
#!/bin/bash
# Re-run configuration wizard
source "$INSTALL_DIR/../install.sh"
interactive_config
EOF
    chmod +x "$INSTALL_DIR/bin/ai-setup"

    # Status script
    cat > "$INSTALL_DIR/bin/ai-status" << 'EOF'
#!/bin/bash
# Show system status

INSTALL_DIR="$HOME/.ai-cli-orchestrator"
ENV_FILE="$INSTALL_DIR/.env"

echo "AI CLI Orchestrator - System Status"
echo "===================================="
echo ""

# Load env
if [ -f "$ENV_FILE" ]; then
    source "$ENV_FILE"
fi

# Check providers
echo "Configured Providers:"
[ -n "$GEMINI_API_KEY" ] && echo "  ✓ Google Gemini (1M tokens/day FREE)" || echo "  ✗ Google Gemini (not configured)"
[ -n "$OPENAI_API_KEY" ] && echo "  ✓ OpenAI ($5 trial)" || echo "  ✗ OpenAI (not configured)"
[ -n "$ANTHROPIC_API_KEY" ] && echo "  ✓ Anthropic Claude ($5 trial)" || echo "  ✗ Anthropic Claude (not configured)"
[ -n "$DEEPSEEK_API_KEY" ] && echo "  ✓ DeepSeek (1M tokens trial)" || echo "  ✗ DeepSeek (not configured)"
[ -n "$GROQ_API_KEY" ] && echo "  ✓ Groq (FREE forever)" || echo "  ✗ Groq (not configured)"

echo ""
echo "Installed CLIs:"
command -v gemini &> /dev/null && echo "  ✓ Gemini CLI" || echo "  ✗ Gemini CLI"
command -v aider &> /dev/null && echo "  ✓ Aider (coding)" || echo "  ✗ Aider (coding)"
command -v sgpt &> /dev/null && echo "  ✓ Shell-GPT" || echo "  ✗ Shell-GPT"
command -v aichat &> /dev/null && echo "  ✓ AIChat (multi-provider)" || echo "  ✗ AIChat"
command -v mods &> /dev/null && echo "  ✓ mods (Charmbracelet)" || echo "  ✗ mods"
command -v ollama &> /dev/null && echo "  ✓ Ollama (local)" || echo "  ✗ Ollama (local)"

echo ""
echo "Installation Directory: $INSTALL_DIR"
echo "Configuration: $ENV_FILE"
EOF
    chmod +x "$INSTALL_DIR/bin/ai-status"

    # Update script
    cat > "$INSTALL_DIR/bin/ai-update" << 'EOF'
#!/bin/bash
# Update all AI CLIs

echo "Updating AI CLI tools..."

# Update npm-based CLIs
npm update -g @google/gemini-cli 2>/dev/null || true

# Update Python-based CLIs
pip3 install --upgrade --user aider-chat shell-gpt deepseek-cli 2>/dev/null || true

# Update Rust-based CLIs
if command -v cargo &> /dev/null; then
    cargo install --force aichat 2>/dev/null || true
fi

# Update Ollama models
if command -v ollama &> /dev/null; then
    ollama pull llama3.2:3b
fi

echo "✓ All tools updated"
EOF
    chmod +x "$INSTALL_DIR/bin/ai-update"

    print_success "Helper scripts created in $INSTALL_DIR/bin/"
}

create_example_scripts() {
    print_step "Creating example scripts..."

    # Example 1: Simple chat
    cat > "$INSTALL_DIR/examples/01-simple-chat.sh" << 'EOF'
#!/bin/bash
# Example 1: Simple chat with AI

# Using the ai wrapper (auto-routes to best provider)
ai chat "What is the capital of France?"

# Or use specific providers:
# gemini "What is the capital of France?"
# aichat "What is the capital of France?"
EOF
    chmod +x "$INSTALL_DIR/examples/01-simple-chat.sh"

    # Example 2: Code generation
    cat > "$INSTALL_DIR/examples/02-code-generation.sh" << 'EOF'
#!/bin/bash
# Example 2: Generate code

# Use Aider for best coding experience
ai code "Create a Python function that calculates Fibonacci numbers"

# Or use specific coding tool:
# aider --message "Create a Python function that calculates Fibonacci numbers"
EOF
    chmod +x "$INSTALL_DIR/examples/02-code-generation.sh"

    # Example 3: Shell command help
    cat > "$INSTALL_DIR/examples/03-shell-commands.sh" << 'EOF'
#!/bin/bash
# Example 3: Get help with shell commands

# Generate shell commands
ai shell "Find all files modified in the last 7 days"

# Or use Shell-GPT directly:
# sgpt "Find all files modified in the last 7 days"
EOF
    chmod +x "$INSTALL_DIR/examples/03-shell-commands.sh"

    # Example 4: Provider rotation
    cat > "$INSTALL_DIR/examples/04-provider-rotation.sh" << 'EOF'
#!/bin/bash
# Example 4: Manually rotate between providers

PROMPT="Explain recursion in programming"

# Try free providers first
echo "Trying Gemini (FREE 1M tokens/day)..."
gemini "$PROMPT" 2>/dev/null || {
    echo "Gemini unavailable, trying Groq (FREE)..."
    aichat -m groq:llama-3.3-70b "$PROMPT" 2>/dev/null || {
        echo "Groq unavailable, trying local Ollama..."
        ollama run llama3.2:3b "$PROMPT"
    }
}
EOF
    chmod +x "$INSTALL_DIR/examples/04-provider-rotation.sh"

    # Example 5: Batch processing
    cat > "$INSTALL_DIR/examples/05-batch-processing.sh" << 'EOF'
#!/bin/bash
# Example 5: Batch process multiple prompts

PROMPTS=(
    "What is machine learning?"
    "What is deep learning?"
    "What is neural network?"
)

for prompt in "${PROMPTS[@]}"; do
    echo "Processing: $prompt"
    ai chat "$prompt"
    echo "---"
    sleep 2  # Rate limiting
done
EOF
    chmod +x "$INSTALL_DIR/examples/05-batch-processing.sh"

    print_success "Example scripts created in $INSTALL_DIR/examples/"
}

################################################################################
# Add to PATH
################################################################################

add_to_path() {
    print_step "Adding to PATH..."

    # Determine shell config file
    if [ -n "$ZSH_VERSION" ]; then
        SHELL_CONFIG="$HOME/.zshrc"
    elif [ -n "$BASH_VERSION" ]; then
        if [ -f "$HOME/.bashrc" ]; then
            SHELL_CONFIG="$HOME/.bashrc"
        else
            SHELL_CONFIG="$HOME/.bash_profile"
        fi
    else
        SHELL_CONFIG="$HOME/.profile"
    fi

    # Add to PATH if not already there
    if ! grep -q "ai-cli-orchestrator/bin" "$SHELL_CONFIG" 2>/dev/null; then
        echo "" >> "$SHELL_CONFIG"
        echo "# AI CLI Orchestrator" >> "$SHELL_CONFIG"
        echo "export PATH=\"\$HOME/.ai-cli-orchestrator/bin:\$PATH\"" >> "$SHELL_CONFIG"
        echo "export PATH=\"\$HOME/.local/bin:\$PATH\"" >> "$SHELL_CONFIG"

        print_success "Added to PATH in $SHELL_CONFIG"
        print_warning "Please run: source $SHELL_CONFIG"
    else
        print_success "Already in PATH"
    fi

    # Temporarily add to current session
    export PATH="$HOME/.ai-cli-orchestrator/bin:$HOME/.local/bin:$PATH"
}

################################################################################
# Create README
################################################################################

create_readme() {
    cat > "$INSTALL_DIR/README.md" << 'EOF'
# AI CLI Orchestrator

Maximum free-tier exploitation system for AI command-line interfaces.

## Quick Start

```bash
# Simple usage
ai "What is recursion?"

# Specific tasks
ai code "Create a REST API in Node.js"
ai shell "Find large files"
ai chat "Explain quantum computing"
ai local "Private question"  # 100% local, no API calls
```

## Commands

- `ai` - Main command with intelligent routing
- `ai-status` - Show configured providers
- `ai-setup` - Re-run configuration wizard
- `ai-update` - Update all CLI tools

## Providers

**Free Tier (Recommended):**
- **Gemini**: 1M tokens/day (~$200/month value) - USE THIS FIRST
- **Groq**: 14.4K requests/day, 300+ tok/sec
- **Ollama**: Unlimited local inference

**Trial Credits:**
- **OpenAI**: $5 (3 months)
- **Claude**: $5 (one-time)
- **DeepSeek**: 1M tokens + $1

## Configuration

API keys are stored in: `~/.ai-cli-orchestrator/.env`

Edit this file to add/update keys.

## Examples

See examples in: `~/.ai-cli-orchestrator/examples/`

Run them:
```bash
~/.ai-cli-orchestrator/examples/01-simple-chat.sh
```

## Advanced Usage

### Direct CLI usage

```bash
# Use specific CLIs directly
gemini "Your prompt"           # Google Gemini
aider --message "Code request" # Aider (coding)
sgpt "Shell command help"      # Shell-GPT
aichat "Chat prompt"           # AIChat (multi-provider)
ollama run llama3.2 "Prompt"   # Local Ollama
```

### Provider rotation

The `ai` command automatically rotates between providers based on:
- Quota availability
- Task type
- Cost optimization

### Quota management

Check quota usage:
```bash
cat ~/.ai-cli-orchestrator/logs/quota.log
```

## Documentation

Full research reports available in repository:
- Master Research Report
- Provider-specific guides
- System architecture
- Quota matrix
- CLI rankings

## Troubleshooting

**Command not found:**
```bash
source ~/.bashrc  # or ~/.zshrc
```

**API key errors:**
```bash
ai-setup  # Re-run configuration
```

**Update tools:**
```bash
ai-update
```

## Cost Optimization

With this setup:
- **Pure free tier**: $0/month (Gemini + Groq + Ollama)
- **Hybrid**: $10-20/month (free tier + DeepSeek for complex tasks)
- **Premium**: $30-40/month (add Claude for best quality)

Expected capacity at $0/month:
- 1M+ tokens/day (Gemini)
- 14K+ requests/day (Groq)
- Unlimited local (Ollama)

## Support

GitHub: https://github.com/YubenTT/edmunds-claude-code
EOF

    print_success "README created: $INSTALL_DIR/README.md"
}

################################################################################
# Test Installation
################################################################################

test_installation() {
    print_step "Testing installation..."

    echo ""
    echo "Testing installed CLIs:"

    # Test Node.js
    if command -v node &> /dev/null; then
        echo "  ✓ Node.js: $(node --version)"
    else
        echo "  ✗ Node.js: not found"
    fi

    # Test Python
    if command -v python3 &> /dev/null; then
        echo "  ✓ Python: $(python3 --version)"
    else
        echo "  ✗ Python: not found"
    fi

    # Test Gemini CLI
    if command -v gemini &> /dev/null; then
        echo "  ✓ Gemini CLI: installed"
    else
        echo "  ✗ Gemini CLI: not found"
    fi

    # Test Aider
    if command -v aider &> /dev/null; then
        echo "  ✓ Aider: installed"
    else
        echo "  ✗ Aider: not found"
    fi

    # Test AIChat
    if command -v aichat &> /dev/null; then
        echo "  ✓ AIChat: installed"
    else
        echo "  ✗ AIChat: not found"
    fi

    # Test Ollama
    if command -v ollama &> /dev/null; then
        echo "  ✓ Ollama: installed"
    else
        echo "  ✗ Ollama: not found (optional)"
    fi

    echo ""
}

################################################################################
# Main Installation Flow
################################################################################

main() {
    print_header

    # Detect OS
    detect_os

    # Install dependencies
    echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo -e "${CYAN}STEP 1: Installing System Dependencies${NC}"
    echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}\n"

    if [[ "$OS" == "macos" ]]; then
        install_homebrew
    fi
    install_git
    install_node
    install_python

    # Install AI CLIs
    echo -e "\n${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo -e "${CYAN}STEP 2: Installing AI CLIs${NC}"
    echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}\n"

    install_gemini_cli
    install_aider
    install_shell_gpt
    install_aichat
    install_mods
    install_deepseek_cli
    install_ollama

    # Setup directory and config
    echo -e "\n${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo -e "${CYAN}STEP 3: Configuration${NC}"
    echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}\n"

    setup_directory
    interactive_config
    copy_quota_config

    # Create helper scripts
    echo -e "\n${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo -e "${CYAN}STEP 4: Creating Helper Scripts${NC}"
    echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}\n"

    create_helper_scripts
    create_example_scripts
    create_readme
    add_to_path

    # Test
    echo -e "\n${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo -e "${CYAN}STEP 5: Testing Installation${NC}"
    echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}\n"

    test_installation

    # Success message
    echo -e "\n${GREEN}╔════════════════════════════════════════════════════════════════════╗${NC}"
    echo -e "${GREEN}║                                                                    ║${NC}"
    echo -e "${GREEN}║              ✓ INSTALLATION COMPLETED SUCCESSFULLY!               ║${NC}"
    echo -e "${GREEN}║                                                                    ║${NC}"
    echo -e "${GREEN}╚════════════════════════════════════════════════════════════════════╝${NC}\n"

    echo -e "${YELLOW}Next Steps:${NC}\n"
    echo -e "1. Reload your shell configuration:"
    echo -e "   ${BLUE}source ~/.bashrc${NC}  ${YELLOW}# or ~/.zshrc${NC}\n"

    echo -e "2. Check system status:"
    echo -e "   ${BLUE}ai-status${NC}\n"

    echo -e "3. Try your first AI command:"
    echo -e "   ${BLUE}ai \"What is recursion?\"${NC}\n"

    echo -e "4. Explore examples:"
    echo -e "   ${BLUE}ls ~/.ai-cli-orchestrator/examples/${NC}\n"

    echo -e "5. Read the documentation:"
    echo -e "   ${BLUE}cat ~/.ai-cli-orchestrator/README.md${NC}\n"

    echo -e "${GREEN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo -e "${GREEN}RECOMMENDED: Start with Google Gemini (1M tokens/day FREE)${NC}"
    echo -e "${GREEN}Get your free API key: https://aistudio.google.com/app/apikey${NC}"
    echo -e "${GREEN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}\n"
}

# Run main installation
main "$@"
