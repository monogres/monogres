"""
Postgres version compatibility.
"""

load("@version_utils//spec:spec.bzl", Spec = "spec")
load("@version_utils//version:version.bzl", Version = "version")

def is_compatible_with(version, version_constraints, debug_prefix = None):
    """
    Returns whether a Postgres version is compatible with the given version constraints.

    **EXAMPLE**

    ```starlark
    is_compatible = is_compatible_with("17.1", ">=16, <18")

    print(is_compatible)
    # True
    ```

    Args:
        version (str): Postgres major.minor version (e.g. "16.0", "15.1").
        version_constraints (str): A version constraint expression (e.g. ">=15,
            <18").
        debug_prefix (str): Optional prefix for debug output.

    Returns:
        `True` if the Postgres version is compatible with the version
        constraints, `False` otherwise.
    """

    spec = Spec.new(version_constraints, version_scheme = Version.SCHEME.PGVER)

    is_compatible = spec.match(version)

    if not is_compatible and debug_prefix:
        debug_msg = "%s not compatible with PG v{}: {}" % debug_prefix

        # buildifier: disable=print
        print(debug_msg.format(version, version_constraints))

    return is_compatible
