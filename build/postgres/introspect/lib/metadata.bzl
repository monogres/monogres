"""
PG introspect manual metadata
"""

# NOTE:
# FEATURES_TO_DEB_PKGS maps the feature to the required Debian package(s). It
# was curated by hand from PG 16.0 contrib extensions. Hopefully / luckily,
# these should not change too often and will probably remain the same for a
# long time. But if not, then we will probably have to add some versioning
# mechanisms.
FEATURES_TO_DEB_PKGS = {
    "bonjour": "libavahi-compat-libdnssd-dev",
    "docs": [
        "libxml2-utils",
        "xsltproc",
    ],
    "docs_pdf": [
        "libxml2-utils",
        "xsltproc",
        "fop",
    ],
    "gssapi": "libkrb5-dev",
    "icu": "libicu-dev",
    "ldap": "libldap-dev",
    "libxml": "libxml2-dev",
    "libxslt": "libxslt1-dev",
    "llvm": [
        "llvm-dev",
        "clang",
    ],
    "lz4": "liblz4-dev",
    "nls": "gettext",
    "pam": "libpam0g-dev",
    "plperl": "libperl-dev",
    "plpython": "libpython3-dev",
    "pltcl": "tcl-dev",
    "readline": {
        "libedit": "libedit-dev",
        "libreadline": "libeditreadline-dev",
    },
    "selinux": "libselinux1-dev",
    "ssl": {
        "openssl": "libssl-dev",
    },
    "systemd": "libsystemd-dev",
    "uuid": {
        "e2fs": "uuid-dev",
        "ossp": "libossp-uuid-dev",
    },
    "zlib": "zlib1g-dev",
    "zstd": "libzstd-dev",
}

FEATURES_OVERRIDE = {
    # the .found() in basebackup_to_shell is only for testing and selecting tools
    "basebackup_to_shell": None,
}

DEP_TO_FEATURE = {
    "perl_dep": "plperl",
    "python3_dep": "plpython",
}

# NOTE:
# We need to override some of the contrib installed paths when the meson.build
# files exist but, due to bugs or other issues, no contrib targets or install
# paths are properly generated. For example:
# https://github.com/postgres/postgres/commit/823eb3db1c50a6b8a89ebedc1db96b14de140183
# where the sepgsql contrib extension was not being installed, pre-17.0
CONTRIB_INSTALLED_PATHS_OVERRIDE = {
    "sepgsql": {
        "<17.0": [
            "lib/{arch}-linux-gnu/sepgsql.so",
            "share/extension/sepgsql.sql",
        ],
    },
}
