FROM alpine:3.21.3 AS build-image

RUN --mount=type=cache,target=/var/cache/apk,sharing=locked \
    set -eux && \
    apk add bash envsubst


WORKDIR /tmp/build
COPY ./script/extractlibrary cp.sh
RUN which envsubst >> cplist && \
    ./cp.sh cplist /build

# final image

FROM busybox:1.37.0-musl

COPY --from=build-image /build /
