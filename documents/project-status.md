# BidbrainAI — where the project is at

*Written 2026-07-07, based on repo changelogs, migrations, and the phasing docs in `bidbrainai-project/docs`. The authoritative live view is the GitHub project "BidbrainAI Roadmap" on `bidbrainai-project`.*

## What the product does

BidbrainAI plans paid ad campaigns for marketing agencies using AI. An agency gives it a client's brief and website; the system scrapes the site, runs a chain of AI steps (brand analysis, keywords, campaign structure, ad copy), and produces ready-to-launch campaign assets — structure spreadsheets, media plans, schedules, slide decks. Eventually campaigns get pushed to the ad platforms (Google, LinkedIn, Meta, Reddit) and performance data flows back for reporting.

The roadmap has three named phases: **Cairns MVP → Go-Live MVP → Post-Go-Live**. We are between the first two.

## Done (roughly May–June 2026) — the Cairns MVP

The foundation is shipped and stable:

- **Infrastructure** — one production VPS running the whole stack as Docker containers, deployed by Ansible from `bidbrainai-infra`. Traefik for routing, Supabase for auth/storage, dev boxes on Proxmox.
- **Auth and tenancy** — multi-tenant (bidbrain staff / agencies / clients) with roles, permissions, and row-level security. Login via Supabase gotrue JWTs.
- **Portal** — the Next.js app: dashboard, campaigns, clients, reports, settings, and the `/admin` area (accounts, users, invitations, audit log, channel management, LLM config).
- **The planning pipeline** — the core value. Brief intake and extraction run inside the api; the scraper and LLM gateway (Claude primary, Gemini fallback) run the AI steps; plan artifacts generate via explicit endpoints with job tracking. Campaign lifecycle: `draft → ready → queued → active ⇄ paused → ended/failed`.

## In progress right now (July 2026) — the Activator front

The api shipped five releases on July 4–5 alone, all pointed at one thing: **connecting to real ad platforms**.

- Storing per-platform OAuth app credentials (admin-entered, encrypted).
- "Test connection" probes for Google Ads, Meta, Reddit, and LinkedIn.
- Centralised per-provider API version management, with canary checks and deprecation-signal capture (ADR-0051) so platform API changes are caught early.

This is the plumbing that lets a campaign reach Google Ads instead of stopping at a spreadsheet.

## Next — Go-Live MVP

- Wire the Activate / Deactivate / Manage Activations buttons in the portal to real campaign pushes.
- Performance data sync from the platforms, feeding the Reporter.
- Reporter exports (PowerPoint / PDF / Excel).
- Flag-gated features switch on at go-live: the invitation email flow and the Wallet/commercial surface (`POST_GO_LIVE_RELEASE`).

## Post-Go-Live

Wallet/billing fully live, customisable dashboard columns, richer quick actions, and whatever the roadmap adds between now and then.

## Glossary — terms you'll keep running into

- **Cairns / Cairns MVP** — the internal codename for the first milestone: plan campaigns end-to-end (brief in → assets out) and see them in the portal, without real ad-platform activation. Named like a release city codename; when docs tag something `[Cairns MVP]` it means "needed for that first milestone."
- **Go-Live MVP** — the second milestone: real customers, real activation. Campaigns actually push to ad platforms, performance data comes back, reports export.
- **Post-Go-Live** — everything deliberately deferred until after launch (Wallet/billing, column customisation, nicer quick actions). Guarded by the `POST_GO_LIVE_RELEASE` feature flag.
- **PoC/Beta** — the *old* Bidbrain system (n8n workflows on the `bidbrain01` server). Being kept alive on `*.beta.bidbrain.ai` while this new product replaces it. When docs say something was "superseded," it usually moved from the PoC's n8n into the new api.
- **Planner / Manager / Activator / Reporter** — the four campaign-management surfaces: Planner creates campaigns from briefs, Manager is the dashboard where you view and act on them, Activator pushes them to ad platforms, Reporter visualises performance and exports.
- **Orchestrator** — the api code that runs the multi-step AI pipeline in order (scrape → brand DNA → keywords → structure → copy → assets).
- **LLM gateway** — the small service that all AI calls go through. Routes to Claude first, falls back to Gemini, so the api never talks to AI providers directly.
- **gotrue** — Supabase's auth service. Checks passwords, issues the JWT session tokens the api verifies.
- **Tenant** — one account's isolated slice of the system (a bidbrain / agency / client account). "Multi-tenant" = many organisations share one deployment without seeing each other's data.
- **RLS** — row-level security: Postgres itself filters query rows by tenant, a safety net under the application checks.
- **ADR** — Architectural Decision Record. Numbered docs (ADR-0011, ADR-0051...) explaining *why* a design choice was made. Never edited, only superseded.
- **Epic / Feature / Story / Task / Spike / Bug** — the GitHub issue types, largest to smallest. All issues live in `bidbrainai-project`.
- **Vault** — Ansible Vault, the encrypted file in `bidbrainai-infra` holding real production secrets (API keys, OAuth credentials).
- **n8n** — a workflow-automation tool (like Zapier, self-hosted). The new product only uses it for side jobs like invitation emails; the old PoC ran everything on it.

## Useful starting points

- `bidbrainai-project/docs/onboarding/developer.md` — the team's own onboarding guide.
- `bidbrainai-project/docs/domains/campaign-management/` — planner / manager / activator / reporter specs, each with a phasing summary.
- `bidbrainai-project/docs/decisions/` and `bidbrainai-infra/docs/decisions/` — ADRs explaining why things are built the way they are.
- The `CLAUDE.md` file in each repo — team conventions.
