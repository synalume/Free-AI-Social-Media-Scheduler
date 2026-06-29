<!-- BEGIN:nextjs-agent-rules -->
# This is NOT the Next.js you know

This version has breaking changes — APIs, conventions, and file structure may all differ from your training data. Read the relevant guide in `node_modules/next/dist/docs/` before writing any code. Heed deprecation notices.
<!-- END:nextjs-agent-rules -->

## Cursor Cloud specific instructions

Dependencies (`npm install`) and `prisma generate` are handled by the startup update script. Commands: `npm run dev` (port 3000), `npm run build`, `npm run lint` (see `package.json`). There are no automated tests.

- **PostgreSQL is required and runs locally in the VM.** The DB service is not auto-started — start it each session with `sudo pg_ctlcluster 16 main start`. A `scheduler` database and `scheduler`/`scheduler` role are provisioned, and an untracked `.env` already points `DATABASE_URL`/`DIRECT_URL` at `postgresql://scheduler:scheduler@localhost:5432/scheduler`. If the DB/role are ever missing, recreate via `sudo -u postgres createuser scheduler` / `createdb -O scheduler scheduler`.
- **Apply the schema with `npx prisma db push`, NOT `prisma migrate deploy`** — there is no `prisma/migrations/` folder (the README's `migrate deploy` will fail). `prisma.config.ts` reads `DIRECT_URL`/`DATABASE_URL` from `.env`.
- **Auth is Google OAuth via NextAuth.** `GOOGLE_CLIENT_ID`/`GOOGLE_CLIENT_SECRET` are empty by default, so sign-in cannot complete and authenticated flows (creating posts via `/api/posts`, connecting accounts) are blocked without real OAuth credentials. Unauthenticated pages (`/`, `/login`, `/pricing`, `/gallery`, `/integrations`) render fine. Real publishing also needs `MUAPIAPP_API_KEY`; Stripe vars are optional for local dev.
