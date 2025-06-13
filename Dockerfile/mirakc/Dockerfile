FROM magicpak/debian:magicpak1.4.0 AS magicpak-image

# mirakc-arib, mirakc
FROM mirakc/mirakc:3.4.20-alpine AS mirakc-image

RUN --mount=type=bind,from=magicpak-image,target=/mnt \
    --mount=type=cache,target=/var/cache/apk,sharing=locked \
    set -eux && \
    apk add gcc libc-dev && \
    /mnt/bin/magicpak -v "$(which mirakc)" "$(which mirakc-arib)" /build

WORKDIR /build
RUN cp --archive --parents --no-dereference /etc/mirakc /build

# recpt1
# hadolint ignore=DL3007
FROM ghcr.io/fetburner/recpt1:latest AS recpt1-image

# recdvb
# hadolint ignore=DL3007
FROM ghcr.io/fetburner/recdvb:latest AS recdvb-image

# arib-b25-stream-test
# hadolint ignore=DL3007
FROM ghcr.io/fetburner/arib-b25-stream-test:latest AS arib-b25-stream-test-image

# final image

FROM busybox:1.37.0-musl

COPY --from=arib-b25-stream-test-image / /

COPY --from=recpt1-image / /

COPY --from=recdvb-image / /

COPY --from=mirakc-image /build /

ENV MIRAKC_CONFIG=/etc/mirakc/config.yml

ENTRYPOINT ["/usr/local/bin/mirakc"]
CMD []
