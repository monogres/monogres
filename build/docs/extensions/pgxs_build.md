<!-- Generated with Stardoc: http://skydoc.bazel.build -->

Rules to build Postgres PGXS extensions from source.

<a id="pgxs_build"></a>

## pgxs_build

<pre>
load("@monogres//extensions:pgxs_build.bzl", "pgxs_build")

pgxs_build(<a href="#pgxs_build-name">name</a>, <a href="#pgxs_build-pgxs_src">pgxs_src</a>, <a href="#pgxs_build-dependencies">dependencies</a>, <a href="#pgxs_build-pg_version">pg_version</a>)
</pre>

Generates a Bazel target to build a PGXS extension with the [PGXS build system].

[PGXS build system]: https://www.postgresql.org/docs/current/extend-pgxs.html


**PARAMETERS**


| Name  | Description | Default Value |
| :------------- | :------------- | :------------- |
| <a id="pgxs_build-name"></a>name |  The name of the Bazel target to generate.   |  none |
| <a id="pgxs_build-pgxs_src"></a>pgxs_src |  The repo with the extension source code.   |  none |
| <a id="pgxs_build-dependencies"></a>dependencies |  List of dependencies needed to build the extension.   |  none |
| <a id="pgxs_build-pg_version"></a>pg_version |  `struct` containing metadata to select the Postgres build that will be used when building the extension.   |  none |


<a id="pgxs_build_all"></a>

## pgxs_build_all

<pre>
load("@monogres//extensions:pgxs_build.bzl", "pgxs_build_all")

pgxs_build_all(<a href="#pgxs_build_all-name">name</a>, <a href="#pgxs_build_all-cfg">cfg</a>)
</pre>

Defines Bazel targets for building all configured PGXS extensions.

This macro calls `pgxs_build` for every extension in the config struct, and
creates aliases for the default version.


**PARAMETERS**


| Name  | Description | Default Value |
| :------------- | :------------- | :------------- |
| <a id="pgxs_build_all-name"></a>name |  The base name for the default target.   |  none |
| <a id="pgxs_build_all-cfg"></a>cfg |  A `pgext` config `struct`.   |  none |


