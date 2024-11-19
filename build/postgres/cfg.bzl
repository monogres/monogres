"""
Postgres build configuration.

This module defines a basic build configuration for a specific Postgres
version. It provides a name and a reference to the source archive repository,
and is intended to be imported into BUILD files to instantiate pg_build rules.
"""

VERSION = "16.0"

# NOTE:
# Postgres embeds the install paths via a generated pg_config.h that uses the
# prefix but the prefix is the install prefix **at build time**. Since we build
# in sandboxes and will be installing the binaries at a different path, we've
# added a patch that adds a new prefix_distro build option to set the prefix of
# the "final install path in the distro".
PREFIX_DISTRO = "/postgres"

# Postgres features, see:
# https://www.postgresql.org/docs/current/install-meson.html#MESON-OPTIONS-FEATURES
BUILD_OPTIONS = {
    "icu": "disabled",
    "prefix_distro": "/%s/%s" % (PREFIX_DISTRO, VERSION),
    "readline": "disabled",
    "rpath": "false",
    "zlib": "disabled",
}

CFG = struct(
    name = "postgres",
    version = VERSION,
    build_options = BUILD_OPTIONS,
    pg_src = "@pg_src--%s" % VERSION,
)
