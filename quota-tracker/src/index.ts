import { createClient } from '@supabase/supabase-js'
import { Redis } from 'ioredis'
import winston from 'winston'
import http from 'http'

// Configuration
const config = {
  supabase: {
    url: process.env.SUPABASE_URL!,
    serviceKey: process.env.SUPABASE_SERVICE_KEY!,
  },
  redis: {
    url: process.env.REDIS_URL || 'redis://localhost:6379',
  },
  checkInterval: parseInt(process.env.CHECK_INTERVAL || '60000'), // 60 seconds
  alertThreshold: parseFloat(process.env.ALERT_THRESHOLD || '0.9'), // 90%
}

// Logger
const logger = winston.createLogger({
  level: process.env.LOG_LEVEL || 'info',
  format: winston.format.combine(
    winston.format.timestamp(),
    winston.format.errors({ stack: true }),
    winston.format.json()
  ),
  defaultMeta: { service: 'quota-tracker' },
  transports: [
    new winston.transports.Console({
      format: winston.format.combine(
        winston.format.colorize(),
        winston.format.printf(({ timestamp, level, message, ...meta }) => {
          return `${timestamp} [${level}]: ${message} ${
            Object.keys(meta).length ? JSON.stringify(meta, null, 2) : ''
          }`
        })
      ),
    }),
    new winston.transports.File({ filename: 'error.log', level: 'error' }),
    new winston.transports.File({ filename: 'combined.log' }),
  ],
})

// Supabase client
const supabase = createClient(config.supabase.url, config.supabase.serviceKey, {
  auth: {
    autoRefreshToken: false,
    persistSession: false,
  },
})

// Redis client
const redis = new Redis(config.redis.url)

// Main quota checking function
async function checkQuotas() {
  try {
    logger.info('Starting quota check')

    // Fetch all quotas with active accounts
    const { data: quotas, error } = await supabase
      .from('quotas')
      .select('*, accounts(*)')
      .eq('accounts.status', 'active')

    if (error) throw error

    if (!quotas || quotas.length === 0) {
      logger.info('No active accounts to check')
      return
    }

    logger.info(`Checking quotas for ${quotas.length} accounts`)

    for (const quota of quotas) {
      const now = new Date()

      // Reset daily quota if past reset time
      if (new Date(quota.reset_daily_at) <= now) {
        logger.info('Resetting daily quota', {
          accountId: quota.account_id,
          provider: quota.provider,
          previousUsage: quota.daily_used,
        })

        await supabase
          .from('quotas')
          .update({
            daily_used: 0,
            reset_daily_at: new Date(now.getTime() + 24 * 60 * 60 * 1000).toISOString(),
            updated_at: now.toISOString(),
          })
          .eq('id', quota.id)

        // If account was quota_exceeded, mark as active
        if (quota.accounts?.status === 'quota_exceeded') {
          await supabase
            .from('accounts')
            .update({ status: 'active' })
            .eq('id', quota.account_id)

          logger.info('Account reactivated after quota reset', {
            accountId: quota.account_id,
          })
        }
      }

      // Reset monthly quota if past reset time
      if (quota.reset_monthly_at && new Date(quota.reset_monthly_at) <= now) {
        logger.info('Resetting monthly quota', {
          accountId: quota.account_id,
          provider: quota.provider,
          previousUsage: quota.monthly_used,
        })

        await supabase
          .from('quotas')
          .update({
            monthly_used: 0,
            reset_monthly_at: new Date(
              now.getFullYear(),
              now.getMonth() + 1,
              1
            ).toISOString(),
            updated_at: now.toISOString(),
          })
          .eq('id', quota.id)
      }

      // Check if approaching daily limit
      const dailyUsagePercentage = quota.daily_used / quota.daily_limit

      if (
        dailyUsagePercentage >= config.alertThreshold &&
        dailyUsagePercentage < 1.0
      ) {
        await sendAlert({
          type: 'quota_warning',
          accountId: quota.account_id,
          provider: quota.provider,
          usagePercentage: dailyUsagePercentage,
          used: quota.daily_used,
          limit: quota.daily_limit,
          remaining: quota.daily_limit - quota.daily_used,
        })
      }

      // Check if daily limit exceeded
      if (dailyUsagePercentage >= 1.0) {
        logger.warn('Daily quota exceeded', {
          accountId: quota.account_id,
          provider: quota.provider,
          used: quota.daily_used,
          limit: quota.daily_limit,
        })

        await sendAlert({
          type: 'quota_exceeded',
          accountId: quota.account_id,
          provider: quota.provider,
          usagePercentage: dailyUsagePercentage,
          used: quota.daily_used,
          limit: quota.daily_limit,
        })

        // Mark account as quota_exceeded
        await supabase
          .from('accounts')
          .update({ status: 'quota_exceeded' })
          .eq('id', quota.account_id)
      }

      // Check monthly limit if applicable
      if (quota.monthly_limit) {
        const monthlyUsagePercentage = quota.monthly_used / quota.monthly_limit

        if (monthlyUsagePercentage >= 1.0) {
          logger.warn('Monthly quota exceeded', {
            accountId: quota.account_id,
            provider: quota.provider,
            used: quota.monthly_used,
            limit: quota.monthly_limit,
          })

          await sendAlert({
            type: 'monthly_quota_exceeded',
            accountId: quota.account_id,
            provider: quota.provider,
            usagePercentage: monthlyUsagePercentage,
            used: quota.monthly_used,
            limit: quota.monthly_limit,
          })

          await supabase
            .from('accounts')
            .update({ status: 'quota_exceeded' })
            .eq('id', quota.account_id)
        }
      }
    }

    logger.info('Quota check completed')
  } catch (error) {
    logger.error('Error checking quotas', {
      error: (error as Error).message,
      stack: (error as Error).stack,
    })
  }
}

