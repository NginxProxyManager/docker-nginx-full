#!/bin/bash -e

export BLUE='\E[1;34m'
export CYAN='\E[1;36m'
export YELLOW='\E[1;33m'
export GREEN='\E[1;32m'
export RED='\E[1;31m'
export RESET='\E[0m'

export DOCKER_IMAGE=baudneo/nginx-full
export MAINTAINER="baudneo <baudneo@protonmail.com>"
export REPO_OWNER="baudneo"
export BASE_TAG='local_latest'

export CERTBOT_NODE_TAG='local_certbot-node'
export CERTBOT_TAG='local_certbot'
#export ACMESH_TAG='local_acmesh'
#export ACMESH_GO_TAG='local_acmesh-golang'

export OPENRESTY_VERSION=1.21.4.1
export LUA_VERSION=5.1.5
export LUAROCKS_VERSION=3.3.1
export NGINX_HTTP_GEOIP2_MODULE_VERSION=3.3
# for GeoIP2 and modsecurity
export MAXMINDDB_VERSION=1.6.0
# crowdsec openresty bouncer
export CROWDSEC_OPENRESTY_BOUNCER_VERSION=0.1.11
# modsecurity
export MODSECURITY_VERSION=3.0.8
export MODSECURITY_NGINX_VERSION=1.0.3
export CRS_VERSION=3.3.4

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
echo -e "${GREEN}❯❯❯ ${RED}DONE!"

#echo -e "${BLUE}❯ ${CYAN}Building ${YELLOW}acmesh ${CYAN}...${RESET}"
#docker build \
#        --build-arg DOCKER_IMAGE="$DOCKER_IMAGE" \
#        --build-arg MAINTAINER="$MAINTAINER" \
#        --build-arg BASE_TAG="$BASE_TAG" \
#        -t ${DOCKER_IMAGE}:acmesh \
#        -f docker/Dockerfile.acmesh \
#        .
echo -e "${BLUE}❯ ${CYAN}Building ${YELLOW}${CERTBOT_TAG} ${CYAN}...${RESET}"
docker build \
        --build-arg DOCKER_IMAGE="$DOCKER_IMAGE" \
        --build-arg MAINTAINER="$MAINTAINER" \
        --build-arg BASE_TAG="$BASE_TAG" \
        --build-arg CERTBOT_TAG="$CERTBOT_TAG" \
        -t ${DOCKER_IMAGE}:${CERTBOT_TAG} \
        -f docker/Dockerfile.certbot \
        .
echo -e "${GREEN}❯❯❯ ${RED}DONE!"
#echo -e "${BLUE}❯ ${CYAN}Building ${YELLOW}acmesh-golang ${CYAN}...${RESET}"
#docker build \
#        --build-arg BASE_TAG=acmesh \
#        --build-arg DOCKER_IMAGE="$DOCKER_IMAGE" \
#        --build-arg MAINTAINER="$MAINTAINER" \
#        -t ${DOCKER_IMAGE}:acmesh-golang \
#        -f docker/Dockerfile.acmesh-golang \
#        .

echo -e "${BLUE}❯ ${CYAN}Building ${YELLOW}${CERTBOT_NODE_TAG} ${CYAN}...${RESET}"
echo -e "${RED}CERTBOT_TAG: ${GREEN}${CERTBOT_TAG} ${RED}- BASE_TAG: ${GREEN}${BASE_TAG}${RED} - CERTBOT_NODE_TAG:${GREEN} ${CERTBOT_NODE_TAG} ${RED}- TARGETPLATFORM:${GREEN} ${TARGETPLATFORM} ${RED}- MAINTAINER:${GREEN} ${MAINTAINER}${RESET}"

docker build \
        --build-arg BASE_TAG="$BASE_TAG" \
        --build-arg DOCKER_IMAGE="$DOCKER_IMAGE" \
        --build-arg MAINTAINER="$MAINTAINER" \
        --build-arg CERTBOT_TAG="$CERTBOT_TAG" \
        --build-arg CERTBOT_NODE_TAG="$CERTBOT_NODE_TAG" \
        -t ${DOCKER_IMAGE}:${CERTBOT_NODE_TAG} \
        -f docker/Dockerfile.certbot-node \
        .

echo -e "${BLUE}❯ ${GREEN}All done!${RESET}"
