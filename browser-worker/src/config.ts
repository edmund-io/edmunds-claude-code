export const config = {
  workerId: process.env.WORKER_ID || '1',
  workerName: process.env.WORKER_NAME || 'browser-worker-1',

  redis: {
    url: process.env.REDIS_URL || 'redis://localhost:6379',
  },

  supabase: {
    url: process.env.SUPABASE_URL!,
    serviceKey: process.env.SUPABASE_SERVICE_KEY!,
  },

  browser: {
    concurrency: parseInt(process.env.CONCURRENCY || '2'),
    headless: process.env.HEADLESS !== 'false',
    screenshotOnError: process.env.SCREENSHOT_ON_ERROR !== 'false',
    videoRecording: process.env.VIDEO_RECORDING === 'true',
    sessionTimeout: parseInt(process.env.SESSION_TIMEOUT || '300000'), // 5 minutes
  },

  directories: {
    sessions: process.env.BROWSER_USER_DATA_DIR || '/app/sessions',
    screenshots: process.env.SCREENSHOT_DIR || '/app/screenshots',
    videos: process.env.VIDEO_DIR || '/app/videos',
  },
}

// Validation
if (!config.supabase.url || !config.supabase.serviceKey) {
  throw new Error('Missing required environment variables: SUPABASE_URL, SUPABASE_SERVICE_KEY')
}
