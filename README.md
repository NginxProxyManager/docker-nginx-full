# nginx-full

<p>
  <img src="https://img.shields.io/badge/openresty-1.21.4.2-green.svg?style=for-the-badge">
  <img src="https://img.shields.io/badge/openssl-3-1-2-green.svg?style=for-the-badge">
  <img src="https://img.shields.io/badge/lua-5.1.5-green.svg?style=for-the-badge">
  <img src="https://img.shields.io/badge/luarocks-3.3.1-green.svg?style=for-the-badge">
  <a href="https://hub.docker.com/repository/docker/jc21/nginx-full">
    <img src="https://img.shields.io/docker/stars/jc21/nginx-full.svg?style=for-the-badge">
  </a>
  <a href="https://hub.docker.com/repository/docker/jc21/nginx-full">
    <img src="https://img.shields.io/docker/pulls/jc21/nginx-full.svg?style=for-the-badge">
  </a>
</p>

This is a base image for use in other images. See Dockerfile for build steps.

The following images are built:

**latest**
- OpenResty
- OpenSSL
- Lua
- [Crowdsec Openresty Bouncer](https://github.com/crowdsecurity/cs-openresty-bouncer)

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
FROM jc21/nginx-full:latest

...
```

#### Acme.sh Example

```
docker run \
  -v /path/to/local/acme-data:/data/.acme.sh \
  jc21/nginx-full:acmesh \
  acme.sh -h
```

