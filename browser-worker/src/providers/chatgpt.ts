import { Page } from 'playwright'
import { logger } from '../logger.js'

export async function automateChat GPT(page: Page, prompt: string) {
  logger.info('Navigating to ChatGPT')
  await page.goto('https://chat.openai.com/', { waitUntil: 'networkidle', timeout: 60000 })

  // Check if logged in
  const isLoggedIn = await page
    .locator('textarea[placeholder*="Message"]')
    .isVisible({ timeout: 5000 })
    .catch(() => false)

  if (!isLoggedIn) {
    throw new Error('Session expired - not logged in to ChatGPT')
  }

  logger.info('Sending prompt to ChatGPT')

  // Find textarea and enter prompt
  const textarea = page.locator('textarea[placeholder*="Message"]')
  await textarea.fill(prompt)
  await textarea.press('Enter')

  // Wait for response to appear
  await page.waitForSelector('[data-message-author-role="assistant"]', { timeout: 90000 })

  // Wait for streaming to complete (Stop generating button disappears)
  logger.info('Waiting for ChatGPT response to complete')
  await page
    .locator('button:has-text("Stop generating")')
    .waitFor({ state: 'hidden', timeout: 120000 })
    .catch(() => {
      // Button might not appear if response is quick
      logger.debug('Stop generating button not found (response might be complete)')
    })

  // Extract response
  const response = await page
    .locator('[data-message-author-role="assistant"]:last-child')
    .textContent()

  if (!response) {
    throw new Error('Failed to extract ChatGPT response')
  }

  logger.info('Successfully received ChatGPT response', {
    responseLength: response.length,
  })

  return {
    text: response.trim(),
    tokens: estimateTokens(prompt + response),
    provider: 'chatgpt',
    model: 'chatgpt-web',
  }
}

function estimateTokens(text: string): number {
  // Rough estimation: ~4 characters per token
  return Math.ceil(text.length / 4)
}
