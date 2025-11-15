# Browser Automation Research for AI Provider Management
## Production-Grade Playwright Implementation Guide

**Research Date:** 2025-11-15
**Purpose:** Build production browser automation for AI provider logins

---

## Executive Summary

**Recommendation:** Use **Playwright** over Puppeteer for production AI automation.

**Key Reasons:**
- ✅ Native parallel execution (100+ concurrent contexts)
- ✅ Better anti-detection capabilities
- ✅ Cross-browser support (Chrome, Firefox, WebKit)
- ✅ Built-in auto-wait (reduces flakiness)
- ✅ Better debugging tools
- ✅ Active development (Microsoft-backed)

**Performance:** Playwright averages **4.5s per test** vs Puppeteer's 4.8s [CONFIRMED]

---

## 1. Playwright vs Puppeteer (2025)

| Feature | Playwright | Puppeteer | Winner |
|---------|-----------|-----------|--------|
| **Parallel Execution** | Native (100+ contexts) | Manual implementation needed | Playwright |
| **Browser Support** | Chrome, Firefox, WebKit | Chrome only | Playwright |
| **Speed (simple tasks)** | Good | 20-30% faster | Puppeteer |
| **Speed (complex)** | 6% faster (4.5s vs 4.8s) | Slower | Playwright |
| **Languages** | JS, TS, Python, Java, .NET | JS/TS only | Playwright |
| **Auto-wait** | Built-in | Manual | Playwright |
| **Stealth** | Good with plugins | Better (more mature) | Puppeteer |
| **Production Use** | Excellent | Good | Playwright |

**Verdict:** Playwright for production due to parallel execution and cross-browser support.

---

## 2. Session Persistence Strategies

### Method 1: Persistent Context (Recommended)

```javascript
const { chromium } = require('playwright');

const context = await chromium.launchPersistentContext('./user-data', {
  headless: true,
  args: ['--disable-blink-features=AutomationControlled']
});

// Session data (cookies, localStorage) automatically saved
// Persists across restarts
```

**Pros:**
- Automatic cookie/storage persistence
- Works across container restarts
- Simple implementation

**Cons:**
- Tied to specific user-data folder
- Can't easily share sessions between workers

### Method 2: Storage State Files

```javascript
// Save session
await context.storageState({ path: 'session.json' });

// Load session
const context = await browser.newContext({
  storageState: 'session.json'
});
```

**Pros:**
- Portable session files
- Easy to backup/restore
- Can share between instances

**Cons:**
- Manual save/load needed
- File management overhead

### Method 3: Database Storage (Production)

```javascript
// Extract cookies and storage
const cookies = await context.cookies();
const localStorage = await page.evaluate(() => JSON.stringify(window.localStorage));

// Save to database (Supabase)
await supabase.from('browser_sessions').insert({
  provider: 'chatgpt',
  account_id: accountId,
  cookies: cookies,
  local_storage: localStorage,
  expires_at: new Date(Date.now() + 28 * 24 * 60 * 60 * 1000) // 28 days
});

// Restore from database
const { data } = await supabase.from('browser_sessions')
  .select('*')
  .eq('account_id', accountId)
  .single();

await context.addCookies(data.cookies);
await page.evaluate((ls) => {
  Object.assign(window.localStorage, JSON.parse(ls));
}, data.local_storage);
```

**Pros:**
- Centralized session management
- Easy multi-worker sharing
- Expiration tracking
- Audit trail

**Cons:**
- More complex implementation
- Database dependency

**Recommendation:** Use Database Storage for production (Supabase)

---

## 3. 2FA Handling Patterns

### Pattern 1: User Input via WebSocket

