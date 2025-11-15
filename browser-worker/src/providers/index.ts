import { Page } from 'playwright'
import { automateChatGPT } from './chatgpt.js'
import { automateClaude } from './claude.js'
import { automateGemini } from './gemini.js'
import { automateDeepSeek } from './deepseek.js'

export interface ChatResponse {
  text: string
  tokens: number
  provider: string
  model: string
}

export async function automateChat(
  provider: string,
  page: Page,
  prompt: string
): Promise<ChatResponse> {
  switch (provider.toLowerCase()) {
    case 'chatgpt':
      return await automateChatGPT(page, prompt)
    case 'claude':
      return await automateClaude(page, prompt)
    case 'gemini':
      return await automateGemini(page, prompt)
    case 'deepseek':
      return await automateDeepSeek(page, prompt)
    default:
      throw new Error(`Unknown provider: ${provider}`)
  }
}
