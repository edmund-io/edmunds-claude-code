#!/bin/bash

################################################################################
# AI CLI ORCHESTRATOR - INSTALLATION TEST SCRIPT
################################################################################
#
# This script tests your AI CLI Orchestrator installation to ensure
# everything is working correctly.
#
# Usage:
#   chmod +x test-installation.sh
#   ./test-installation.sh
#
################################################################################

set -e

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
PURPLE='\033[0;35m'
CYAN='\033[0;36m'
NC='\033[0m'

INSTALL_DIR="$HOME/.ai-cli-orchestrator"
ENV_FILE="$INSTALL_DIR/.env"

TESTS_PASSED=0
TESTS_FAILED=0
TESTS_WARNING=0

print_header() {
    echo -e "${PURPLE}"
    echo "╔════════════════════════════════════════════════════════════════════╗"
    echo "║                                                                    ║"
    echo "║        AI CLI ORCHESTRATOR - Installation Test Suite              ║"
    echo "║                                                                    ║"
    echo "╚════════════════════════════════════════════════════════════════════╝"
    echo -e "${NC}\n"
}

test_pass() {
    echo -e "${GREEN}✓ PASS${NC}: $1"
    ((TESTS_PASSED++))
}

test_fail() {
    echo -e "${RED}✗ FAIL${NC}: $1"
    echo -e "  ${YELLOW}→ $2${NC}"
    ((TESTS_FAILED++))
}

test_warn() {
    echo -e "${YELLOW}⚠ WARN${NC}: $1"
    echo -e "  ${BLUE}→ $2${NC}"
    ((TESTS_WARNING++))
}

print_section() {
    echo -e "\n${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo -e "${CYAN}$1${NC}"
    echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}\n"
}

################################################################################
# Test System Dependencies
################################################################################

test_system_dependencies() {
    print_section "TEST 1: System Dependencies"

    # Test Node.js
    if command -v node &> /dev/null; then
        NODE_VERSION=$(node --version | cut -d'v' -f2 | cut -d'.' -f1)
        if [ "$NODE_VERSION" -ge 18 ]; then
            test_pass "Node.js $(node --version) installed"
        else
            test_warn "Node.js $NODE_VERSION is old" "Recommended: Node.js 18+"
        fi
    else
        test_fail "Node.js not found" "Install: https://nodejs.org/"
    fi

    # Test Python
    if command -v python3 &> /dev/null; then
        PYTHON_VERSION=$(python3 --version)
        test_pass "Python $PYTHON_VERSION installed"
    else
        test_fail "Python3 not found" "Install: https://www.python.org/"
    fi

    # Test pip
    if command -v pip3 &> /dev/null; then
        test_pass "pip3 installed"
    else
        test_warn "pip3 not found" "Some Python CLIs may not install"
    fi

    # Test git
    if command -v git &> /dev/null; then
        test_pass "Git installed"
    else
        test_warn "Git not found" "Optional but recommended"
    fi
}

################################################################################
# Test AI CLI Tools
################################################################################

test_ai_clis() {
    print_section "TEST 2: AI CLI Tools"

    # Test Gemini CLI
    if command -v gemini &> /dev/null; then
        test_pass "Gemini CLI installed"
    else
        test_fail "Gemini CLI not found" "Install: npm install -g @google/gemini-cli"
    fi

    # Test Aider
    if command -v aider &> /dev/null; then
        test_pass "Aider installed"
    else
        test_warn "Aider not found" "Install: pip3 install aider-chat (optional but recommended for coding)"
    fi

    # Test Shell-GPT
    if command -v sgpt &> /dev/null; then
        test_pass "Shell-GPT (sgpt) installed"
    else
        test_warn "Shell-GPT not found" "Install: pip3 install shell-gpt (optional)"
    fi

    # Test AIChat
    if command -v aichat &> /dev/null; then
        test_pass "AIChat installed"
    else
        test_warn "AIChat not found" "Install: See https://github.com/sigoden/aichat (optional)"
    fi

    # Test mods
    if command -v mods &> /dev/null; then
        test_pass "mods (Charmbracelet) installed"
    else
        test_warn "mods not found" "Install: See https://github.com/charmbracelet/mods (optional)"
    fi

    # Test Ollama
    if command -v ollama &> /dev/null; then
        test_pass "Ollama installed (local AI)"

        # Test if Ollama is running
        if ollama list &> /dev/null; then
            MODELS=$(ollama list 2>/dev/null | tail -n +2 | wc -l)
            if [ "$MODELS" -gt 0 ]; then
                test_pass "Ollama has $MODELS model(s) installed"
            else
                test_warn "Ollama installed but no models" "Download: ollama pull llama3.2:3b"
            fi
        else
            test_warn "Ollama installed but not running" "Start: ollama serve"
        fi
    else
        test_warn "Ollama not found" "Install: https://ollama.com (optional, for local/free AI)"
    fi
}

