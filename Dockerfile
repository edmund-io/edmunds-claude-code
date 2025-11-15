# AI CLI Orchestrator - Docker Image
# Provides a containerized environment with all AI CLIs installed
#
# Usage:
#   docker build -t ai-cli-orchestrator .
#   docker run -it --env-file .env ai-cli-orchestrator ai "Your prompt"
#

FROM node:20-slim

LABEL maintainer="AI CLI Orchestrator"
LABEL description="Maximum free-tier AI CLI orchestration system"
LABEL version="1.0.0"

# Install system dependencies
RUN apt-get update && apt-get install -y \
    python3 \
    python3-pip \
    python3-venv \
    curl \
    git \
    ca-certificates \
    && rm -rf /var/lib/apt/lists/*

# Create app directory
WORKDIR /app

# Install Node.js-based CLIs
RUN npm install -g \
    @google/gemini-cli \
    && npm cache clean --force

# Install Python-based CLIs
RUN pip3 install --no-cache-dir \
    aider-chat \
    shell-gpt \
    deepseek-cli \
    && rm -rf /root/.cache/pip

# Create installation directory
RUN mkdir -p /root/.ai-cli-orchestrator/bin \
    && mkdir -p /root/.ai-cli-orchestrator/logs \
    && mkdir -p /root/.ai-cli-orchestrator/examples

# Copy configuration files
COPY quota-config.yaml /root/.ai-cli-orchestrator/config.yaml
COPY AI_CLI_MASTER_RESEARCH_REPORT.md /app/docs/

# Create the main ai wrapper script
RUN echo '#!/bin/bash\n\
\n\
# Load environment variables\n\
if [ -f "/root/.ai-cli-orchestrator/.env" ]; then\n\
    set -a\n\
    source /root/.ai-cli-orchestrator/.env\n\
    set +a\n\
fi\n\
\n\
TASK_TYPE="$1"\n\
shift\n\
PROMPT="$@"\n\
\n\
case "$TASK_TYPE" in\n\
    code|coding)\n\
        if [ -n "$ANTHROPIC_API_KEY" ] && command -v aider &> /dev/null; then\n\
            aider --message "$PROMPT"\n\
        elif [ -n "$GEMINI_API_KEY" ]; then\n\
            gemini "$PROMPT"\n\
        else\n\
            echo "No coding provider configured"\n\
            exit 1\n\
        fi\n\
        ;;\n\
    shell|cmd)\n\
        if command -v sgpt &> /dev/null; then\n\
            sgpt "$PROMPT"\n\
        else\n\
            echo "Shell-GPT not installed"\n\
            exit 1\n\
        fi\n\
        ;;\n\
    chat|ask|*)\n\
        if [ -n "$GEMINI_API_KEY" ] && command -v gemini &> /dev/null; then\n\
            gemini "$TASK_TYPE $PROMPT"\n\
        else\n\
            echo "No chat provider configured"\n\
            exit 1\n\
        fi\n\
        ;;\n\
esac\n\
' > /root/.ai-cli-orchestrator/bin/ai

RUN chmod +x /root/.ai-cli-orchestrator/bin/ai

# Add to PATH
ENV PATH="/root/.ai-cli-orchestrator/bin:${PATH}"
ENV PATH="/root/.local/bin:${PATH}"

# Set working directory
WORKDIR /workspace

# Default command
CMD ["/bin/bash"]

# Health check
HEALTHCHECK --interval=30s --timeout=10s --start-period=5s --retries=3 \
    CMD command -v gemini &> /dev/null || exit 1

# Volume for workspace
VOLUME ["/workspace"]

# Environment variables placeholder (override with --env-file)
ENV GEMINI_API_KEY=""
ENV OPENAI_API_KEY=""
ENV ANTHROPIC_API_KEY=""
ENV DEEPSEEK_API_KEY=""
ENV GROQ_API_KEY=""
