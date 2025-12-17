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
<<<<<<< Updated upstream
# Install dependencies
=======
$ npx @backstage/create-app@latest
```

## Adding New Plugins
Backstage has an extensive list of [existing plugins](https://backstage.io/plugins/) and each with its directions on how to install and configure it in backstage.
The first plugin added to our app is the kubernetes plugin following the instructions [here](https://backstage.io/docs/features/kubernetes/installation) and modifying the code accordingly.

## Building the App

### Dockerfile Customizations (Yarn 4 Fixes)
The [standard Backstage Dockerfile](https://backstage.io/docs/deployment/docker/) failed to build so it was modified to support Yarn 4 (modern yarn). These were added to handle the modern package manager and resolve "permission denied" errors:

- Corepack: Enabled to automatically detect and use the specific Yarn version defined in package.json.

- Permission Fix: Explicitly defined COREPACK_HOME so the node user can download and execute Yarn binaries without `EACCES` errors.

- Unified Cache: Optimized the build cache to speed up dependency installation.

```
# Define cache location for Yarn 4 binaries
ENV COREPACK_HOME=/home/node/.cache/corepack

# Enable corepack (must be run as root)
RUN corepack enable

# switch to node user and ensure cache directory exists
USER node
RUN mkdir -p /home/node/.cache/corepack

```

The image is built, tagged and pushed to the rancherlabs dockerhub repo:
```bash
$ docker build -t rancherlabs/custom-backstage:v1.0.0 .
$ docker push rancherlabs/custom-backstage:v1.0.0
```

This image is referenced in the backstage helmrelease in the cluster's repository.

## Upgrading the App

### Prerequisites
Ensure you're using Node 18 or 20:
```bash
$ nvm use 20
$ node --version  # Should show v20.x.x
```

### Update Backstage Packages
Use Backstage's official upgrade tool to update all `@backstage/*` packages:
```bash
$ npx @backstage/cli versions:bump
```

This command will:
- Check for updates to all Backstage packages
- Update `package.json` and workspace packages
- Show you the version changes
- Provide a link to the upgrade helper for breaking changes

### Install and Test
```bash
# Install updated dependencies
>>>>>>> Stashed changes
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
