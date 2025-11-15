import { Page } from 'playwright'
import { logger } from '../logger.js'

export async function automateClaude(page: Page, prompt: string) {
  logger.info('Navigating to Claude')
  await page.goto('https://claude.ai/new', { waitUntil: 'networkidle', timeout: 60000 })

  // Check if logged in
  const isLoggedIn = await page
    .locator('div[contenteditable="true"]')
    .isVisible({ timeout: 5000 })
    .catch(() => false)

  if (!isLoggedIn) {
    throw new Error('Session expired - not logged in to Claude')
  }

  logger.info('Sending prompt to Claude')

  // Enter prompt
  const input = page.locator('div[contenteditable="true"]')
  await input.fill(prompt)
  await page.keyboard.press('Enter')

  // Wait for response to appear
  await page.waitForSelector('.font-claude-message', { timeout: 90000 })

  // Wait for streaming to finish (look for Copy button on last message)
  logger.info('Waiting for Claude response to complete')
  await page
    .locator('button:has-text("Copy")')
    .last()
    .waitFor({ state: 'visible', timeout: 120000 })

  // Extract response
  const response = await page.locator('.font-claude-message').last().textContent()

  if (!response) {
    throw new Error('Failed to extract Claude response')
  }

  logger.info('Successfully received Claude response', {
    responseLength: response.length,
  })

  return {
    text: response.trim(),
    tokens: estimateTokens(prompt + response),
    provider: 'claude',
    model: 'claude-web',
  }
}

function estimateTokens(text: string): number {
  // Rough estimation: ~4 characters per token
  return Math.ceil(text.length / 4)
}