################################################################################
# Test Installation Directory
################################################################################

test_installation_directory() {
    print_section "TEST 3: Installation Directory"

    # Test main directory
    if [ -d "$INSTALL_DIR" ]; then
        test_pass "Installation directory exists: $INSTALL_DIR"
    else
        test_fail "Installation directory not found" "Expected: $INSTALL_DIR"
        return
    fi

    # Test subdirectories
    if [ -d "$INSTALL_DIR/bin" ]; then
        test_pass "bin directory exists"
    else
        test_fail "bin directory not found" "Expected: $INSTALL_DIR/bin"
    fi

    if [ -d "$INSTALL_DIR/examples" ]; then
        test_pass "examples directory exists"
    else
        test_warn "examples directory not found" "Expected: $INSTALL_DIR/examples"
    fi

    if [ -d "$INSTALL_DIR/logs" ]; then
        test_pass "logs directory exists"
    else
        test_warn "logs directory not found" "Expected: $INSTALL_DIR/logs"
    fi

    # Test environment file
    if [ -f "$ENV_FILE" ]; then
        test_pass "Environment file exists"

        # Check permissions
        PERMS=$(stat -c "%a" "$ENV_FILE" 2>/dev/null || stat -f "%A" "$ENV_FILE" 2>/dev/null)
        if [ "$PERMS" == "600" ]; then
            test_pass "Environment file has correct permissions (600)"
        else
            test_warn "Environment file permissions: $PERMS" "Should be 600 for security"
        fi
    else
        test_fail "Environment file not found" "Expected: $ENV_FILE"
    fi

    # Test README
    if [ -f "$INSTALL_DIR/README.md" ]; then
        test_pass "README.md exists"
    else
        test_warn "README.md not found" "Expected: $INSTALL_DIR/README.md"
    fi
}

################################################################################
# Test Helper Scripts
################################################################################

test_helper_scripts() {
    print_section "TEST 4: Helper Scripts"

    # Test ai command
    if [ -f "$INSTALL_DIR/bin/ai" ] && [ -x "$INSTALL_DIR/bin/ai" ]; then
        test_pass "ai command exists and is executable"
    else
        test_fail "ai command not found or not executable" "Expected: $INSTALL_DIR/bin/ai"
    fi

    # Test ai-status
    if [ -f "$INSTALL_DIR/bin/ai-status" ] && [ -x "$INSTALL_DIR/bin/ai-status" ]; then
        test_pass "ai-status command exists and is executable"
    else
        test_fail "ai-status not found or not executable" "Expected: $INSTALL_DIR/bin/ai-status"
    fi

    # Test ai-setup
    if [ -f "$INSTALL_DIR/bin/ai-setup" ] && [ -x "$INSTALL_DIR/bin/ai-setup" ]; then
        test_pass "ai-setup command exists and is executable"
    else
        test_fail "ai-setup not found or not executable" "Expected: $INSTALL_DIR/bin/ai-setup"
    fi

    # Test ai-update
    if [ -f "$INSTALL_DIR/bin/ai-update" ] && [ -x "$INSTALL_DIR/bin/ai-update" ]; then
        test_pass "ai-update command exists and is executable"
    else
        test_fail "ai-update not found or not executable" "Expected: $INSTALL_DIR/bin/ai-update"
    fi
}

################################################################################
# Test PATH Configuration
################################################################################

