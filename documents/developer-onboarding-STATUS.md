---
title: "BidbrainAI — Developer Onboarding — ANNOTATED PROGRESS COPY"
source: bidbrainai-project/docs/onboarding/developer.md (upstream, unmodified)
annotated-by: Cowork session for Jerome
annotated-on: 2026-07-12
note: This is a DUPLICATE of the upstream onboarding doc with a status marker + comment on every step. It does not change the upstream file. Re-check anything marked "confirm".
---

# How to read this — status legend

| Marker | Meaning |
|---|---|
| ✅ **DONE** | Completed. The comment says *how we know* (the evidence). |
| 🟡 **ALT** | Effectively done, but a **different way** than the doc says — almost always because we built the **Dockerised `local-dev` stack** instead of installing tools natively / using a `devN` box. Functionally covered; the doc's literal step was skipped on purpose. |
| ⬜ **TODO** | Not done. You *could* do it yourself; the comment says why it's outstanding. |
| 🔒 **LEX** | Blocked on Lex / infra (server provisioning, keys, accounts). Can't be done from your machine alone. |
| ▫️ **REF** | Reference/prose only — nothing to "do". |

**One-glance rule:** ✅ and 🟡 = you're covered. ⬜ and 🔒 = outstanding. Scan the left margin.

---

## AT-A-GLANCE SUMMARY

