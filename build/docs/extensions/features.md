<!-- Generated with Stardoc: http://skydoc.bazel.build -->

Utility functions to determine whether the version of a Postgres extension is
compatible with a Postgres version.

<a id="is_compatible"></a>

## is_compatible

<pre>
load("@monogres//extensions:features.bzl", "is_compatible")

is_compatible(<a href="#is_compatible-name">name</a>, <a href="#is_compatible-version">version</a>, <a href="#is_compatible-pg_version">pg_version</a>, <a href="#is_compatible-metadata">metadata</a>, <a href="#is_compatible-debug">debug</a>)
</pre>

Checks if a given extension version is compatible with a Postgres version.

**PARAMETERS**


| Name  | Description | Default Value |
| :------------- | :------------- | :------------- |
| <a id="is_compatible-name"></a>name |  The name of the extension.   |  none |
| <a id="is_compatible-version"></a>version |  The version of the extension being checked.   |  none |
| <a id="is_compatible-pg_version"></a>pg_version |  The Postgres version to check against.   |  none |
| <a id="is_compatible-metadata"></a>metadata |  Optional metadata with `compatible_with` mapping.   |  `None` |
| <a id="is_compatible-debug"></a>debug |  If True, prints a debug message on incompatibility.   |  `False` |

**RETURNS**

`True` if the extension version is compatible with the given Postgres
  version, `False` otherwise.


