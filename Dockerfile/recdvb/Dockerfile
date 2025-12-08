FROM magicpak/debian:magicpak1.4.0 AS magicpak-image

FROM alpine:3.23.0 AS build-image

RUN --mount=type=cache,target=/var/cache/apk,sharing=locked \
    set -eux && \
    apk add autoconf automake bash clang cmake curl make pkgconfig linux-headers libc-dev

WORKDIR /tmp/recdvb
COPY ./Dockerfile/recdvb/recdvb /tmp/recdvb
RUN --mount=type=bind,from=magicpak-image,target=/mnt \
    ./autogen.sh && \
    ./configure && \
    sed -i -e 's/msgbuf/_msgbuf/' recpt1core.h && \
    sed -i '1i#include <sys/types.h>' tsmain.c && \
    sed -i '1i#include <sys/types.h>' tssplitter_lite.c && \
    make -j"$(nproc)" && \
    make install && \
    /mnt/bin/magicpak -v "$(which recdvb)" /build

# final image
FROM scratch

COPY --from=build-image /build /
