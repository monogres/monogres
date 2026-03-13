"""
Extensions build configuration.
"""

load("@pgext_citus//:repo.bzl", "METADATA", "REPO_NAME", "VERSIONS")
load("//extensions:cfg.bzl", "cfg")
load("//postgres:cfg.bzl", PG_CFG = "CFG")

CFG = cfg.new(
    name = "citus",
    versions = VERSIONS,
    pg_targets = PG_CFG.targets,
    repo_name = REPO_NAME,
    deps_buildtime = [
        "@pgext_citus_deps_debian12//libcurl4-openssl-dev",
        "@pgext_citus_deps_debian12//libkrb5-dev",
        "@pgext_citus_deps_debian12//liblz4-dev",
        "@pgext_citus_deps_debian12//libssl-dev",
        "@pgext_citus_deps_debian12//libzstd-dev",
    ],
    deps_runtime = [
        "@pgext_citus_deps_debian12//libcurl4",
        "@pgext_citus_deps_debian12//liblz4-1",
        "@pgext_citus_deps_debian12//libzstd1",
    ],
    metadata = METADATA,
)
