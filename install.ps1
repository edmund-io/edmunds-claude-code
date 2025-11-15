# AI CLI ORCHESTRATOR - Windows PowerShell Installation Script
#
# Usage (Run as Administrator):
#   irm https://raw.githubusercontent.com/YubenTT/edmunds-claude-code/main/install.ps1 | iex
#   OR
#   .\install.ps1
#
################################################################################

$ErrorActionPreference = "Continue"

# Installation directory
$InstallDir = "$env:USERPROFILE\.ai-cli-orchestrator"
$ConfigFile = "$InstallDir\config.yaml"
$EnvFile = "$InstallDir\.env"

################################################################################
# Helper Functions
################################################################################

function Write-Header {
    Write-Host ""
    Write-Host "╔════════════════════════════════════════════════════════════════════╗" -ForegroundColor Magenta
    Write-Host "║                                                                    ║" -ForegroundColor Magenta
    Write-Host "║           AI CLI ORCHESTRATOR - Installation Wizard                ║" -ForegroundColor Magenta
    Write-Host "║                                                                    ║" -ForegroundColor Magenta
    Write-Host "║  Max Free-Tier Exploitation System (Windows)                      ║" -ForegroundColor Magenta
    Write-Host "║  70+ CLIs • 7 Providers • $0-43/month for 10K requests/day        ║" -ForegroundColor Magenta
    Write-Host "║                                                                    ║" -ForegroundColor Magenta
    Write-Host "╚════════════════════════════════════════════════════════════════════╝" -ForegroundColor Magenta
    Write-Host ""
}

function Write-Step {
    param([string]$Message)
    Write-Host "▶ $Message" -ForegroundColor Cyan
}

function Write-Success {
    param([string]$Message)
    Write-Host "✓ $Message" -ForegroundColor Green
}

function Write-Failure {
    param([string]$Message)
    Write-Host "✗ $Message" -ForegroundColor Red
}

function Write-Warning {
    param([string]$Message)
    Write-Host "⚠ $Message" -ForegroundColor Yellow
}

################################################################################
# Check Administrator
################################################################################

function Test-Administrator {
    $currentUser = New-Object Security.Principal.WindowsPrincipal([Security.Principal.WindowsIdentity]::GetCurrent())
    return $currentUser.IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)
}

if (-not (Test-Administrator)) {
    Write-Warning "Not running as Administrator. Some installations may fail."
    Write-Warning "Right-click PowerShell and select 'Run as Administrator'"
    Write-Host ""
    $response = Read-Host "Continue anyway? [y/N]"
    if ($response -ne 'y' -and $response -ne 'Y') {
        exit
    }
}

################################################################################
# Dependency Installation
################################################################################

function Install-Chocolatey {
    if (Get-Command choco -ErrorAction SilentlyContinue) {
        Write-Success "Chocolatey already installed"
    } else {
        Write-Step "Installing Chocolatey package manager..."
        Set-ExecutionPolicy Bypass -Scope Process -Force
        [System.Net.ServicePointManager]::SecurityProtocol = [System.Net.ServicePointManager]::SecurityProtocol -bor 3072
        Invoke-Expression ((New-Object System.Net.WebClient).DownloadString('https://community.chocolatey.org/install.ps1'))
        Write-Success "Chocolatey installed"
    }
}

function Install-NodeJS {
    if (Get-Command node -ErrorAction SilentlyContinue) {
        $version = (node --version).Trim('v').Split('.')[0]
        if ([int]$version -ge 18) {
            Write-Success "Node.js already installed ($(node --version))"
        } else {
            Write-Warning "Node.js version is old. Upgrading..."
            choco upgrade nodejs -y
        }
    } else {
        Write-Step "Installing Node.js..."
        choco install nodejs -y
        Write-Success "Node.js installed"
    }
}

function Install-Python {
    if (Get-Command python -ErrorAction SilentlyContinue) {
        Write-Success "Python already installed ($(python --version))"
    } else {
        Write-Step "Installing Python..."
        choco install python -y
        Write-Success "Python installed"
    }
}

function Install-Git {
    if (Get-Command git -ErrorAction SilentlyContinue) {
        Write-Success "Git already installed"
    } else {
        Write-Step "Installing Git..."
        choco install git -y
        Write-Success "Git installed"
    }
}

################################################################################
# AI CLI Installation
################################################################################

