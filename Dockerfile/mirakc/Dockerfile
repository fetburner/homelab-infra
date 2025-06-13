# arib-b25-stream-test
# hadolint ignore=DL3007
FROM ghcr.io/fetburner/arib-b25-stream-test:latest AS arib-b25-stream-test

# mirakc-arib, mirakc
FROM mirakc/mirakc:3.4.20-alpine AS mirakc-image

RUN --mount=type=cache,target=/var/cache/apk,sharing=locked \
    apk add bash

WORKDIR /tmp/build
COPY ./script/extractlibrary cp.sh
RUN which mirakc-arib >> cplist && \
    which mirakc >> cplist && \
    which recpt1 >> cplist && \
    which recdvb >> cplist && \
    ./cp.sh cplist /build

WORKDIR /build
RUN cp --archive --parents --no-dereference /etc/mirakc /build && \
    cp --archive --parents --no-dereference /usr/local/bin/recdvb.conf /build

# final image

FROM busybox:1.37.0-musl

COPY --from=mirakc-image /build /

COPY --from=arib-b25-stream-test / /

ENV MIRAKC_CONFIG=/etc/mirakc/config.yml

ENTRYPOINT ["/usr/local/bin/mirakc"]
CMD []
