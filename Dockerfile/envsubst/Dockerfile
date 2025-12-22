FROM magicpak/debian:magicpak1.4.0 AS magicpak-image

FROM alpine:3.23.2 AS build-image

RUN --mount=type=bind,from=magicpak-image,target=/mnt \
    --mount=type=cache,target=/var/cache/apk,sharing=locked \
    set -eux && \
    apk add gcc libc-dev envsubst && \
    /mnt/bin/magicpak -v "$(which envsubst)" /build

# final image

FROM busybox:1.37.0-musl

COPY --from=build-image /build /