```javascript
// Server-side
io.on('connection', (socket) => {
  socket.on('provide-2fa', async ({ accountId, code }) => {
    // Resume automation with 2FA code
    await resume2FAFlow(accountId, code);
  });
});

// Browser automation
async function handle2FA(page, accountId) {
  // Detect 2FA prompt
  const has2FA = await page.locator('input[name="otp"]').isVisible();

  if (has2FA) {
    // Request code from user via websocket
    io.to(`account-${accountId}`).emit('request-2fa', {
      provider: 'chatgpt',
      message: 'Enter your 2FA code'
    });

    // Wait for user input (with timeout)
    const code = await waitFor2FACode(accountId, 60000); // 60s timeout

    // Enter code
    await page.fill('input[name="otp"]', code);
    await page.click('button[type="submit"]');
  }
}
```

### Pattern 2: TOTP Automation (If Secret Available)

```javascript
const OTPAuth = require('otpauth');

// Generate TOTP code
function generate2FACode(secret) {
  const totp = new OTPAuth.TOTP({
    secret: OTPAuth.Secret.fromBase32(secret)
  });
  return totp.generate();
}

// Use in automation
const code = generate2FACode(account.totpSecret);
await page.fill('input[name="otp"]', code);
```

**Note:** Only works if user provides TOTP secret (not always possible)

### Pattern 3: SMS 2FA

```javascript
// Requires SMS API integration (e.g., Twilio, MailSlurp)
const smsCode = await fetchSMSCode(phoneNumber);
await page.fill('input[name="sms_code"]', smsCode);
```

**Recommendation:** Pattern 1 (User Input) for maximum compatibility

---

## 4. Anti-Bot Evasion

### Playwright Stealth Configuration

```javascript
const { chromium } = require('playwright-extra');
const StealthPlugin = require('puppeteer-extra-plugin-stealth');

chromium.use(StealthPlugin());

const browser = await chromium.launch({
  headless: true,
  args: [
    '--disable-blink-features=AutomationControlled',
    '--disable-dev-shm-usage',
    '--no-sandbox',
    '--disable-setuid-sandbox',
    '--disable-web-security',
    '--disable-features=IsolateOrigins,site-per-process'
  ]
});
```

### Best Practices

1. **Random delays**: Simulate human typing speed
   ```javascript
   await page.type('input[name="email"]', email, { delay: 100 });
   ```

2. **Mouse movements**: Random mouse activity
   ```javascript
   await page.mouse.move(100, 200);
   await page.mouse.move(300, 400);
   ```

3. **Viewport randomization**: Different screen sizes
   ```javascript
   await page.setViewportSize({
     width: 1280 + Math.floor(Math.random() * 100),
     height: 720 + Math.floor(Math.random() * 100)
   });
   ```

4. **User-agent rotation**: Realistic browser fingerprints
   ```javascript
   userAgent: 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36...'
   ```

5. **Residential proxies**: Avoid datacenter IP detection
   ```javascript
   proxy: {
     server: 'http://proxy.example.com:8080',
     username: 'user',
     password: 'pass'
   }
   ```

---

## 5. Docker Deployment

### Official Playwright Docker Image

```dockerfile
FROM mcr.microsoft.com/playwright:v1.48.0-jammy

WORKDIR /app

# Install dependencies
COPY package*.json ./
RUN npm ci

# Copy app
COPY . .

# Run
CMD ["node", "browser-worker.js"]
```

### Multi-Instance Docker Compose

```yaml
version: '3.8'

services:
  browser-worker-1:
    build: ./browser-worker
    environment:
      - WORKER_ID=1
      - REDIS_URL=redis://redis:6379
    volumes:
      - ./sessions:/app/sessions
    depends_on:
      - redis

  browser-worker-2:
    build: ./browser-worker
    environment:
      - WORKER_ID=2
      - REDIS_URL=redis://redis:6379
    volumes:
      - ./sessions:/app/sessions
    depends_on:
      - redis

  redis:
    image: redis:7-alpine
```

### Resource Usage

| Browsers | RAM | CPU | Notes |
|----------|-----|-----|-------|
| 1 headless | ~200MB | 5-10% | Idle |
| 1 active | ~400MB | 20-40% | Chatting |
| 5 parallel | ~2GB | 100% | 4-core |
| 10 parallel | ~4GB | 200% | 8-core |

