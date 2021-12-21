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

The following is compiled/installed:

- OpenResty
- Lua
- Certbot
- Python3 and pip

The following architectures are supported:

- amd64
- arm/v7
- arm64

### Usage:

```
FROM nginxproxymanager/nginx-full

...
```
