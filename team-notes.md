# Team Notes — GLA: Ship the Service (Breakout 5)

## Warm-Up: Theory Round

1. **RUN vs CMD:** `RUN` executes at build time and bakes its result into an image layer, while `CMD` only sets the default command that runs when a container starts.
2. **Pinning the base image tag:** `python:3.11-slim` guarantees every build uses the same Python release, while a bare `python` tag can silently move to a newer version and break builds.
3. **What Compose solves:** it records ports, environment variables and service wiring in one versioned file, so the whole stack starts with a single command instead of everyone remembering `docker run` flags.
4. **Actions runner:** a fresh VM GitHub provisions for each workflow run; on push it checks out the commit and executes every step of the job on that machine.
5. **Fail fast:** stopping at the first error gives faster feedback and guarantees later steps (like publishing an image) never run on top of code that already failed.
6. **Installer vs registry:** an installer (pip, uv) downloads and installs packages onto a machine, while a registry (PyPI) is the server that stores and serves them; the Docker equivalent is a container registry, and GHCR is GitHub's built-in registry for container images.

## Phase 1 — Dockerfile discussion

- `uv pip install --system` installs into the container's global site-packages instead of a virtual environment. That is safe here because the image itself is the isolation boundary, but outside a container it would pollute the system Python and cause conflicts between projects.

## Phase 2 — Compose discussion

- `docker compose up` without `--build` reuses a cached image: useful for a fast start when nothing changed, dangerous after editing the Dockerfile or requirements because you would be testing a stale image instead of your latest code.

## Phase 3 — CI discussion

- **Using `GITHUB_TOKEN` after the run:** it would be rejected. GitHub generates the token per run and expires it when the run ends, so a leaked token is useless afterwards.
- **Lint and tests before build and push:** every image that lands in GHCR has passed the full quality gate. It is impossible to publish an image from a commit that failed flake8 or pytest.

## Phase 4 — Deliberate failure discussion

- **Failure A prediction:** the flake8 step. Trailing whitespace and an unused import are lint errors, so the job dies at step 4 and the tests never run. Prediction confirmed by the log.
- **Failure B prediction:** the pytest step. The code still lints, but the health test asserts `"status": "ok"` and the route now returns `"error"`. Confirmed.
- **Who fixes a CI failure:** whoever is available should be free to fix it so main goes green quickly, but the person who broke it should review the fix and understand it. Owner-only fixing creates bottlenecks when that person is offline; anyone-fixes without follow-up means the author never learns what went wrong.
