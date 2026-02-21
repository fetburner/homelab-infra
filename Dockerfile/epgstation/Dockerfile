# node.js
FROM node:18-bookworm AS base

# hadolint ignore=DL3009
RUN --mount=type=cache,id=apt,target=/var/cache/apt,sharing=locked \
    --mount=type=cache,id=apt,target=/var/apt/lists,sharing=locked \
    apt-get update && \
    apt-get install -y --no-upgrade --no-install-recommends tini

# EPGStation client build
FROM --platform=$BUILDPLATFORM base AS client-builder

WORKDIR /app/client

COPY ./Dockerfile/epgstation/epgstation/client/package*.json .

RUN --mount=type=cache,id=client,target=~/.npm,sharing=locked \
    --mount=type=cache,id=client,target=./node_modules/.cache,sharing=locked \
    npm install --no-save --loglevel=info

COPY ./Dockerfile/epgstation/epgstation /app

RUN npm run build --loglevel=info

# EPGStation server build
FROM base AS server-deps

WORKDIR /app

# hadolint ignore=DL3009
RUN --mount=type=cache,id=apt,target=/var/cache/apt,sharing=locked \
    --mount=type=cache,id=apt,target=/var/apt/lists,sharing=locked \
    apt-get update && \
    apt-get install -y --no-upgrade --no-install-recommends build-essential python3

FROM --platform=$BUILDPLATFORM server-deps AS server-builder

ENV DOCKER="YES"

COPY ./Dockerfile/epgstation/epgstation/package*.json .

RUN --mount=type=cache,id=server-builder,target=~/.npm,sharing=locked \
    --mount=type=cache,id=server-builder,target=./node_modules/.cache,sharing=locked \
    npm install --no-save --loglevel=info

COPY --exclude=client Dockerfile/epgstation/epgstation /app

RUN npm run build-server --loglevel=info

FROM server-deps AS server-prod-deps

COPY ./Dockerfile/epgstation/epgstation/package*.json .

RUN --mount=type=cache,id=server-prod-deps,target=~/.npm,sharing=locked \
    --mount=type=cache,id=server-prod-deps,target=./node_modules/.cache,sharing=locked \
    npm install --omit=dev --no-save --loglevel=info

# final image
# hadolint ignore=DL3006
FROM gcr.io/distroless/nodejs18-debian12

WORKDIR /app

COPY --from=base /usr/bin/dash /bin/sh
COPY --parents --from=base /usr/bin/tini /

COPY --from=ghcr.io/fetburner/ffmpeg:sha-ee1ad2a38d51d7f9b076fed5a7f626e662c27ee2 / /

COPY --parents --from=server-prod-deps --exclude=**/*.d.ts --exclude=**/README* --exclude=**/LICENSE* --exclude=**/CHANGELOG* /app/node_modules /

COPY --parents --from=client-builder /app/client/dist /

COPY --parents --from=server-builder /app/dist /

COPY Dockerfile/epgstation/epgstation/api.yml \
    Dockerfile/epgstation/epgstation/img \
    Dockerfile/epgstation/epgstation/ormconfig.js \
    Dockerfile/epgstation/epgstation/package.json /app/

RUN --mount=type=bind,from=busybox:1.35.0-glibc,source=/bin,target=/bin \
    addgroup -g 44 video && \
    mkdir -p drop config recorded thumbnail data/key data/streamfiles logs/EPGUpdater logs/Operator logs/Service

LABEL maintainer="fetburner"

EXPOSE 8888

ENTRYPOINT ["/usr/bin/tini", "--"]
CMD ["/nodejs/bin/node", "/app/dist/index.js"]
