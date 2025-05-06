"""
Postgres extensions build configuration.

This module defines a build configuration for a Postgres extension. It's
intended to be imported into BUILD files to then call `pgxs_build` rules.
"""

def _new(name, versions, pg_targets, repo_name):
    """
    Creates a config `struct` containing build targets for multiple Postgres extensions.

    For each of the extension versions, it will generate a target `struct` that
    contains all the required config needed to compile the extension.

    Args:
        name (str): A base name for the group of targets (usually the name of
            the extension).
        versions (list[str]): List of versions for the extension.
        pg_targets (list[struct]): The list of pg_target `struct`s for
            which to build the extension.
        repo_name (str): The name of the external Bazel repository with the
            extension source code.

    Returns:
        A `pgext` config `struct` with:
          - `name`: the base name
          - `targets`: a list of `pgext_target` `struct`s
          - `default`: the default `pgext_target` (the first target)
    """
    targets = [
        struct(
            name = "~".join([name, version, pg_target.pg_version.name]),
            version = version,
            pg_version = pg_target.pg_version,
            pgxs_src = "@%s//%s:dir" % (repo_name, version),
        )
        for version in versions
        for pg_target in pg_targets
        if pg_target.pg_version
    ]

    return struct(
        name = name,
        targets = targets,
        default = targets[0],
    )

cfg = struct(
    new = _new,
)
