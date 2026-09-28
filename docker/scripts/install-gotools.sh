#!/bin/bash
set -e

BLUE='\E[1;34m'
CYAN='\E[1;36m'
GREEN='\E[1;32m'
RESET='\E[0m'

# Determine the correct binary file for the architecture given
case $TARGETPLATFORM in
	linux/arm64)
		ARCH=arm64
		;;

	*)
		ARCH=amd64
		;;
esac

if [ "$ARCH" = "amd64" ]; then
	go install github.com/golangci/golangci-lint/v2/cmd/golangci-lint@latest
	go install github.com/kyoh86/richgo@latest
	go install github.com/mfridman/tparse@latest
	go install github.com/vladopajic/go-test-coverage/v2@latest
	go install github.com/jstemmer/go-junit-report/v2@latest
	go install golang.org/x/tools/cmd/goimports@latest
	go install golang.org/x/tools/cmd/benchcmp@latest
	go install golang.org/x/tools/cmd/godoc@latest
	go install golang.org/x/vuln/cmd/govulncheck@latest
	go install github.com/oligot/go-mod-upgrade@latest
	go install github.com/Zxilly/go-size-analyzer/cmd/gsa@latest
	# Packages required to generate grpc/protobuf/docs
	go install google.golang.org/protobuf/cmd/protoc-gen-go@latest
	go install google.golang.org/grpc/cmd/protoc-gen-go-grpc@latest
	go install github.com/mwitkow/go-proto-validators/protoc-gen-govalidators@latest
	go install github.com/pseudomuto/protoc-gen-doc/cmd/protoc-gen-doc@latest
	go install github.com/daveshanley/vacuum@v0.26.4
	go install golang.org/x/tools/gopls/internal/analysis/modernize/cmd/modernize@latest
fi

rm -rf "$(go env GOPATH)/.cache/go-build"
echo -e "${BLUE}❯ ${GREEN}Tools install completed${RESET}"

