<!-- markdownlint-capture -->
<!-- markdownlint-disable MD013 MD033 MD041 -->
<p style="text-align: left;">
    <img src="logo.svg" alt="version_utils logo" title="logo" align="left" height="60" />
</p>
<!-- markdownlint-restore -->

# `Monogres`: The reproducible Postgres monorepo

[![pre-commit](
    ../../actions/workflows/pre-commit.yaml/badge.svg
)](../../actions/workflows/pre-commit.yaml)

**`Monogres`** is a Postgres distribution that centralizes, builds, and
packages [PostgreSQL]. It’s designed to be **reproducible**, **modular**, and
**community-driven**.

At its core, `Monogres` provides:

- **Upstream, reproducible Postgres builds** with many predefined "option sets"
  (see below).
- A **foundation** for downstream distributions to base their own customized
  Postgres variants.

## 🐘 Postgres, Your Way

`Monogres` builds Postgres with many predefined "option sets" (combinations of
compile-time options) tailored for different use cases:

<details>
<summary>Option Sets</summary>

### Option Sets

|                 | `barebones` | `minimal` | `regular` | `full` |
|----------------:|:-----------:|:---------:|:---------:|:------:|
| `bonjour`       |             |           |           | X      |
| `gssapi`        |             |           |           | X      |
| `icu`           |             |           | X         | X      |
| `ldap`          |             |           |           | X      |
| `libxml`        |             |           |           | X      |
| `libxslt`       |             |           |           | X      |
| `llvm`          |             |           | X         | X      |
| `lz4`           |             |           | X         | X      |
| `nls`           |             | X         | X         | X      |
| `pam`           |             |           |           | X      |
| `plperl`        |             |           |           | X      |
| `plpython`      |             |           | X         | X      |
| `pltcl`         |             |           |           | X      |
| `readline`      |             | X         | X         | X      |
| `selinux`       |             |           |           | X      |
| `ssl=openssl`   |             | X         | X         | X      |
| `systemd`       |             |           | X         | X      |
| `uuid=e2fs`     |             | X         | X         | X      |
| `zlib`          |             | X         | X         | X      |
| `zstd`          |             |           | X         | X      |

</details>

## 🌱 Built for the Community

`Monogres` isn’t an end-user product. It’s an upstream project meant to serve
as a **foundation** for building downstream Postgres distributions.

It’s developed and licensed under the [Apache 2 License], a permissive license
that favors the integration and proliferation of downstream projects,
encouraging Postgres vendors, contributors, and enthusiasts to extend and
adapt the project to their specific needs.

## 🔒 Reproducible by Design

`Monogres` aims to ensure **bit-for-bit reproducibility** by:

- Always building from upstream source
- Always version-pinning and checksumming **everything**: source code, tools,
  binary dependencies, etc.
- Maintaining [monogres/postgres], a mirror of the official PostgreSQL repo
  with [PG-version branches] containing only the minimal patches needed to make
  builds reproducible.

These practices align with the principles of [Reproducible Builds] and make it
easy to verify the integrity of published artifacts, strengthening the build
pipeline against [supply chain attacks]:

> Reproducible Builds elevate deterministic builds by making the build process
> independently verifiable by anyone. This means others can confirm your
> binaries match the source code exactly, fostering trust, improving debugging,
> speeding up builds, and demonstrating your commitment to high standards.

> First, the **build system** needs to be made entirely deterministic:
> transforming a given source must always create the same result.

> Second, the set of tools used to perform the build and more generally the
> **build environment** should either be recorded or pre-defined.

> Third, users should be given a way to recreate a close enough build
> environment, perform the build process, and **validate** that the output
> matches the original build.

### 🪞 Postgres reproducible patches

We aim to never modify Postgres' functional source code. However, its build
process is not yet fully reproducible.

To address this, we maintain a minimal set of reproducibility-focused patches
for each release in the [monogres/postgres] mirror. These patches are usually
one-liners that affect **only the build system and Postgres metadata**. Nothing
else is changed.

The long-term goal is for these patches to be upstreamed. Once that happens,
this mirror will no longer be needed for future Postgres versions but it will
remain available to support reproducible builds of older releases.

## 💡 Contributing

Please feel free to open [issues] and [PRs], contributions are always welcome!
See [CONTRIBUTING.md] and [build/README.md] for more info on how to work with
this repo.

[Apache 2 License]: https://www.apache.org/licenses/LICENSE-2.0
[build/README.md]: build/README.md
[CONTRIBUTING.md]: CONTRIBUTING.md
[issues]: ../../issues
[monogres/postgres]: https://github.com/monogres/postgres
[PG-version branches]: https://github.com/monogres/postgres/branches/all?query=monogres
[PostgreSQL]: https://postgresql.org
[PRs]: ../../pulls
[Reproducible Builds]: https://reproducible-builds.org
[supply chain attacks]: https://en.wikipedia.org/wiki/Supply_chain_attack
