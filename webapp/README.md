# AI CLI Orchestrator - React Webapp

Web-based dashboard for managing AI provider accounts and monitoring quota usage.

## Features

- **Account Management** - Add/remove AI provider accounts (ChatGPT, Claude, Gemini, DeepSeek)
- **Real-time Quota Tracking** - Live updates on daily/monthly usage limits
- **Authentication** - Secure login with Supabase Auth
- **Responsive Design** - Works on desktop, tablet, and mobile
- **Dark Mode** - Automatic dark mode support

## Tech Stack

- React 18
- TypeScript
- Vite (build tool)
- TailwindCSS (styling)
- Supabase (backend)
- React Query (data fetching)

## Development

```bash
# Install dependencies
npm install

# Copy environment template
cp .env.example .env

# Fill in your Supabase credentials in .env
# VITE_SUPABASE_URL=https://your-project.supabase.co
# VITE_SUPABASE_ANON_KEY=...

# Start dev server
npm run dev

# Open http://localhost:3000
```

## Build

```bash
# Build for production
npm run build

# Preview production build
npm run preview
```

## Docker

```bash
# Build image
docker build -t ai-orchestrator-webapp .

# Run container
docker run -p 3000:80 \
  -e VITE_SUPABASE_URL=https://your-project.supabase.co \
  -e VITE_SUPABASE_ANON_KEY=... \
  ai-orchestrator-webapp
```

## Project Structure

```
src/
├── components/        # React components
│   ├── QuotaDashboard.tsx
│   ├── AccountList.tsx
│   └── AddAccountModal.tsx
├── hooks/             # Custom React hooks
│   ├── useQuotas.ts
│   └── useAccounts.ts
├── lib/               # Utilities
│   └── supabase.ts
├── App.tsx            # Main app component
├── main.tsx           # Entry point
└── index.css          # Global styles
```

## Environment Variables

- `VITE_SUPABASE_URL` - Your Supabase project URL
- `VITE_SUPABASE_ANON_KEY` - Your Supabase anon/public key
- `VITE_API_URL` - API Gateway URL (optional)

## License

MIT
