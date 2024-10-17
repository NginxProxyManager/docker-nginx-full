#!/bin/bash -e

BLUE='\E[1;34m'
CYAN='\E[1;36m'
YELLOW='\E[1;33m'
GREEN='\E[1;32m'
RESET='\E[0m'

echo -e "${BLUE}❯ ${CYAN}Building brotli ${YELLOW}${LUA_VERSION}...${RESET}"

# Determine the correct binary file for the architecture given
M64="-m64"
if [ "$TARGETPLATFORM" = "linux/arm/v7" ]; then
	echo -e "${BLUE}❯ ${YELLOW}Skipping brotli for non-64bit arch${RESET}"
else
	cd /tmp
	git clone --recurse-submodules -j8 "https://github.com/google/ngx_brotli"
	cd /tmp/ngx_brotli/deps/brotli

	mkdir -p /tmp/ngx_brotli/deps/brotli/out
	cd /tmp/ngx_brotli/deps/brotli/out

	cmake -DCMAKE_BUILD_TYPE=Release -DBUILD_SHARED_LIBS=OFF -DCMAKE_C_FLAGS="-Ofast -m64 -march=native -mtune=native -flto -funroll-loops -ffunction-sections -fdata-sections -Wl,--gc-sections" -DCMAKE_CXX_FLAGS="-Ofast -m64 -march=native -mtune=native -flto -funroll-loops -ffunction-sections -fdata-sections -Wl,--gc-sections" -DCMAKE_INSTALL_PREFIX=./installed ..
	cmake --build . --config Release --target brotlienc

	echo -e "${BLUE}❯ ${GREEN}brotli build completed${RESET}"
fi
