FROM magicpak/debian:magicpak1.4.0 AS magicpak-image

FROM alpine:3.22.1 AS build-image

RUN --mount=type=cache,target=/var/cache/apk,sharing=locked \
    set -eux && \
    apk add autoconf automake bash clang cmake curl make pkgconfig linux-headers libc-dev

# recpt1
WORKDIR /tmp/recpt1
COPY ./Dockerfile/recpt1/recpt1 /tmp/recpt1

WORKDIR /tmp/recpt1/recpt1
RUN --mount=type=bind,from=magicpak-image,target=/mnt \
    ./autogen.sh && \
    ./configure && \
    make -j"$(nproc)" && \
    make install && \
    /mnt/bin/magicpak -v "$(which recpt1)" /build

# final image
FROM scratch

COPY --from=build-image /build /
