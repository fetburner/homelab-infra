FROM magicpak/debian:magicpak1.4.0 AS magicpak-image

FROM debian:13.5 AS builder

RUN --mount=type=cache,target=/var/lib/apt,sharing=locked \
    --mount=type=cache,target=/var/cache/apt,sharing=locked \
    apt-get update && \
    apt-get install -y --no-install-recommends autoconf automake cmake clang make

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

COPY --from=builder /build /
