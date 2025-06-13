FROM alpine:3.22.0 AS build-image

RUN --mount=type=cache,target=/var/cache/apk,sharing=locked \
    set -eux && \
    apk add autoconf automake bash clang cmake curl make pkgconfig linux-headers

# recpt1
WORKDIR /tmp/recpt1
SHELL ["/bin/ash", "-eo", "pipefail", "-c"]
RUN curl -fsSL https://github.com/stz2012/recpt1/tarball/master | tar -xz --strip-components=1

WORKDIR /tmp/recpt1/recpt1
RUN ./autogen.sh && \
    ./configure --enable-b25 && \
    make -j"$(nproc)" && \
    make install

WORKDIR /tmp/build
COPY ./script/extractlibrary cp.sh
RUN which recpt1 >> cplist && \
    ./cp.sh cplist /build

# final image
FROM scratch

COPY --from=build-image /build /
