# AI CLI Orchestrator V2 - Deployment Guide

Complete step-by-step guide to deploy the AI CLI Orchestrator V2 system.

## Prerequisites

### 1. Supabase Project

Create a free Supabase project at https://app.supabase.com

**Get your credentials:**
1. Go to Settings → API
2. Copy:
   - `Project URL` (SUPABASE_URL)
   - `anon/public` key (SUPABASE_ANON_KEY)
   - `service_role` key (SUPABASE_SERVICE_KEY)

### 2. Server Requirements

**Minimum specs:**
- 4GB RAM
- 2 vCPU
- 20GB SSD storage
- Ubuntu 20.04+ or Debian 11+

**Recommended providers:**
- Hetzner CPX31: €11.90/month (~$13)
- DigitalOcean: $24/month
- AWS t3.medium: ~$30/month

### 3. Docker Installation

```bash
# Install Docker
curl -fsSL https://get.docker.com -o get-docker.sh
sudo sh get-docker.sh

# Install Docker Compose
sudo apt-get install docker-compose-plugin

# Add user to docker group
sudo usermod -aG docker $USER
newgrp docker

# Verify installation
docker --version
docker compose version
```

## Step 1: Deploy Database Schema

1. **Open Supabase SQL Editor**
   - Go to https://app.supabase.com/project/YOUR_PROJECT/sql

2. **Copy and run schema**
   - Open `supabase/schema.sql`
   - Copy entire contents
   - Paste into SQL Editor
   - Click "Run"

3. **Verify tables created**
   ```sql
   SELECT table_name FROM information_schema.tables
   WHERE table_schema = 'public';
   ```

   You should see:
   - accounts
   - browser_sessions
   - quotas
   - usage_logs
   - requests
   - api_keys
   - alerts

4. **Enable Realtime**
   - Go to Database → Replication
   - Enable replication for: `accounts`, `quotas`, `requests`, `alerts`

## Step 2: Clone Repository

```bash
# Clone repository
git clone https://github.com/your-username/ai-cli-orchestrator.git
cd ai-cli-orchestrator

# Or if you're setting this up fresh:
mkdir ai-cli-orchestrator
cd ai-cli-orchestrator

# Copy all files from this project
```

## Step 3: Configure Environment

```bash
# Copy environment template
cp .env.v2.example .env

# Edit configuration
nano .env
```

**Fill in these critical values:**

```env
# Supabase (from Step 1)
SUPABASE_URL=https://your-project.supabase.co
SUPABASE_ANON_KEY=eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...
SUPABASE_SERVICE_KEY=eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...

# Redis (default for Docker)
REDIS_URL=redis://redis:6379

# Security (CHANGE THESE!)
JWT_SECRET=$(openssl rand -hex 32)
API_KEY_SALT=$(openssl rand -hex 32)
SESSION_ENCRYPTION_KEY=$(openssl rand -hex 32)
```

## Step 4: Build Docker Images

```bash
# Build all services
docker compose -f docker-compose.v2.yml build

# This will take 5-10 minutes
```

## Step 5: Start Services

```bash
# Start all containers
docker compose -f docker-compose.v2.yml up -d

# Check status
docker compose -f docker-compose.v2.yml ps

# You should see:
# ai-webapp           running   0.0.0.0:3000->80/tcp
# ai-api              running   0.0.0.0:3001->3001/tcp
# ai-redis            running   0.0.0.0:6379->6379/tcp
# ai-browser-worker-1 running
# ai-browser-worker-2 running
# ai-browser-worker-3 running
# ai-quota-tracker    running
```

## Step 6: Verify Deployment

### Check Webapp
```bash
curl http://localhost:3000
# Should return HTML
```

### Check Redis
```bash
docker compose -f docker-compose.v2.yml exec redis redis-cli ping
# Should return: PONG
```

