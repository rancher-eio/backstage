
TARGET_REPOSITORY := env_var_or_default("TARGET_REPOSITORY", `yq 'explode(.).target.repository' config.yaml`)
TARGET_TAG := env_var_or_default("TARGET_TAG", `yq 'explode(.).target.tag' config.yaml`)

TARGET := TARGET_REPOSITORY + ":" + TARGET_TAG

_default: build-push

@build-push:
    docker buildx build \
      --platform=linux/arm64,linux/amd64 \
      --tag="{{ TARGET }}" \
      --push \
      .
