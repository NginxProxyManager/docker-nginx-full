#!/bin/bash -e

export BLUE='\E[1;34m'
export CYAN='\E[1;36m'
export YELLOW='\E[1;33m'
export GREEN='\E[1;32m'
export RESET='\E[0m'

DOCKER_IMAGE=baudneo/nginx-full
MAINTAINER="baudneo <baudneo@protonmail.com>"
REPO_OWNER="baudneo"
BASE_TAG='cs-modsec'

export OPENRESTY_VERSION=1.19.9.1
export LUA_VERSION=5.1.5
export LUAROCKS_VERSION=3.3.1
export NGINX_HTTP_GEOIP2_MODULE_VERSION=3.3
# needed for GeoIP2 and modsecurity
export MAXMINDDB_VERSION=1.6.0
# crowdsec openresty bouncer
export CROWDSEC_OPENRESTY_BOUNCER_VERSION=0.1.0
#modsecurity
export MODSECURITY_VERSION=3.0.6
export MODSECURITY_NGINX_VERSION=1.0.2
export CRS_VERSION=3.3.2

# Builds
echo -e "${BLUE}❯ ${CYAN}Building ${YELLOW}${BASE_TAG} ${CYAN}...${RESET}"
docker build \
        --pull \
        --build-arg OPENRESTY_VERSION \
        --build-arg LUA_VERSION \
        --build-arg LUAROCKS_VERSION \
        --build-arg CROWDSEC_OPENRESTY_BOUNCER_VERSION \
        --build-arg NGINX_HTTP_GEOIP2_MODULE_VERSION \
        --build-arg MAXMINDDB_VERSION \
        --build-arg MODSECURITY_VERSION \
        --build-arg MODSECURITY_NGINX_VERSION \
        --build-arg CRS_VERSION \
        --build-arg DOCKER_IMAGE \
        --build-arg MAINTAINER \
        --build-arg BASE_TAG \
        --build-arg REPO_OWNER \
        -t ${DOCKER_IMAGE}:${BASE_TAG} \
        -f docker/Dockerfile \
        .

echo -e "${BLUE}❯ ${CYAN}Building ${YELLOW}acmesh ${CYAN}...${RESET}"
docker build \
        --build-arg DOCKER_IMAGE="$DOCKER_IMAGE" \
        --build-arg MAINTAINER="$MAINTAINER" \
        --build-arg BASE_TAG="$BASE_TAG" \
        -t ${DOCKER_IMAGE}:acmesh \
        -f docker/Dockerfile.acmesh \
        .

echo -e "${BLUE}❯ ${CYAN}Building ${YELLOW}certbot ${CYAN}...${RESET}"
docker build \
        --build-arg DOCKER_IMAGE="$DOCKER_IMAGE" \
        --build-arg MAINTAINER="$MAINTAINER" \
        --build-arg BASE_TAG="$BASE_TAG" \
        -t ${DOCKER_IMAGE}:certbot \
        -f docker/Dockerfile.certbot \
        .

echo -e "${BLUE}❯ ${CYAN}Building ${YELLOW}acmesh-golang ${CYAN}...${RESET}"
docker build \
        --build-arg BASE_TAG=acmesh \
        --build-arg DOCKER_IMAGE="$DOCKER_IMAGE" \
        --build-arg MAINTAINER="$MAINTAINER" \
        -t ${DOCKER_IMAGE}:acmesh-golang \
        -f docker/Dockerfile.acmesh-golang \
        .

echo -e "${BLUE}❯ ${CYAN}Building ${YELLOW}certbot-node ${CYAN}...${RESET}"
docker build \
        --build-arg BASE_TAG=certbot \
        --build-arg DOCKER_IMAGE="$DOCKER_IMAGE" \
        --build-arg MAINTAINER="$MAINTAINER" \
        -t ${DOCKER_IMAGE}:certbot-node \
        -f docker/Dockerfile.certbot-node \
        .

echo -e "${BLUE}❯ ${GREEN}All done!${RESET}"