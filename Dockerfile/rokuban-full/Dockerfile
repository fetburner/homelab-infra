# rokuban 側 Dockerfile.full（99c1444 時点）の jls ステージをそのまま持ってきている。
# Dockerfile.full は「セルフビルド例」で ghcr に publish されないため、うちの
# rokuban-full が唯一の ffmpeg 入りイメージになる。上流の差分はここへ手で反映する。
#
# JLSE command-line tools are built without the AviSynth wrapper so workers can
# analyze original MPEG-TS files directly. Versions are pinned to source commits.
# Upstream: tobitti0/dtvindex, chapter_exe, logoframe; yobibi/join_logo_scp v5.1.1.
FROM debian:bookworm-slim AS jls
# curl | tar は pipefail が無いと curl の失敗が tar の失敗に化ける（hadolint DL4006）。
SHELL ["/bin/bash", "-o", "pipefail", "-c"]
RUN --mount=type=cache,target=/var/cache/apt,sharing=locked \
    --mount=type=cache,target=/var/lib/apt,sharing=locked \
    apt-get update && apt-get install -y --no-install-recommends \
      ca-certificates curl build-essential pkg-config \
      libavformat-dev libavcodec-dev libavutil-dev libswscale-dev libswresample-dev
WORKDIR /src
ARG DTVINDEX_SHA=196272d2e1b8d8aa0d960b4245a8f3a419debfae
ARG CHAPTER_EXE_SHA=a32c8f06c3207f8d144b6be37110c63221d7e79a
ARG LOGOFRAME_SHA=8185bafc281e86d847d8084de53c7ae42acfb532
ARG JOIN_LOGO_SCP_VERSION=5.1.1
RUN set -eux; \
    mkdir -p dtvindex chapter_exe logoframe join_logo_scp; \
    curl -fsSL --retry 5 --retry-all-errors "https://github.com/tobitti0/dtvindex/archive/${DTVINDEX_SHA}.tar.gz" | tar -xz --strip-components=1 -C dtvindex; \
    curl -fsSL --retry 5 --retry-all-errors "https://github.com/tobitti0/chapter_exe/archive/${CHAPTER_EXE_SHA}.tar.gz" | tar -xz --strip-components=1 -C chapter_exe; \
    curl -fsSL --retry 5 --retry-all-errors "https://github.com/tobitti0/logoframe/archive/${LOGOFRAME_SHA}.tar.gz" | tar -xz --strip-components=1 -C logoframe; \
    curl -fsSL --retry 5 --retry-all-errors "https://github.com/yobibi/join_logo_scp/archive/refs/tags/v${JOIN_LOGO_SCP_VERSION}.tar.gz" | tar -xz --strip-components=1 -C join_logo_scp; \
    make -C dtvindex build/libdtvindex.a; \
    make -C chapter_exe/src WITH_AVISYNTH=no DTVINDEX_DIR=/src/dtvindex; \
    make -C logoframe/src WITH_AVISYNTH=no DTVINDEX_DIR=/src/dtvindex; \
    make -C join_logo_scp/src; \
    install -d /opt/jls/bin /opt/jls/share/rokuban/cm_detect; \
    install -m 0755 chapter_exe/src/chapter_exe /opt/jls/bin/chapter_exe; \
    install -m 0755 logoframe/src/logoframe /opt/jls/bin/logoframe; \
    install -m 0755 join_logo_scp/src/join_logo_scp /opt/jls/bin/join_logo_scp; \
    install -m 0644 join_logo_scp/JL/JL_標準.txt /opt/jls/share/rokuban/cm_detect/JL_標準.txt; \
    test -s /opt/jls/share/rokuban/cm_detect/JL_標準.txt

FROM ghcr.io/fetburner/rokuban:55e63bcff975db849b2d631d60d6e512a37e7f4d
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
# JLSE ツールは jls ステージで bookworm の libav*-dev にリンクしている。
# ランタイムの libavformat59 等は上の ffmpeg の依存として入る。
# 配置先は config.yml の cm_detect.binary_dir と
# config.CMDetectRulePath（/usr/local/share/rokuban/cm_detect/JL_標準.txt）に一致させる。
COPY --from=jls /opt/jls/bin/ /usr/local/bin/
COPY --from=jls /opt/jls/share/rokuban/cm_detect/ /usr/local/share/rokuban/cm_detect/
USER nobody

ENTRYPOINT ["rokuban"]
