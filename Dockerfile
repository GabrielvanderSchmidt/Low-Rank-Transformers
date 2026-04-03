# Builder stage
FROM python:3.12-slim AS builder

WORKDIR /workspace
RUN apt-get update && apt-get install -y curl && rm -rf /var/lib/apt/lists/*

# Install `uv`
COPY --from=ghcr.io/astral-sh/uv:0.11.3 /uv /uvx /bin/

# Install dependencies
COPY pyproject.toml uv.lock ./
RUN uv pip install --system --no-cache -- --frozen \
    --extra-index-url https://download.pytorch.org/whl/cu130

# Runtime stage
FROM python:3.12-slim AS runtime

WORKDIR /workspace
RUN apt-get update && apt-get install -y curl && rm -rf /var/lib/apt/lists/*

# Pull packages from builder
COPY --from=builder /usr/local/lib/python3.12/site-packages /usr/local/lib/python3.12/site-packages
COPY --from=builder /usr/local/bin /usr/local/bin

# Pull repo files
COPY . .

CMD ["python", "-u", "main.py"]