function Install-GeminiCLI {
    Write-Step "Installing Google Gemini CLI..."
    npm install -g @google/gemini-cli 2>&1 | Out-Null
    if ($?) {
        Write-Success "Gemini CLI installed"
    } else {
        Write-Warning "Gemini CLI installation failed"
    }
}

function Install-Aider {
    Write-Step "Installing Aider (Best for coding)..."
    pip install --user aider-chat 2>&1 | Out-Null
    if ($?) {
        Write-Success "Aider installed"
    } else {
        Write-Warning "Aider installation failed"
    }
}

function Install-ShellGPT {
    Write-Step "Installing Shell-GPT..."
    pip install --user shell-gpt 2>&1 | Out-Null
    if ($?) {
        Write-Success "Shell-GPT installed"
    } else {
        Write-Warning "Shell-GPT installation failed"
    }
}

function Install-Ollama {
    Write-Step "Ollama installation for Windows..."
    Write-Host "Ollama offers 100% FREE local AI inference." -ForegroundColor Yellow
    $response = Read-Host "Download Ollama installer? [y/N]"

    if ($response -eq 'y' -or $response -eq 'Y') {
        Start-Process "https://ollama.com/download/windows"
        Write-Host "Please install Ollama from the opened browser window." -ForegroundColor Cyan
        Write-Host "After installation, run: ollama pull llama3.2:3b" -ForegroundColor Cyan
    } else {
        Write-Host "Skipping Ollama installation"
    }
}

################################################################################
# Configuration
################################################################################

function New-InstallationDirectory {
    Write-Step "Creating installation directory..."

    New-Item -ItemType Directory -Force -Path $InstallDir | Out-Null
    New-Item -ItemType Directory -Force -Path "$InstallDir\bin" | Out-Null
    New-Item -ItemType Directory -Force -Path "$InstallDir\logs" | Out-Null
    New-Item -ItemType Directory -Force -Path "$InstallDir\examples" | Out-Null

    Write-Success "Directory created: $InstallDir"
}

