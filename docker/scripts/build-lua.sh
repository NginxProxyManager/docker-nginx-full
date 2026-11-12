#!/bin/bash -e

BLUE='\E[1;34m'
CYAN='\E[1;36m'
YELLOW='\E[1;33m'
GREEN='\E[1;32m'
RESET='\E[0m'

# lua.org intermittently resets TLS handshakes, so retry downloads
download() {
	local url="$1"
	local attempt
	for attempt in 1 2 3 4 5 6; do
		if wget -q --timeout=30 -O "$(basename "$url")" "$url"; then
			return 0
		fi
		echo -e "${YELLOW}Download of ${url} failed (attempt ${attempt}), retrying...${RESET}"
		sleep $((attempt * 2))
	done
	echo "Failed to download ${url}" >&2
	return 1
}

echo -e "${BLUE}❯ ${CYAN}Building Lua ${YELLOW}${LUA_VERSION}...${RESET}"

cd /tmp
download "https://www.lua.org/ftp/lua-${LUA_VERSION}.tar.gz"
tar -xzf "lua-${LUA_VERSION}.tar.gz"
mv "/tmp/lua-${LUA_VERSION}" /tmp/lua
cd /tmp/lua

make linux test
# We have to install Lua for the Luarocks build to succeed,
# it will be installed again when building the final image
make install

echo -e "${BLUE}❯ ${GREEN}Lua build completed${RESET}"

echo -e "${BLUE}❯ ${CYAN}Building Luarocks ${YELLOW}${LUAROCKS_VERSION}...${RESET}"

cd /tmp
download "https://luarocks.github.io/luarocks/releases/luarocks-${LUAROCKS_VERSION}.tar.gz"
tar -xzf "luarocks-${LUAROCKS_VERSION}.tar.gz"
mv "/tmp/luarocks-${LUAROCKS_VERSION}" /tmp/luarocks
cd /tmp/luarocks

./configure
make

echo -e "${BLUE}❯ ${GREEN}Luarocks build completed${RESET}"
