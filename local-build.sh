#!/bin/bash -e

BLUE='\E[1;34m'
CYAN='\E[1;36m'
YELLOW='\E[1;33m'
GREEN='\E[1;32m'
RESET='\E[0m'

REGISTRY=${REGISTRY:-}
DOCKER_IMAGE="${REGISTRY}nginxproxymanager/nginx-full"

for version in `cat versions`; do export $version; done

export BASE_IMAGE="${DOCKER_IMAGE}:latest"
export ACMESH_IMAGE="${DOCKER_IMAGE}:acmesh"
export CERTBOT_IMAGE="${DOCKER_IMAGE}:certbot"
export CERTBOT_NODE_IMAGE="${DOCKER_IMAGE}:certbot-node"
export ACMESH_GOLANG_IMAGE="${DOCKER_IMAGE}:acmesh-golang"

# Builds

echo -e "${BLUE}❯ ${CYAN}Building ${YELLOW}latest ${CYAN}...${RESET}"
docker build \
	--pull \
	--build-arg OPENRESTY_VERSION \
	--build-arg CROWDSEC_OPENRESTY_BOUNCER_VERSION \
	--build-arg LUA_VERSION \
	--build-arg LUAROCKS_VERSION \
	--build-arg LIBMODSECURITY_VERSION \
	--build-arg MODSECURITY_NGINX_VERSION \
	--build-arg CRS_VERSION \
	-t "$BASE_IMAGE" \
	-f docker/Dockerfile \
	.

echo -e "${BLUE}❯ ${CYAN}Building ${YELLOW}acmesh ${CYAN}...${RESET}"
docker build \
	--build-arg BASE_IMAGE \
	-t "$ACMESH_IMAGE" \
	-f docker/Dockerfile.acmesh \
	.

echo -e "${BLUE}❯ ${CYAN}Building ${YELLOW}certbot ${CYAN}...${RESET}"
docker build \
	--build-arg BASE_IMAGE \
	-t "$CERTBOT_IMAGE" \
	-f docker/Dockerfile.certbot \
	.

echo -e "${BLUE}❯ ${CYAN}Building ${YELLOW}acmesh-golang ${CYAN}...${RESET}"
docker build \
	--build-arg ACMESH_IMAGE \
	-t "$ACMESH_GOLANG_IMAGE" \
	-f docker/Dockerfile.acmesh-golang \
	.

echo -e "${BLUE}❯ ${CYAN}Building ${YELLOW}certbot-node ${CYAN}...${RESET}"
docker build \
	--build-arg CERTBOT_IMAGE \
	-t "$CERTBOT_NODE_IMAGE" \
	-f docker/Dockerfile.certbot-node \
	.

echo -e "${BLUE}❯ ${GREEN}All done!${RESET}"
