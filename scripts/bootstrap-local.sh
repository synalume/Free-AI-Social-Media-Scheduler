#!/usr/bin/env bash
# Bootstrap local scheduler after Phase 3 (Neon) + Phase 4 (Google OAuth) env is filled.
set -euo pipefail
cd "$(dirname "$0")/.."

if [[ ! -f .env ]]; then
  cp .env.example .env
  echo "Created .env from .env.example — fill DATABASE_URL, OAuth, and MUAPIAPP_API_KEY first."
  exit 1
fi

if grep -q 'ep-xxx' .env 2>/dev/null || grep -q 'NEXTAUTH_SECRET=""' .env 2>/dev/null; then
  echo "Fill .env (Neon URLs, NEXTAUTH_SECRET, Google OAuth, MUAPIAPP_API_KEY) then re-run."
  exit 1
fi

echo "Installing dependencies..."
npm install

echo "Pushing Prisma schema to Neon..."
npx prisma db push
npx prisma generate

echo ""
echo "Ready. Start dev server:"
echo "  npm run dev"
echo ""
echo "Then open http://localhost:3000 and sign in with team@synalume.com"
