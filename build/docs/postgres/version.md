<!-- Generated with Stardoc: http://skydoc.bazel.build -->

Postgres version compatibility.

<a id="is_compatible_with"></a>

## is_compatible_with

<pre>
load("@monogres//postgres:version.bzl", "is_compatible_with")

is_compatible_with(<a href="#is_compatible_with-version">version</a>, <a href="#is_compatible_with-version_constraints">version_constraints</a>, <a href="#is_compatible_with-debug_prefix">debug_prefix</a>)
</pre>

Returns whether a Postgres version is compatible with the given version constraints.

**EXAMPLE**

```starlark
is_compatible = is_compatible_with("17.1", ">=16, <18")

print(is_compatible)
# True
```


**PARAMETERS**


| Name  | Description | Default Value |
| :------------- | :------------- | :------------- |
| <a id="is_compatible_with-version"></a>version |  Postgres major.minor version (e.g. "16.0", "15.1").   |  none |
| <a id="is_compatible_with-version_constraints"></a>version_constraints |  A version constraint expression (e.g. ">=15, <18").   |  none |
| <a id="is_compatible_with-debug_prefix"></a>debug_prefix |  Optional prefix for debug output.   |  `None` |

**RETURNS**

`True` if the Postgres version is compatible with the version
  constraints, `False` otherwise.


