#############
# Nginx Builder
#############

FROM debian:trixie-slim AS nginxbuilder

ARG OPENRESTY_VERSION
ARG LUA_VERSION
ARG LUAROCKS_VERSION

ENV OPENRESTY_VERSION=${OPENRESTY_VERSION} \
	LUA_VERSION=${LUA_VERSION} \
	LUAROCKS_VERSION=${LUAROCKS_VERSION}

RUN apt-get update \
	&& apt-get install -y \
	build-essential \
	ca-certificates \
	libncurses-dev \
	libpcre2-dev \
	libreadline-dev \
	libssl-dev \
	openssl unzip \
	wget \
	zlib1g-dev \
	git \
	libmaxminddb-dev \
	dos2unix

# Lua build
COPY ./docker/scripts/build-lua.sh /tmp/build-lua.sh
RUN /tmp/build-lua.sh

# Nginx build
COPY ./docker/patches/ /tmp/openresty-patches/
COPY ./docker/scripts/build-openresty.sh /tmp/build-openresty.sh
RUN /tmp/build-openresty.sh

#############
# Final Image
#############

FROM debian:trixie-slim AS final
LABEL maintainer="Jamie Curnow <jc@jc21.com>"

SHELL ["/bin/bash", "-o", "pipefail", "-c"]

ARG TARGETPLATFORM
RUN echo "Base: debian:trixie-slim, ${TARGETPLATFORM:-linux/amd64}" > /built-for-arch

# OpenResty uses LuaJIT which has a dependency on GCC
RUN apt-get update \
	&& apt-get install -y --no-install-recommends \
	apache2-utils \
	ca-certificates \
	curl \
	figlet \
	jq \
	libncurses6 \
	libpcre2-8-0 \
	libreadline8 \
	openssl \
	perl \
	tzdata \
	unzip \
	zlib1g \
	gettext \
	wget \
	xz-utils \
	libmaxminddb-dev \
	moreutils \
	&& apt-get clean \
	&& rm -rf /var/lib/apt/lists/* \
	&& rm -rf /var/cache/* /var/log/* /tmp/* /var/lib/dpkg/status-old

COPY ./docker/files/.bashrc /root/.bashrc

# Copy lua and luarocks builds from first image
COPY --from=nginxbuilder /tmp/lua /tmp/lua
COPY --from=nginxbuilder /tmp/luarocks /tmp/luarocks
COPY ./docker/scripts/install-lua.sh /tmp/install-lua.sh

# Copy openresty build from first image
COPY --from=nginxbuilder /tmp/openresty /tmp/openresty
COPY ./docker/scripts/install-openresty.sh /tmp/install-openresty.sh

ARG OPENRESTY_VERSION
ENV SSL_CERT_FILE=/etc/ssl/certs/ca-certificates.crt \
	OPENRESTY_VERSION=${OPENRESTY_VERSION}

# Install openresty, lua, then clean up file system
RUN apt-get update \
	&& apt-get install -y gcc make socat git \
	&& /tmp/install-lua.sh \
	&& /tmp/install-openresty.sh \
	&& apt-get remove -y make gcc git wget gettext \
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
