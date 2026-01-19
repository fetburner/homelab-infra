FROM magicpak/debian:magicpak1.4.0 AS magicpak-image

# recpt1
FROM ghcr.io/fetburner/recpt1:sha-a4964ca1b5d6e3fa5a2e70e525126d39fc95a09f AS recpt1-image

# recdvb
FROM ghcr.io/fetburner/recdvb:sha-e3c7ab81b507ce31fa3c6845e72207653374e4c5 AS recdvb-image

# arib-b25-stream-test
FROM ghcr.io/fetburner/arib-b25-stream-test:sha-085c401f12ee501e47ee7243881776154194c227 AS arib-b25-stream-test-image

# mirakc-arib, mirakc
FROM mirakc/mirakc:3.4.52-alpine AS mirakc-image

RUN --mount=type=bind,from=magicpak-image,target=/mnt \
    --mount=type=cache,target=/var/cache/apk,sharing=locked \
    set -eux && \
    apk add gcc libc-dev && \
    /mnt/bin/magicpak -v "$(which mirakc)" "$(which mirakc-arib)" /build

WORKDIR /build
RUN cp --archive --parents --no-dereference /etc/mirakc /build

COPY --from=arib-b25-stream-test-image / /build

COPY --from=recpt1-image / /build

COPY --from=recdvb-image / /build

# final image

FROM busybox:1.37.0-musl

COPY --from=mirakc-image /build /

ENV MIRAKC_CONFIG=/etc/mirakc/config.yml

ENTRYPOINT ["/usr/local/bin/mirakc"]
CMD []
