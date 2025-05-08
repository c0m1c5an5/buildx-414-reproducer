# BuildKit registry cache issue docker/buildx/issues/414

This repository reprocduces the issue described in https://github.com/docker/buildx/issues/414.
In short, cache-from registry seems to stop working with multiple targets having another target
as their context. The `pkg-cache` context seems to be important, as without it, the issue does
not reproduce.

See `docker-bake.hcl` to configure the proper registry connection and caching by setting environment variables.

It has been tested, fully reproducible every time with GitLab registry.
To reproduce, run the command below multiple times:
```bash
docker buildx prune -af && docker buildx bake --progress=plain
```

The issue is reproducible when using such configuration:

```bash
$ docker buildx inspect
Name:          buildx
Driver:        docker-container
Last Activity: 2025-05-08 17:24:17 +0000 UTC

Nodes:
Name:                  buildx0
Endpoint:              rootless
Status:                running
BuildKit daemon flags: --allow-insecure-entitlement=network.host
BuildKit version:      v0.20.2
Platforms:             linux/amd64, linux/amd64/v2, linux/amd64/v3, linux/386
Labels:
 org.mobyproject.buildkit.worker.executor:         oci
 org.mobyproject.buildkit.worker.hostname:         54d43fe8486b
 org.mobyproject.buildkit.worker.network:          host
 org.mobyproject.buildkit.worker.oci.process-mode: sandbox
 org.mobyproject.buildkit.worker.selinux.enabled:  false
 org.mobyproject.buildkit.worker.snapshotter:      overlayfs
GC Policy rule#0:
 All:            false
 Filters:        type==source.local,type==exec.cachemount,type==source.git.checkout
 Keep Duration:  48h0m0s
 Max Used Space: 488.3MiB
GC Policy rule#1:
 All:            false
 Keep Duration:  1440h0m0s
 Reserved Space: 9.313GiB
 Max Used Space: 93.13GiB
 Min Free Space: 74.51GiB
GC Policy rule#2:
 All:            false
 Reserved Space: 9.313GiB
 Max Used Space: 93.13GiB
 Min Free Space: 74.51GiB
GC Policy rule#3:
 All:            true
 Reserved Space: 9.313GiB
 Max Used Space: 93.13GiB
 Min Free Space: 74.51GiB

$ docker buildx version
github.com/docker/buildx v0.23.0 28c90ea

$ docker version
Client: Docker Engine - Community
 Version:           28.1.1
 API version:       1.49
 Go version:        go1.23.8
 Git commit:        4eba377
 Built:             Fri Apr 18 09:54:03 2025
 OS/Arch:           linux/amd64
 Context:           rootless

Server: Docker Engine - Community
 Engine:
  Version:          28.1.1
  API version:      1.49 (minimum version 1.24)
  Go version:       go1.23.8
  Git commit:       01f442b
  Built:            Fri Apr 18 09:52:20 2025
  OS/Arch:          linux/amd64
  Experimental:     false
 containerd:
  Version:          1.7.27
  GitCommit:        05044ec0a9a75232cad458027ca83437aae3f4da
 runc:
  Version:          1.2.5
  GitCommit:        v1.2.5-0-g59923ef
 docker-init:
  Version:          0.19.0
  GitCommit:        de40ad0
 rootlesskit:
  Version:          2.3.4
  ApiVersion:       1.1.1
  NetworkDriver:    slirp4netns
  PortDriver:       builtin
  StateDir:         /run/user/1000/dockerd-rootless
 slirp4netns:
  Version:          1.3.1
  GitCommit:        e5e368c4f5db6ae75c2fce786e31eef9da6bf236
```