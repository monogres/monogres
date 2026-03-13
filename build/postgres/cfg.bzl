"""
Postgres build configuration.
"""

load("@pg_src//:repo.bzl", "DEFAULT_VERSION", "METADATA", "REPO_NAME", "VERSIONS")
load(":build_options.bzl", "DEFAULT_OPTION_SET", "OPTION_SETS", "build_options")

def _target(name, version, option_set, repo_name, deps_buildtime, deps_runtime):
    """
    Creates a struct representing a Postgres build target.

    Args:
        name (str): Base name for the target (e.g. "postgres").
        version (str): Postgres version string (e.g. "16.0"). Must be one of
            the versions in `pg_src`.
        option_set (str): The name of the Postgres option sets to add to the
            target. An option set is a predefined combination of compile-time
            options.
        repo_name (str): The name of the external Bazel repository with the
            Postgres source code.
        deps_buildtime (list[str]): List of Postgres buildtime dependencies.
        deps_runtime (list[str]): List of Postgres runtime dependencies.

    Returns:
        A `pg_target` `struct`:
          - `name (str)`: a unique target name (e.g. "postgres~16.0").
          - `version (str)`: the Postgres version.
          - `build_options (dict)`: Meson build options that configure optional
            Postgres features and other compilation parameters.
          - `auto_features (str)`: Controls the enabling and disabling of Meson
            build options and optional Postgres features not specified in
            `build_options`.
          - `pg_src (str)`: the label of the external Bazel repository with the
            source code for the given Postgres version.
          - `deps_buildtime (list[str])`: the list of Postgres buildtime
            dependencies.
          - `deps_runtime (list[str])`: the list of Postgres runtime
            dependencies.
    """
    if version not in VERSIONS:
        fail("Postgres version %s is not available in pg_src" % version)

    options, auto_features = build_options(
        version,
        option_set,
        METADATA.get("build_options", {}),
    )

    pg_version = None

    if option_set == "full":
        # We want the "full" option_set to be the default Postgres target
        pg_version = struct(
            name = "~".join((name, version)),
            version = version,
        )

    return struct(
        name = "~".join((name, version, option_set)),
        version = version,
        option_set = option_set,
        build_options = options,
        auto_features = auto_features,
        pg_src = "@%s//%s" % (repo_name, version),
        pg_version = pg_version,
        deps_buildtime = deps_buildtime,
        deps_runtime = deps_runtime,
    )

def _new(name, versions, option_sets, repo_name, deps_buildtime, deps_runtime):
    """
    Creates a config `struct` containing build targets for multiple Postgres versions.

    Args:
        name (str): A base name for the group of targets (e.g. "postgres").
        versions (list[str]): List of Postgres versions.
        option_sets (list[str]): The names of the Postgres option sets to
            add to the targets. An option set is a predefined combination of
            compile-time options.
        repo_name (str): The name of the external Bazel repository with the
            Postgres source code.
        deps_buildtime (list[str]): List of Postgres buildtime dependencies.
        deps_runtime (list[str]): List of Postgres runtime dependencies.

    Returns:
        A config `struct` with:
          - `name`: the base name,
          - `targets`: a list of `pg_target` `struct`s (see `_target`),
          - `default`: the `pg_target` corresponding to the `DEFAULT_VERSION`.
    """
    targets = []
    default_target = None

    for version in versions:
        for option_set in option_sets:
            target = _target(
                name,
                version,
                option_set,
                repo_name,
                deps_buildtime,
                deps_runtime,
            )

            if (
                version == DEFAULT_VERSION and
                option_set == DEFAULT_OPTION_SET
            ):
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
    option_sets = OPTION_SETS,
    repo_name = REPO_NAME,
    deps_buildtime = [
        "@pg_deps_debian12//gettext",
        "@pg_deps_debian12//libavahi-compat-libdnssd-dev",
        "@pg_deps_debian12//libcurl4-openssl-dev",
        "@pg_deps_debian12//libedit-dev",
        "@pg_deps_debian12//libeditreadline-dev",
        "@pg_deps_debian12//libicu-dev",
        "@pg_deps_debian12//libkrb5-dev",
        "@pg_deps_debian12//libldap-dev",
        "@pg_deps_debian12//liblz4-dev",
        "@pg_deps_debian12//libnuma-dev",
        "@pg_deps_debian12//libossp-uuid-dev",
        "@pg_deps_debian12//libpam0g-dev",
        "@pg_deps_debian12//libperl-dev",
        "@pg_deps_debian12//libpython3-dev",
        "@pg_deps_debian12//libselinux1-dev",
        "@pg_deps_debian12//libssl-dev",
        "@pg_deps_debian12//libsystemd-dev",
        "@pg_deps_debian12//liburing-dev",
        "@pg_deps_debian12//libxml2-dev",
        "@pg_deps_debian12//libxslt1-dev",
        "@pg_deps_debian12//libzstd-dev",
        "@pg_deps_debian12//llvm-14-dev",
        "@pg_deps_debian12//tcl-dev",
        "@pg_deps_debian12//uuid-dev",
        "@pg_deps_debian12//zlib1g-dev",
    ],
    deps_runtime = [
        "@pg_deps_debian12//gettext",
        "@pg_deps_debian12//libavahi-compat-libdnssd1",
        "@pg_deps_debian12//libedit2",
        "@pg_deps_debian12//libicu72",
        "@pg_deps_debian12//libkrb5-3",
        "@pg_deps_debian12//libldap-2.5-0",
        "@pg_deps_debian12//liblz4-1",
        "@pg_deps_debian12//libnuma1",
        "@pg_deps_debian12//libossp-uuid16",
        "@pg_deps_debian12//libpam0g",
        "@pg_deps_debian12//libperl5.36",
        "@pg_deps_debian12//libpython3.11",
        "@pg_deps_debian12//libselinux1",
        "@pg_deps_debian12//libssl3",
        "@pg_deps_debian12//libsystemd0",
        "@pg_deps_debian12//liburing2",
        "@pg_deps_debian12//libuuid1",
        "@pg_deps_debian12//libxml2",
        "@pg_deps_debian12//libxslt1.1",
        "@pg_deps_debian12//libzstd1",
        "@pg_deps_debian12//llvm-14-runtime",
        "@pg_deps_debian12//ncurses-term",
        "@pg_deps_debian12//tcl",
        "@pg_deps_debian12//zlib1g",
    ],
)
