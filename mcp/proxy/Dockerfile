# MCP Proxy base image
# https://github.com/stephenlacy/mcp-proxy

ARG RMCP_PROXY_VERSION=0c040c083fe3d144f6a6f4877f5e233d9ece38d5

FROM public.ecr.aws/docker/library/rust:alpine AS builder
ARG RMCP_PROXY_VERSION
RUN apk add --no-cache musl-dev openssl-dev openssl-libs-static pkgconfig git
RUN cargo install --git https://github.com/stephenlacy/mcp-proxy.git --rev ${RMCP_PROXY_VERSION} rmcp-proxy

FROM public.ecr.aws/docker/library/alpine:latest
RUN apk add --no-cache netcat-openbsd
COPY --from=builder /usr/local/cargo/bin/mcp-proxy /usr/local/bin/

ENV MCP_PORT=8080
EXPOSE 8080

# No ENTRYPOINT - servers specify full CMD with env var expansion
