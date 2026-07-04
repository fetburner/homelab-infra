FROM debian:13.5 AS builder

RUN --mount=type=cache,target=/var/lib/apt,sharing=locked \
    --mount=type=cache,target=/var/cache/apt,sharing=locked \
    apt-get update && \
    apt-get install -y --no-install-recommends gettext-base

# final image

FROM busybox:1.38.0-glibc

COPY --parents --from=builder /usr/bin/envsubst /
