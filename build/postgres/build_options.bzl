"""
Postgres Meson build options

Defines default and conditional Meson build options for Postgres predefined
option sets.

For the full list of available options, see [PostgreSQL Features] and
[`meson_options.txt`].

[Postgres Features]: https://www.postgresql.org/docs/current/install-meson.html#MESON-OPTIONS-FEATURES
[`meson_options.txt`]: https://github.com/postgres/postgres/blob/master/meson_options.txt
"""

load(":version.bzl", "is_compatible_with")

# NOTE:
# Postgres embeds the install paths via a generated pg_config.h that uses the
# prefix but the prefix is the install prefix **at build time**. Since we build
# in sandboxes and will be installing the binaries at a different path, we've
# added a patch that adds a new prefix_distro build option to set the prefix of
# the "final install path in the distro".
_PREFIX_DISTRO = "/postgres"

_DEFAULT_OPTIONS = dict(
    rpath = "false",
    system_tzdata = "/usr/share/zoneinfo",
)

# These options are always enabled because usually it never makes sense to
# disable them
_ENABLED_UNLESS_EXPLICITLY_DISABLED = [
    ("spinlocks", "true"),
    ("atomics", "true"),
]

# These options usually only make sense on specific OSes or specific builds
# requiring the functionality (e.g. the docs or developer options) so we
# disable these by default even if auto-features is enabled and are only
# enabled when explicitly enabled.
_DISABLED_UNLESS_EXPLICITLY_ENABLED = [
    ("docs", "disabled"),
    ("docs_pdf", "disabled"),
    ("bsd_auth", "disabled"),
    ("bonjour", "disabled"),
    # --- developer options ---
    ("tap_tests", "disabled"),
    ("dtrace", "disabled"),
    ("cassert", "false"),
    ("injection_points", "false"),
    ("b_coverage", "false"),
    # --- developer options ---
]

# Predefined option sets
_OPTION_SETS_MINIMAL = [
    "nls",
    "readline",
    ("ssl", "openssl"),
    ("uuid", "e2fs"),
    "zlib",
]

_OPTION_SETS_REGULAR = _OPTION_SETS_MINIMAL + [
    "icu",
    "llvm",
    "lz4",
    "plpython",
    "systemd",
    "zstd",
]

# buildifier: leave-alone, do not sort
_OPTION_SETS = dict(
    barebones = [
        ("extra_version", "barebones"),
        None,
    ],
    minimal = [
        ("extra_version", "minimal"),
    ] + _OPTION_SETS_MINIMAL,
    regular = [
        ("extra_version", "regular"),
    ] + _OPTION_SETS_REGULAR,
    full = [
        ("extra_version", "full"),
        "all",
        "bonjour",
        "selinux",  # in 16.0 it's not 'auto' so it has to be enabled explicitly
    ] + _OPTION_SETS_REGULAR,
)

# we only want the sizes to be used publicly, the mapping remains private
OPTION_SETS = _OPTION_SETS.keys()
DEFAULT_OPTION_SET = OPTION_SETS[-1]

def is_compatible(option, version, build_options_metadata, debug = False):
    """
    Checks if a build option is compatible with the given Postgres version.

    Args:
        option (string): The name of the build option to check.
        version (string): Postgres major.minor version (e.g., "16.0").
        build_options_metadata (dict): A dictionary mapping Postgres build
            options to their compatible PG version constraints spec.
        debug (bool): If `True`, prints a debug message if the build option is
            incompatible.

    Returns:
        `True` if the build option is compatible with the version, `False`
        otherwise.
    """
    compatible_with = build_options_metadata.get(option, {"compatible": "*"})
    version_constraints = compatible_with["compatible"]

    debug_prefix = "PG build option %r" % option if debug else None

    return is_compatible_with(version, version_constraints, debug_prefix)

def build_options(version, option_set, build_options_metadata, debug = False):
    """
    Computes Postgres build options and auto-feature settings.

    Args:
        version (string): Postgres major.minor version (e.g., "16.0").
        option_set (string): One of the predefined build option sets (e.g.
            "barebones", "full", etc).
        build_options_metadata (dict): A dictionary mapping Postgres build
            options to their compatible PG version constraints spec.
        debug (bool): If `True`, prints debug messages when build options are
            incompatible with the given Postgre version.

    Returns:
        (options, auto_features)

        A build options tuple:
            - options: Meson build options.
            - auto_features: PG `--auto-features flag.
    """
    if option_set not in OPTION_SETS:
        fail("Invalid option set: %r" % option_set)

    options = _DEFAULT_OPTIONS | dict([
        option if type(option) == "tuple" else (option, "enabled")
        for option in _OPTION_SETS[option_set]
        if option != None
    ])

    def is_enabled(option):
        return options.get(option, None) in ("enabled", "true")

    def is_disabled(option):
        return options.get(option, None) in ("disabled", "false")

    # we always begin with auto-features=disabled so that we enable each option
    # explicitly but:
    # - we also allow an "all" wildcard for convenience
    # - we always disable some options unless explicitly enabled
    # - we always enable some options unless explicitly disabled
    auto_features = "disabled"

    if "all" in options:
        auto_features = "enabled"
        options.pop("all")

        for option, value in _DISABLED_UNLESS_EXPLICITLY_ENABLED:
            if (
                is_compatible(option, version, build_options_metadata, debug) and
                not is_enabled(option)
            ):
                options[option] = value
    else:
        for option, value in _ENABLED_UNLESS_EXPLICITLY_DISABLED:
            if (
                is_compatible(option, version, build_options_metadata, debug) and
                not is_disabled(option)
            ):
                options[option] = value

    options = options | dict(
        prefix_distro = "%s/%s" % (_PREFIX_DISTRO, version),
    )

    return options, auto_features