test_path() {
    print_section "TEST 5: PATH Configuration"

    # Check if bin directory is in PATH
    if echo "$PATH" | grep -q "$INSTALL_DIR/bin"; then
        test_pass "Installation bin directory is in PATH"
    else
        test_fail "Installation bin directory not in PATH" "Add to ~/.bashrc or ~/.zshrc: export PATH=\"$INSTALL_DIR/bin:\$PATH\""
    fi

    # Check if Python user bin is in PATH
    if echo "$PATH" | grep -q "$HOME/.local/bin"; then
        test_pass "Python user bin directory is in PATH"
    else
        test_warn "Python user bin not in PATH" "Add to ~/.bashrc or ~/.zshrc: export PATH=\"$HOME/.local/bin:\$PATH\""
    fi

    # Test if commands are accessible
    if command -v ai &> /dev/null; then
        test_pass "ai command is in PATH"
    else
        test_fail "ai command not in PATH" "Run: source ~/.bashrc (or ~/.zshrc)"
    fi
}

################################################################################
# Test API Configuration
################################################################################

test_api_configuration() {
    print_section "TEST 6: API Configuration"

    if [ ! -f "$ENV_FILE" ]; then
        test_fail "Environment file not found" "Run: ai-setup"
        return
    fi

    source "$ENV_FILE" 2>/dev/null

    # Count configured providers
    CONFIGURED=0

    if [ -n "$GEMINI_API_KEY" ] && [ "$GEMINI_API_KEY" != "" ]; then
        test_pass "Gemini API key configured"
        ((CONFIGURED++))
    else
        test_warn "Gemini API key not set" "Get free key: https://aistudio.google.com/app/apikey"
    fi

    if [ -n "$OPENAI_API_KEY" ] && [ "$OPENAI_API_KEY" != "" ]; then
        test_pass "OpenAI API key configured"
        ((CONFIGURED++))
    else
        test_warn "OpenAI API key not set" "Optional. Get key: https://platform.openai.com/api-keys"
    fi

    if [ -n "$ANTHROPIC_API_KEY" ] && [ "$ANTHROPIC_API_KEY" != "" ]; then
        test_pass "Anthropic API key configured"
        ((CONFIGURED++))
    else
        test_warn "Anthropic API key not set" "Optional. Get key: https://console.anthropic.com/settings/keys"
    fi

    if [ -n "$DEEPSEEK_API_KEY" ] && [ "$DEEPSEEK_API_KEY" != "" ]; then
        test_pass "DeepSeek API key configured"
        ((CONFIGURED++))
    else
        test_warn "DeepSeek API key not set" "Optional. Get key: https://platform.deepseek.com/api_keys"
    fi

    if [ -n "$GROQ_API_KEY" ] && [ "$GROQ_API_KEY" != "" ]; then
        test_pass "Groq API key configured"
        ((CONFIGURED++))
    else
        test_warn "Groq API key not set" "Get free key: https://console.groq.com/keys"
    fi

    echo -e "\n${BLUE}ℹ Total configured providers: $CONFIGURED${NC}"

    if [ "$CONFIGURED" -eq 0 ]; then
        test_fail "No API keys configured" "Run: ai-setup to configure at least one provider"
    elif [ "$CONFIGURED" -lt 2 ]; then
        test_warn "Only $CONFIGURED provider configured" "Add more providers for better fallback coverage"
    else
        test_pass "$CONFIGURED providers configured (good coverage)"
    fi
}

################################################################################
# Test Functional Commands
################################################################################

test_functional() {
    print_section "TEST 7: Functional Tests (Optional)"

    echo -e "${YELLOW}These tests require valid API keys and may consume quota.${NC}"
    read -p "Run functional tests? [y/N]: " -n 1 -r
    echo

    if [[ ! $REPLY =~ ^[Yy]$ ]]; then
        test_warn "Functional tests skipped" "User declined"
        return
    fi

    # Load environment
    if [ -f "$ENV_FILE" ]; then
        source "$ENV_FILE"
    fi

    # Test Gemini API call (if configured)
    if [ -n "$GEMINI_API_KEY" ] && command -v gemini &> /dev/null; then
        echo -e "${BLUE}Testing Gemini CLI...${NC}"
        RESULT=$(gemini "Say 'OK'" 2>&1 | head -n 5)
        if echo "$RESULT" | grep -iq "OK\|ok"; then
            test_pass "Gemini CLI functional test passed"
        else
            test_fail "Gemini CLI functional test failed" "Response: $RESULT"
        fi
    fi

    # Test Ollama (if installed and running)
    if command -v ollama &> /dev/null; then
        if ollama list | grep -q "llama3.2:3b"; then
            echo -e "${BLUE}Testing Ollama...${NC}"
            RESULT=$(ollama run llama3.2:3b "Say OK" 2>&1 | head -n 5)
            if echo "$RESULT" | grep -iq "OK\|ok"; then
                test_pass "Ollama functional test passed"
            else
                test_warn "Ollama response unclear" "Response: $RESULT"
            fi
        else
            test_warn "Ollama llama3.2:3b model not installed" "Download: ollama pull llama3.2:3b"
        fi
    fi
}

