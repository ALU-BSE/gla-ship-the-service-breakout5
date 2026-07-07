[![Open in Codespaces](https://classroom.github.com/assets/launch-codespace-2972f46106e565e64193e422d61a12cf1da4916b45550586e14ef0a7c637dd04.svg)](https://classroom.github.com/open-in-codespaces?assignment_repo_id=24215936)

# NairobiPulse

A city-data aggregator API packaged to run the same everywhere: Docker for the runtime, Docker Compose for a one-command start, and a GitHub Actions pipeline that lints, tests, and publishes every tested image to GHCR.

## Endpoints

| Route | Response |
|---|---|
| `GET /health` | `{"service":"nairobipulse","status":"ok"}` |
| `GET /districts` | `{"districts":["Westlands","Kibera","Karen","Eastleigh","Kasarani"]}` |

## Run locally with uv

```bash
pip install uv
uv pip install -r requirements.txt
uv run pytest
python -m app.main
```

## Run with Docker Compose

```bash
docker compose up --build
```

The service starts on port 5000.

## CI pipeline

Every push to a feature branch and every PR targeting `main` runs `.github/workflows/ci.yml`: install dependencies with uv, lint with flake8, run pytest, then build the Docker image and push it to GHCR tagged with the commit SHA. A failure at any step stops the run, so no untested image is ever published.

Session discussion notes, warm-up answers, and the closing retro live in [team-notes.md](team-notes.md).

---

# GLA: Ship the Service — 90-Minute Breakout Edition

> **Format:** GitHub Classroom group activity conducted as a Google Meet breakout session
> **Duration:** 90 minutes (strict)
> **Group size:** 3–6 members
> **Pre-work required:** Yes — 20 minutes before the session (see below)

---

## Quick Reference

| Phase | Time | What happens |
|---|---|---|
| Setup | 00:00–05:00 | Repo clone, role confirm, local verification with uv |
| Warm-Up | 05:00–15:00 | 6 theory questions, round-robin verbal answers |
| Phase 1 | 15:00–35:00 | Dockerfile (uv deps) — R1 leads guided lab |
| Phase 2 | 35:00–48:00 | docker-compose.yml — R2 leads guided lab |
| Phase 3 | 48:00–73:00 | CI pipeline: uv + GHCR image push — R3 leads |
| Phase 4 | 73:00–83:00 | Deliberate failures — R5 breaks it, team fixes |
| Close | 83:00–90:00 | Ownership round + one-sentence retro per person |

---

## Pre-Work (Complete Before the Session — 20 min)

Each member reads their assigned section individually. You do not need to take notes — you will be asked to explain it verbally during Warm-Up.

| Role | Read before session |
|---|---|
| R1, R4 | [Dockerfile reference — `FROM`, `RUN`, `COPY`, `WORKDIR`, `USER`, `CMD`](https://docs.docker.com/reference/dockerfile/) — focus on what each instruction does at build time vs. run time |
| R2, R5 | [Docker Compose file reference — `services`, `networks`, `volumes`, `environment`](https://docs.docker.com/compose/compose-file/) — focus on why each section exists |
| R3, R6 | [Understanding GitHub Actions — workflows, jobs, steps, runners, events](https://docs.github.com/en/actions/learn-github-actions/understanding-github-actions) — focus on the execution model; also skim [Working with the Container Registry (GHCR)](https://docs.github.com/en/packages/working-with-a-github-packages-registry/working-with-the-container-registry) — focus only on the `GITHUB_TOKEN` authentication section |
| All | [uv — Getting Started](https://docs.astral.sh/uv/getting-started/) — read the first two sections; note what problem uv solves compared to pip |

> **Groups of 3–4:** each member reads two sections. See the role consolidation table.

---

## Scenario

Your team has just joined **NairobiPulse**, a startup building a city-data aggregator API. The app works on one developer's laptop but breaks on everyone else's machine. There is no automated check to catch regressions before they reach the main branch. Your sprint goal: package the service so it runs the same everywhere, then wire up an automated quality gate.

You have 90 minutes and a working starter repository.

---

## GitHub Classroom Setup (Instructor — Do Before Session)

1. Create a **template repository** called `nairobipulse-starter` with the structure below. Mark it as a GitHub Template.
2. In the template, **pre-configure branch protection on `main`**: require status checks, require at least 1 approving review, block direct push.
3. Create the Classroom assignment: group assignment, max team size 6, linked to template.
4. Share the invitation link — no other instructions.

---

## Role Assignments

Every member owns one deliverable and reviews at least one other. Ownership means you share your screen and drive while the team watches and comments.

| Role | Owns | Reviews |
|---|---|---|
| **R1 — Container Engineer** | `Dockerfile` | `.dockerignore` |
| **R2 — Compose Architect** | `docker-compose.yml` | `Dockerfile` |
| **R3 — Pipeline Engineer** | `.github/workflows/ci.yml` | `docker-compose.yml` |
| **R4 — Security Reviewer** | Security sign-off on Dockerfile + `.dockerignore` | `ci.yml` |
| **R5 — Quality Gatekeeper** | Deliberate failure + fix in Phase 4 | `ci.yml`, test output |
| **R6 — Process Lead** | `team-notes.md` (live note-taker), README update | All PRs |

**Role consolidation for smaller groups:**

| Size | Merge rule |
|---|---|
| 5 | R5 + R6 merged |
| 4 | R4 + R5 merged; R5 + R6 merged |
| 3 | R1 + R4, R2 + R5, R3 + R6 |

---

## Session Flow

### [00:00–05:00] Setup (5 min)

1. One member creates the Classroom team; all others join and clone immediately.
2. Confirm roles (use the table above — first to speak claims R1, and so on).
3. Establish the **Google Meet screen share protocol** for the session:
   - The role owner shares their screen during their phase.
   - Everyone else keeps the GitHub repo open in their browser.
   - R6 keeps a `team-notes.md` file open in VS Code or a shared Google Doc to capture discussion in real time.
4. Everyone installs dependencies and verifies tests locally:
   ```bash
   pip install uv                          # install uv if not already present
   uv pip install -r requirements.txt      # install project deps
   uv run pytest                           # run tests
   ```
   Confirm all tests pass before proceeding.

> **If someone's local setup is broken:** they pair with the nearest available member and co-drive from one screen. Do not spend more than 2 minutes troubleshooting setup.

---

### [05:00–15:00] Warm-Up: Theory Round (10 min)

R6 reads each question aloud. Go around the group — each person answers one question. No notes allowed; use only what you read before the session.

1. *What is the difference between `RUN` and `CMD` in a Dockerfile? When does each execute?*
2. *Why do we pin a specific base image tag like `python:3.11-slim` instead of just `python`?*
3. *What problem does Docker Compose solve that a single `docker run` command does not?*
4. *What is a GitHub Actions runner? What happens on it when you push a commit?*
5. *Why would you want a pipeline to fail fast — stopping at the first error — rather than running all steps regardless?*
6. *`uv` is used instead of `pip` in this project. What is the difference between a package **installer** (like pip or uv) and a package **registry** (like PyPI)? What is the equivalent registry for Docker images — and what is GHCR specifically?*

R6 records a one-sentence answer per question in `team-notes.md`. Unanswered questions or disagreements stay open — the team will resolve them during the relevant phase.

---

### [15:00–35:00] Phase 1 — Dockerfile (20 min)

**R1 shares screen and drives. Everyone else watches and prepares review comments.**

#### Why this matters

Without a `Dockerfile`, every developer must manually install the right Python version, dependencies, and OS libraries. The Dockerfile makes the runtime reproducible: same image, same behaviour, everywhere.

#### Lab: Build the Dockerfile

R1 creates `Dockerfile` in the repository root. Start from this scaffold — the only blank to fill in is the Python version tag:

```dockerfile
# ── Base image ──────────────────────────────────────────────────────────────
# Pinning a specific tag ensures every build uses the same Python release.
FROM python:3.11-slim

# ── Working directory ────────────────────────────────────────────────────────
WORKDIR /app

# ── Install uv (fast Python package manager — replaces pip) ──────────────────
# uv is 10–100× faster than pip and produces reproducible installs.
RUN pip install uv

# ── Install dependencies ─────────────────────────────────────────────────────
COPY requirements.txt .
# --system installs into the container's system Python; no venv needed inside a container.
RUN uv pip install --system -r requirements.txt

# ── Copy application source ──────────────────────────────────────────────────
COPY . .

# ── Security: never run application code as root ─────────────────────────────
RUN useradd --create-home appuser
USER appuser

# ── Start the service ────────────────────────────────────────────────────────
CMD ["python", "-m", "app.main"]
```

**While R1 writes, R4 creates `.dockerignore`** (no PR needed — commit directly to R1's branch with a separate commit):

```
.git
__pycache__
*.pyc
*.pyo
.env
.env.*
```

#### Verify it works

R1 runs these two commands and pastes output into the team chat:

```bash
docker build -t nairobipulse .
docker run --rm -p 5000:5000 nairobipulse
```

Any other member opens a second terminal:

```bash
curl http://localhost:5000/health
# Expected output: {"service":"nairobipulse","status":"ok"}
```

**You are done when:** `curl` returns `"status": "ok"` and the container logs show the app started.

#### Security check (R4 reads aloud, 2 min)

- [ ] `USER appuser` appears before `CMD`?
- [ ] No `.env` file or tokens in the build context (`.dockerignore` covers it)?
- [ ] Base image tag is `3.11-slim` — not `:latest` or bare `python`?
- [ ] `uv pip install --system` used — no venv inside the container?

R1 opens a PR. **R4 + one other member must leave at least one inline comment on the Dockerfile** (not just an approval click) before merging.

**Discussion (1 min — R6 records):**
> *`uv pip install --system` is used instead of plain `pip install`. What does `--system` do, and why would you avoid it outside of a container context?*

---

### [35:00–48:00] Phase 2 — Docker Compose (13 min)

**R2 shares screen and drives.**

#### Why this matters

`docker compose up` gives anyone on the team a single command to start the full stack — no manual `docker run` flags, no memorising container names, no "it works on my machine" arguments.

#### Lab: Write the Compose file

R2 creates `docker-compose.yml` in the repository root:

```yaml
services:
  api:
    build: .                      # build from the local Dockerfile
    ports:
      - "5000:5000"               # host_port:container_port
    environment:
      FLASK_ENV: development      # passed into the container as an env var
```

#### Verify it works

**All members run this command simultaneously** (each on their own machine):

```bash
docker compose up --build
```

While it starts, R2 narrates each line of the YAML aloud — what it configures and why.

In a second terminal, hit both endpoints:

```bash
curl http://localhost:5000/health
# Expected: {"service":"nairobipulse","status":"ok"}

curl http://localhost:5000/districts
# Expected: {"districts":["Westlands","Kibera","Karen","Eastleigh","Kasarani"]}
```

Stop with `Ctrl+C`.

**You are done when:** all members see both endpoints respond.

R2 opens a PR. R1 reviews (they own the Dockerfile that Compose builds from). Merge.

**Discussion (1 min — R6 records):**
> *`docker compose up` without `--build` uses a cached image if one exists. When is this useful? When is it dangerous?*

---

### [48:00–73:00] Phase 3 — CI Pipeline with uv and GHCR Push (25 min)

**R3 shares screen and drives.**

#### Why this matters

Every push to a feature branch will trigger this pipeline. It installs dependencies with uv (fast), runs lint and tests (quality gate), then builds the Docker image and pushes it to **GitHub Container Registry (GHCR)** — so any team member can pull the exact tested image by its commit SHA.

#### How GHCR authentication works (R3 explains before writing — 2 min)

GitHub automatically injects a `GITHUB_TOKEN` secret into every Actions run. No one creates it; GitHub generates it fresh for each run and it expires when the run ends. The token carries `packages: write` permission only when you declare it in the job's `permissions:` block. That is why this works with zero manual secret configuration.

> **Team question before writing:** *The token is injected automatically and expires. What would happen if someone tried to use this token after the pipeline run finished?*

#### Lab: Write the CI workflow

R3 creates `.github/workflows/ci.yml`. This is the complete file — R3 reads each comment to the team before typing the corresponding block:

```yaml
name: CI

on:
  push:
    branches-ignore:
      - main          # branch protection already blocks direct pushes to main
  pull_request:
    branches:
      - main          # always run when a PR targets main

jobs:
  quality-gate:
    runs-on: ubuntu-latest
    permissions:
      contents: read
      packages: write   # required to push images to GHCR

    steps:
      # ── 1. Fetch the source code ─────────────────────────────────────────
      - uses: actions/checkout@v4

      # ── 2. Install uv (no need for setup-python — uv manages Python too) ─
      - uses: astral-sh/setup-uv@v4

      # ── 3. Install project dependencies ──────────────────────────────────
      - run: uv pip install -r requirements.txt

      # ── 4. Lint — job fails here on any flake8 error ─────────────────────
      - run: uv run flake8 app/ tests/

      # ── 5. Tests — job fails here if any test fails ───────────────────────
      - run: uv run pytest

      # ── 6. Log in to GitHub Container Registry ───────────────────────────
      #       GITHUB_TOKEN is automatically available — no secrets to configure
      - uses: docker/login-action@v3
        with:
          registry: ghcr.io
          username: ${{ github.actor }}
          password: ${{ secrets.GITHUB_TOKEN }}

      # ── 7. Build the image AND push to GHCR ──────────────────────────────
      #       Tag: ghcr.io/<owner>/<repo>:<commit-sha>
      #       This step fails if the Docker build fails — same gate as before.
      - uses: docker/build-push-action@v5
        with:
          context: .
          push: true
          tags: ghcr.io/${{ github.repository }}:${{ github.sha }}
```

#### Push and watch the run

R3 pushes the branch. R3 shares the **GitHub Actions browser tab** — everyone watches the run together.

The pipeline takes ~2–3 min. While waiting, team discusses:

> *Steps 4 and 5 (lint + tests) run before step 7 (build + push). What does this ordering guarantee about every image that lands in GHCR?*

#### Find the published image (when the run goes green)

Navigate to the repository's **Packages** tab (right side of the repo homepage) or go to:
```
https://github.com/<your-org>/<your-repo>/pkgs/container/<your-repo>
```

The image tagged with the commit SHA should appear. Any member can pull it:
```bash
docker pull ghcr.io/<your-org>/<your-repo>:<commit-sha>
```

**You are done when:** the Actions tab shows a green run AND the image appears in the Packages tab.

R3 opens a PR. R6 reviews — check that:
- `permissions: packages: write` is present
- The tag uses `${{ github.repository }}` (not a hardcoded repo name)
- Steps 4 and 5 run before step 7

Merge.

---

### [73:00–83:00] Phase 4 — Deliberate Failure (10 min)

**R5 shares screen.** R5 introduces two deliberate failures on separate branches, one at a time.

**Failure A — Lint (4 min):**
R5 adds a line with trailing whitespace and an unused import to `app/routes.py`, then pushes.

Before looking at logs, team answers: *Which step do you predict failed? Why?*

R5 reads the failure log aloud. **A member who is not R5 writes the fix and pushes.** Team watches the pipeline go green and the corrected image appear in GHCR.

**Failure B — Tests (4 min):**
R5 changes the `/health` route to return `{"status": "error"}` without updating the test, then pushes.

Same drill: predict, read log, non-R5 member writes the fix.

**Brief discussion (2 min):**
> *In a team of 10 engineers, who should be responsible for fixing a CI failure — only the person who broke it, or whoever is available? What are the trade-offs of each approach?*

---

### [83:00–90:00] Ownership Round + Close (7 min)

**No screens shared. Verbal only.**

Go around once. Each person completes this sentence for their role:

> *"I owned [X]. The decision I made that I'd want to explain to a new teammate is [Y] because [Z]."*

Then one final round: each person completes this sentence:

> *"Before today I thought [X], but doing it showed me that [Y]."*

R6 adds both rounds as bullet points to `team-notes.md`, commits with the message `retro: ownership round notes`, and pushes.

---

## Google Meet Protocol Notes

- **Screen sharing:** only the role owner shares their screen during their phase. Everyone else keeps the GitHub repo open in their own browser and leaves review comments directly on the PR.
- **Code review on Meet:** reviewers speak their feedback aloud and simultaneously post it as a PR comment on GitHub. This creates a written record without slowing the group down.
- **Waiting for CI:** when the pipeline is running, use the time for the associated discussion prompt — do not idle.
- **Running behind:** if Phase 2 runs long, compress the discussion prompt to one sentence per person rather than skipping it. Never skip Phase 4 — the deliberate failure is the most important learning moment in the session.
- **Solo fixers:** during Phase 4, the non-R5 member who writes the fix should share their screen. The act of writing and explaining the fix in front of the team is the point.

---

## Completion Criteria

The activity is complete when the group's repository has:

- [ ] `Dockerfile` — builds, uses `python:3.11-slim`, non-root user, one-line comments, uv for deps
- [ ] `.dockerignore` — excludes `.git`, `__pycache__`, `.env`, `*.pyc`
- [ ] `docker-compose.yml` — `docker compose up` starts the service on port 5000
- [ ] `.github/workflows/ci.yml` — triggers on push + PR, runs uv lint → uv test → build + GHCR push
- [ ] Docker image published to GHCR — visible in the repository Packages tab, tagged with a commit SHA
- [ ] At least 3 merged PRs (one per deliverable), each with at least 1 written review comment
- [ ] At least 2 failed pipeline runs visible in Actions history (the Phase 4 deliberate failures)
- [ ] `team-notes.md` committed by at least 2 different authors, containing warm-up answers, discussion notes, and retro bullets


