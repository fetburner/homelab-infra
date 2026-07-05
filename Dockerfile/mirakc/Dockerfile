# mirakc-arib, mirakc
FROM mirakc/mirakc:3.4.21-debian AS mirakc-image

RUN --mount=type=cache,target=/var/lib/apt,sharing=locked \
    --mount=type=cache,target=/var/cache/apt,sharing=locked \
    apt-get update && \
    apt-get install -y --no-install-recommends dash clang

RUN --mount=type=bind,from=magicpak/debian:magicpak1.4.0,target=/mnt \
    /mnt/bin/magicpak -v /bin/sh "$(which timeout)" "$(which mirakc)" "$(which mirakc-arib)" /build

FROM scratch AS builder

COPY --from=mirakc-image /build /
COPY --parents --from=mirakc-image /etc/mirakc /

# arib-b25-stream-test
COPY --from=ghcr.io/fetburner/arib-b25-stream-test:sha-3cb032d81f43ca27ea5b2e4b0fae83e36b819a14 / /

# recpt1
COPY --from=ghcr.io/fetburner/recpt1:sha-941af914965e01873bb28d94d007c873ee1bc147 / /

# recdvb
COPY --from=ghcr.io/fetburner/recdvb:sha-3e9860bef025704e621e6a6436b56b6a9fbeec6a / /

# final image

FROM scratch

COPY --from=builder / /

ENV MIRAKC_CONFIG=/etc/mirakc/config.yml
ENV LD_LIBRARY_PATH=/usr/local/lib

ENTRYPOINT ["/usr/local/bin/mirakc"]
CMD []
