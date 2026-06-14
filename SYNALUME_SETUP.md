# Synalume — scheduler fork setup notes

**Fork:** https://github.com/synalume/Free-AI-Social-Media-Scheduler  
**Upstream:** https://github.com/Anil-matcha/Free-AI-Social-Media-Scheduler  
**Local clone:** `synalume-workspace/synalume-social-scheduler/`

## Quick local dev

```bash
cd synalume-social-scheduler
cp .env.example .env
# Fill .env — see docs/notes/ambient_pov_manual_setup_checklist.md

npm install
npx prisma db push    # no migrations folder in upstream; use db push
npm run dev
```

## Pull upstream updates

```bash
git fetch upstream
git merge upstream/main
```

## Synalume integration

Publishing from Moonbow Command Center does **not** use this app's `/api/posts` directly.  
Use the **synalume-marketing bridge** (`POST /publish`) — see `docs/notes/ambient_pov_social_scheduler_setup.md`.

This app is still required to **OAuth-connect** YouTube/TikTok to MuAPI and to discover `account_id` values.

---

## Phase 8 — Deploy to Vercel (production scheduler)

**Decision:** Scheduler on **Vercel**; Synalume publish bridge on **Cloud Run** (Phase 9).

### 1. Push fork (Synalume fixes)

Ensure `main` on [synalume/Free-AI-Social-Media-Scheduler](https://github.com/synalume/Free-AI-Social-Media-Scheduler) includes MuAPI account-list fixes before importing to Vercel.

### 2. Import to Vercel

1. [vercel.com/new](https://vercel.com/new) → **Import** → GitHub → `synalume/Free-AI-Social-Media-Scheduler`
2. Framework: **Next.js** (auto-detected)
3. Build command: `npm run build` (runs `prisma generate && next build`)
4. Deploy once with env vars from step 3 below

### 3. Environment variables (Vercel → Settings → Environment Variables)

Copy from local `.env` (Production + Preview):

| Variable | Production value |
|----------|------------------|
| `DATABASE_URL` | Neon **pooled** connection string |
| `DIRECT_URL` | Neon **direct** connection string |
| `NEXTAUTH_SECRET` | Same as local (`openssl rand -base64 32`) |
| `GOOGLE_CLIENT_ID` | GCP OAuth web client |
| `GOOGLE_CLIENT_SECRET` | GCP OAuth secret |
| `MUAPIAPP_API_KEY` | `moonbow-marketing-prod` key |
| `STRIPE_*` | Leave empty unless using Stripe checkout |

**After first deploy**, set URL-dependent vars to your Vercel URL (or custom domain):

| Variable | Example |
|----------|---------|
| `NEXTAUTH_URL` | `https://free-ai-social-media-scheduler.vercel.app` |
| `WEBHOOK_URL` | Same as `NEXTAUTH_URL` |

Redeploy after updating `NEXTAUTH_URL` / `WEBHOOK_URL`.

### 4. Google OAuth redirect URI

In [Google Cloud Console](https://console.cloud.google.com/) → APIs & Services → Credentials → your **Web client**:

Add **Authorized redirect URI**:

```
https://YOUR-VERCEL-URL/api/auth/callback/google
```

Keep `http://localhost:3000/api/auth/callback/google` for local dev.

### 5. Verify production

1. Open production URL → **Sign in** with `team@synalume.com`
2. **Integrations** → confirm **Moonbow (YouTube)** appears (connected via MuAPI dashboard; do **not** use Connect YouTube on Vercel — MuAPI ext OAuth redirect is still broken)
3. Optional smoke test: upload short MP4 → YouTube → Moonbow → Unlisted → Publish

Save for bridge `.env`:

```env
MUAPI_YOUTUBE_ACCOUNT_ID=48
SCHEDULER_APP_URL=https://YOUR-VERCEL-URL
```

### 6. Custom domain (optional)

Vercel → Domains → e.g. `scheduler.moonbow.app` → update `NEXTAUTH_URL`, `WEBHOOK_URL`, and Google OAuth redirect to match → redeploy.

### Troubleshooting

| Issue | Fix |
|-------|-----|
| Build fails on Prisma | Ensure `DATABASE_URL` + `DIRECT_URL` set in Vercel before build |
| Sign-in redirect loop | `NEXTAUTH_URL` must exactly match deployed URL (no trailing slash) |
| Integrations empty | Confirm `MUAPIAPP_API_KEY` is prod key; accounts API uses `https://muapi.ai/api/social/accounts` |
| YouTube Connect fails | Use MuAPI dashboard Integrations instead of scheduler Connect button |
