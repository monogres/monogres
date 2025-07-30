<!-- Generated with Stardoc: http://skydoc.bazel.build -->

Postgres contrib extensions build configuration.

This module defines a build configuration for a Postgres contrib extension.
It's intended to be imported into BUILD files to then call `pgext_contrib`
rules.

<a id="cfg.new"></a>

## cfg.new

<pre>
load("@monogres//extensions/contrib:cfg.bzl", "cfg")

cfg.new(<a href="#cfg.new-name">name</a>, <a href="#cfg.new-pgext_pg_targets">pgext_pg_targets</a>)
</pre>

Creates a config `struct` containing build targets for multiple Postgres contrib extensions.

**PARAMETERS**


| Name  | Description | Default Value |
| :------------- | :------------- | :------------- |
| <a id="cfg.new-name"></a>name |  The base name of the extension (e.g. "sslutils").   |  none |
| <a id="cfg.new-pgext_pg_targets"></a>pgext_pg_targets |  The list of pg_target `struct`s for which to build the extension.   |  none |

**RETURNS**

A contrib extension config `struct` with:
    - `name`: the base name of the extension,
    - `targets`: a list of `pgext_pg_target` `struct`s (see `_target`),
    - `default`: the default `pgext_pg_target` (the first target).


