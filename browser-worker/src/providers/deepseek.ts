import { Page } from 'playwright'
import { logger } from '../logger.js'

export async function automateDeepSeek(page: Page, prompt: string) {
  logger.info('Navigating to DeepSeek')
  await page.goto('https://chat.deepseek.com/', { waitUntil: 'networkidle', timeout: 60000 })

  // Check if logged in
  const isLoggedIn = await page
    .locator('textarea[placeholder*="Ask"]')
    .isVisible({ timeout: 5000 })
    .catch(() => false)

  if (!isLoggedIn) {
    throw new Error('Session expired - not logged in to DeepSeek')
  }

  logger.info('Sending prompt to DeepSeek')

  // Enter prompt
  await page.fill('textarea[placeholder*="Ask"]', prompt)
  await page.keyboard.press('Enter')

  // Wait for response
  await page.waitForSelector('.message-content.assistant', { timeout: 90000 })

  // Wait for streaming completion
  logger.info('Waiting for DeepSeek response to complete')
  await page.waitForFunction(
    () => {
      const stopBtn = document.querySelector('button[aria-label*="Stop"]')
      return !stopBtn || stopBtn.hasAttribute('disabled')
    },
    { timeout: 120000 }
  )

  // Extract response
  const response = await page.locator('.message-content.assistant').last().textContent()

  if (!response) {
    throw new Error('Failed to extract DeepSeek response')
  }

  logger.info('Successfully received DeepSeek response', {
    responseLength: response.length,
  })

  return {
    text: response.trim(),
    tokens: estimateTokens(prompt + response),
    provider: 'deepseek',
    model: 'deepseek-web',
  }
}

function estimateTokens(text: string): number {
  // Rough estimation: ~4 characters per token
  return Math.ceil(text.length / 4)
}
