<!-- Generated with Stardoc: http://skydoc.bazel.build -->

Postgres build configuration.

<a id="cfg.new"></a>

## cfg.new

<pre>
load("@monogres//postgres:cfg.bzl", "cfg")

cfg.new(<a href="#cfg.new-name">name</a>, <a href="#cfg.new-versions">versions</a>, <a href="#cfg.new-option_sets">option_sets</a>, <a href="#cfg.new-repo_name">repo_name</a>)
</pre>

Creates a config `struct` containing build targets for multiple Postgres versions.

**PARAMETERS**


| Name  | Description | Default Value |
| :------------- | :------------- | :------------- |
| <a id="cfg.new-name"></a>name |  A base name for the group of targets (e.g. "postgres").   |  none |
| <a id="cfg.new-versions"></a>versions |  List of Postgres versions.   |  none |
| <a id="cfg.new-option_sets"></a>option_sets |  The names of the Postgres option sets to add to the targets. An option set is a predefined combination of compile-time options.   |  none |
| <a id="cfg.new-repo_name"></a>repo_name |  The name of the external Bazel repository with the Postgres source code.   |  none |

**RETURNS**

A config `struct` with:
    - `name`: the base name,
    - `targets`: a list of `pg_target` `struct`s (see `_target`),
    - `default`: the `pg_target` corresponding to the `DEFAULT_VERSION`.


