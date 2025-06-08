FROM nginx:1.28.0-alpine AS nginx-image

RUN --mount=type=cache,target=/var/cache/apk,sharing=locked \
    set -eux && \
    apk add bash

WORKDIR /tmp/build
COPY ./script/extractlibrary cp.sh
RUN which nginx >> cplist && \
    which envsubst >> cplist && \
    ./cp.sh cplist /asset

# final image

FROM busybox:1.37.0-musl

COPY --from=nginx-image /asset /
COPY --from=nginx-image /etc/ssl /etc/ssl
COPY --from=nginx-image /etc/nginx /etc/nginx
COPY --from=nginx-image /etc/group /etc/group
COPY --from=nginx-image /etc/passwd /etc/passwd
COPY --from=nginx-image /var/log/nginx /var/log/nginx
COPY --from=nginx-image /var/cache/nginx /var/cache/nginx
COPY --from=nginx-image /docker-entrypoint.d /docker-entrypoint.d
COPY --from=nginx-image /docker-entrypoint.sh /docker-entrypoint.sh

RUN mkdir -m 755 /run && \
    ln -sf /run /var/run && \
    ln -sf /dev/stderr /var/log/nginx/error.log && \
    ln -sf /dev/stdout /var/log/nginx/access.log

ENTRYPOINT ["/docker-entrypoint.sh"]

EXPOSE 80

STOPSIGNAL SIGQUIT

CMD ["nginx", "-g", "daemon off;"]
