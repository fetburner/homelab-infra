# FFmpeg 入りイメージのビルド例。
# 公式イメージは ffmpeg を含まないため、エンコード／サムネイルの worker で使う
# イメージをこのリポジトリの CI からビルドする。GHCR では private パッケージとして扱う。

ARG BASE=ghcr.io/fetburner/rokuban:latest

FROM ${BASE}
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
