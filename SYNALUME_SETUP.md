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
