# node.js
FROM node:18-alpine3.21 AS node-deps

RUN --mount=type=cache,id=apk,target=/var/cache/apk,sharing=locked \
    set -eux && \
    apk --update-cache add gcc libc-dev ca-certificates tini

RUN --mount=type=bind,from=magicpak/debian:magicpak1.4.0,source=/bin,target=/bin/magicpak \
    /bin/magicpak/magicpak -v "$(which node)" "$(which tini)" /build --include '/usr/lib/libssl*' --include '/usr/lib/libcrypto*'

# EPGStation client build
FROM --platform=$BUILDPLATFORM node:18-alpine3.21 AS client-builder

WORKDIR /app/client

COPY ./Dockerfile/epgstation/epgstation/client/package*.json .

RUN --mount=type=cache,id=client,target=~/.npm,sharing=locked \
    --mount=type=cache,id=client,target=./node_modules,sharing=locked \
    npm config set fetch-retries 10 && \
    npm config set fetch-retry-mintimeout 100000 && \
    npm config set fetch-retry-maxtimeout 600000 && \
    npm install --no-save --loglevel=info

COPY ./Dockerfile/epgstation/epgstation /app

RUN --mount=type=cache,id=client,target=~/.npm,sharing=locked \
    --mount=type=cache,id=client,target=./node_modules,sharing=locked \
    npm run build --loglevel=info

# EPGStation server build
FROM node:18-alpine3.21 AS server-base

WORKDIR /app

RUN --mount=type=cache,id=apk,target=/var/cache/apk,sharing=locked \
    set -eux && \
    apk add g++ make pkgconf python3 py3-pip

FROM --platform=$BUILDPLATFORM server-base AS server-builder

ENV DOCKER="YES"

COPY ./Dockerfile/epgstation/epgstation/package*.json .

RUN --mount=type=cache,id=server,target=~/.npm,sharing=locked \
    --mount=type=cache,id=server,target=./node_modules,sharing=locked \
    npm config set fetch-retries 10 && \
    npm config set fetch-retry-mintimeout 100000 && \
    npm config set fetch-retry-maxtimeout 600000 && \
    npm install --no-save --loglevel=info

COPY --exclude=./Dockerfile/epgstation/epgstation/client ./Dockerfile/epgstation/epgstation /app

RUN --mount=type=cache,id=server,target=~/.npm,sharing=locked \
    --mount=type=cache,id=server,target=./node_modules,sharing=locked \
    npm run build-server --loglevel=info

FROM server-base AS server-prod-deps

COPY ./Dockerfile/epgstation/epgstation/package*.json .

RUN --mount=type=cache,id=server,target=~/.npm,sharing=locked \
    --mount=type=cache,id=server,target=./node_modules/.cache,sharing=locked \
    npm config set fetch-retries 10 && \
    npm config set fetch-retry-mintimeout 100000 && \
    npm config set fetch-retry-maxtimeout 600000 && \
    npm install --omit=dev --no-save --loglevel=info

# final image
FROM busybox:1.37.0-musl

COPY --from=ghcr.io/fetburner/ffmpeg:sha-ee1ad2a38d51d7f9b076fed5a7f626e662c27ee2 / /

COPY --from=node-deps /build /

COPY --parents --from=node-deps /etc/ssl /

COPY --parents --from=server-prod-deps /app/node_modules /

COPY --parents --from=client-builder /app/client /

COPY --parents --from=server-builder --exclude=/app/node_modules /app /

WORKDIR /app
ENTRYPOINT ["/sbin/tini", "--"]
CMD ["node", "/app/dist/index.js"]
