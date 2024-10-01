# 💡 Contributing

Please feel free to open [issues] and [PRs], contributions are always welcome!

## 🛠️ Development Setup

Ready to contribute? Here’s how to set up your fork and get started with
development.

### ✅ `pre-commit` hooks

This project uses [`pre-commit`] to enforce automatic checks on commits.

You can see the config and all of the checks in the `.pre-commit-config.yaml`
file.

To install the pre-commit hook, please run `pre-commit install` from the root
of the repo. Once installed, `pre-commit` will do automatic checks on every
commit.

Note that there's also a GH Actions that will run the checks when submitting
PRs and when pushing to any branch except the `wip/*` branches.

### 🧱 Building

This project is built with [Bazel]. You can build everything and run all the
tests in the repo with:

```sh
cd build && bazel test //...
```

[Bazel]: https://bazel.build
[issues]: ../../issues
[`pre-commit`]: https://pre-commit.com
[PRs]: ../../pulls