function Start-InteractiveConfig {
    Write-Header
    Write-Host "═══════════════════════════════════════════════════════════════" -ForegroundColor Cyan
    Write-Host "              API KEY CONFIGURATION WIZARD" -ForegroundColor Cyan
    Write-Host "═══════════════════════════════════════════════════════════════" -ForegroundColor Cyan
    Write-Host ""

    Write-Host "This wizard will help you configure API keys for various providers." -ForegroundColor Yellow
    Write-Host "You can skip any provider and add keys later by editing: $EnvFile" -ForegroundColor Yellow
    Write-Host ""

    # Google Gemini
    Write-Host "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━" -ForegroundColor Green
    Write-Host "🏆 GOOGLE GEMINI (FREE - HIGHLY RECOMMENDED)" -ForegroundColor Green
    Write-Host "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━" -ForegroundColor Green
    Write-Host "Free tier: 1 MILLION tokens/day (~`$200/month value)" -ForegroundColor White
    Write-Host "Get key: https://aistudio.google.com/app/apikey" -ForegroundColor Blue
    Write-Host ""
    $GeminiKey = Read-Host "Enter your Gemini API key (or press Enter to skip)"

    # OpenAI
    Write-Host ""
    Write-Host "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━" -ForegroundColor Cyan
    Write-Host "OPENAI (Trial Credits)" -ForegroundColor Cyan
    Write-Host "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━" -ForegroundColor Cyan
    Write-Host "Free tier: `$5 credits (3 months)" -ForegroundColor White
    Write-Host "Get key: https://platform.openai.com/api-keys" -ForegroundColor Blue
    Write-Host ""
    $OpenAIKey = Read-Host "Enter your OpenAI API key (or press Enter to skip)"

    # Anthropic
    Write-Host ""
    Write-Host "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━" -ForegroundColor Magenta
    Write-Host "ANTHROPIC CLAUDE (Best Quality)" -ForegroundColor Magenta
    Write-Host "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━" -ForegroundColor Magenta
    Write-Host "Free tier: `$5 trial credits" -ForegroundColor White
    Write-Host "Get key: https://console.anthropic.com/settings/keys" -ForegroundColor Blue
    Write-Host ""
    $AnthropicKey = Read-Host "Enter your Anthropic API key (or press Enter to skip)"

    # DeepSeek
    Write-Host ""
    Write-Host "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━" -ForegroundColor Yellow
    Write-Host "DEEPSEEK (Cheapest - 27x cheaper than OpenAI o1)" -ForegroundColor Yellow
    Write-Host "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━" -ForegroundColor Yellow
    Write-Host "Free tier: 1M tokens + `$1 credit trial" -ForegroundColor White
    Write-Host "Get key: https://platform.deepseek.com/api_keys" -ForegroundColor Blue
    Write-Host ""
    $DeepSeekKey = Read-Host "Enter your DeepSeek API key (or press Enter to skip)"

    # Groq
    Write-Host ""
    Write-Host "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━" -ForegroundColor Blue
    Write-Host "GROQ (Fastest - 300+ tokens/sec, FREE)" -ForegroundColor Blue
    Write-Host "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━" -ForegroundColor Blue
    Write-Host "Free tier: 14,400 requests/day, unlimited tokens" -ForegroundColor White
    Write-Host "Get key: https://console.groq.com/keys" -ForegroundColor Blue
    Write-Host ""
    $GroqKey = Read-Host "Enter your Groq API key (or press Enter to skip)"

    # Save to .env
    $EnvContent = @"
# AI CLI Orchestrator - Environment Configuration
# Generated: $(Get-Date)

# Google Gemini (FREE 1M tokens/day - HIGHLY RECOMMENDED)
GEMINI_API_KEY=$GeminiKey

# OpenAI (`$5 trial credits)
OPENAI_API_KEY=$OpenAIKey

# Anthropic Claude (`$5 trial credits, best quality)
ANTHROPIC_API_KEY=$AnthropicKey

# DeepSeek (1M tokens trial, cheapest after trial)
DEEPSEEK_API_KEY=$DeepSeekKey

# Groq (FREE forever, fastest)
GROQ_API_KEY=$GroqKey

# xAI Grok (optional - no free tier as of 2025)
XAI_API_KEY=

# Configuration
AI_CLI_ORCHESTRATOR_DIR=$InstallDir
AI_CLI_ORCHESTRATOR_LOG_LEVEL=info
"@

    $EnvContent | Out-File -FilePath $EnvFile -Encoding UTF8
    Write-Success "Configuration saved to: $EnvFile"

    # Count configured
    $Configured = 0
    if ($GeminiKey) { $Configured++ }
    if ($OpenAIKey) { $Configured++ }
    if ($AnthropicKey) { $Configured++ }
    if ($DeepSeekKey) { $Configured++ }
    if ($GroqKey) { $Configured++ }

    Write-Host ""
    Write-Success "Configured $Configured provider(s)"
    Write-Host ""
}

################################################################################
# Create Helper Scripts (Windows Batch Files)
################################################################################

function New-HelperScripts {
    Write-Step "Creating helper scripts..."

    # Main ai.bat script
    $AiBat = @'
@echo off
REM AI CLI Orchestrator - Main Entry Point (Windows)

set INSTALL_DIR=%USERPROFILE%\.ai-cli-orchestrator
set ENV_FILE=%INSTALL_DIR%\.env

REM Load environment variables
if exist "%ENV_FILE%" (
    for /f "delims== tokens=1,2" %%G in (%ENV_FILE%) do (
        if not "%%G"=="" if not "%%H"=="" set %%G=%%H
    )
)

REM Route to appropriate CLI
set TASK_TYPE=%1
shift
set PROMPT=%*

if "%TASK_TYPE%"=="code" (
    if exist "C:\Users\%USERNAME%\AppData\Roaming\Python\Python*\Scripts\aider.exe" (
        aider --message "%PROMPT%"
    ) else if not "%GEMINI_API_KEY%"=="" (
        gemini "%PROMPT%"
    ) else (
        echo No coding provider configured
    )
) else if "%TASK_TYPE%"=="shell" (
    sgpt "%PROMPT%"
) else if "%TASK_TYPE%"=="chat" (
    if not "%GEMINI_API_KEY%"=="" (
        gemini "%PROMPT%"
    ) else (
        echo No chat provider configured
    )
) else (
    REM Default: use Gemini
    if not "%GEMINI_API_KEY%"=="" (
        gemini "%TASK_TYPE% %PROMPT%"
    ) else (
        echo No AI provider configured. Run: ai-setup.bat
    )
)
'@
    $AiBat | Out-File -FilePath "$InstallDir\bin\ai.bat" -Encoding ASCII

    # ai-status.bat
    $StatusBat = @'
@echo off
echo AI CLI Orchestrator - System Status
echo ====================================
echo.
set ENV_FILE=%USERPROFILE%\.ai-cli-orchestrator\.env

if exist "%ENV_FILE%" (
    findstr /C:"GEMINI_API_KEY=" "%ENV_FILE%" >nul && echo   ✓ Google Gemini configured || echo   ✗ Google Gemini not configured
    findstr /C:"OPENAI_API_KEY=" "%ENV_FILE%" >nul && echo   ✓ OpenAI configured || echo   ✗ OpenAI not configured
    findstr /C:"ANTHROPIC_API_KEY=" "%ENV_FILE%" >nul && echo   ✓ Anthropic Claude configured || echo   ✗ Anthropic not configured
) else (
    echo Environment file not found. Run: ai-setup.bat
)

echo.
echo Installed CLIs:
where gemini >nul 2>&1 && echo   ✓ Gemini CLI || echo   ✗ Gemini CLI
where aider >nul 2>&1 && echo   ✓ Aider || echo   ✗ Aider
where sgpt >nul 2>&1 && echo   ✓ Shell-GPT || echo   ✗ Shell-GPT
where ollama >nul 2>&1 && echo   ✓ Ollama || echo   ✗ Ollama
'@
    $StatusBat | Out-File -FilePath "$InstallDir\bin\ai-status.bat" -Encoding ASCII

    Write-Success "Helper scripts created"
}

