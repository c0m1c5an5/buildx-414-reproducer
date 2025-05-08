variable CI_REGISTRY_IMAGE { default = "example" }
variable CI_COMMIT_SHA { default = "manual" }
variable CI_DEFAULT_BRANCH { default = "main" }
variable CI_COMMIT_BRANCH { default = null }

variable "DEFAULT_CACHE_SLUG" {
  default = usanitize(CI_DEFAULT_BRANCH)
}

variable "CACHE_SLUG" {
  default = try(usanitize(CI_COMMIT_BRANCH), null)
}

function "usanitize" {
  params = [arg]
  result = join("-", [replace(sanitize(arg), "_", "-"), md5(arg)])
}

function "ref" {
  params = [name, arch, tag]
  result = "${CI_REGISTRY_IMAGE}/${name}:${arch}-${tag}"
}

function "tags" {
  params = [name, arch]
  result = [
    ref(name, arch, CI_COMMIT_SHA),
  ]
}

function "cache" {
  params = [name, arch, tag]
  result = {
    type = "registry"
    ref  = ref(name, "cache", join("-", [arch, tag]))
  }
}

function "cache-to" {
  params = [name, arch]
  result = try([
    merge(
      cache(name, arch, CACHE_SLUG),
      { mode = "max" },
    )
  ], [])
}

function "cache-from" {
  params = [name, arch]
  result = concat(
    try([cache(name, arch, CACHE_SLUG)], []),
    [cache(name, arch, DEFAULT_CACHE_SLUG)]
  )
}

group "default" {
  targets = ["distro"]
}

variable "distro-targets" {
  default = [
    "base",
    "aws-cli",
    "docker-cli",
  ]
}

variable "almalinux-image" {
  default = "docker-image://quay.io/almalinuxorg/9-minimal:9.5-20250307"
}

target "distro" {
  name = "${tgt}-${arch}"
  matrix = {
    tgt  = distro-targets
    arch = ["amd64"]
  }
  platforms = ["linux/${arch}"]
  context   = "src/${tgt}"
  contexts = {
    base                  = tgt == "base" ? almalinux-image : "target:base-${arch}"
    pkg-cache             = "pkg-cache"
  }
  output     = [{ type = "registry" }]
  tags       = tags(tgt, arch)
  cache-from = cache-from(tgt, arch)
  cache-to   = cache-to(tgt, arch)
}
