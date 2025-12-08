# GitHub MCP Server
# https://github.com/github/github-mcp-server

IMAGE := github-mcp
CONTAINER := github-mcp
CLAUDE_PATH := $(HOME)/.claude/local/claude

# Token from gh CLI, server config from local .env
-include .env
export

.PHONY: build start stop restart logs status clean register unregister

build:
	podman build -t $(IMAGE) .

start: build
ifndef GITHUB_MCP_PORT
	$(error GITHUB_MCP_PORT not set)
endif
	podman run -d --name $(CONTAINER) --replace \
		-p $(GITHUB_MCP_PORT):8080 \
		-e GITHUB_PERSONAL_ACCESS_TOKEN=$$(gh auth token) \
		-e GITHUB_TOOLSETS \
		-e GITHUB_TOOLS \
		-e GITHUB_HOST \
		--health-cmd "nc -z localhost 8080" \
		--health-interval 30s \
		--health-timeout 3s \
		--health-start-period 5s \
		--health-retries 3 \
		$(IMAGE)
	@echo "GitHub MCP server running at http://localhost:$(GITHUB_MCP_PORT)"

stop:
	-podman stop $(CONTAINER)
	-podman rm $(CONTAINER)

restart: stop start

logs:
	podman logs -f $(CONTAINER)

status:
	@podman ps -f name=$(CONTAINER) --format "{{.Status}}" || echo "Not running"
	@$(CLAUDE_PATH) mcp get $(CONTAINER) 2>/dev/null || echo "Not registered"

clean: stop
	-podman rmi $(IMAGE)

register:
ifndef GITHUB_MCP_PORT
	$(error GITHUB_MCP_PORT not set)
endif
ifndef GITHUB_MCP_SCOPE
	$(error GITHUB_MCP_SCOPE not set)
endif
	$(CLAUDE_PATH) mcp add --transport http --scope $(GITHUB_MCP_SCOPE) $(CONTAINER) http://localhost:$(GITHUB_MCP_PORT)/mcp

unregister:
	$(CLAUDE_PATH) mcp remove $(CONTAINER)
