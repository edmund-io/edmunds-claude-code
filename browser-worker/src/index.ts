import { createWorker } from './worker.js'
import { closeAllContexts } from './browser.js'
import { logger } from './logger.js'
import { config } from './config.js'
import http from 'http'

logger.info('Starting browser worker', {
  workerId: config.workerId,
  workerName: config.workerName,
  concurrency: config.browser.concurrency,
  headless: config.browser.headless,
})

// Create worker
const worker = createWorker()

// Health check server
const server = http.createServer((req, res) => {
  if (req.url === '/health') {
    res.writeHead(200, { 'Content-Type': 'application/json' })
    res.end(
      JSON.stringify({
        status: 'healthy',
        workerId: config.workerId,
        uptime: process.uptime(),
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

// Graceful shutdown
process.on('SIGTERM', async () => {
  logger.info('Received SIGTERM, shutting down gracefully')

  // Close worker
  await worker.close()

  // Close all browser contexts
  await closeAllContexts()

  // Close health check server
  server.close()

  process.exit(0)
})

process.on('SIGINT', async () => {
  logger.info('Received SIGINT, shutting down gracefully')

  await worker.close()
  await closeAllContexts()
  server.close()

  process.exit(0)
})

// Handle uncaught exceptions
process.on('uncaughtException', (error) => {
  logger.error('Uncaught exception', { error: error.message, stack: error.stack })
  process.exit(1)
})

process.on('unhandledRejection', (reason, promise) => {
  logger.error('Unhandled rejection', { reason, promise })
  process.exit(1)
})

logger.info('Browser worker started successfully')
