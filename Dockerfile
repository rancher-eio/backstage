# Stage 1 - Create yarn install skeleton layer
FROM node:22-bookworm-slim AS packages

WORKDIR /app
COPY backstage.json package.json yarn.lock ./
COPY .yarn ./.yarn
COPY .yarnrc.yml ./

COPY packages packages

# Commented out by default; uncomment if you have a /plugins folder in your root
# COPY plugins plugins

RUN find packages \! -name "package.json" -mindepth 2 -maxdepth 2 -exec rm -rf {} \+

# Stage 2 - Install dependencies and build packages
FROM node:22-bookworm-slim AS build

ENV PYTHON=/usr/bin/python3
# Set Corepack home to a directory the node user can write to
ENV COREPACK_HOME=/home/node/.cache/corepack

RUN --mount=type=cache,target=/var/cache/apt,sharing=locked \
    --mount=type=cache,target=/var/lib/apt,sharing=locked \
    apt-get update && \
    apt-get install -y --no-install-recommends python3 g++ build-essential libsqlite3-dev && \
    rm -rf /var/lib/apt/lists/*

# Enable Corepack as root
RUN corepack enable

USER node
WORKDIR /app

# Create the cache directory as the node user
RUN mkdir -p /home/node/.cache/corepack

COPY --from=packages --chown=node:node /app .

# Combined cache mount to cover both Yarn and Corepack downloads
RUN --mount=type=cache,target=/home/node/.cache,uid=1000,gid=1000 \
    yarn install --immutable

COPY --chown=node:node . .

RUN yarn tsc
RUN yarn --cwd packages/backend build

RUN mkdir -p packages/backend/dist/skeleton packages/backend/dist/bundle \
    && tar xzf packages/backend/dist/skeleton.tar.gz -C packages/backend/dist/skeleton \
    && tar xzf packages/backend/dist/bundle.tar.gz -C packages/backend/dist/bundle

# Stage 3 - Final Image
FROM node:22-bookworm-slim

ENV PYTHON=/usr/bin/python3
ENV COREPACK_HOME=/home/node/.cache/corepack

RUN --mount=type=cache,target=/var/cache/apt,sharing=locked \
    --mount=type=cache,target=/var/lib/apt,sharing=locked \
    apt-get update && \
    apt-get install -y --no-install-recommends python3 g++ build-essential libsqlite3-dev && \
    rm -rf /var/lib/apt/lists/*

RUN corepack enable

USER node
WORKDIR /app
RUN mkdir -p /home/node/.cache/corepack

COPY --from=build --chown=node:node /app/.yarn ./.yarn
COPY --from=build --chown=node:node /app/.yarnrc.yml  ./
COPY --from=build --chown=node:node /app/backstage.json ./
COPY --from=build --chown=node:node /app/yarn.lock /app/package.json /app/packages/backend/dist/skeleton/ ./

RUN --mount=type=cache,target=/home/node/.cache,uid=1000,gid=1000 \
    yarn workspaces focus --all --production && rm -rf "$(yarn cache clean)"

COPY --from=build --chown=node:node /app/packages/backend/dist/bundle/ ./
COPY --chown=node:node app-config*.yaml ./

ENV NODE_ENV=production
ENV NODE_OPTIONS="--no-node-snapshot"

CMD ["node", "packages/backend", "--config", "app-config.yaml", "--config", "app-config.production.yaml"]
