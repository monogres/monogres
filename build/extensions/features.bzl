"""
Utility functions to determine whether the version of a Postgres extension is
compatible with a Postgres version.
"""

load("@version_utils//spec:spec.bzl", Spec = "spec")
load("@version_utils//version:version.bzl", Version = "version")

def _cspec(metadata, pgext_version):
    """
    Extracts the compatibility specifier for a given extension version.

    Args:
        metadata (dict): Metadata dictionary that may include a
            `compatible_with` mapping of extension versions to Postgres
            compatibility specs.
        pgext_version (str): The version of the extension being checked.

    Returns:
        A version spec string (e.g. ">=13,<16") or "*" if unspecified.
    """
    compatible_with = metadata.get("compatible_with", {})
    return compatible_with.get(pgext_version, "*")

def _is_compatible_with(cspec, pg_version, debug_msg = None):
    """
    Evaluates whether a Postgres version matches a given compatibility spec.

    Args:
        cspec (str): A version spec string (e.g. ">=16.0,<17.0").
        pg_version (str): The Postgres version to check against (e.g. "15.0").
        debug_msg (str, optional): If provided, prints this message on mismatch.
            Should contain format placeholders for pg_version and cspec.

    Returns:
        `True` if the version matches the spec, `False` otherwise.
    """
    spec = Spec.new(cspec, version_scheme = Version.SCHEME.PGVER)

    is_compatible = spec.match(pg_version)

    if not is_compatible and debug_msg:
        # buildifier: disable=print
        print(debug_msg.format(pg_version, cspec))

    return is_compatible

def is_compatible(name, version, pg_version, metadata = None, debug = False):
    """
    Checks if a given extension version is compatible with a Postgres version.

    Args:
        name (str): The name of the extension.
        version (str): The version of the extension being checked.
        pg_version (str): The Postgres version to check against.
        metadata (dict, optional): Optional metadata with `compatible_with`
            mapping.
        debug (bool): If True, prints a debug message on incompatibility.

    Returns:
        `True` if the extension version is compatible with the given Postgres
        version, `False` otherwise.
    """
    metadata = metadata or {}

    debug_msg = "Skipping extension %r v%s for PG v{}: {}"
    debug_msg = debug_msg % (name, version) if debug else None

    return _is_compatible_with(_cspec(metadata, version), pg_version, debug_msg)
