# nginx-full

<p>
  <img src="https://img.shields.io/badge/openresty-1.21.4.1-green.svg?style=for-the-badge">
  <img src="https://img.shields.io/badge/lua-5.1.5-green.svg?style=for-the-badge">
  <img src="https://img.shields.io/badge/luarocks-3.3.1-green.svg?style=for-the-badge">
  <a href="https://github.com/baudneo/docker-nginx-full/tree/crowdsec_openresty">
    <img src="https://img.shields.io/badge/CrowdSec OpenResty Bouncer-0.1.11-green.svg?style=for-the-badge">
  </a>
  <a href="https://github.com/SpiderLabs/ModSecurity/tree/e9a7ba4a60be48f761e0328c6dfcc668d70e35a0">
    <img src="https://img.shields.io/badge/ModSecurity Commit-e9a7ba4a60be48f761e0328c6dfcc668d70e35a0-yellow.svg?style=for-the-badge">
  </a>
  <a href="https://github.com/SpiderLabs/ModSecurity-nginx">
    <img src="https://img.shields.io/badge/ModSecurity NGINX Connector-1.0.3-green.svg?style=for-the-badge">
  </a>

  <a href="https://hub.docker.com/repository/docker/baudneo/nginx-full">
    <img src="https://img.shields.io/docker/stars/baudneo/nginx-full.svg?style=for-the-badge">
  </a>
  <a href="https://hub.docker.com/repository/docker/baudneo/nginx-full">
    <img src="https://img.shields.io/docker/pulls/baudneo/nginx-full.svg?style=for-the-badge">
  </a>
</p>

This is a base image for use in other images. See Dockerfile for build steps.

The following images are built:

**latest**
- OpenResty
- Lua
- CrowdSec OpenResty-Bouncer
- ModSecurity 3.x __(Memory Leak present in ALL 3.x builds!!!)__ SEE: https://github.com/SpiderLabs/ModSecurity/issues/2817
- ModSecurity NGINX Connector

**certbot**
- Certbot
- Python3 and pip

**acmesh** _(used in Nginx Proxy Manager v3)_
- Acme.sh

**certbot-node** _(used in Nginx Proxy Manager v2)_
- Certbot
- Python3 and pip
- Nodejs

**acmesh-golang** _(development for Nginx Proxy Manager v3)_
- Acme.sh
- Golang

The following architectures are supported for all images:

- amd64
- arm/v7
- arm64

### Usage:

```
FROM baudneo/nginx-full:latest

...
```

#### Acme.sh Example

```
docker run \
  -v /path/to/local/acme-data:/data/.acme.sh \
  baudneo/nginx-full:acmesh \
  acme.sh -h
```