# Agent Mail MCP Server
# https://github.com/Dicklesworthstone/mcp_agent_mail

FROM public.ecr.aws/docker/library/python:3.12-slim-bookworm

RUN apt-get update && apt-get install -y --no-install-recommends \
    git curl build-essential && \
    rm -rf /var/lib/apt/lists/*

COPY --from=ghcr.io/astral-sh/uv:latest /uv /usr/local/bin/uv

WORKDIR /app

ARG AGENT_MAIL_VERSION=f2b563dad55aa03fcb2a3563b773089f6f03ef50
RUN git clone https://github.com/Dicklesworthstone/mcp_agent_mail.git . && \
    git checkout ${AGENT_MAIL_VERSION} && \
    uv sync --frozen --no-editable

ENV PATH="/app/.venv/bin:$PATH" \
    PYTHONUNBUFFERED=1 \
    HTTP_HOST=0.0.0.0 \
    HTTP_PORT=8765 \
    STORAGE_ROOT=/data/mailbox \
    DATABASE_URL=sqlite+aiosqlite:////data/agent_mail.db

EXPOSE 8765

CMD ["python", "-m", "mcp_agent_mail.cli", "serve-http"]