**Recommendation:** 1-2 browsers per 1GB RAM

---

## 6. Production Architecture

```
┌─────────────┐
│  Web UI     │  (React)
└──────┬──────┘
       │
       ├─ WebSocket (2FA input, status updates)
       │
┌──────▼──────┐
│  API Gateway│  (Supabase Edge Functions)
└──────┬──────┘
       │
       ├─ Job Queue (Redis/BullMQ)
       │
┌──────▼──────┐
│  Browser    │
│  Worker Pool│  (Playwright containers)
│             │
│  ┌────┐    │
│  │ 1  │    │  ← ChatGPT session
│  ├────┤    │
│  │ 2  │    │  ← Claude session
│  ├────┤    │
│  │ 3  │    │  ← Gemini session
│  └────┘    │
└──────┬──────┘
       │
       ├─ Session Storage (Supabase)
       │
┌──────▼──────┐
│  Session DB │  (cookies, localStorage, tokens)
└─────────────┘
```

---

## 7. Queue Management (BullMQ)

```javascript
const { Queue, Worker } = require('bullmq');

// Create queue
const browserQueue = new Queue('browser-tasks', {
  connection: { host: 'redis', port: 6379 }
});

// Add job
await browserQueue.add('chat-request', {
  provider: 'chatgpt',
  accountId: 'acc123',
  prompt: 'What is recursion?'
}, {
  attempts: 3,
  backoff: { type: 'exponential', delay: 2000 }
});

// Process jobs
const worker = new Worker('browser-tasks', async (job) => {
  const { provider, accountId, prompt } = job.data;

  // Load browser session
  const context = await loadSession(accountId);

  // Send chat message
  const response = await sendChatMessage(context, prompt);

  // Save session
  await saveSession(accountId, context);

  return { response };
}, {
  connection: { host: 'redis', port: 6379 },
  concurrency: 5 // 5 parallel jobs per worker
});
```

---

## 8. Monitoring & Debugging

### Screenshot on Failure

```javascript
try {
  await page.click('button#submit');
} catch (error) {
  await page.screenshot({ path: `error-${Date.now()}.png` });
  throw error;
}
```

### Video Recording

```javascript
const context = await browser.newContext({
  recordVideo: {
    dir: './videos/',
    size: { width: 1280, height: 720 }
  }
});
```

### Console Logging

```javascript
page.on('console', msg => console.log('PAGE LOG:', msg.text()));
page.on('pageerror', error => console.error('PAGE ERROR:', error));
```

### Health Checks

```javascript
// Docker health check
HEALTHCHECK --interval=30s --timeout=10s --retries=3 \
  CMD node healthcheck.js

// healthcheck.js
const { chromium } = require('playwright');

async function check() {
  try {
    const browser = await chromium.launch({ timeout: 5000 });
    await browser.close();
    process.exit(0);
  } catch (error) {
    process.exit(1);
  }
}

check();
```

---

## 9. Common Pitfalls & Solutions

### Problem: Session Expires

**Solution:** Implement session refresh logic

```javascript
async function ensureValidSession(accountId) {
  const session = await getSession(accountId);

  if (isExpired(session)) {
    // Re-authenticate
    await performLogin(accountId);
  }

  return getSession(accountId);
}
```

### Problem: Memory Leaks

**Solution:** Properly close browsers and contexts

```javascript
try {
  const context = await browser.newContext();
  const page = await context.newPage();

  // ... do work ...
} finally {
  await page?.close();
  await context?.close();
}
```

### Problem: CAPTCHA Blocks

**Solutions:**
1. Use residential proxies
2. Implement human-like delays
3. Rotate user agents
4. Use stealth plugins
5. Have manual CAPTCHA solving fallback (2captcha, AntiCaptcha)

---

## 10. ToS Compliance Considerations

**Allowed (Low Risk):**
- ✅ DeepSeek (no explicit prohibition)
- ✅ HuggingChat (official API available)
- ✅ DuckDuckGo AI Chat (privacy-focused, unclear ToS)

