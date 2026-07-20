# additional pcsc tool
FROM ghcr.io/fetburner/pcsc-tool-build:sha-7bfbb376e6f3994b7246fd99e630c51b8a4c957b AS pcsc-tool-image

FROM debian:13.6 AS builder

RUN --mount=type=cache,target=/var/lib/apt,sharing=locked \
    --mount=type=cache,target=/var/cache/apt,sharing=locked \
    apt-get update && \
    apt-get install -y --no-install-recommends clang cmake make pkg-config libpcsclite-dev

# additional pcsc tool
COPY --from=pcsc-tool-image / /

# libaribb25
WORKDIR /tmp/libaribb25
COPY ./Dockerfile/arib-b25-stream-test/libaribb25 /tmp/libaribb25
RUN cmake -B build

WORKDIR /tmp/libaribb25/build
RUN make -j"$(nproc)" && \
    make install

RUN --mount=type=bind,from=magicpak/debian:magicpak1.4.0,target=/mnt \
    /mnt/bin/magicpak -v "$(which arib-b25-stream-test)" /build

# final image
FROM scratch

COPY --from=builder /build /
