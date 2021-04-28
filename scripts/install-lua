#!/bin/bash -e

BLUE='\E[1;34m'
CYAN='\E[1;36m'
YELLOW='\E[1;33m'
GREEN='\E[1;32m'
RESET='\E[0m'

echo -e "${BLUE}❯ ${CYAN}Installing Lua ${YELLOW}${LUA_VERSION}...${RESET}"

cd /tmp/lua
make install
rm -rf /tmp/lua

echo -e "${BLUE}❯ ${GREEN}Lua install completed${RESET}"

echo -e "${BLUE}❯ ${CYAN}Installing Luarocks ${YELLOW}${LUAROCKS_VERSION}...${RESET}"

cd /tmp/luarocks
make install
rm -rf /tmp/luarocks

echo -e "${BLUE}❯ ${GREEN}Luarocks install completed${RESET}"