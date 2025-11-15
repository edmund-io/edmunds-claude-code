import { chromium, BrowserContext, Page } from 'playwright'
import { config } from './config.js'
import { logger } from './logger.js'
import { loadSession, saveSession, supabase } from './supabase.js'
import path from 'path'

const contextPool = new Map<string, BrowserContext>()

export async function getBrowserContext(accountId: string): Promise<BrowserContext> {
  // Check if context already exists
  if (contextPool.has(accountId)) {
    logger.debug('Reusing existing browser context', { accountId })
    return contextPool.get(accountId)!
  }

  // Load session from database
  const session = await loadSession(accountId)

  // Launch browser with persistent context
  const userDataDir = path.join(config.directories.sessions, accountId)

  const context = await chromium.launchPersistentContext(userDataDir, {
    headless: config.browser.headless,
    args: [
      '--no-sandbox',
      '--disable-setuid-sandbox',
      '--disable-dev-shm-usage',
      '--disable-blink-features=AutomationControlled',
    ],
    viewport: { width: 1920, height: 1080 },
    userAgent:
      'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/120.0.0.0 Safari/537.36',
    recordVideo: config.browser.videoRecording
      ? {
          dir: config.directories.videos,
          size: { width: 1280, height: 720 },
        }
      : undefined,
  })

  // Restore session if exists
  if (session && new Date(session.expires_at) > new Date()) {
    logger.info('Restoring session from database', { accountId })

    try {
      // Add cookies
      await context.addCookies(session.cookies)

      // Restore localStorage
      const page = context.pages()[0] || (await context.newPage())
      await page.addInitScript((ls) => {
        Object.assign(window.localStorage, ls)
      }, session.local_storage)

      logger.info('Session restored successfully', { accountId })
    } catch (error) {
      logger.error('Failed to restore session', { accountId, error })
    }
  } else {
    logger.warn('No valid session found in database', { accountId })
  }

  // Store in pool
  contextPool.set(accountId, context)

  return context
}

export async function saveBrowserSession(
  accountId: string,
  context: BrowserContext
): Promise<void> {
  try {
    const cookies = await context.cookies()
    const page = context.pages()[0]

    if (!page) {
      logger.warn('No page available to save localStorage', { accountId })
      return
    }

    const localStorage = await page.evaluate(() => JSON.stringify(window.localStorage))

    const expiresAt = new Date(Date.now() + 28 * 24 * 60 * 60 * 1000) // 28 days

    await saveSession(accountId, cookies, localStorage, expiresAt)

    logger.info('Browser session saved to database', { accountId })
  } catch (error) {
    logger.error('Failed to save browser session', { accountId, error })
    throw error
  }
}

export async function takeScreenshot(
  page: Page,
  accountId: string,
  name: string
): Promise<string | null> {
  if (!config.browser.screenshotOnError) return null

  try {
    const screenshotPath = path.join(
      config.directories.screenshots,
      `${accountId}-${name}-${Date.now()}.png`
    )

    await page.screenshot({ path: screenshotPath, fullPage: true })

    // Upload to Supabase Storage
    const fileBuffer = await import('fs').then((fs) => fs.promises.readFile(screenshotPath))

    await supabase.storage.from('screenshots').upload(`${accountId}/${name}.png`, fileBuffer, {
      contentType: 'image/png',
      upsert: true,
    })

    logger.info('Screenshot saved', { accountId, path: screenshotPath })

    return screenshotPath
  } catch (error) {
    logger.error('Failed to save screenshot', { accountId, error })
    return null
  }
}

export async function closeContext(accountId: string): Promise<void> {
  const context = contextPool.get(accountId)

  if (context) {
    await context.close()
    contextPool.delete(accountId)
    logger.info('Browser context closed', { accountId })
  }
}

export async function closeAllContexts(): Promise<void> {
  logger.info('Closing all browser contexts', {
    count: contextPool.size,
  })

  for (const [accountId, context] of contextPool.entries()) {
    try {
      await context.close()
    } catch (error) {
      logger.error('Error closing context', { accountId, error })
    }
  }

  contextPool.clear()
}