### Check Worker Health
```bash
curl http://localhost:8080/health
# Should return: {"status":"healthy","workerId":"1","uptime":...}
```

### Check Logs
```bash
# View all logs
docker compose -f docker-compose.v2.yml logs -f

# View specific service
docker compose -f docker-compose.v2.yml logs -f browser-worker-1
```

## Step 7: Create First User & API Key

### Option A: Via Webapp (Recommended)

1. Open http://localhost:3000
2. Click "Sign Up"
3. Enter email and password
4. Check email for confirmation link
5. Log in
6. Dashboard will show no accounts yet

### Option B: Via Supabase Dashboard

1. Go to Authentication → Users
2. Create user manually
3. Copy user ID

### Create API Key (SQL)

```sql
-- Generate API key
INSERT INTO api_keys (user_id, name, key_hash, key_prefix)
VALUES (
  'YOUR-USER-ID-HERE',
  'My First API Key',
  encode(digest('sk_live_' || gen_random_uuid()::text, 'sha256'), 'hex'),
  'sk_live_abc...'
);

-- Get the generated key (run before insert to save it)
SELECT 'sk_live_' || replace(gen_random_uuid()::text, '-', '');
```

**Important:** Save the full API key! It's only shown once.

## Step 8: Add First AI Provider Account

### Via Webapp

1. Log into http://localhost:3000
2. Click "Add Account"
3. Select provider (e.g., "ChatGPT")
4. Enter email associated with that provider
5. Click "Add Account"

The account will be in "pending" status until you complete login.

### Complete Login (Browser Worker)

Check browser worker logs:
```bash
docker compose -f docker-compose.v2.yml logs -f browser-worker-1
```

The worker will attempt to automate login. For first-time setup, you may need to manually log in:

1. Access the browser worker container
2. Run Playwright in non-headless mode
3. Manually log in to the provider
4. Session will be saved automatically

**Alternative: Manual session import**
- Log in to ChatGPT/Claude/etc in your regular browser
- Export cookies using browser extension
- Import into database via SQL

## Step 9: Test the API

```bash
# Test chat endpoint
curl -X POST http://localhost:3001/api/v1/chat \
  -H "Authorization: Bearer YOUR_API_KEY_HERE" \
  -H "Content-Type: application/json" \
  -d '{
    "prompt": "What is recursion?",
    "provider": "auto"
  }'

# Response:
# {
#   "id": "req_abc123",
#   "status": "queued",
#   "provider_used": "chatgpt",
#   "estimated_wait": 5,
#   "quota_remaining": { ... }
# }

# Check status
curl http://localhost:3001/api/v1/status/req_abc123 \
  -H "Authorization: Bearer YOUR_API_KEY_HERE"

# Get quotas
curl http://localhost:3001/api/v1/quotas \
  -H "Authorization: Bearer YOUR_API_KEY_HERE"
```

## Step 10: Production Hardening

### Enable HTTPS with Nginx

```bash
# Install Nginx
sudo apt install nginx certbot python3-certbot-nginx

# Create Nginx config
sudo nano /etc/nginx/sites-available/ai-orchestrator
```

```nginx
server {
    listen 80;
    server_name your-domain.com;

    # Webapp
    location / {
        proxy_pass http://localhost:3000;
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
    }

    # API
    location /api/ {
        proxy_pass http://localhost:3001/;
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
    }
}
```

```bash
# Enable site
sudo ln -s /etc/nginx/sites-available/ai-orchestrator /etc/nginx/sites-enabled/
sudo nginx -t
sudo systemctl restart nginx

# Get SSL certificate
sudo certbot --nginx -d your-domain.com
```

### Configure Firewall

```bash
# Install UFW
sudo apt install ufw

# Allow SSH
sudo ufw allow 22/tcp

# Allow HTTP/HTTPS
sudo ufw allow 80/tcp
sudo ufw allow 443/tcp

# Enable firewall
sudo ufw enable
```

