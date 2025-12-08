# MCP Proxy base image
# https://github.com/stephenlacy/mcp-proxy

IMAGE := mcp-proxy

.PHONY: build clean

build:
	podman build -t $(IMAGE) .

clean:
	-podman rmi $(IMAGE)
