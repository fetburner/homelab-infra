# FFmpeg build
FROM debian:13.5 AS builder

ARG TARGETPLATFORM

RUN case ${TARGETPLATFORM} in \
      linux/amd64) sed -i "s/Components: main/Components: main non-free non-free-firmware/" /etc/apt/sources.list.d/debian.sources;; \
    esac

RUN --mount=type=cache,target=/var/lib/apt,sharing=locked \
    --mount=type=cache,target=/var/cache/apt,sharing=locked \
    apt-get update && \
    apt-get install -y --no-install-recommends \
      build-essential autoconf automake libtool nasm yasm pkg-config \
      libssl-dev zlib1g-dev libexpat1-dev libass-dev libfreetype-dev \
      libmp3lame-dev libopus-dev libtheora-dev libvorbis-dev libvpx-dev \
      libx264-dev libx265-dev && \
    case ${TARGETPLATFORM} in \
      linux/amd64) apt-get install -y --no-install-recommends \
        libva-dev libvdpau-dev libvpl-dev \
        i965-va-driver intel-media-va-driver-non-free libmfx-gen1.2;; \
    esac

# aribb24
WORKDIR /tmp/aribb24
COPY ./Dockerfile/ffmpeg/aribb24 /tmp/aribb24
RUN autoreconf -fiv && \
    ./configure && \
    make -j"$(nproc)" && \
    make install && \
    ldconfig

# ffmpeg build
WORKDIR /tmp/ffmpeg
COPY ./Dockerfile/ffmpeg/ffmpeg /tmp/ffmpeg
RUN case ${TARGETPLATFORM} in \
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
          --enable-libvpl \
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

# hadolint ignore=SC2086
RUN --mount=type=bind,from=magicpak/debian:magicpak1.4.0,target=/mnt \
    set -eux && \
    case ${TARGETPLATFORM} in \
      linux/amd64) \
        extra_inputs="/usr/lib/x86_64-linux-gnu/dri/iHD_drv_video.so \
          /usr/lib/x86_64-linux-gnu/dri/i965_drv_video.so \
          /usr/lib/x86_64-linux-gnu/libmfx-gen.so.1.2" ;; \
      *) extra_inputs="" ;; \
    esac && \
    /mnt/bin/magicpak -v \
      "$(which ffmpeg)" \
      "$(which ffprobe)" \
      $extra_inputs \
      /build

# final image
FROM scratch

COPY --from=builder /build /

ENV LD_LIBRARY_PATH=/usr/local/lib
