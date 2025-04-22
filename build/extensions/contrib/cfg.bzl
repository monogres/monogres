"""
Postgres contrib extensions build configuration.

This module defines a build configuration for a Postgres contrib extension.
It's intended to be imported into BUILD files to then call `pgext_contrib`
rules.
"""

load("@pg_introspect//:defs.bzl", "INTROSPECTIONS")
load("//postgres:cfg.bzl", PG_CFG = "CFG")

def _target(name, pg_target, pgext_metadata):
    """
    Creates a struct representing a build target for a Postgres contrib extension.
    """
    return struct(
        name = "~".join([name, pg_target.pg_version.name]),
        pg_target = pg_target,
        files = pgext_metadata["paths"],
    )

def _pgext_metadata(pg_target):
    ikey = (pg_target.pg_version.version, pg_target.option_set)
    return INTROSPECTIONS[ikey]

def _new(name, pgext_pg_targets):
    """
    Creates a config `struct` containing build targets for multiple Postgres contrib extensions.

    Args:
        name (str): The base name of the extension (e.g. "sslutils").
        pgext_pg_targets (list[struct]): The list of pg_target `struct`s for
            which to build the extension.

    Returns:
        A contrib extension config `struct` with:
          - `name`: the base name of the extension,
          - `targets`: a list of `pgext_pg_target` `struct`s (see `_target`),
          - `default`: the default `pgext_pg_target` (the first target).
    """
    targets = [
        _target(
            name = name,
            pg_target = pg_target,
            pgext_metadata = _pgext_metadata(pg_target)["contrib"][name],
        )
        for pg_target in pgext_pg_targets
    ]

    return struct(
        name = name,
        targets = targets,
        default = targets[0],
    )

cfg = struct(
    new = _new,
)

def _pgext_contrib(pg_targets):
    """
    Maps the contrib extension name to the Postgres versions in the `pg_targets`.
    """
    pgext_contrib = {}

    for pg_target in pg_targets:
        if pg_target.pg_version == None:
            continue

        for pgext_name in _pgext_metadata(pg_target)["contrib"]:
            if pgext_name not in pgext_contrib:
                pgext_contrib[pgext_name] = []

            pgext_contrib[pgext_name].append(pg_target)

    return pgext_contrib

CFGS = {
    pgext_name: cfg.new(
        name = pgext_name,
        pgext_pg_targets = pgext_pg_targets,
    )
    for pgext_name, pgext_pg_targets in _pgext_contrib(PG_CFG.targets).items()
}
