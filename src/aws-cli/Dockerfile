FROM base
SHELL ["/bin/bash", "-euo", "pipefail", "-O", "globstar", "-c"]

ARG TARGETOS TARGETARCH
RUN --mount=type=cache,sharing=private,target=/var/cache/yum,id="cache:example:${TARGETOS}:${TARGETARCH}" \
    --mount=type=bind,from=pkg-cache,source="${TARGETOS}_${TARGETARCH}",rw=true,target=/var/cache/yum/metadata \
    --mount=type=tmpfs,target=/var/lib/dnf \
<<~~~
touch /var/cache/yum/**
microdnf install -y \
    awscli2
~~~
