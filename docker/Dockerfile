#############
# Nginx Builder
#############

FROM debian:buster-slim as nginxbuilder

ARG OPENRESTY_VERSION
ARG LUA_VERSION
ARG LUAROCKS_VERSION
ARG MAXMIND_VERSION
ARG MODSECURITY_VERSION
ARG MODSECURITY_NGINX_VERSION

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
	file \
	zlib1g-dev \
	git

# Lua build
COPY ./scripts/build-lua /tmp/build-lua
RUN /tmp/build-lua

# libmaxminddb build
COPY ./scripts/build-libmaxminddb /tmp/build-libmaxminddb
RUN /tmp/build-libmaxminddb

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
LABEL maintainer="Jamie Curnow <jc@jc21.com>"

SHELL ["/bin/bash", "-o", "pipefail", "-c"]

ARG TARGETPLATFORM
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

# Copy lua and luarocks builds from first image
COPY --from=nginxbuilder /tmp/lua /tmp/lua
COPY --from=nginxbuilder /tmp/luarocks /tmp/luarocks
COPY ./scripts/install-lua /tmp/install-lua

#Copy libmaxminddb build from first image
COPY --from=nginxbuilder /tmp/libmaxminddb /tmp/libmaxminddb
COPY ./scripts/install-libmaxminddb /tmp/install-libmaxminddb

# Copy Modsecurity build from first image
COPY --from=nginxbuilder /usr/local/modsecurity /usr/local/modsecurity

# Copy openresty build from first image
COPY --from=nginxbuilder /tmp/openresty /tmp/openresty
COPY --from=nginxbuilder /tmp/modsecurity-nginx /tmp/modsecurity-nginx
COPY ./scripts/install-openresty /tmp/install-openresty

ARG OPENRESTY_VERSION
ENV SSL_CERT_FILE=/etc/ssl/certs/ca-certificates.crt \
	OPENRESTY_VERSION=${OPENRESTY_VERSION}

# Install openresty, lua, then clean up file system
RUN apt-get update \
	&& apt-get install -y gcc make socat git \
	&& /tmp/install-libmaxminddb \
	&& /tmp/install-lua \
	&& /tmp/install-openresty \
	&& apt-get remove -y make gcc git \
	&& apt-get autoremove -y \
	&& apt-get clean \
	&& rm -rf /var/lib/apt/lists/* \
	&& rm -rf /var/cache/* /var/log/* /tmp/* /var/lib/dpkg/status-old

LABEL org.label-schema.schema-version="1.0" \
	org.label-schema.license="MIT" \
	org.label-schema.name="nginx-full" \
	org.label-schema.description="A base image for use by Nginx Proxy Manager" \
	org.label-schema.url="https://github.com/nginxproxymanager/docker-nginx-full" \
	org.label-schema.vcs-url="https://github.com/nginxproxymanager/docker-nginx-full.git" \
	org.label-schema.cmd="docker run --rm -ti nginxproxymanager/nginx-full:latest"
