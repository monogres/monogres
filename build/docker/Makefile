PROJECT_NAME := monogres
REPO := $(abspath $(lastword $(MAKEFILE_LIST))/../..)

DOCKER := $(shell command -v docker || which docker)

ifndef DOCKER
$(error Can't find docker)
endif

DOCKERFILE := debian
BASE_NAME := debian
TARGET ?= rbe
DOCKER_TARGET := $(if $(TARGET),$(BASE_NAME)-$(TARGET),$(BASE_NAME))
IMAGE_NAME := $(PROJECT_NAME)/$(DOCKER_TARGET)

REGISTRY := ghcr.io
GH_ORG := monogres
GH_REPO_URL := https://github.com/$(GH_ORG)/$(PROJECT_NAME)
TAG := $(REGISTRY)/$(GH_ORG)/$(IMAGE_NAME):latest

ARCH ?= $(shell uname -m)
USERNAME ?= postgres

BASE_IMAGE=debian
# https://hub.docker.com/_/debian/tags
BASE_IMAGE_TAG=stable-20250113-slim
# https://github.com/bazelbuild/bazel
BAZEL_VERSION := $(shell cat $(REPO)/.bazelversion 2>/dev/null || echo 7.3.1)
# https://github.com/reproducible-containers/repro-sources-list.sh
REPRODUCIBLE_CONTAINERS_VERSION ?= 0.1.4
# https://github.com/bazelbuild/bazelisk
BAZELISK_VERSION ?= 1.20.0

DEPS_CC_TOOLCHAIN = \
	llvm-14 clang-14 lld-14 \
	libclang-rt-14-dev libc++-14-dev libc++abi-14-dev \
	libc6-dev

all:
	@echo $(REPO)
	@echo "Run make gen-image to generate $(TARGET) image and "
	@echo "make gen-image TARGET=debug to make the debug image "
	@echo "(it will build all the rest since debug depends on "
	@echo "all of the previous images)"

.PHONY: all

run-image:
	# NOTE:
    # MUST RUN --privileged so that Bazel --experimental_use_hermetic_linux_sandbox works!
    # OTHERWISE IT JUST SILENTLY CONTINUES WITHOUT HERMETIC SANDBOX!!?
	$(DOCKER) run \
		--platform "linux/$(ARCH)" \
		--name "sandbox_$(PROJECT_NAME)_$(ARCH)" \
		--privileged \
		--rm \
		--tty \
		--interactive \
		--group-add root \
		--volume "$(REPO)":/src/repo:ro \
		--volume "$(REPO)":/src/workspace:rw \
		--workdir /src/workspace \
		--entrypoint /bin/bash \
		$(TAG)

.PHONY: run-image

gen-image: .$(DOCKER_TARGET).Dockerfile

.PHONY: gen-image

.$(DOCKER_TARGET).Dockerfile: $(DOCKERFILE).Dockerfile
	$(DOCKER) build \
		--platform "linux/amd64,linux/arm64" \
		--file "$<" \
		--build-arg BASE_IMAGE="$(BASE_IMAGE)" \
		--build-arg BASE_IMAGE_TAG="$(BASE_IMAGE_TAG)" \
		--build-arg REPRODUCIBLE_CONTAINERS_VERSION="$(REPRODUCIBLE_CONTAINERS_VERSION)" \
		--build-arg BAZELISK_VERSION="$(BAZELISK_VERSION)" \
		--build-arg BAZEL_VERSION="$(BAZEL_VERSION)" \
		--build-arg DEPS_CC_TOOLCHAIN="$(DEPS_CC_TOOLCHAIN)" \
		--build-arg USERNAME="$(USERNAME)" \
		--build-arg HOMEDIR="/$(USERNAME)" \
		--label org.opencontainers.image.source="$(GH_REPO_URL)" \
		--target "$(DOCKER_TARGET)" \
		--tag "$(IMAGE_NAME)" \
		. && \
	cp "$<" "$@"

# https://docs.github.com/en/authentication/keeping-your-account-and-data-secure/managing-your-personal-access-tokens
# https://docs.github.com/en/packages/working-with-a-github-packages-registry/working-with-the-container-registry
# https://docs.github.com/en/packages/learn-github-packages/connecting-a-repository-to-a-package
push-image: gen-image
	$(DOCKER) image tag $(IMAGE_NAME) $(TAG) && \
	echo "\n\nEnter a GH Personal Access Token with (at least) write:packages scope:\n\n" && \
	$(DOCKER) login --username $(USER) $(REGISTRY)  && \
	$(DOCKER) push $(TAG)

.PHONY: push-image

pull-image:
	@echo "\n\nEnter a GH Personal Access Token with (at least) read:packages scope:\n\n" && \
	$(DOCKER) login --username $(USER) $(REGISTRY)  && \
	$(DOCKER) pull $(TAG)

.PHONY: pull-image

.PHONY: clean test  # making checkmake happy
