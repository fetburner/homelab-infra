# node.js
FROM node:18-alpine3.21 AS node-image

RUN --mount=type=cache,target=/var/cache/apk,sharing=locked \
    set -eux && \
    apk add bash

WORKDIR /tmp
COPY ./script/extractlibrary cp.sh
RUN which node >> cplist && \
    ./cp.sh cplist /build

# FFmpeg
FROM ghcr.io/fetburner/ffmpeg:latest AS ffmpeg-image

# EPGStation client build
FROM node:18-alpine3.21 AS epgstation-client-image

RUN --mount=type=cache,target=/var/cache/apk,sharing=locked \
    set -eux && \
    apk add curl

WORKDIR /app
RUN --mount=type=cache,target=~/.npm,sharing=locked \
    --mount=type=cache,target=/app/client/node_modules,sharing=locked \
    curl -fsSL https://github.com/l3tnun/EPGStation/tarball/v2.10.0 | tar -xz --strip-components=1 && \
    cd /app/client && \
    npm config set fetch-retries 10 && \
    npm config set fetch-retry-mintimeout 100000 && \
    npm config set fetch-retry-maxtimeout 600000 && \
    npm install --no-save --loglevel=info && \
    npm run build --loglevel=info

WORKDIR /build
RUN cp --archive --parents --no-dereference /app/client /build

# EPGStation server build
FROM node:18-alpine3.21 AS epgstation-server-image

RUN --mount=type=cache,target=/var/cache/apk,sharing=locked \
    set -eux && \
    apk add curl g++ make pkgconf python3 py3-pip

ENV DOCKER="YES"

WORKDIR /app
RUN --mount=type=tmpfs,target=/app/client \
    --mount=type=cache,target=~/.npm,sharing=locked \
    curl -fsSL https://github.com/l3tnun/EPGStation/tarball/v2.10.0 | tar -xz --strip-components=1 && \
    npm config set fetch-retries 10 && \
    npm config set fetch-retry-mintimeout 100000 && \
    npm config set fetch-retry-maxtimeout 600000 && \
    npm install --no-save --loglevel=info && \
    npm run build-server --loglevel=info && \
    npm prune --omit=dev

WORKDIR /build
RUN cp --archive --parents --no-dereference /app /build

# final image
FROM busybox:1.37.0-musl

COPY --from=node-image /build /

COPY --from=ffmpeg-image / /

COPY --from=epgstation-client-image /build /

COPY --from=epgstation-server-image /build /

WORKDIR /app
ENTRYPOINT ["node"]
CMD ["/app/dist/index.js"]
