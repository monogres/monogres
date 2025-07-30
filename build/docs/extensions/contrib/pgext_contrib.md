<!-- Generated with Stardoc: http://skydoc.bazel.build -->

Rules to package Postgres contrib extensions from source.

Postgres contrib extensions are built as part of the main Postgres build. These
rules isolate and collect the relevant files for each extension and package
them into individual tar archives for distribution or reuse.

<a id="pgext_contrib"></a>

## pgext_contrib

<pre>
load("@monogres//extensions/contrib:pgext_contrib.bzl", "pgext_contrib")

pgext_contrib(<a href="#pgext_contrib-name">name</a>, <a href="#pgext_contrib-files">files</a>, <a href="#pgext_contrib-pg_target">pg_target</a>)
</pre>

Create a Postgres contrib extension.

This macro:
- Extracts a subset of files for a specific extension from a Postgres build
  target.
- Generates an mtree spec and applies ownership/permission metadata.
- Packages the extension into a `.tar` file.


**PARAMETERS**


| Name  | Description | Default Value |
| :------------- | :------------- | :------------- |
| <a id="pgext_contrib-name"></a>name |  The name of the contrib extension.   |  none |
| <a id="pgext_contrib-files"></a>files |  The list of file paths (relative to the Postgres base dir) that make the contrib extension.   |  none |
| <a id="pgext_contrib-pg_target"></a>pg_target |  A struct with the Postgres build configuration.   |  none |


<a id="pgext_contrib_all"></a>

## pgext_contrib_all

<pre>
load("@monogres//extensions/contrib:pgext_contrib.bzl", "pgext_contrib_all")

pgext_contrib_all(<a href="#pgext_contrib_all-name">name</a>, <a href="#pgext_contrib_all-cfgs">cfgs</a>)
</pre>

Generate `pgext_contrib` targets for multiple Postgres contrib extensions.

**PARAMETERS**


| Name  | Description | Default Value |
| :------------- | :------------- | :------------- |
| <a id="pgext_contrib_all-name"></a>name |  A base name for the macro call (not used internally, but required by Bazel).   |  none |
| <a id="pgext_contrib_all-cfgs"></a>cfgs |  A list of contrib extension `cfg` `struct`s.   |  none |


