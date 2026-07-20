FROM magicpak/debian:magicpak1.4.0 AS magicpak-image

FROM nginx:1.31.2-trixie AS nginx-image

RUN --mount=type=cache,target=/var/lib/apt,sharing=locked \
    --mount=type=cache,target=/var/cache/apt,sharing=locked \
    set -eux && \
    apt-get update && \
    apt-get install -y --no-install-recommends gcc libc6-dev

RUN --mount=type=bind,from=magicpak-image,target=/mnt \
    set -eux && \
    /mnt/bin/magicpak -v \
      "$(which nginx)" \
      /lib/*/libzstd.so.1 \
      /asset && \
    mkdir -m 755 /asset/run && \
    mkdir -p /asset/var && \
    ln -sf /run /asset/var/run

# final image

FROM scratch

COPY --from=nginx-image /asset /
COPY --parents --from=nginx-image /etc/ssl /etc/nginx /etc/group /etc/passwd /var/log/nginx /var/cache/nginx /

EXPOSE 80

STOPSIGNAL SIGQUIT

CMD ["/usr/sbin/nginx", "-g", "daemon off;"]
