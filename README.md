# nginx-full

<p>
  <img src="https://img.shields.io/badge/openresty-1.19.9.1-green.svg?style=for-the-badge">
  <img src="https://img.shields.io/badge/lua-5.1.5-green.svg?style=for-the-badge">
  <img src="https://img.shields.io/badge/luarocks-3.3.1-green.svg?style=for-the-badge">
  <a href="https://hub.docker.com/repository/docker/nginxproxymanager/nginx-full">
    <img src="https://img.shields.io/docker/stars/nginxproxymanager/nginx-full.svg?style=for-the-badge">
  </a>
  <a href="https://hub.docker.com/repository/docker/nginxproxymanager/nginx-full">
    <img src="https://img.shields.io/docker/pulls/nginxproxymanager/nginx-full.svg?style=for-the-badge">
  </a>
  <a href="https://ci.nginxproxymanager.com/blue/organizations/jenkins/docker-nginx-full/branches/">
    <img src="https://img.shields.io/jenkins/build?jobUrl=https%3A%2F%2Fci.nginxproxymanager.com%2Fjob%2Fdocker-nginx-full%2Fjob%2Fmaster&style=for-the-badge">
  </a>
</p>

This is a base image for use in other images. See Dockerfile for build steps.

The following images are built:

**latest**
- OpenResty
- Lua

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
FROM nginxproxymanager/nginx-full:latest

...
```

#### Acme.sh Example

```
docker run \
  -v /path/to/local/acme-data:/data/.acme.sh \
  nginxproxymanager/nginx-full:acmesh \
  acme.sh -h
```