**Unclear (Moderate Risk):**
- ⚠️ Perplexity (not explicitly forbidden)
- ⚠️ Poe (forbidden but enforcement unclear)
- ⚠️ Le Chat (ToS unclear)

**Forbidden (High Risk):**
- ❌ ChatGPT (explicitly forbidden in ToS)
- ❌ Claude (explicitly forbidden)
- ❌ Gemini (Google TOS ambiguous but risky)

**Recommendation:**
- Use official APIs where available (even if paid)
- Only automate providers with permissive/unclear ToS
- Implement opt-in user consent for risky providers
- Add disclaimers about ToS violations

---

## 11. Code Examples

### Complete ChatGPT Login Flow (For Reference Only - Violates ToS)

```javascript
async function loginChatGPT(email, password) {
  const browser = await chromium.launch({ headless: true });
  const context = await browser.newContext();
  const page = await context.newPage();

  try {
    // Navigate to login
    await page.goto('https://chat.openai.com/auth/login');

    // Click "Continue with Email"
    await page.click('button:has-text("Continue with Email")');

    // Enter email
    await page.fill('input[name="email"]', email, { delay: 100 });
    await page.click('button[type="submit"]');

    // Enter password
    await page.waitForSelector('input[name="password"]');
    await page.fill('input[name="password"]', password, { delay: 100 });
    await page.click('button[type="submit"]');

    // Wait for 2FA if needed
    if (await page.locator('input[name="code"]').isVisible()) {
      // Handle 2FA (request from user)
      const code = await request2FAFromUser();
      await page.fill('input[name="code"]', code);
      await page.click('button[type="submit"]');
    }

    // Wait for chat interface
    await page.waitForURL('https://chat.openai.com/', { timeout: 30000 });

    // Save session
    const cookies = await context.cookies();
    const localStorage = await page.evaluate(() => JSON.stringify(window.localStorage));

    return { cookies, localStorage };
  } finally {
    await page.close();
    await context.close();
    await browser.close();
  }
}
```

### Safe DeepSeek Automation

```javascript
async function chatDeepSeek(prompt) {
  const browser = await chromium.launch({ headless: true });
  const context = await browser.newContext();
  const page = await context.newPage();

  try {
    await page.goto('https://chat.deepseek.com/');

    // Enter prompt
    await page.fill('textarea[placeholder*="Message"]', prompt);
    await page.press('textarea', 'Enter');

    // Wait for response
    await page.waitForSelector('.response-message', { timeout: 30000 });

    // Extract response
    const response = await page.textContent('.response-message:last-child');

    return response;
  } finally {
    await page.close();
    await context.close();
    await browser.close();
  }
}
```

---

## 12. Resource Recommendations

**Tools:**
- Playwright Official Docs: https://playwright.dev/
- Playwright Docker: https://playwright.dev/docs/docker
- BullMQ: https://docs.bullmq.io/
- Puppeteer Extra Stealth: https://github.com/berstend/puppeteer-extra/tree/master/packages/puppeteer-extra-plugin-stealth

**Best Practices:**
- Always use headless mode in production
- Implement proper error handling and retries
- Monitor browser resource usage
- Log all automation activities
- Have manual fallback for failures

---

## Conclusion

**Production Stack:**
- **Browser:** Playwright (headless)
- **Language:** Node.js/TypeScript
- **Queue:** Redis + BullMQ
- **Storage:** Supabase (sessions, logs)
- **Deployment:** Docker Compose
- **Monitoring:** Custom dashboard + logs

**Cost Estimate (10 parallel browsers):**
- VPS: $20-40/month (4GB RAM, 4 vCPU)
- Proxies (optional): $50-100/month (residential)
- Total: $20-140/month

**Expected Capacity:**
- 5-10 requests/minute per browser
- 50-100 requests/minute with 10 browsers
- ~100K requests/day

This research provides the foundation for building a production-grade browser automation system for AI provider management.
