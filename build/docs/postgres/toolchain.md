<!-- Generated with Stardoc: http://skydoc.bazel.build -->

Rule for extracting Postgres-specific template variables from a Postgres build
target.

It uses `template_variable_info_rule` to expose template variables, as follows:
- `<BINARY_NAME>`: each binary under `<target>/bin/` is mapped to an uppercase
  variable of the binary name (e.g., `pg_config` â `PG_CONFIG`).
- `PG_INSTALL_DIR`: the Postgres install dir, derived from the path to
  `pg_config`.

<a id="pg_template_variable_info"></a>

## pg_template_variable_info

<pre>
load("@monogres//postgres:toolchain.bzl", "pg_template_variable_info")

pg_template_variable_info(<a href="#pg_template_variable_info-name">name</a>, <a href="#pg_template_variable_info-target">target</a>)
</pre>



**ATTRIBUTES**


| Name  | Description | Type | Mandatory | Default |
| :------------- | :------------- | :------------- | :------------- | :------------- |
| <a id="pg_template_variable_info-name"></a>name |  A unique name for this target.   | <a href="https://bazel.build/concepts/labels#target-names">Name</a> | required |  |
| <a id="pg_template_variable_info-target"></a>target |  -   | <a href="https://bazel.build/concepts/labels">Label</a> | optional |  `None`  |


