import { Worker, Job } from 'bullmq'
import { config } from './config.js'
import { logger } from './logger.js'
import {
  getBrowserContext,
  saveBrowserSession,
  takeScreenshot,
  closeContext,
} from './browser.js'
import { automateChat } from './providers/index.js'
import {
  updateAccountStatus,
  updateQuota,
  logUsage,
  supabase,
} from './supabase.js'

interface ChatRequestJob {
  type: 'chat-request'
  request_id: string
  account_id: string
  provider: string
  prompt: string
  priority: number
}

export function createWorker() {
  const worker = new Worker<ChatRequestJob>(
    'chat-requests',
    async (job: Job<ChatRequestJob>) => {
      const startTime = Date.now()
      const { account_id, provider, prompt, request_id } = job.data

      logger.info('Processing chat request', {
        requestId: request_id,
        accountId: account_id,
        provider,
        promptLength: prompt.length,
      })

      try {
        // Update request status to processing
        await supabase
          .from('requests')
          .update({ status: 'processing' })
          .eq('id', request_id)

        // Get browser context
        const context = await getBrowserContext(account_id)
        const page = context.pages()[0] || (await context.newPage())

        // Execute automation
        const response = await automateChat(provider, page, prompt)

        const latencyMs = Date.now() - startTime

        // Update quota
        await updateQuota(account_id, provider, response.tokens)

        // Log usage
        await logUsage(
          account_id,
          provider,
          request_id,
          response.tokens,
          latencyMs,
          'success'
        )

        // Save session
        await saveBrowserSession(account_id, context)

        // Update account last_used_at
        await supabase
          .from('accounts')
          .update({ last_used_at: new Date().toISOString() })
          .eq('id', account_id)

        // Update request with result
        await supabase
          .from('requests')
          .update({
            status: 'completed',
            provider_used: provider,
            response: response.text,
            tokens_used: response.tokens,
            latency_ms: latencyMs,
            completed_at: new Date().toISOString(),
          })
          .eq('id', request_id)

        logger.info('Chat request completed successfully', {
          requestId: request_id,
          provider,
          tokens: response.tokens,
          latencyMs,
        })

        return response
      } catch (error) {
        const latencyMs = Date.now() - startTime
        const errorMessage = (error as Error).message

        logger.error('Chat request failed', {
          requestId: request_id,
          provider,
          error: errorMessage,
        })

        // Take screenshot on error
        const context = await getBrowserContext(account_id).catch(() => null)
        if (context) {
          const page = context.pages()[0]
          if (page) {
            await takeScreenshot(page, account_id, `error-${request_id}`)
          }
        }

        // Log error
        await logUsage(account_id, provider, request_id, 0, latencyMs, 'error', errorMessage)

        // Update request status
        await supabase
          .from('requests')
          .update({
            status: 'failed',
            error_message: errorMessage,
            latency_ms: latencyMs,
            completed_at: new Date().toISOString(),
          })
          .eq('id', request_id)

        // Check if session expired
        if (errorMessage.includes('Session expired') || errorMessage.includes('not logged in')) {
          await updateAccountStatus(account_id, 'expired')
          logger.warn('Account marked as expired', { accountId: account_id })
        }

        throw error
      }
    },
    {
      connection: {
        host: config.redis.url.replace('redis://', '').split(':')[0],
        port: parseInt(config.redis.url.split(':')[2] || '6379'),
      },
      concurrency: config.browser.concurrency,
      limiter: {
        max: 10,
        duration: 1000,
      },
    }
  )

  worker.on('completed', (job) => {
    logger.info('Job completed', {
      jobId: job.id,
      requestId: job.data.request_id,
    })
  })

  worker.on('failed', (job, error) => {
    logger.error('Job failed', {
      jobId: job?.id,
      requestId: job?.data.request_id,
      error: error.message,
    })
  })

  worker.on('error', (error) => {
    logger.error('Worker error', { error: error.message })
  })

  return worker
}
