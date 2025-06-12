# additional pcsc tool
# hadolint ignore=DL3007
FROM ghcr.io/fetburner/pcsc-tool-build:latest AS pcsc-tool-image

FROM alpine:3.22.0 AS build-image

RUN --mount=type=cache,target=/var/cache/apk,sharing=locked \
    set -eux && \
    apk add autoconf automake bash clang cmake curl make pkgconfig linux-headers

# additional pcsc tool
COPY --from=pcsc-tool-image / /

# libaribb25
WORKDIR /tmp/libaribb25
SHELL ["/bin/ash", "-eo", "pipefail", "-c"]
RUN curl -fsSL https://github.com/tsukumijima/libaribb25/tarball/master | tar -xz --strip-components=1 && \
    cmake -B build

WORKDIR /tmp/libaribb25/build
RUN make -j"$(nproc)" && \
    make install

WORKDIR /tmp/build
COPY ./script/extractlibrary cp.sh
RUN which arib-b25-stream-test >> cplist && \
    ./cp.sh cplist /build

# final image
FROM scratch

COPY --from=build-image /build /
