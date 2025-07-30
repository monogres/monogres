<!-- Generated with Stardoc: http://skydoc.bazel.build -->

Postgres Meson build options

Defines default and conditional Meson build options for Postgres predefined
option sets.

For the full list of available options, see [PostgreSQL Features] and
[`meson_options.txt`].

[Postgres Features]: https://www.postgresql.org/docs/current/install-meson.html#MESON-OPTIONS-FEATURES
[`meson_options.txt`]: https://github.com/postgres/postgres/blob/master/meson_options.txt

<a id="build_options"></a>

## build_options

<pre>
load("@monogres//postgres:build_options.bzl", "build_options")

build_options(<a href="#build_options-version">version</a>, <a href="#build_options-option_set">option_set</a>, <a href="#build_options-build_options_metadata">build_options_metadata</a>, <a href="#build_options-debug">debug</a>)
</pre>

Computes Postgres build options and auto-feature settings.

**PARAMETERS**


| Name  | Description | Default Value |
| :------------- | :------------- | :------------- |
| <a id="build_options-version"></a>version |  Postgres major.minor version (e.g., "16.0").   |  none |
| <a id="build_options-option_set"></a>option_set |  One of the predefined build option sets (e.g. "barebones", "full", etc).   |  none |
| <a id="build_options-build_options_metadata"></a>build_options_metadata |  A dictionary mapping Postgres build options to their compatible PG version constraints spec.   |  none |
| <a id="build_options-debug"></a>debug |  If `True`, prints debug messages when build options are incompatible with the given Postgre version.   |  `False` |

**RETURNS**

(options, auto_features)

  A build options tuple:
      - options: Meson build options.
      - auto_features: PG `--auto-features flag.


<a id="is_compatible"></a>

## is_compatible

<pre>
load("@monogres//postgres:build_options.bzl", "is_compatible")

is_compatible(<a href="#is_compatible-option">option</a>, <a href="#is_compatible-version">version</a>, <a href="#is_compatible-build_options_metadata">build_options_metadata</a>, <a href="#is_compatible-debug">debug</a>)
</pre>

Checks if a build option is compatible with the given Postgres version.

**PARAMETERS**


| Name  | Description | Default Value |
| :------------- | :------------- | :------------- |
| <a id="is_compatible-option"></a>option |  The name of the build option to check.   |  none |
| <a id="is_compatible-version"></a>version |  Postgres major.minor version (e.g., "16.0").   |  none |
| <a id="is_compatible-build_options_metadata"></a>build_options_metadata |  A dictionary mapping Postgres build options to their compatible PG version constraints spec.   |  none |
| <a id="is_compatible-debug"></a>debug |  If `True`, prints a debug message if the build option is incompatible.   |  `False` |

**RETURNS**

`True` if the build option is compatible with the version, `False`
  otherwise.


