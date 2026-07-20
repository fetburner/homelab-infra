# node.js
FROM node:18-bookworm-slim AS node-deps

RUN --mount=type=cache,target=/var/lib/apt,sharing=locked \
    --mount=type=cache,target=/var/cache/apt,sharing=locked \
    apt-get update && \
    apt-get install -y --no-install-recommends dash clang tini ca-certificates

RUN --mount=type=bind,from=magicpak/debian:magicpak1.4.0,target=/mnt \
    /mnt/bin/magicpak -v /bin/sh "$(which node)" "$(which tini)" /build

# EPGStation client build
FROM --platform=$BUILDPLATFORM node:18-bookworm-slim AS client-builder

WORKDIR /app/client

COPY ./Dockerfile/epgstation/epgstation/client/package*.json .

RUN --mount=type=cache,id=client,target=~/.npm,sharing=locked \
    --mount=type=cache,id=client,target=./node_modules/.cache,sharing=locked \
    npm config set fetch-retries 10 && \
    npm config set fetch-retry-mintimeout 100000 && \
    npm config set fetch-retry-maxtimeout 600000 && \
    npm install --no-save --loglevel=info

COPY ./Dockerfile/epgstation/epgstation /app

RUN npm run build --loglevel=info

# EPGStation server build
FROM node:18-bookworm-slim AS server-base

WORKDIR /app

RUN --mount=type=cache,target=/var/lib/apt,sharing=locked \
    --mount=type=cache,target=/var/cache/apt,sharing=locked \
    apt-get update && \
    apt-get install -y --no-install-recommends g++ make pkg-config python3

FROM --platform=$BUILDPLATFORM server-base AS server-builder

ENV DOCKER="YES"

COPY ./Dockerfile/epgstation/epgstation/package*.json .

RUN --mount=type=cache,id=server-builder,target=~/.npm,sharing=locked \
    --mount=type=cache,id=server-builder,target=./node_modules/.cache,sharing=locked \
    npm config set fetch-retries 10 && \
    npm config set fetch-retry-mintimeout 100000 && \
    npm config set fetch-retry-maxtimeout 600000 && \
    npm install --no-save --loglevel=info

COPY --exclude=client Dockerfile/epgstation/epgstation /app

RUN npm run build-server --loglevel=info

FROM server-base AS server-prod-deps

COPY ./Dockerfile/epgstation/epgstation/package*.json .

RUN --mount=type=cache,id=server-prod-deps,target=~/.npm,sharing=locked \
    --mount=type=cache,id=server-prod-deps,target=./node_modules/.cache,sharing=locked \
    npm config set fetch-retries 10 && \
    npm config set fetch-retry-mintimeout 100000 && \
    npm config set fetch-retry-maxtimeout 600000 && \
    npm install --omit=dev --no-save --loglevel=info

FROM scratch AS builder

COPY --from=node-deps /build /

COPY --parents --from=node-deps /etc/ssl /etc/passwd /etc/group /

COPY --from=ghcr.io/fetburner/ffmpeg:a5ce6541b822a69d132fecda901cbaad60115848 / /

COPY --parents --from=server-prod-deps --exclude=**/*.d.ts --exclude=**/README* --exclude=**/LICENSE* --exclude=**/CHANGELOG* /app/node_modules /

COPY --parents --from=client-builder /app/client/dist /

COPY --parents --from=server-builder /app/dist /

COPY --exclude=client \
  --exclude=.npmrc \
  --exclude=.prettierrc \
  --exclude=.eslintrc.json \
  --exclude=tsconfig.json \
  --exclude=package-lock.json \
  --exclude=src \
  --exclude=**/*.d.ts \
  --exclude=**/.gitkeep \
  Dockerfile/epgstation/epgstation /app

# final image
FROM scratch

COPY --from=builder / /

WORKDIR /app
ENTRYPOINT ["/usr/bin/tini", "--"]
CMD ["node", "/app/dist/index.js"]
