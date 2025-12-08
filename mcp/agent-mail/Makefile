# Agent Mail MCP Server
# https://github.com/Dicklesworthstone/mcp_agent_mail

IMAGE := agent-mail
CONTAINER := agent-mail
CLAUDE_PATH := $(HOME)/.claude/local/claude

-include .env
-include $(HOME)/.env
export

.PHONY: build start stop restart logs status clean register unregister

build:
	podman build -t $(IMAGE) .

start: build
ifndef AGENT_MAIL_MCP_PORT
	$(error AGENT_MAIL_MCP_PORT not set)
endif
ifndef AGENT_MAIL_DATA_DIR
	$(error AGENT_MAIL_DATA_DIR not set)
endif
	@mkdir -p $(AGENT_MAIL_DATA_DIR)
	podman run -d --name $(CONTAINER) --replace \
		-p $(AGENT_MAIL_MCP_PORT):8765 \
		-v $(AGENT_MAIL_DATA_DIR):/data:Z \
		-e GIT_IDENTITY_ENABLED=$(AGENT_MAIL_GIT_IDENTITY_ENABLED) \
		-e PROJECT_IDENTITY_MODE=$(AGENT_MAIL_PROJECT_IDENTITY_MODE) \
		-e LLM_ENABLED=$(AGENT_MAIL_LLM_ENABLED) \
		-e LLM_DEFAULT_MODEL=$(AGENT_MAIL_LLM_DEFAULT_MODEL) \
		-e ANTHROPIC_API_KEY=$(ANTHROPIC_API_KEY) \
		-e LOG_LEVEL=DEBUG \
		--health-cmd "curl -fsS http://127.0.0.1:8765/health/liveness || exit 1" \
		--health-interval 30s \
		--health-timeout 5s \
		--health-start-period 20s \
		--health-retries 3 \
		$(IMAGE)
	@echo "Agent Mail running at http://localhost:$(AGENT_MAIL_MCP_PORT)"

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
ifndef AGENT_MAIL_MCP_PORT
	$(error AGENT_MAIL_MCP_PORT not set)
endif
ifndef AGENT_MAIL_MCP_SCOPE
	$(error AGENT_MAIL_MCP_SCOPE not set)
endif
	$(CLAUDE_PATH) mcp add --transport http --scope $(AGENT_MAIL_MCP_SCOPE) $(CONTAINER) http://localhost:$(AGENT_MAIL_MCP_PORT)/mcp

unregister:
	$(CLAUDE_PATH) mcp remove $(CONTAINER)
