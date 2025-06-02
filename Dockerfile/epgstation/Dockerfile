# node.js
FROM node:18-alpine3.21 AS node-image

RUN --mount=type=cache,target=/var/cache/apk,sharing=locked \
    set -eux && \
    apk add bash

WORKDIR /tmp
COPY ./script/extractlibrary cp.sh
RUN which node >> cplist && \
    ./cp.sh cplist /build

# FFmpeg build
FROM alpine:3.21.3 AS ffmpeg-image

ENV FFMPEG_VERSION=6.1.2

RUN --mount=type=cache,target=/var/cache/apk,sharing=locked \
    set -eux && \
    apk add autoconf automake bash binutils bzip2 cmake curl coreutils diffutils file g++ gcc gperf libtool \
      make python3 openssl-dev tar yasm nasm zlib-dev expat-dev pkgconfig libass-dev lame-dev opus-dev \
      libtheora-dev libvorbis-dev libvpx-dev x264-dev x265-dev libva-dev libgcc libstdc++ ca-certificates \
      libgomp expat git lame-libs libass libvpx opus libtheora libvorbis x264-libs x265-libs libva libva-intel-driver \
      intel-media-driver libvdpau-dev intel-media-sdk-dev

# aribb24
WORKDIR /tmp/aribb24
RUN curl -fsSL https://github.com/nkoriyama/aribb24/tarball/master | tar -xz --strip-components=1 && \
    autoreconf -fiv && \
    ./configure && \
    make -j$(nproc) && \
    make install

#ffmpeg build
WORKDIR /tmp/ffmpeg
RUN curl -fsSL http://ffmpeg.org/releases/ffmpeg-${FFMPEG_VERSION}.tar.bz2 | tar -xj --strip-components=1 && \
    ./configure \
      --extra-cflags="-Wno-error=incompatible-pointer-types" \
      --prefix=/usr/local \
      --disable-shared \
      --enable-gpl \
      --enable-libass \
      --enable-libfreetype \
      --enable-libmp3lame \
      --enable-libopus \
      --enable-libtheora \
      --enable-libvorbis \
      --enable-libvpx \
      --enable-libx264 \
      --enable-libx265 \
      --enable-version3 \
      --enable-libaribb24 \
      --enable-vaapi \
      --enable-libmfx \
      --enable-nonfree \
      --disable-debug \
      --disable-doc \
    && \
    make -j$(nproc) && \
    make install

WORKDIR /tmp/build
COPY ./script/extractlibrary cp.sh
RUN which ffmpeg >> cplist && \
    which ffprobe >> cplist && \
    # Add intel-media-driver manually
    echo /usr/lib/libigfxcmrt.so.7 >> cplist && \
    echo /usr/lib/dri/iHD_drv_video.so >> cplist && \
    # Add libva-intel-driver manually
    echo /usr/lib/dri/i965_drv_video.so >> cplist && \
    ./cp.sh cplist /build

# EPGStation client build
FROM node:18-alpine3.21 AS epgstation-client-image

RUN --mount=type=cache,target=/var/cache/apk,sharing=locked \
    set -eux && \
    apk add curl

WORKDIR /app
RUN --mount=type=cache,target=~/.npm,sharing=locked \
    --mount=type=cache,target=/app/client/node_modules,sharing=locked \
    curl -fsSL https://github.com/l3tnun/EPGStation/tarball/v2.10.0 | tar -xz --strip-components=1 && \
    cd /app/client && \
    npm config set fetch-retries 10 && \
    npm config set fetch-retry-mintimeout 100000 && \
    npm config set fetch-retry-maxtimeout 600000 && \
    npm install --no-save --loglevel=info && \
    npm run build --loglevel=info

WORKDIR /build
RUN cp --archive --parents --no-dereference /app/client /build

# EPGStation server build
FROM node:18-alpine3.21 AS epgstation-server-image

RUN --mount=type=cache,target=/var/cache/apk,sharing=locked \
    set -eux && \
    apk add curl g++ make pkgconf python3 py3-pip

ENV DOCKER="YES"

WORKDIR /app
RUN --mount=type=tmpfs,target=/app/client \
    --mount=type=cache,target=~/.npm,sharing=locked \
    curl -fsSL https://github.com/l3tnun/EPGStation/tarball/v2.10.0 | tar -xz --strip-components=1 && \
    npm config set fetch-retries 10 && \
    npm config set fetch-retry-mintimeout 100000 && \
    npm config set fetch-retry-maxtimeout 600000 && \
    npm install --no-save --loglevel=info && \
    npm run build-server --loglevel=info && \
    npm prune --omit=dev

WORKDIR /build
RUN cp --archive --parents --no-dereference /app /build

# final image
FROM busybox:1.37.0-musl

COPY --from=node-image /build /

COPY --from=ffmpeg-image /build /

COPY --from=epgstation-client-image /build /

COPY --from=epgstation-server-image /build /

WORKDIR /app
ENTRYPOINT ["node"]
CMD ["/app/dist/index.js"]
