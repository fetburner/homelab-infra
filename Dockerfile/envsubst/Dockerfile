FROM alpine:3.23.3 AS build-image

RUN --mount=type=cache,target=/var/cache/apk,sharing=locked \
    set -eux && \
    apk add gcc libc-dev envsubst

RUN --mount=type=bind,from=magicpak/debian:magicpak1.4.0,target=/mnt \
    /mnt/bin/magicpak -v "$(which envsubst)" /build

# final image

FROM busybox:1.37.0-musl

COPY --from=build-image /build /
