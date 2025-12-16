# EIO's [Backstage](https://backstage.io)
This is EIO's backstage App customized and configured with the necessary plugins needed for our use cases.
It is based on [Spotify's backstage project](https://github.com/backstage/backstage).

## How it was created
This app was created using the instructions from the [backstage docs](https://backstage.io/docs/getting-started/create-an-app/) for creating an app.

*Requirements:*
```bash
$ brew install nvm
$ nvm install 20
$ nvm use v20
```

*Creating the app:*
```bash
$ npx @backstage/create-app@latest
```

## Adding New Plugins
Backstage has an extensive list of [existing plugins](https://backstage.io/plugins/) and each with its directions on how to install and configure it in backstage.
The first plugin added to our app is the kubernetes plugin following the instructions [here](https://backstage.io/docs/features/kubernetes/installation) and modifying the code accordingly.

## Building the App
The image is built, tagged and pushed to the rancherlabs dockerhub repo:
```bash
$ docker image build -t backstage .
$ docker tag <image-id> rancherlabs/custom-backstage:v0.0.X
$ docker push rancherlabs/custom-backstage:v0.0.X
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
$ yarn install

# Type check
$ yarn tsc

# Build all packages
$ yarn build

# Test locally
$ yarn dev
```

Visit http://localhost:3000 to verify everything works.

### Review Breaking Changes
If the upgrade spans multiple versions, review the upgrade helper:
```
https://backstage.github.io/upgrade-helper/?from=OLD_VERSION&to=NEW_VERSION
```

### Deploy
Once tested, build and push a new Docker image:
```bash
$ docker build -t rancherlabs/custom-backstage:v0.0.X .
$ docker push rancherlabs/custom-backstage:v0.0.X
```

### Recommended Upgrade Frequency
- **Monthly**: check for updates and apply minor/patch versions
- **As needed**: apply security patches immediately
- **Quarterly**: review and apply major version updates

### Troubleshooting
- If `yarn install` fails, ensure you're on Node 20: `nvm use 20`
- If builds fail, check the [upgrade helper](https://backstage.github.io/upgrade-helper/) for breaking changes
- If tests fail, review plugin compatibility with the new Backstage version
