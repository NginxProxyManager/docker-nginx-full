#############
# Go Builder
#############

FROM golang:latest as go

ENV MKCERT_VERSION=1.4.2
RUN mkdir /workspace
WORKDIR /workspace
RUN go get github.com/amacneil/dbmate
RUN wget -O mkcert.tgz "https://github.com/FiloSottile/mkcert/archive/v${MKCERT_VERSION}.tar.gz"
RUN tar -xzf mkcert.tgz
WORKDIR "/workspace/mkcert-${MKCERT_VERSION}"
RUN go build -ldflags "-X main.Version=v${MKCERT_VERSION}" -o /bin/mkcert

#############
# Nginx Builder
#############

FROM debian:stable-slim as builder

ARG OPENRESTY_VERSION
ARG LUA_VERSION
ARG LUAROCKS_VERSION

RUN apt-get update \
	&& apt-get install -y --no-install-recommends wget build-essential libreadline-dev openssl unzip libncurses-dev libpcre3-dev libssl-dev zlib1g-dev

# Lua build
COPY ./scripts/build-lua /tmp/build-lua
RUN /tmp/build-lua

# Nginx build
COPY ./scripts/build-openresty /tmp/build-openresty
RUN /tmp/build-openresty

#############
# Final Image
#############

FROM debian:stable-slim
LABEL maintainer="Jamie Curnow <jc@jc21.com>"

SHELL ["/bin/bash", "-o", "pipefail", "-c"]

# Env var for bashrc
ARG OPENRESTY_VERSION
ENV OPENRESTY_VERSION=${OPENRESTY_VERSION}

ARG TARGETPLATFORM
RUN echo "Base: debian:stable-slim, ${TARGETPLATFORM:-linux/amd64}" > /built-for-arch

# OpenResty uses LuaJIT which has a dependency on GCC
RUN apt-get update \
	&& apt-get install -y --no-install-recommends curl figlet openssl libpcre3 zlib1g apache2-utils tzdata perl libreadline7 unzip libncurses6 make gcc \
	&& apt-get clean \
	&& rm -rf /var/lib/apt/lists/*

ADD ./files/.bashrc /root/.bashrc

# Copy lua and luarocks builds from first image
COPY --from=builder /tmp/lua /tmp/lua
COPY --from=builder /tmp/luarocks /tmp/luarocks
COPY ./scripts/install-lua /tmp/install-lua

# Copy openresty build from first image
COPY --from=builder /tmp/openresty /tmp/openresty
COPY ./scripts/install-openresty /tmp/install-openresty

# Copy golang built packages
COPY --from=go /bin/mkcert /bin/mkcert
COPY --from=go /go/bin/dbmate /bin/dbmate

RUN /tmp/install-lua \
	&& /tmp/install-openresty \
	&& rm -f /tmp/install-lua \
	&& rm -f /tmp/install-openresty \
	&& apt-get remove -y make gcc \
	&& apt-get autoremove -y

LABEL org.label-schema.schema-version="1.0" \
	org.label-schema.license="MIT" \
	org.label-schema.name="nginx-full" \
	org.label-schema.description="A base image for use by Nginx Proxy Manager" \
	org.label-schema.url="https://github.com/jc21/docker-nginx-full" \
	org.label-schema.vcs-url="https://github.com/jc21/docker-nginx-full.git" \
	org.label-schema.cmd="docker run --rm -ti jc21/nginx-full:latest"
