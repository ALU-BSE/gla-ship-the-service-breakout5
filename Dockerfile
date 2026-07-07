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
