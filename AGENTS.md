<!-- BEGIN:nextjs-agent-rules -->
# This is NOT the Next.js you know

This version has breaking changes — APIs, conventions, and file structure may all differ from your training data. Read the relevant guide in `node_modules/next/dist/docs/` before writing any code. Heed deprecation notices.
<!-- END:nextjs-agent-rules -->

## Cursor Cloud specific instructions

Dependencies (`npm install`) and `prisma generate` are handled by the startup update script. Commands: `npm run dev` (port 3000), `npm run build`, `npm run lint` (see `package.json`). There are no automated tests.

- **PostgreSQL is required and runs locally in the VM.** The DB service is not auto-started — start it each session with `sudo pg_ctlcluster 16 main start`. A `scheduler` database and `scheduler`/`scheduler` role are provisioned, and an untracked `.env` already points `DATABASE_URL`/`DIRECT_URL` at `postgresql://scheduler:scheduler@localhost:5432/scheduler`. If the DB/role are ever missing, recreate via `sudo -u postgres createuser scheduler` / `createdb -O scheduler scheduler`.
- **Apply the schema with `npx prisma db push`, NOT `prisma migrate deploy`** — there is no `prisma/migrations/` folder (the README's `migrate deploy` will fail). `prisma.config.ts` reads `DIRECT_URL`/`DATABASE_URL` from `.env`.
- **Auth is Google OAuth via NextAuth (database sessions through the Prisma adapter).** `GOOGLE_CLIENT_ID`/`GOOGLE_CLIENT_SECRET`/`MUAPIAPP_API_KEY` are provided as Cursor secrets and copied into the untracked `.env`; if those secrets are rotated, update `.env` to match. With them set, `/login` redirects to a real Google consent screen and `/api/social/accounts` lists the live MuAPI-connected "Moonbow" YouTube/TikTok accounts. Stripe vars are optional for local dev.
- **Testing authenticated flows without a Google user account:** completing Google's own login screen needs a real Google account, which isn't available here. Instead, seed a NextAuth **database session** and use it: insert a `User` (with `credits`) and a `Session` row, then set the browser cookie `next-auth.session-token=<sessionToken>` (e.g. via the DevTools console; the app reads it server-side). This authenticates the dashboard and loads real accounts. **Scheduling a future-dated post only persists to Postgres — it does NOT call MuAPI.** An *immediate* publish DOES call MuAPI and would post to the real Moonbow channels, so always use a future `scheduledAt` for tests. Video upload goes through `/api/upload` → MuAPI `upload_file` (returns a CDN URL); a small local MP4 works.
