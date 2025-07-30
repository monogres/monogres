<!-- Generated with Stardoc: http://skydoc.bazel.build -->

Postgres extensions build configuration.

This module defines a build configuration for a Postgres extension. It's
intended to be imported into BUILD files to then call `pgxs_build` rules.

<a id="cfg.new"></a>

## cfg.new

<pre>
load("@monogres//extensions:cfg.bzl", "cfg")

cfg.new(<a href="#cfg.new-name">name</a>, <a href="#cfg.new-versions">versions</a>, <a href="#cfg.new-pg_targets">pg_targets</a>, <a href="#cfg.new-repo_name">repo_name</a>, <a href="#cfg.new-dependencies">dependencies</a>, <a href="#cfg.new-metadata">metadata</a>)
</pre>

Creates a config `struct` containing build targets for multiple Postgres extensions.

For each of the extension versions, it will generate a target `struct` that
contains all the required config needed to compile the extension, filtering
out the PG versions that are incompatible with the extension.


**PARAMETERS**


| Name  | Description | Default Value |
| :------------- | :------------- | :------------- |
| <a id="cfg.new-name"></a>name |  A base name for the group of targets (usually the name of the extension).   |  none |
| <a id="cfg.new-versions"></a>versions |  List of versions for the extension.   |  none |
| <a id="cfg.new-pg_targets"></a>pg_targets |  The list of pg_target `struct`s for which to build the extension.   |  none |
| <a id="cfg.new-repo_name"></a>repo_name |  The name of the external Bazel repository with the extension source code.   |  none |
| <a id="cfg.new-dependencies"></a>dependencies |  List of dependencies needed to build the extension.   |  `None` |
| <a id="cfg.new-metadata"></a>metadata |  Extension metadata that can contain e.g. `compatible_with` metadata to filter incompatible Postgres versions.   |  `None` |

**RETURNS**

A `pgext` config `struct` with:
    - `name`: the base name
    - `targets`: a list of `pgext_target` `struct`s
    - `default`: the default `pgext_target` (the first target)


