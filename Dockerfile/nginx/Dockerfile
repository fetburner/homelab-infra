FROM magicpak/debian:magicpak1.4.0 AS magicpak-image

FROM nginx:1.28.0-alpine-slim AS nginx-image

RUN --mount=type=bind,from=magicpak-image,target=/mnt \
    --mount=type=cache,target=/var/cache/apk,sharing=locked \
    set -eux && \
    apk add gcc libc-dev openssl-dev pcre2-dev zlib-dev linux-headers && \
    /mnt/bin/magicpak -v "$(which nginx)" /asset

# final image

FROM scratch

COPY --from=nginx-image /asset /
COPY --from=nginx-image /etc/ssl /etc/ssl
COPY --from=nginx-image /etc/nginx /etc/nginx
COPY --from=nginx-image /etc/group /etc/group
COPY --from=nginx-image /etc/passwd /etc/passwd
COPY --from=nginx-image /var/log/nginx /var/log/nginx
COPY --from=nginx-image /var/cache/nginx /var/cache/nginx

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
