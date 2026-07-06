# Running BidbrainAI locally

Everything runs in Docker containers — the api, the portal, and the database. You don't need Python, Node, or Postgres on your machine.

## Start the stack

Open PowerShell in this folder and run:

```powershell
.\dev.ps1
```

The first run is slow (several minutes). It builds the api image, pulls the Postgres and Node images, runs all database migrations including the demo seed data, and installs the portal's dependencies inside the container. Every run after that is fast.

If PowerShell complains that running scripts is disabled, use this instead:

```powershell
powershell -ExecutionPolicy Bypass -File .\dev.ps1
```

You can watch what's happening with `.\dev.ps1 logs`. The portal is ready once Next.js prints `Ready`.

Once it's up:

- Portal → http://localhost:3000
- API → http://localhost:8000/docs
- Database → `localhost:5432`, user `postgres`, password `postgres`

## Sign in

There's no auth service in this stack, so the login form won't work. Instead you mint yourself a session:

```powershell
.\dev-login.ps1
```

The script prints a `document.cookie = "bb_session=..."` line. To use it: open http://localhost:3000, press F12, go to the **Console** tab, and paste that line. If Chrome refuses the paste, type `allow pasting` and hit Enter first, then paste again.

Now open http://localhost:3000/dashboard — you're signed in as `lex@bidbrain.ai`, the seeded admin, for 30 days. Use a normal browser window; incognito forgets the cookie when you close it.

## Day to day

Start with `.\dev.ps1`, stop with `.\dev.ps1 down`. Your data survives stops and restarts.

Portal code changes reload automatically in the browser — just edit and save. API code changes need `.\dev.ps1 rebuild`, since the api runs from a built image.

If you ever want a completely fresh database, run `.\dev.ps1 reset`, start again with `.\dev.ps1`, and rerun `.\dev-login.ps1` (the reset wipes the user link the login script created).

## When something's off

**A port is already taken** — something else on your machine is using 3000, 8000, or 5432. Stop it, or change the left-hand number of the `ports:` mapping in `docker-compose.yml`.

**Bounced to /login after a reset** — that's the wiped user link. Rerun `.\dev-login.ps1`.

**Portal stuck or serving errors** — its build cache can wedge after big changes. Clear it with `docker compose exec portal rm -rf /app/.next` and then `docker compose restart portal`.

**Hydration warnings in the browser console** — almost always a browser extension touching the page (form fillers are the usual suspect). Harmless in dev.
