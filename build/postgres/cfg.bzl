"""
Postgres build configuration.
"""

REPO_NAME = "pg_src"

VERSIONS = [
    "17.0",
    "16.0",
]

DEFAULT_VERSION = VERSIONS[0]

# NOTE:
# Postgres embeds the install paths via a generated pg_config.h that uses the
# prefix but the prefix is the install prefix **at build time**. Since we build
# in sandboxes and will be installing the binaries at a different path, we've
# added a patch that adds a new prefix_distro build option to set the prefix of
# the "final install path in the distro".
PREFIX_DISTRO = "/postgres"

def _target(name, version, repo_name, prefix_distro):
    """
    Creates a struct representing a Postgres build target.

    Args:
        name (str): Base name for the target (e.g. "postgres").
        version (str): Postgres version string (e.g. "16.0"). Must be one of
            the versions in `pg_src`.
        repo_name (str): The name of the external Bazel repository with the
            Postgres source code.
        prefix_distro (str): The install prefix where the Postgres binaries are
            finally installed.

    Returns:
        A `pg_target` `struct`:
          - `name (str)`: a unique target name (e.g. "postgres~16.0").
          - `version (str)`: the Postgres version.
          - `prefix_distro (str)`: The install prefix where the binaries are
            finally installed.
          - `pg_src (str)`: the label of the external Bazel repository with the
            source code for the given Postgres version.
    """
    if version not in VERSIONS:
        fail("Postgres version %s is not available in pg_src" % version)

    # Postgres features, see:
    # https://www.postgresql.org/docs/current/install-meson.html#MESON-OPTIONS-FEATURES
    build_options = {
        "icu": "disabled",
        "prefix_distro": "%s/%s" % (prefix_distro, version),
        "readline": "disabled",
        "rpath": "false",
        "zlib": "disabled",
    }

    return struct(
        name = "~".join((name, version)),
        version = version,
        build_options = build_options,
        pg_src = "@%s--%s" % (repo_name, version),
    )

def _new(name, versions, repo_name, prefix_distro):
    """
    Creates a config `struct` containing build targets for multiple Postgres versions.

    Args:
        name (str): A base name for the group of targets (e.g. "postgres").
        versions (list[str]): List of Postgres versions.
        repo_name (str): The name of the external Bazel repository with the
            Postgres source code.
        prefix_distro (str): The install prefix where the Postgres binaries are
            finally installed.

    Returns:
        A config `struct` with:
          - `name`: the base name,
          - `targets`: a list of `pg_target` `struct`s (see `_target`),
          - `default`: the `pg_target` corresponding to the `DEFAULT_VERSION`.
    """
    targets = []
    default_target = None

    for version in versions:
        target = _target(name, version, repo_name, prefix_distro)

        if version == DEFAULT_VERSION:
            default_target = target

        targets.append(target)

    return struct(
        name = name,
        targets = targets,
        default = default_target,
    )

cfg = struct(
    new = _new,
)

CFG = cfg.new(
    name = "postgres",
    versions = VERSIONS,
    repo_name = REPO_NAME,
    prefix_distro = PREFIX_DISTRO,
)
