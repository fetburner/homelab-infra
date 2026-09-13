FROM ghcr.io/fetburner/rokuban:6a697e0d8e88801882c94eea4c44e0b86df11e4a
USER root
ARG TARGETARCH
# EPGStation と同じ Intel GPU を使えるよう、amd64 には VA-API（i965 / iHD）と
# QSV（libmfx）のランタイムを含める。GPU デバイスは Kubernetes 側から /dev/dri を渡す。
RUN --mount=type=cache,target=/var/cache/apt,sharing=locked \
    --mount=type=cache,target=/var/lib/apt,sharing=locked \
    set -eux; \
    case "${TARGETARCH}" in \
      amd64) \
        sed -i 's/Components: main/Components: main non-free non-free-firmware/' \
          /etc/apt/sources.list.d/debian.sources; \
        apt-get update && \
        apt-get install -y --no-install-recommends \
          ffmpeg \
          i965-va-driver \
          intel-media-va-driver-non-free \
          libmfx-gen1.2 ;; \
      *) \
        apt-get update && \
        apt-get install -y --no-install-recommends ffmpeg ;; \
    esac
USER nobody

ENTRYPOINT ["rokuban"]