| Section | Overall | One-line status |
|---|---|---|
| Prereqs (Lex) | 🟡 / 🔒 | Org access ✅. devN box, SSH key, n8n user — 🔒 not needed yet (we went local-Docker). |
| 1. Install tools | 🟡 | The GitHub + Docker tools are in; native Python/Node/pnpm/uv **intentionally skipped** — the Docker stack runs them for you. PowerShell 7 ⬜. |
| 2. GitHub access (PAT/gh/clone) | ✅ | PAT + `gh` + clones all working — we've pushed branches and opened PRs (#344, #102). |
| 2.4–2.5 Cowork + 4 MCPs | 🟡 | Running in Cowork with built-in tools; the four named MCPs (GitHub/Windows/SSH/n8n) **not** installed — we use `gh` in PowerShell instead. |
| 3. GitHub ops (branch/PR/CI) | ✅ | Done for real: conventional commits, cross-repo `Refs`, CI watched, `migration-release-guard` + link-gate passed. |
| 3.5 Dev→Staging→App deploy | ⬜ | Never deployed anywhere — no devN, no tag cut. |
| 4. devN server / tailnet / SSH | 🔒 | Entirely unstarted — needs Lex to provision. We substituted the local Docker stack. |
| 5. Per-dev toolchain | 🟡 | Portal + API both run — but via Docker containers, not native `pnpm`/`uv`. |
| 6. `/admin` via DEV_PROFILE_STUB | ✅ | Wired into our `local-dev/.env.portal` (commented, ready to flip). |
| 7. Verification checklist | 🟡 | GitHub + local-run items pass; every SSH/devN/tailnet item ⬜/🔒. |
| 8. First Story | ✅ | Already shipped several (#102, #682) and #545 in flight — different tickets than the doc's examples, but the flow is done. |
| 10. Things from Lex | 🔒 | devN, n8n key, Canva IDs, staging DB, Slack — all still pending Lex. |

---

# Annotated walkthrough

## Prerequisites — what Lex sets up for you

1. ✅ **DONE — Org collaborator access.** You clearly have read+write: we've cloned `bidbrainai-project`, `bidbrainai-api`, `bidbrainai-portal`, `bidbrainai-renderer` (+ others) and opened/pushed PRs. Evidence: PR #344 (api), #102 (portal).
2. 🔒 **LEX — `devN` box on Proxmox + tailnet.** Not provisioned. We didn't need it: we built the local Docker `local-dev` stack as a substitute. Only needed if you want a real remote dev server.
3. 🔒 **LEX — SSH public key in `authorized_keys`.** Not done (depends on #2 and on generating a key). No SSH work happened this session.
4. 🔒 **LEX — n8n user + API key.** Not done. Only needed for workflow debugging / the n8n MCP, which we haven't touched.
5. 🟡 **ALT / confirm — Cowork project instructions.** You're running in Cowork already. Whether you pasted `bidbrainai-project/CLAUDE.md` into the Project Instructions field is **worth confirming** (see § 2.4).

---

## 1. Download & install

> Big-picture note: the whole point of our `local-dev` stack was to **avoid installing Python/Node/uv/pnpm natively** — Docker runs them. So most "native install" rows below are 🟡 (covered by Docker) rather than ✅.

### Required

| Tool | Status | Comment |
|---|---|---|
| Python 3.14 | 🟡 ALT | Not installed natively. The API + its tests run inside Docker (`ghcr.io/astral-sh/uv` throwaway containers + the `local-dev` api service). Install natively only if you want to run `uv` outside Docker. |
| Node.js LTS + pnpm | 🟡 ALT | Not native. The portal runs in the `local-dev` `portal` container (`next dev`, `pnpm` inside it). We ran `docker compose exec portal pnpm test`. |
| Git + Git Credential Manager | ✅ DONE | Git works — we branch/commit/push all session. |
| GitHub CLI (`gh`) | ✅ DONE | Authenticated and used heavily (`gh pr create`, `gh run view`). |
| Claude for Windows | ✅ DONE | You're in it right now (Cowork). |
| PuTTY | ⬜ TODO | Not needed yet — only for the SSH/servers path (§ 4), which we haven't started. |
| Docker Desktop | ✅ DONE | The backbone of everything we did — the stack + all test runs go through it. |
| PowerShell 7 (`pwsh`) | ⬜ TODO | Looks like you're on Windows PowerShell **5.1** (we hit 5.1-only quirks: the em-dash parse error in `dev.ps1`, positional-parameter errors). Install `pwsh` before you touch `dev-sync.ps1` / the devN sync. |
| OpenSSH client | ⬜ TODO | Not exercised — belongs to the § 4 SSH path. |

### Recommended

| Tool | Status | Comment |
|---|---|---|
| WinSCP | ⬜ TODO | Server file transfer — not needed until devN exists. |
| Notepad++ | ⬜ TODO | Optional. You've been using VS Code. |

- ✅ **DONE — verify essentials** (`git`, `gh`, `node`, `python`, `docker`, `ssh`): the GitHub + Docker ones verify; `python`/`node` native may be absent (we use Docker), `ssh` untested.
- ✅ **DONE — Git identity** (`user.name` / `user.email`): commits carry your identity, so this is set.

---

## 2. GitHub access — PAT, `gh`, and the MCPs

### 2.1 Personal Access Token (classic)
✅ **DONE.** `gh` is authenticated and cross-repo `gh api` / PR operations work, which a classic PAT with `repo`+`project` enables. If org-level calls ever `FORBIDDEN`, re-check it's *classic*, not fine-grained.

### 2.2 Authenticate `gh`
✅ **DONE.** `gh auth status` is effectively proven every time we push / open PRs / read runs.

### 2.3 Clone the repos
🟡 **ALT (path differs).** Repos are cloned, but under **`C:\Commissions Folder\BidbrainAI\`**, *not* the doc's `C:\projects\BidbrainAI\`. Functionally fine; just know the canonical-path references in `CLAUDE.md` won't match your disk. You have more than the list (incl. `bidbrainai-renderer`, `-scraper`, `-ops-infra`, `-www`).
- ⬜ **TODO — read-first docs.** Worth actually reading `CLAUDE.md`, `portal.md`/`data-model.md`, and the ADRs if you haven't — we've referenced ADR-0026/0052/0053 in passing but not a full read.

### 2.4 Cowork project setup
🟡 **ALT / confirm.** Working folder is set (that's how I have file access). **Confirm** you pasted `CLAUDE.md` into the Cowork *Project Instructions* field — that's the one step here that isn't self-evident from the session.

### 2.5 MCPs (GitHub / Windows / SSH / n8n)
🟡 **ALT — we did NOT install these four.** Instead we drove GitHub through **`gh` in PowerShell** (the built-in path) and used Cowork's own file/shell tools. Consequence: everything worked, but if you want Claude to do GitHub/SSH/n8n natively via MCP later, these are still ⬜.
- GitHub MCP — ⬜ (used `gh` instead)
- Windows MCP — 🟡 (Cowork's own shell/file tools cover this)
- SSH MCP — 🔒 (no servers to point at yet)
- n8n MCP — 🔒 (needs Lex's n8n key)

---

## 3. GitHub operations — PRs, rules, Actions, Dev→Staging→App

### 3.1 Cross-repo model (Issues in `-project`, PRs on code repos)
✅ **DONE — understood + applied.** Our PR bodies link with the full cross-repo form. We used `Refs BidbrainAI/bidbrainai-project#545` / `#102`; the **cross-repo link gate passed** on both. (We used `Refs` not `Closes` for #545 because it's two coordinated PRs.)

### 3.2 Branch → PR → merge
✅ **DONE.** Conventional-commit branches (`feat/545-...`, `feat/102-...`), PRs against `main`, cross-repo links filled.
- ⬜ **TODO — `qa-review` subagent (`/bidbrainai-modes:qa`).** We did **not** run this before marking work ready. If the team expects it as the gate before "Ready for review", that's an outstanding step per PR.
- ⬜ **Note — squash-merge / AC-ticking** happen at merge/review time (Lex reviews), so not yet exercised by us.

### 3.3 Rules
✅ **DONE — encountered and satisfied.** We hit and cleared: the **cross-repo link gate**, **PR title lint**, and **`migration-release-guard`** (passed — our #545 PR doesn't itself add a migration). We also lived the "main moved under us" reality and resolved a merge conflict in `kpi_cards.py`.

### 3.4 Actions (CI/CD)
✅ **DONE — used exactly as described.** We watched runs and used `gh run view <id> --log-failed` to debug the #545 CI failures (ruff-format gate, then the two currency tests).

### 3.5 Dev → Staging → App
⬜ **TODO / not reached.** We've never deployed. No `v*` tag cut, no staging/prod promotion. release-please behaviour observed on `main` (lots of `chore(main): release` commits) but we haven't driven it.

---

## 4. Connecting to your own dev server `devN`
🔒 **LEX — entirely unstarted.** No Tailscale/Headscale, no `devN` box, no SSH, no `*.devN` domains. **We deliberately substituted the local Docker `local-dev` stack** (portal + api + db + supabase-less auth) for this. Everything in § 4 (Tailscale login, `ssh devN`, `sync-dev.sh`, DNS notes) is outstanding and needs Lex to provision the box first.

---

## 5. Per-dev toolchain

### Portal (`bidbrainai-portal`) — the doc's `pnpm install` / `pnpm dev`
🟡 **ALT — running, via Docker.** Instead of native `pnpm dev`, the portal runs in the `local-dev` `portal` container and is reachable at `http://localhost:3000`. We ran its Vitest suite with `docker compose exec portal pnpm test`.

### API (`bidbrainai-api`) — the doc's `uv sync` / `alembic` / `pytest` / `uvicorn`
🟡 **ALT — running, via Docker.** Not native `uv`. The api runs in the `local-dev` stack; migrations run in the stack; tests run in throwaway `uv`/`playwright` containers (`uv run pytest ...`). Same outcomes, containerised.

---

## 6. Portal `/admin` via `DEV_PROFILE_STUB`
✅ **DONE — wired, ready to flip.** `DEV_PROFILE_STUB=bidbrain-admin` is present (commented) in `local-dev/.env.portal`. Uncomment + restart the portal to reach `/admin/*` locally without a real session. The limits described (prod-locked, identity-only, admin data pages still hit the api) apply.

---

## 7. Verification checklist

- ✅ `gh auth status` authenticated (proven by every PR/push).
- ✅ `gh repo view ...bidbrainai-project` works.
- 🟡 `git status` clean in all clones — mostly; you carry some working changes (the #682 files, the `uv.lock` churn) — not a blocker.
- 🔒 `ssh bidbrainai01 hostname` — no SSH set up.
- 🔒 `tailscale status` / `ssh devN` / `portal.devN...` — no devN.
- ✅ Cowork "list open Features / issues" — done repeatedly via `gh`.
- ✅ Cowork "run `gh auth status`" — done.
- 🟡 Portal opens `http://localhost:3000` — **yes, via Docker** (not native `pnpm dev`).
- 🟡 `uv run pytest` passes — **yes, via Docker** (api unit tests 20/20; renderer 63/63).
- ⬜ Read the AC-handling section in `CLAUDE.md` — **confirm** you've done this; we haven't walked it together.

---

## 8. Your first Story
✅ **DONE — and then some.** The doc suggests #79/#84 (Will) or #36/#46 (Ian) as *examples*. You instead worked real tickets under **Epic #430**: shipped **#102** (Reporter page + Export) and **#682** (invite-dialog cancel fix), and **#545** (KpiCard↔IR currency contract) is in flight across api + renderer PRs. The branch→build→test→PR flow is fully exercised.

---

## 9. Troubleshooting
▫️ **REF.** Reference table. Two rows we actually lived: the `gh` `--type` limitation (not hit), and CI debugging via `gh run view --log-failed` (used). Add your own: **PowerShell 5.1 quirks** (em-dash parse errors, `<` reserved operator) — installing `pwsh` 7 avoids these.

---

## 10. Things you'll need from Lex once running
🔒 **LEX — all pending:**
- devN box + tailnet access — 🔒
- n8n trigger + API key — 🔒
- Canva test team + template IDs — 🔒 (relevant once a Reporter/export Story needs real Canva)
- Supabase **staging** connection string — 🔒 (we used a local throwaway Postgres instead)
- Slack access (`#bidbrain-sysadmin`, `#bidbrainai-dev`) — 🔒

---

## Bottom line

- **Overall: ~half done.** You're fully set on the **local-Docker + GitHub-flow half** (✅/🟡 across §§ 2–3, 5–6, 8). The **server/infra half is not started** (🔒 — devN box, tailnet, SSH, n8n, staging, Slack), which mostly waits on Lex and wasn't needed to ship ticket work.
- **Did we follow the doc literally?** No — we deliberately swapped the native-install + `devN`-server path for the Dockerised `local-dev` stack. It works for coding; it's a stand-in for the intended dev environment. Worth confirming with Lex that this substitution is acceptable.

### You can close these yourself (4)

- ⬜ **`[OPTIONAL]`** Install **PowerShell 7** (`winget install --id Microsoft.PowerShell`). Recommended — removes the 5.1 quirks we kept hitting — but 5.1 still works.
- ⬜ **`[RECOMMENDED]`** Confirm **`CLAUDE.md` is pasted into Cowork Project Instructions** (§ 2.4). It's how Claude follows team conventions — do it, not truly optional.
- ⬜ **`[RECOMMENDED]`** Read the **AC-handling / deferral** section of `CLAUDE.md` (§ 7 last item). Process knowledge for ticking ACs correctly.
- ⬜ **`[OPTIONAL]`** Decide whether you want the **four MCPs** (GitHub/Windows/SSH/n8n) — driving GitHub via `gh` has worked fine, so this is a preference, not a blocker.

### Gated on Lex — can't be done from your machine (6)

- 🔒 **`[GATED]`** `devN` box on Proxmox + Headscale tailnet access.
- 🔒 **`[GATED]`** Your SSH public key added to the servers' `authorized_keys`.
- 🔒 **`[GATED]`** n8n user + API key (workflow debugging / n8n MCP).
- 🔒 **`[GATED]`** Canva test team + template IDs (for a Reporter/export Story).
- 🔒 **`[GATED]`** Supabase **staging** connection string.
- 🔒 **`[GATED]`** Slack access (`#bidbrain-sysadmin`, `#bidbrainai-dev`).

> Net: 2 of the 4 self-serve items are truly **optional**; 2 are **recommended** process steps. All 6 Lex items are **gated** — ping him when you want the remote-server half.
