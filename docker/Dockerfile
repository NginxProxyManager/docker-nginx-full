#############
# Nginx Builder
#############

FROM debian:buster-slim as nginxbuilder

ARG DOCKER_IMAGE
ARG BASE_TAG
ARG MAINTAINER
ARG REPO_OWNER

ARG OPENRESTY_VERSION
ARG LUA_VERSION
ARG LUAROCKS_VERSION
# CrowdSec and ModSecurity
ARG CROWDSEC_OPENRESTY_BOUNCER_VERSION
ARG NGINX_HTTP_GEOIP2_MODULE_VERSION
ARG MAXMINDDB_VERSION
ARG CRS_VERSION
ARG MODSECURITY_VERSION
ARG MODSECURITY_NGINX_VERSION
# URLs
ARG OPENRESTY_URL=https://openresty.org/download/openresty-${OPENRESTY_VERSION}.tar.gz
ARG NGINX_HTTP_GEOIP2_MODULE_URL=https://github.com/leev/ngx_http_geoip2_module/archive/${NGINX_HTTP_GEOIP2_MODULE_VERSION}.tar.gz
ARG LIBMAXMINDDB_URL=https://github.com/maxmind/libmaxminddb/releases/download/${MAXMINDDB_VERSION}/libmaxminddb-${MAXMINDDB_VERSION}.tar.gz
ARG MODSECURITY_NGINX_URL=https://github.com/SpiderLabs/ModSecurity-nginx/releases/download/v${MODSECURITY_NGINX_VERSION}/modsecurity-nginx-v${MODSECURITY_NGINX_VERSION}.tar.gz
ARG MODSECURITY_GIT_URL=https://github.com/SpiderLabs/ModSecurity.git

RUN apt-get update \
        && apt-get install -y \
        build-essential \
        automake \
        pkg-config \
        libtool \
        flex \
        bison \
        ca-certificates \
        libncurses-dev \
        perl \
        libpcre3-dev \
        libreadline-dev \
        libssl-dev \
        libyajl-dev \
        libpcre3-dev \
        libxml2-dev \
        libcurl4-gnutls-dev \
        libgeoip-dev \
        liblmdb-dev \
        libfuzzy-dev \
        liblua5.1-0-dev \
        openssl unzip \
        wget \
        curl \
        file \
        zlib1g-dev \
        git

# Lua build
COPY ./scripts/build-lua /tmp/build-lua
RUN /tmp/build-lua

# MindMax DB
COPY ./scripts/build-mindmaxdb /tmp/build-mindmaxdb
RUN /tmp/build-mindmaxdb

# Modsecurity build
COPY ./scripts/build-modsecurity /tmp/build-modsecurity
RUN /tmp/build-modsecurity

# Nginx build
COPY ./scripts/build-openresty /tmp/build-openresty
RUN /tmp/build-openresty

#############
# Final Image
#############

FROM debian:buster-slim

ARG DOCKER_IMAGE
ARG BASE_TAG
ARG MAINTAINER
ARG REPO_OWNER
ARG TARGETPLATFORM
ARG CROWDSEC_OPENRESTY_BOUNCER_VERSION
ARG CROWDSEC_OPENRESTY_BOUNCER_URL=https://github.com/crowdsecurity/cs-openresty-bouncer/releases/download/v${CROWDSEC_OPENRESTY_BOUNCER_VERSION}/crowdsec-openresty-bouncer.tgz
ARG NGINX_HTTP_GEOIP2_MODULE_VERSION
ARG MAXMINDDB_VERSION
ARG OPENRESTY_VERSION
ARG CRS_VERSION
ARG MODSECURITY_VERSION
ARG MODSECURITY_NGINX_VERSION

LABEL maintainer="${MAINTAINER:-'baudneo <baudneo@protonmail.me>'}"

SHELL ["/bin/bash", "-o", "pipefail", "-c"]

RUN echo "Base: debian:buster-slim, ${TARGETPLATFORM:-linux/amd64}" > /built-for-arch

# OpenResty uses LuaJIT which has a dependency on GCC
RUN apt-get update \
        && apt-get install -y --no-install-recommends \
        apache2-utils \
        ca-certificates \
        curl \
        figlet \
        jq \
        libncurses6 \
        libpcre3 \
        libreadline7 \
        openssl \
        perl \
        libpcre3-dev \
        tzdata \
        unzip \
        zlib1g \
        libyajl2 \
        libpcre3 \
        libxml2 \
        libcurl3-gnutls \
        libgeoip1 \
        liblmdb0 \
        libfuzzy2 \
        liblua5.1-0 \
        && apt-get clean \
        && rm -rf /var/lib/apt/lists/* \
        && rm -rf /var/cache/* /var/log/* /tmp/* /var/lib/dpkg/status-old

COPY ./files/.bashrc /root/.bashrc
COPY ./files/sed-patch /usr/bin

# Copy lua and luarocks builds from first image
COPY --from=nginxbuilder /tmp/lua /tmp/lua
COPY --from=nginxbuilder /tmp/luarocks /tmp/luarocks
COPY ./scripts/install-lua /tmp/install-lua

# Copy openresty build from first image with modules
#Copy libmaxminddb build from first image
COPY --from=nginxbuilder /tmp/libmaxminddb /tmp/libmaxminddb
COPY --from=nginxbuilder /tmp/ngx_http_geoip2_module /tmp/ngx_http_geoip2_module
# Copy Modsecurity config files from first image
COPY --from=nginxbuilder /tmp/configs /tmp/configs
# Copy Modsecurity build from first image
COPY --from=nginxbuilder /usr/local/modsecurity /usr/local/modsecurity
COPY --from=nginxbuilder /tmp/modsecurity-nginx /tmp/modsecurity-nginx

COPY --from=nginxbuilder /tmp/openresty /tmp/openresty
COPY ./scripts/install-openresty /tmp/install-openresty
COPY ./scripts/install-modsecurity /tmp/install-modsecurity
# Copy crowdsec openresty bouncer install script
COPY ./scripts/install-crowdsec-openresty-bouncer /tmp/install-crowdsec-openresty-bouncer

ENV SSL_CERT_FILE=/etc/ssl/certs/ca-certificates.crt \
        OPENRESTY_VERSION=${OPENRESTY_VERSION} \
        CROWDSEC_BOUNCER="0" \
         ADMIN_PANEL_LOG="0"

# Install openresty, lua, crowdsec openresty bouncer then clean up file system
RUN apt-get update \
        && apt-get install -y gcc make socat git \
        && /tmp/install-lua \
        && /tmp/install-modsecurity \
        && /tmp/install-openresty \
        && /tmp/install-crowdsec-openresty-bouncer \
        && apt-get remove -y make gcc git \
        && apt-get autoremove -y \
        && apt-get clean \
        && rm -rf /var/lib/apt/lists/* \
        && rm -rf /var/cache/* /var/log/* /tmp/* /var/lib/dpkg/status-old

LABEL org.label-schema.schema-version="1.0" \
        org.label-schema.license="MIT" \
        org.label-schema.name="nginx-full" \
        org.label-schema.description="A base image for use by Nginx Proxy Manager with CrowdSec, GeoIP2 and ModSecurity" \
        org.label-schema.url="https://github.com/${REPO_OWNER:-nginxproxymanager}/docker-nginx-full" \
        org.label-schema.vcs-url="https://github.com/${REPO_OWNER:-nginxproxymanager}/docker-nginx-full.git" \
        org.label-schema.cmd="docker run --rm -ti ${DOCKER_IMAGE:-nginxproxymanager/nginx-full}:${BASE_TAG:-latest}"
