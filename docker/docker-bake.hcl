variable "DOCKER_IMAGE" {
	default = "nginxproxymanager/nginx-full"
}
variable "BASE_TAG" {
	default = "latest"
}
variable "TAG_PREFIX" {
	default = ""
}
variable "OPENRESTY_VERSION" {
	default = "1.31.1.1"
}
variable "LUA_VERSION" {
	default = "5.1.5"
}
variable "LUAROCKS_VERSION" {
	default = "3.13.0"
}

group "default" {
	targets = ["base", "acmesh", "acmesh-golang", "certbot", "certbot-node"]
}

target "common" {
	platforms = ["linux/amd64", "linux/arm64"]
}

target "base" {
	inherits = ["common"]
	dockerfile = "docker/Dockerfile"
	args = {
		OPENRESTY_VERSION = "${OPENRESTY_VERSION}"
		LUA_VERSION = "${LUA_VERSION}"
		LUAROCKS_VERSION = "${LUAROCKS_VERSION}"
	}
	tags = ["${DOCKER_IMAGE}:${BASE_TAG}"]
}

target "acmesh" {
	inherits = ["common"]
	dockerfile = "docker/Dockerfile.acmesh"
	contexts = {
		base = "target:base"
	}
	tags = ["${DOCKER_IMAGE}:${TAG_PREFIX}acmesh"]
}

target "acmesh-golang" {
	inherits = ["common"]
	dockerfile = "docker/Dockerfile.acmesh-golang"
	contexts = {
		acmesh = "target:acmesh"
	}
	tags = ["${DOCKER_IMAGE}:${TAG_PREFIX}acmesh-golang"]
}

target "certbot" {
	inherits = ["common"]
	dockerfile = "docker/Dockerfile.certbot"
	contexts = {
		base = "target:base"
	}
	tags = ["${DOCKER_IMAGE}:${TAG_PREFIX}certbot"]
}

target "certbot-node" {
	inherits = ["common"]
	dockerfile = "docker/Dockerfile.certbot-node"
	contexts = {
		certbot = "target:certbot"
	}
	tags = ["${DOCKER_IMAGE}:${TAG_PREFIX}certbot-node"]
}
