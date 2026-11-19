#!/bin/bash -e

BLUE='\E[1;34m'
CYAN='\E[1;36m'
YELLOW='\E[1;33m'
GREEN='\E[1;32m'
RESET='\E[0m'

echo -e "${BLUE}❯ ${CYAN}Building OpenResty ${YELLOW}${OPENRESTY_VERSION} with nginx_http_geoip2 module...${RESET}"

cd /tmp

# The official releases:
# wget "https://openresty.org/download/openresty-${OPENRESTY_VERSION}.tar.gz" -O "openresty-${OPENRESTY_VERSION}.tar.gz"

# The github tagged releases:
wget "https://github.com/openresty/openresty/archive/refs/tags/v${OPENRESTY_VERSION}.tar.gz" -O "openresty-${OPENRESTY_VERSION}.tar.gz"

tar -xzf "openresty-${OPENRESTY_VERSION}.tar.gz"
mv "/tmp/openresty-${OPENRESTY_VERSION}" /tmp/openresty
# Pinned, so a new push to that repo can't change what gets compiled into nginx.
# To update: review the module's changes, then replace the hash. The build fails
# if this commit can't be checked out.
GEOIP2_COMMIT=445df24ef3781e488cee3dfe8a1e111997fc1dfe
git clone 'https://github.com/leev/ngx_http_geoip2_module.git'
git -C /tmp/ngx_http_geoip2_module -c advice.detachedHead=false checkout "$GEOIP2_COMMIT"
[ "$(git -C /tmp/ngx_http_geoip2_module rev-parse HEAD)" = "$GEOIP2_COMMIT" ]
mv /tmp/ngx_http_geoip2_module /tmp/openresty/ngx_http_geoip2_module
cd /tmp/openresty

make

# Backport the two nginx 1.31.9 HTTP/2 security fixes to this OpenResty release.
# The DATA-frame queue change is required by the CVE-2026-123007 fix.
if [ "${OPENRESTY_VERSION}" = "1.31.8.1" ]; then
	for patch in http2-data-frame-queue.patch CVE-2026-123633.patch CVE-2026-123007.patch; do
		git -C "/tmp/openresty/openresty-${OPENRESTY_VERSION}/bundle/nginx-1.31.8" apply "/tmp/openresty-patches/$patch"
	done
fi

cd "/tmp/openresty/openresty-${OPENRESTY_VERSION}"

./configure \
	--prefix=/etc/nginx \
	--sbin-path=/usr/sbin/nginx \
	--modules-path=/usr/lib/nginx/modules \
	--conf-path=/etc/nginx/nginx.conf \
	--error-log-path=/var/log/nginx/error.log \
	--http-log-path=/var/log/nginx/access.log \
	--pid-path=/var/run/nginx.pid \
	--lock-path=/var/run/nginx.lock \
	--http-client-body-temp-path=/var/cache/nginx/client_temp \
	--http-proxy-temp-path=/var/cache/nginx/proxy_temp \
	--http-fastcgi-temp-path=/var/cache/nginx/fastcgi_temp \
	--http-uwsgi-temp-path=/var/cache/nginx/uwsgi_temp \
	--http-scgi-temp-path=/var/cache/nginx/scgi_temp \
	--user=nginx \
	--group=nginx \
	--with-compat \
	--with-threads \
	--with-http_addition_module \
	--with-http_auth_request_module \
	--with-http_dav_module \
	--with-http_flv_module \
	--with-http_gunzip_module \
	--with-http_gzip_static_module \
	--with-http_mp4_module \
	--with-http_random_index_module \
	--with-http_realip_module \
	--with-http_secure_link_module \
	--with-http_slice_module \
	--with-http_ssl_module \
	--with-http_stub_status_module \
	--with-http_sub_module \
	--with-http_v2_module \
	--with-mail \
	--with-mail_ssl_module \
	--with-stream \
	--with-stream_realip_module \
	--with-stream_ssl_module \
	--with-stream_ssl_preread_module \
	--with-http_v3_module \
	--add-dynamic-module=/tmp/openresty/ngx_http_geoip2_module

make -j"$(nproc)"

echo -e "${BLUE}❯ ${GREEN}OpenResty build completed${RESET}"
