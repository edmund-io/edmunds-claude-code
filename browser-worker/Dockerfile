# AI CLI Orchestrator - Browser Worker
# Playwright-based automation for web AI providers

FROM node:20-bookworm

# Install Playwright system dependencies
RUN npx -y playwright@1.41.1 install --with-deps chromium

WORKDIR /app

# Copy package files
COPY package*.json ./

# Install dependencies
RUN npm ci --only=production

# Copy source
COPY . .

# Build TypeScript
RUN npm run build

# Create directories
RUN mkdir -p /app/sessions /app/screenshots /app/videos

# Health check
HEALTHCHECK --interval=30s --timeout=10s --start-period=10s --retries=3 \
  CMD node -e "require('http').get('http://localhost:8080/health', (r) => r.statusCode === 200 ? process.exit(0) : process.exit(1))"

# Run worker
CMD ["node", "dist/index.js"]
