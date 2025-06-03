# additional pcsc tool
FROM ghcr.io/fetburner/pcsc-tool-build:latest AS pcsc-tool-image

# recpt1, recdvb
FROM alpine:3.21.3 AS build-image

RUN --mount=type=cache,target=/var/cache/apk,sharing=locked \
    set -eux && \
    apk add autoconf automake bash clang cmake curl make pkgconfig linux-headers

# additional pcsc tool
COPY --from=pcsc-tool-image / /

# libaribb25
WORKDIR /tmp/libaribb25
RUN curl -fsSL https://github.com/tsukumijima/libaribb25/tarball/master | tar -xz --strip-components=1 && \
    cmake -B build && \
    cd build && \
    make -j$(nproc) && \
    make install

# recpt1
WORKDIR /tmp/recpt1
RUN curl -fsSL https://github.com/stz2012/recpt1/tarball/master | tar -xz --strip-components=1 && \
    cd recpt1 && \
    ./autogen.sh && \
    ./configure --enable-b25 && \
    make -j$(nproc) && \
    make install

# recdvb
WORKDIR /tmp/recdvb
RUN curl -fsSL https://github.com/kaikoma-soft/recdvb/tarball/master | tar -xz --strip-components=1 && \
    ./autogen.sh && \
    ./configure --enable-b25 && \
    sed -i -e 's/msgbuf/_msgbuf/' recpt1core.h && \
    sed -i '1i#include <sys/types.h>' tsmain.c && \
    sed -i '1i#include <sys/types.h>' tssplitter_lite.c && \
    make -j$(nproc) && \
    make install

WORKDIR /tmp/build
COPY ./script/extractlibrary cp.sh
RUN which recpt1 >> cplist && \
    which recdvb >> cplist && \
    ./cp.sh cplist /build

# mirakc-arib, mirakc
FROM mirakc/mirakc:3.4.17-alpine AS mirakc-image

RUN --mount=type=cache,target=/var/cache/apk,sharing=locked \
    apk add bash

WORKDIR /tmp/build
COPY ./script/extractlibrary cp.sh
RUN which mirakc-arib >> cplist && \
    which mirakc >> cplist && \
    ./cp.sh cplist /build

WORKDIR /build
RUN cp --archive --parents --no-dereference /etc/mirakc /build

# final image

FROM busybox:1.37.0-musl

COPY --from=build-image /build /

COPY --from=mirakc-image /build /

ENV MIRAKC_CONFIG=/etc/mirakc/config.yml

ENTRYPOINT ["/usr/local/bin/mirakc"]
CMD []
