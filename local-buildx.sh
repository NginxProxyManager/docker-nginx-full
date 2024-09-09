#!/bin/bash -e

BLUE='\E[1;34m'
CYAN='\E[1;36m'
YELLOW='\E[1;33m'
GREEN='\E[1;32m'
RESET='\E[0m'

DOCKER_IMAGE="${REGISTRY:-}nginxproxymanager/nginx-full"
PLATFORMS=linux/amd64,linux/arm64,linux/arm/7

export OPENRESTY_VERSION=1.25.3.2
export CROWDSEC_OPENRESTY_BOUNCER_VERSION=0.1.7
export LUA_VERSION=5.1.5
export LUAROCKS_VERSION=3.3.1

export BASE_IMAGE="${DOCKER_IMAGE}:latest"
export ACMESH_IMAGE="${DOCKER_IMAGE}:acmesh"
export CERTBOT_IMAGE="${DOCKER_IMAGE}:certbot"
export CERTBOT_NODE_IMAGE="${DOCKER_IMAGE}:certbot-node"
export ACMESH_GOLANG_IMAGE="${DOCKER_IMAGE}:acmesh-golang"

# Setup

docker buildx rm "${BUILDX_NAME:-nginx-full}" || echo
docker buildx create --name "${BUILDX_NAME:-nginx-full}" || echo
docker buildx use "${BUILDX_NAME:-nginx-full}"

# Builds

echo -e "${BLUE}❯ ${CYAN}Building ${YELLOW}latest ${CYAN}...${RESET}"
docker buildx build \
	--platform "$PLATFORMS" \
	--progress plain \
	--pull \
	--push \
	--build-arg OPENRESTY_VERSION \
	--build-arg CROWDSEC_OPENRESTY_BOUNCER_VERSION \
	--build-arg LUA_VERSION \
	--build-arg LUAROCKS_VERSION \
	-t "$BASE_IMAGE" \
	-f docker/Dockerfile \
	.

echo -e "${BLUE}❯ ${CYAN}Building ${YELLOW}acmesh ${CYAN}...${RESET}"
docker buildx build \
	--platform "$PLATFORMS" \
	--progress plain \
	--push \
	--build-arg BASE_IMAGE \
	-t "$ACMESH_IMAGE" \
	-f docker/Dockerfile.acmesh \
	.

echo -e "${BLUE}❯ ${CYAN}Building ${YELLOW}certbot ${CYAN}...${RESET}"
docker buildx build \
	--platform "$PLATFORMS" \
	--progress plain \
	--push \
	--build-arg BASE_IMAGE \
	-t "$CERTBOT_IMAGE" \
	-f docker/Dockerfile.certbot \
	.

echo -e "${BLUE}❯ ${CYAN}Building ${YELLOW}acmesh-golang ${CYAN}...${RESET}"
docker buildx build \
	--platform "$PLATFORMS" \
	--progress plain \
	--push \
	--build-arg ACMESH_IMAGE \
	-t "$ACMESH_GOLANG_IMAGE" \
	-f docker/Dockerfile.acmesh-golang \
	.

echo -e "${BLUE}❯ ${CYAN}Building ${YELLOW}certbot-node ${CYAN}...${RESET}"
docker buildx build \
	--platform "$PLATFORMS" \
	--progress plain \
	--push \
	--build-arg CERTBOT_IMAGE \
	-t "$CERTBOT_NODE_IMAGE" \
	-f docker/Dockerfile.certbot-node \
	.

docker buildx rm "${BUILDX_NAME:-nginx-full}"

echo -e "${BLUE}❯ ${GREEN}All done!${RESET}"
