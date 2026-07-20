FROM magicpak/debian:magicpak1.4.0 AS magicpak-image

FROM debian:13.6 AS builder

RUN --mount=type=cache,target=/var/lib/apt,sharing=locked \
    --mount=type=cache,target=/var/cache/apt,sharing=locked \
    apt-get update && \
    apt-get install -y --no-install-recommends autoconf automake cmake clang make

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

COPY --from=builder /build /
