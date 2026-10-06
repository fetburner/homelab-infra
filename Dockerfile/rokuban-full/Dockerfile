# rokuban 側 Dockerfile.full の推奨構成を homelab 向けに反映する。
# Dockerfile.full は「セルフビルド例」で ghcr に publish されないため、ここでは
# upstream の Trixie / FFmpeg 7.1 系 / JLSE runtime library を使い、Intel GPU driver
# と QSV runtime を追加した rokuban-full を作る。上流の変更はここへ手で反映する。
#
# JLSE command-line tools are built without the AviSynth wrapper so workers can
# analyze original MPEG-TS files directly. Versions are pinned to source commits.
# Upstream: tobitti0/dtvindex, chapter_exe, logoframe; yobibi/join_logo_scp v5.1.1.
# FFmpeg 7.1 以降は VA-API のカット処理で推奨される。Trixie の ffmpeg は 7.1.5。
# JLSE を Trixie の libav* にリンクし、runtime 側も同じ soname のライブラリを入れる。
ARG BASE=ghcr.io/fetburner/rokuban:3a2a55b77478cda9079cfda7d8eea37af3780542
FROM debian:trixie-slim AS jls
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
          libavformat61 libavcodec61 libavutil59 libswscale8 libswresample5 \
          i965-va-driver \
          intel-media-va-driver-non-free \
          libmfx-gen1.2 ;; \
      *) \
        apt-get update && \
        apt-get install -y --no-install-recommends \
          ffmpeg \
          libavformat61 libavcodec61 libavutil59 libswscale8 libswresample5 ;; \
    esac
# JLSE ツールは jls ステージで trixie の libav*-dev にリンクしている。
# 対応する runtime libav* は ffmpeg とは別に明示しているため、ffmpeg を差し替えても JLS は動く。
# 配置先は config.yml の cm_detect.binary_dir と
# config.CMDetectRulePath（/usr/local/share/rokuban/cm_detect/JL_標準.txt）に一致させる。
COPY --from=jls /opt/jls/bin/ /usr/local/bin/
COPY --from=jls /opt/jls/share/rokuban/cm_detect/ /usr/local/share/rokuban/cm_detect/
USER nobody

ENTRYPOINT ["rokuban"]
