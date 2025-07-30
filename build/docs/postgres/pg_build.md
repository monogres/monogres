<!-- Generated with Stardoc: http://skydoc.bazel.build -->

Rules to build Postgres from source using rules_foreign_cc.

This module defines the `pg_build` macro, which wraps the [`rules_foreign_cc`
`meson` rule] to build Postgres from source. It sets up the required
environment variables, toolchain references, and Meson options needed for the
build.

[`rules_foreign_cc` `meson` rule]: https://bazel-contrib.github.io/rules_foreign_cc/meson.html

<a id="pg_build"></a>

## pg_build

<pre>
load("@monogres//postgres:pg_build.bzl", "pg_build")

pg_build(<a href="#pg_build-name">name</a>, <a href="#pg_build-pg_src">pg_src</a>, <a href="#pg_build-build_options">build_options</a>, <a href="#pg_build-auto_features">auto_features</a>, <a href="#pg_build-pg_version">pg_version</a>)
</pre>

Generates a Bazel target to build Postgres with the Meson build system.

This rule configures the environment and invokes the rules_foreign_cc
`meson` rule, using preconfigured options, toolchains, etc.


**PARAMETERS**


| Name  | Description | Default Value |
| :------------- | :------------- | :------------- |
| <a id="pg_build-name"></a>name |  The name of the Bazel target to generate.   |  none |
| <a id="pg_build-pg_src"></a>pg_src |  The external Bazel repo with the Postgres source code.   |  none |
| <a id="pg_build-build_options"></a>build_options |  Meson build options that configure optional Postgres features and other compilation parameters. For the full list of available options, see [PostgreSQL Features](https://www.postgresql.org/docs/current/install-meson.html#MESON-OPTIONS-FEATURES) and [`meson_options.txt`](https://github.com/postgres/postgres/blob/master/meson_options.txt).   |  none |
| <a id="pg_build-auto_features"></a>auto_features |  Controls whether Meson build options and optional Postgres features not specified in `build_options` will be `enable`d, `disable`d or `auto` (enabled or disabled based on detected system capabilities). For more details, see the official documentation for [Postgres `--auto-features`](https://www.postgresql.org/docs/current/install-meson.html#CONFIGURE-AUTO-FEATURES-MESON) and [Meson Build Options "Features"](https://mesonbuild.com/Build-options.html#features).   |  none |
| <a id="pg_build-pg_version"></a>pg_version |  Optional `struct` that contains the Postgres name and version that will be the default target.   |  `None` |


<a id="pg_build_all"></a>

## pg_build_all

<pre>
load("@monogres//postgres:pg_build.bzl", "pg_build_all")

pg_build_all(<a href="#pg_build_all-name">name</a>, <a href="#pg_build_all-cfg">cfg</a>)
</pre>

Defines Bazel targets for building all configured Postgres versions.

This macro calls `pg_build` for every version listed in the Postgres config
struct, and creates aliases for the default version.


**PARAMETERS**


| Name  | Description | Default Value |
| :------------- | :------------- | :------------- |
| <a id="pg_build_all-name"></a>name |  The base name for the default target (e.g. "postgres").   |  none |
| <a id="pg_build_all-cfg"></a>cfg |  A Postgres config struct (see `cfg.new(...)`).   |  none |


