#############
# Certbot Builder
#############

FROM debian:buster-slim as certbotbuilder

SHELL ["/bin/bash", "-o", "pipefail", "-c"]

RUN apt-get update
RUN apt-get install -y \
	build-essential \
	curl \
	libaugeas0 \
	python3 \
	python3-dev \
	libffi-dev \
	libssl-dev \
	python3-venv \
	ca-certificates

ENV SSL_CERT_FILE=/etc/ssl/certs/ca-certificates.crt

# Yes, python compilation requires rust.
RUN curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y
ENV PATH="/root/.cargo/bin:$PATH"

# It's all about pip now.
RUN python3 -m venv /opt/certbot/
ENV PATH="/opt/certbot/bin:$PATH"

RUN curl -L 'https://bootstrap.pypa.io/get-pip.py' | python3

# Handle an extremely specific issue when building the cryptography package for
# 32-bit architectures within QEMU running on a 64-bit host
# Special thanks to https://github.com/JonasAlfredsson/docker-nginx-certbot
RUN if [ "$(getconf LONG_BIT)" = "32" ]; then \
	pip3 install --no-cache-dir -U cryptography==3.3.2; \
	fi

RUN pip install --no-cache-dir cffi certbot \
	&& pip install tldextract

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
	git \
	zlib1g-dev

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

# OpenResty uses LuaJIT which has a dependency on GCC
RUN apt-get update \
	&& apt-get install -y --no-install-recommends \
	apache2-utils \
	ca-certificates \
	curl \
	figlet \
	libncurses6 \
	libpcre3 \
	libreadline7 \
	openssl \
	perl \
	python3 \
	python3-distutils \
	python3-venv \
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
	&& rm -rf /var/lib/apt/lists/*

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

ENV SSL_CERT_FILE=/etc/ssl/certs/ca-certificates.crt

# Copy certbot
COPY --from=certbotbuilder /opt/certbot /opt/certbot
RUN curl -L 'https://bootstrap.pypa.io/get-pip.py' | python3 \
	&& python3 -m venv /opt/certbot/ \
	&& ln -s /opt/certbot/bin/certbot /usr/bin/certbot

ARG OPENRESTY_VERSION
ENV OPENRESTY_VERSION=${OPENRESTY_VERSION} \
	CERT_HOME='/data/acme.sh/' \
	PATH="/opt/certbot/bin:$PATH"

# Install openresty, lua
RUN apt-get update \
	&& apt-get install -y \
	gcc \
	make \
	socat \
	&& /tmp/install-libmaxminddb \
	&& /tmp/install-lua \
	&& /tmp/install-openresty \
	&& rm -f /tmp/install-libmaxminddb \
	&& rm -f /tmp/install-lua \
	&& rm -f /tmp/install-openresty \
	&& apt-get remove -y make gcc \
	&& apt-get autoremove -y \
	&& apt-get clean \
	&& rm -rf /var/lib/apt/lists/*

# acme.sh
RUN mkdir -p /data/acme.sh \
	&& curl -o /bin/acme.sh 'https://raw.githubusercontent.com/acmesh-official/acme.sh/master/acme.sh' \
	&& chmod +x /bin/acme.sh

LABEL org.label-schema.schema-version="1.0" \
	org.label-schema.license="MIT" \
	org.label-schema.name="nginx-full" \
	org.label-schema.description="A base image for use by Nginx Proxy Manager" \
	org.label-schema.url="https://github.com/jc21/docker-nginx-full" \
	org.label-schema.vcs-url="https://github.com/jc21/docker-nginx-full.git" \
	org.label-schema.cmd="docker run --rm -ti jc21/nginx-full:latest"