// Send alert (via Realtime, Redis pub/sub, or webhook)
async function sendAlert(alert: any) {
  logger.warn('Sending alert', alert)

  try {
    // Publish to Redis for real-time updates
    await redis.publish('quota_alerts', JSON.stringify(alert))

    // Could also send to webhook, email, Slack, etc.
    // await sendWebhook(alert)
    // await sendEmail(alert)

    // Store alert in database
    await supabase.from('alerts').insert({
      type: alert.type,
      account_id: alert.accountId,
      provider: alert.provider,
      data: alert,
      created_at: new Date().toISOString(),
    })
  } catch (error) {
    logger.error('Failed to send alert', {
      error: (error as Error).message,
      alert,
    })
  }
}

// Session refresh check
async function checkExpiringSessions() {
  try {
    logger.info('Checking for expiring sessions')

    const sevenDaysFromNow = new Date(Date.now() + 7 * 24 * 60 * 60 * 1000)

    const { data: sessions, error } = await supabase
      .from('browser_sessions')
      .select('*, accounts(*)')
      .lt('expires_at', sevenDaysFromNow.toISOString())
      .eq('accounts.status', 'active')

    if (error) throw error

    if (!sessions || sessions.length === 0) {
      logger.info('No expiring sessions found')
      return
    }

    logger.warn(`Found ${sessions.length} sessions expiring within 7 days`)

    for (const session of sessions) {
      logger.warn('Session expiring soon', {
        accountId: session.account_id,
        expiresAt: session.expires_at,
      })

      // Send alert
      await sendAlert({
        type: 'session_expiring',
        accountId: session.account_id,
        provider: session.accounts?.provider,
        expiresAt: session.expires_at,
      })
    }
  } catch (error) {
    logger.error('Error checking expiring sessions', {
      error: (error as Error).message,
    })
  }
}

// Health check server
const server = http.createServer((req, res) => {
  if (req.url === '/health') {
    res.writeHead(200, { 'Content-Type': 'application/json' })
    res.end(
      JSON.stringify({
        status: 'healthy',
        uptime: process.uptime(),
        lastCheck: new Date().toISOString(),
      })
    )
  } else {
    res.writeHead(404)
    res.end()
  }
})

server.listen(8080, () => {
  logger.info('Health check server listening on port 8080')
})

// Start periodic checks
logger.info('Starting quota tracker service', {
  checkInterval: config.checkInterval,
  alertThreshold: config.alertThreshold,
})

// Run immediately
checkQuotas()
checkExpiringSessions()

// Schedule periodic checks
setInterval(checkQuotas, config.checkInterval)
setInterval(checkExpiringSessions, 24 * 60 * 60 * 1000) // Daily

// Graceful shutdown
process.on('SIGTERM', async () => {
  logger.info('Received SIGTERM, shutting down gracefully')
  server.close()
  await redis.quit()
  process.exit(0)
})

process.on('SIGINT', async () => {
  logger.info('Received SIGINT, shutting down gracefully')
  server.close()
  await redis.quit()
  process.exit(0)
})

logger.info('Quota tracker started successfully')