### Set Up Monitoring

```bash
# Install Prometheus Node Exporter
wget https://github.com/prometheus/node_exporter/releases/download/v1.7.0/node_exporter-1.7.0.linux-amd64.tar.gz
tar xvfz node_exporter-*.tar.gz
sudo mv node_exporter-*/node_exporter /usr/local/bin/
sudo useradd -rs /bin/false node_exporter

# Create systemd service
sudo nano /etc/systemd/system/node_exporter.service
```

```ini
[Unit]
Description=Node Exporter
After=network.target

[Service]
User=node_exporter
Group=node_exporter
Type=simple
ExecStart=/usr/local/bin/node_exporter

[Install]
WantedBy=multi-user.target
```

```bash
sudo systemctl daemon-reload
sudo systemctl start node_exporter
sudo systemctl enable node_exporter
```

### Automated Backups

```bash
# Create backup script
nano ~/backup.sh
```

```bash
#!/bin/bash
BACKUP_DIR="/backups"
DATE=$(date +%Y%m%d_%H%M%S)

# Backup Docker volumes
docker run --rm \
  -v ai-logs:/source \
  -v $BACKUP_DIR:/backup \
  alpine tar czf /backup/logs_$DATE.tar.gz -C /source .

# Backup .env
cp .env $BACKUP_DIR/env_$DATE

# Clean old backups (keep 30 days)
find $BACKUP_DIR -name "*.tar.gz" -mtime +30 -delete
```

```bash
chmod +x ~/backup.sh

# Add to crontab (daily at 2 AM)
crontab -e
0 2 * * * /home/user/backup.sh
```

## Troubleshooting

### Containers won't start

```bash
# Check logs
docker compose -f docker-compose.v2.yml logs

# Rebuild
docker compose -f docker-compose.v2.yml build --no-cache
docker compose -f docker-compose.v2.yml up -d
```

### Browser worker errors

```bash
# Check Playwright installation
docker compose -f docker-compose.v2.yml exec browser-worker-1 \
  npx playwright --version

# Reinstall browsers
docker compose -f docker-compose.v2.yml exec browser-worker-1 \
  npx playwright install chromium
```

### Session expired errors

Sessions expire after 28 days. Users need to re-login:

1. Delete expired session from database
2. Update account status to 'pending'
3. Re-run login flow

### Quota not resetting

Check quota tracker logs:
```bash
docker compose -f docker-compose.v2.yml logs -f quota-tracker
```

Force manual reset:
```sql
UPDATE quotas SET daily_used = 0, reset_daily_at = NOW() + INTERVAL '1 day';
```

## Scaling

### Add More Workers

Edit `docker-compose.v2.yml`:

```yaml
browser-worker-4:
  build: ./browser-worker
  environment:
    - WORKER_ID=4
    - CONCURRENCY=2
  # ... copy config from worker-1
```

```bash
docker compose -f docker-compose.v2.yml up -d --scale browser-worker=5
```

### Increase Worker Concurrency

```bash
# Edit .env
WORKER_CONCURRENCY=4  # from 2

# Restart workers
docker compose -f docker-compose.v2.yml restart browser-worker-1
```

## Support

- Documentation: `SYSTEM_ARCHITECTURE_V2_OAUTH.md`
- Issues: GitHub Issues
- Logs: `docker compose logs -f`

## Success Checklist

- [ ] Supabase project created
- [ ] Database schema deployed
- [ ] Realtime enabled
- [ ] Docker installed
- [ ] .env configured
- [ ] All containers running
- [ ] Webapp accessible
- [ ] First user created
- [ ] API key generated
- [ ] First account added
- [ ] Test request successful
- [ ] HTTPS enabled (production)
- [ ] Firewall configured (production)
- [ ] Backups scheduled (production)

**Deployment complete!** 🎉

Your AI CLI Orchestrator V2 is now running and ready to handle requests.
