# EIO's [Backstage](https://backstage.io)

EIO's internal developer portal built on [Backstage](https://github.com/backstage/backstage).

## Requirements
```bash
$ brew install nvm
$ nvm install 20
$ nvm use v20
$ corepack enable
```

## Local Development
```bash
# Install dependencies
$ yarn install

# Start backend and frontend
$ yarn start
```

Visit http://localhost:3000

## Building & Deploying
```bash
# Build backend
$ yarn workspace backend build

# Build Docker image
$ docker build -t rancherlabs/backstage:v1.45.0 .

# Push to registry
$ docker push rancherlabs/backstage:v1.45.0
```

Update image tag in `infrastructure/backstage/helmrelease.yaml` to deploy.

## Upgrading Backstage
```bash
# Update packages
$ npx @backstage/cli versions:bump

# Install and verify
$ yarn install
$ yarn tsc
$ yarn workspace backend build

# Test locally before deploying
$ yarn start
```

Check [upgrade helper](https://backstage.github.io/upgrade-helper/) for breaking changes.

## Plugins

- **Kubernetes**: View deployment status and pod information
- **Catalog**: Service catalog with GitHub integration
- **TechDocs**: Documentation site generator
- **Scaffolder**: Software templates for self-service

See [Backstage plugins](https://backstage.io/plugins/) for available integrations.