function Add-ToPath {
    Write-Step "Adding to PATH..."

    $BinPath = "$InstallDir\bin"
    $CurrentPath = [Environment]::GetEnvironmentVariable("PATH", "User")

    if ($CurrentPath -notlike "*$BinPath*") {
        [Environment]::SetEnvironmentVariable("PATH", "$CurrentPath;$BinPath", "User")
        $env:PATH = "$env:PATH;$BinPath"
        Write-Success "Added to PATH"
    } else {
        Write-Success "Already in PATH"
    }
}

################################################################################
# Main Installation
################################################################################

Write-Header

Write-Host "STEP 1: Installing System Dependencies" -ForegroundColor Cyan
Write-Host "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━" -ForegroundColor Cyan
Write-Host ""
Install-Chocolatey
Install-NodeJS
Install-Python
Install-Git

Write-Host ""
Write-Host "STEP 2: Installing AI CLIs" -ForegroundColor Cyan
Write-Host "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━" -ForegroundColor Cyan
Write-Host ""
Install-GeminiCLI
Install-Aider
Install-ShellGPT
Install-Ollama

Write-Host ""
Write-Host "STEP 3: Configuration" -ForegroundColor Cyan
Write-Host "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━" -ForegroundColor Cyan
Write-Host ""
New-InstallationDirectory
Start-InteractiveConfig

Write-Host ""
Write-Host "STEP 4: Creating Helper Scripts" -ForegroundColor Cyan
Write-Host "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━" -ForegroundColor Cyan
Write-Host ""
New-HelperScripts
Add-ToPath

Write-Host ""
Write-Host "╔════════════════════════════════════════════════════════════════════╗" -ForegroundColor Green
Write-Host "║                                                                    ║" -ForegroundColor Green
Write-Host "║              ✓ INSTALLATION COMPLETED SUCCESSFULLY!               ║" -ForegroundColor Green
Write-Host "║                                                                    ║" -ForegroundColor Green
Write-Host "╚════════════════════════════════════════════════════════════════════╝" -ForegroundColor Green
Write-Host ""

Write-Host "Next Steps:" -ForegroundColor Yellow
Write-Host ""
Write-Host "1. Restart your PowerShell to refresh PATH" -ForegroundColor White
Write-Host ""
Write-Host "2. Check system status:" -ForegroundColor White
Write-Host "   ai-status.bat" -ForegroundColor Blue
Write-Host ""
Write-Host "3. Try your first AI command:" -ForegroundColor White
Write-Host "   ai.bat `"What is recursion?`"" -ForegroundColor Blue
Write-Host ""
Write-Host "4. Read documentation:" -ForegroundColor White
Write-Host "   type $InstallDir\README.md" -ForegroundColor Blue
Write-Host ""
