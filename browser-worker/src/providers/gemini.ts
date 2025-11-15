import { Page } from 'playwright'
import { logger } from '../logger.js'

export async function automateGemini(page: Page, prompt: string) {
  logger.info('Navigating to Gemini')
  await page.goto('https://gemini.google.com/app', { waitUntil: 'networkidle', timeout: 60000 })

  // Check if logged in
  const isLoggedIn = await page
    .locator('rich-textarea')
    .isVisible({ timeout: 5000 })
    .catch(() => false)

  if (!isLoggedIn) {
    throw new Error('Session expired - not logged in to Gemini')
  }

  logger.info('Sending prompt to Gemini')

  // Enter prompt
  await page.fill('rich-textarea', prompt)
  await page.keyboard.press('Enter')

  // Wait for response
  await page.waitForSelector('.model-response-text', { timeout: 90000 })

  // Wait for generation to complete (Stop button becomes disabled or disappears)
  logger.info('Waiting for Gemini response to complete')
  await page.waitForFunction(
    () => {
      const stopBtn = document.querySelector('button[aria-label*="Stop"]')
      return stopBtn === null || stopBtn.getAttribute('aria-disabled') === 'true'
    },
    { timeout: 120000 }
  )

  // Extract response
  const response = await page.locator('.model-response-text').last().textContent()

  if (!response) {
    throw new Error('Failed to extract Gemini response')
  }

  logger.info('Successfully received Gemini response', {
    responseLength: response.length,
  })

  return {
    text: response.trim(),
    tokens: estimateTokens(prompt + response),
    provider: 'gemini',
    model: 'gemini-web',
  }
}

function estimateTokens(text: string): number {
  // Rough estimation: ~4 characters per token
  return Math.ceil(text.length / 4)
}
