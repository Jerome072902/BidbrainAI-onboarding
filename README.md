# BidbrainAI — Local Dev Stack (Docker)

Everything runs in containers. The only local requirement is **Docker Desktop**.

> Setting this up on a new machine? Follow **SETUP.md** — full step-by-step guide.

## Start

```powershell
cd "C:\Commissions Folder\BidbrainAI\local-dev"
.\dev.ps1
```

First run takes several minutes (builds the api image, installs portal dependencies inside the container). After that, starts are fast.

| Service | URL | Notes |
|---|---|---|
| Portal | http://localhost:3000 | `next dev` with hot reload — edit files in `bidbrainai-portal` and the browser updates |
| API | http://localhost:8000/docs | FastAPI + Swagger UI |
| Postgres | `localhost:5432` | user/pass/db: `postgres` / `postgres` / `postgres` |

Migrations (`alembic upgrade head`, including the demo seed data) run automatically before the api starts.

## Commands

```powershell
.\dev.ps1 logs      # follow api + portal logs
.\dev.ps1 down      # stop (keeps data)
.\dev.ps1 reset     # stop + wipe database and caches
.\dev.ps1 rebuild   # rebuild api image after changing api code
.\dev.ps1 status    # container status
```

Portal code changes hot-reload automatically. **API code changes need `.\dev.ps1 rebuild`** (the api runs from a built image, not a mount).

## What's included / not included

This is the **core** stack: Postgres + api + portal. The self-hosted Supabase services (gotrue auth, storage, Kong, Studio) are **not** included, so:

- The login *form* doesn't work (no gotrue to check passwords). Instead, run `.\dev-login.ps1` — it mints a real session token signed with the local JWT secret for a seeded demo user (default: `lex@bidbrain.ai`, the bidbrain admin) and prints a one-line cookie snippet to paste in the browser console. After that, all pages work with real seeded data.
- File uploads (briefs) and anything hitting Supabase Storage will fail at call time. The api boots fine regardless.
- llm-gateway, n8n, www, and the Cloudflare scraper are not part of this stack; api settings point at their in-Docker/production defaults and calls to them fail gracefully.

If you later need real auth/storage locally, the Supabase compose templates in `bidbrainai-infra/ansible/templates/supabase-*` can be adapted into this file.

## Files

- `docker-compose.yml` — the stack definition
- `.env.db`, `.env.api`, `.env.portal` — local-only env (secrets randomly generated for this machine; not production values)
- `dev.ps1` — control script

## Troubleshooting

- **Port already in use** — something on your machine is using 3000/8000/5432. Stop it or edit the `ports:` mapping in `docker-compose.yml`.
- **Portal shows nothing for a while** — first compile of `next dev` is slow; check `.\dev.ps1 logs`.
- **Portal wedged after big source changes** — `docker compose exec portal rm -rf /app/.next` then `docker compose restart portal` (known Turbopack cache issue, Bug #1031).
- **Migrations failed** — `docker compose logs migrations`. A wiped restart is `.\dev.ps1 reset` then `.\dev.ps1`.
