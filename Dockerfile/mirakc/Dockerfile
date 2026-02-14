# mirakc-arib, mirakc
FROM mirakc/mirakc:3.4.21-alpine AS mirakc-image

RUN --mount=type=cache,target=/var/cache/apk,sharing=locked \
    set -eux && \
    apk add gcc libc-dev

RUN --mount=type=bind,from=magicpak/debian:magicpak1.4.0,target=/mnt \
    /mnt/bin/magicpak -v "$(which mirakc)" "$(which mirakc-arib)" /build

# arib-b25-stream-test
COPY --from=ghcr.io/fetburner/arib-b25-stream-test:sha-085c401f12ee501e47ee7243881776154194c227 / /build

# recpt1
COPY --from=ghcr.io/fetburner/recpt1:sha-a4964ca1b5d6e3fa5a2e70e525126d39fc95a09f / /build

# recdvb
COPY --from=ghcr.io/fetburner/recdvb:sha-e3c7ab81b507ce31fa3c6845e72207653374e4c5 / /build

# final image

FROM busybox:1.37.0-musl

COPY --from=mirakc-image /build /
COPY --parents --from=mirakc-image /etc/mirakc /

ENV MIRAKC_CONFIG=/etc/mirakc/config.yml

ENTRYPOINT ["/usr/local/bin/mirakc"]
CMD []
