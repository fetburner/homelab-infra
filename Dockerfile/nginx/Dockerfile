FROM magicpak/debian:magicpak1.4.0 AS magicpak-image

FROM nginx:1.29.4-alpine-slim AS nginx-image

RUN --mount=type=cache,target=/var/cache/apk,sharing=locked \
    set -eux && \
    apk add gcc libc-dev

RUN --mount=type=bind,from=magicpak-image,target=/mnt \
    /mnt/bin/magicpak -v "$(which nginx)" /asset

# final image

FROM scratch

COPY --from=nginx-image /asset /
COPY --parents --from=nginx-image /etc/ssl /etc/nginx /etc/group /etc/passwd /var/log/nginx /var/cache/nginx /

RUN --mount=type=bind,from=nginx-image,target=/mnt ["/mnt/bin/busybox", "mkdir", "-m", "755", "/run"]
# hadolint ignore=DL3059
RUN --mount=type=bind,from=nginx-image,target=/mnt ["/mnt/bin/busybox", "ln", "-sf", "/run", "/var/run"]
# hadolint ignore=DL3059
RUN --mount=type=bind,from=nginx-image,target=/mnt ["/mnt/bin/busybox", "ln", "-sf", "/dev/stderr", "/var/log/nginx/error.log"]
# hadolint ignore=DL3059
RUN --mount=type=bind,from=nginx-image,target=/mnt ["/mnt/bin/busybox", "ln", "-sf", "/dev/stdout", "/var/log/nginx/access.log"]
# hadolint ignore=DL3059

EXPOSE 80

STOPSIGNAL SIGQUIT

CMD ["/usr/sbin/nginx", "-g", "daemon off;"]
