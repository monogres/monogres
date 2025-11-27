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
    dependencies = [
        "@pgext_citus_deps_debian12//libcurl4-openssl-dev",
    ],
    metadata = METADATA,
)
