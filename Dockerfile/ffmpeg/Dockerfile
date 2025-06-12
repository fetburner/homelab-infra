# FFmpeg build
FROM alpine:3.22.0 AS ffmpeg-image

ARG TARGETPLATFORM

ENV FFMPEG_VERSION=6.1.2

RUN --mount=type=cache,target=/var/cache/apk,sharing=locked \
    set -eux && \
    apk add autoconf automake bash binutils bzip2 cmake curl coreutils diffutils file g++ gcc gperf libtool \
      make python3 openssl-dev tar yasm nasm zlib-dev expat-dev pkgconfig libass-dev lame-dev opus-dev \
      libtheora-dev libvorbis-dev libvpx-dev x264-dev x265-dev libva-dev libgcc libstdc++ ca-certificates \
      libgomp expat git lame-libs libass libvpx opus libtheora libvorbis x264-libs x265-libs && \
    case ${TARGETPLATFORM} in \
      linux/amd64) apk add libva libvdpau-dev libva-intel-driver intel-media-driver intel-media-sdk-dev;; \
    esac

# aribb24
WORKDIR /tmp/aribb24
COPY ./Dockerfile/ffmpeg/aribb24 /tmp/aribb24
RUN autoreconf -fiv && \
    ./configure && \
    make -j"$(nproc)" && \
    make install

#ffmpeg build
WORKDIR /tmp/ffmpeg
SHELL ["/bin/ash", "-eo", "pipefail", "-c"]
RUN curl -fsSL http://ffmpeg.org/releases/ffmpeg-${FFMPEG_VERSION}.tar.bz2 | tar -xj --strip-components=1 && \
    case ${TARGETPLATFORM} in \
      linux/amd64) \
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
          --disable-doc;; \
      *) \
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
          --enable-nonfree \
          --disable-debug \
          --disable-doc;; \
    esac && \
    make -j"$(nproc)" && \
    make install

WORKDIR /tmp/build
COPY ./script/extractlibrary cp.sh
RUN which ffmpeg >> cplist && \
    which ffprobe >> cplist && \
    case ${TARGETPLATFORM} in \
      linux/amd64 ) \
        # Add intel-media-driver manually
        echo /usr/lib/libigfxcmrt.so.7 >> cplist && \
        echo /usr/lib/dri/iHD_drv_video.so >> cplist && \
        # Add libva-intel-driver manually
        echo /usr/lib/dri/i965_drv_video.so >> cplist;; \
    esac && \
    ./cp.sh cplist /build

# final image
FROM scratch

COPY --from=ffmpeg-image /build /