################################################################################
# Test Example Scripts
################################################################################

test_examples() {
    print_section "TEST 8: Example Scripts"

    if [ ! -d "$INSTALL_DIR/examples" ]; then
        test_fail "Examples directory not found" "Expected: $INSTALL_DIR/examples"
        return
    fi

    EXAMPLE_COUNT=$(find "$INSTALL_DIR/examples" -name "*.sh" 2>/dev/null | wc -l)

    if [ "$EXAMPLE_COUNT" -gt 0 ]; then
        test_pass "Found $EXAMPLE_COUNT example script(s)"

        # Test if examples are executable
        NON_EXEC=$(find "$INSTALL_DIR/examples" -name "*.sh" ! -executable 2>/dev/null | wc -l)
        if [ "$NON_EXEC" -eq 0 ]; then
            test_pass "All example scripts are executable"
        else
            test_warn "$NON_EXEC example script(s) not executable" "Run: chmod +x $INSTALL_DIR/examples/*.sh"
        fi
    else
        test_warn "No example scripts found" "Expected at least 5 examples"
    fi
}

################################################################################
# Final Summary
################################################################################

print_summary() {
    echo -e "\n${PURPLE}════════════════════════════════════════════════════════════════════${NC}"
    echo -e "${PURPLE}                        TEST SUMMARY${NC}"
    echo -e "${PURPLE}════════════════════════════════════════════════════════════════════${NC}\n"

    TOTAL=$((TESTS_PASSED + TESTS_FAILED + TESTS_WARNING))

    echo -e "${GREEN}✓ Passed:  $TESTS_PASSED${NC}"
    echo -e "${RED}✗ Failed:  $TESTS_FAILED${NC}"
    echo -e "${YELLOW}⚠ Warnings: $TESTS_WARNING${NC}"
    echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo -e "${BLUE}  Total:   $TOTAL${NC}"

    echo -e "\n${PURPLE}════════════════════════════════════════════════════════════════════${NC}\n"

    if [ "$TESTS_FAILED" -eq 0 ]; then
        echo -e "${GREEN}✓ Installation looks good!${NC}\n"

        if [ "$TESTS_WARNING" -gt 0 ]; then
            echo -e "${YELLOW}There are $TESTS_WARNING warning(s) to address.${NC}"
            echo -e "${YELLOW}Review the warnings above for optimization suggestions.${NC}\n"
        fi

        echo -e "${CYAN}Next steps:${NC}"
        echo -e "  1. Run: ${BLUE}ai-status${NC} to see configured providers"
        echo -e "  2. Try: ${BLUE}ai \"What is recursion?\"${NC}"
        echo -e "  3. Explore examples: ${BLUE}ls $INSTALL_DIR/examples/${NC}\n"
    else
        echo -e "${RED}✗ Installation has issues that need to be fixed.${NC}\n"
        echo -e "${YELLOW}Review the failed tests above and:${NC}"
        echo -e "  1. Re-run the installer: ${BLUE}./install.sh${NC}"
        echo -e "  2. Configure API keys: ${BLUE}ai-setup${NC}"
        echo -e "  3. Check documentation: ${BLUE}cat $INSTALL_DIR/README.md${NC}\n"
    fi

    echo -e "${BLUE}For help, see: QUICKSTART.md${NC}\n"
}

################################################################################
# Main Test Execution
################################################################################

main() {
    print_header

    test_system_dependencies
    test_ai_clis
    test_installation_directory
    test_helper_scripts
    test_path
    test_api_configuration
    test_functional
    test_examples

    print_summary
}

main "$@"
