# 🗂️ `build/`

This directory contains the Bazel repo to build PostgreSQL and many Postgres
extensions.

## 🧱 Building

First, run a local RBE container with:

```sh
make -C docker run-image
```

Then, you can build everything in the repo with:

```sh
bazel build //...
```

### Build all targets

Bazel has a few useful [target patterns] to build multiple targets. Here's a
quick summary:

- `:all`: is a wildcard over *targets*, matching all rules within a `package`.
- `...`: is a wildcard over *packages*, indicating all packages recursively
    beneath the given directory. E.g. `//...` or `//foo/...`. Note that these
    patterns implicitly use `:all`, that is, `//foo/...` is equivalent to
    `//foo/...:all`.
- `:*` or `:all-targets`: is a wildcard that matches *every target* in the
    matched packages, including files that aren't normally built by any rule.
    This implies that `:*` denotes a superset of `:all` and, while potentially
    confusing, this syntax does allow the familiar `:all` wildcard to be used
    for typical builds avoiding files that are usually not wanted.

You may list all the targets using the following command:

```sh
bazel query ...
```

### Build all targets *and run all tests*

```sh
bazel test //...
```

Note that when running `bazel test`, Bazel will build all targets in the repo
(see [🧵](https://bazelbuild.slack.com/archives/CA31HN1T3/p1742490210321409)).

While this is convenient in a CI environment where we want to validate that the
whole repo builds, in development we sometimes want to iterate and just run the
tests.

To avoid this behavior and **only run the tests** in the repo, do:

```sh
bazel test --build_tests_only //...
```

### Build image to run bazel builds

Run `make -C docker gen-image` to generate rbe-pgdeps image and
`make -C docker gen-image TARGET=debug` to make the debug image
(it will build all the rest since debug depends on all of the previous images).

To build image for a specific platform use `BUILD_PLATFORMS` variable like below:

```sh
make -C docker gen-image BUILD_PLATFORMS=linux/amd64
```

> **NOTE**: in Linux, to build multi-platform images make sure the following configuration
> in `/etc/docker/daemon.json`:
>
> ```json
> {
>   "features": {
>     "containerd-snapshotter": true
>   }
> }
> ```

Finally, the `gen-image` target depends on the `Dockerfile`, `Makefile` and
`.bazelversion` files, so the image is rebuilt only when one of these changes.
To force a rebuild at any time, run `make -C docker clean` to remove the
`.*.lock` files.

## 📄 docs

See [`docs/README.md`].

[`docs/README.md`]: docs/README.md
[target patterns]: https://bazel.build/run/build#specifying-build-targets
