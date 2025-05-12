"""
Extensions build configuration.
"""

load("@pgext_sslutils//:repo.bzl", "METADATA", "REPO_NAME", "VERSIONS")
load("//extensions:cfg.bzl", "cfg")
load("//postgres:cfg.bzl", PG_CFG = "CFG")

CFG = cfg.new(
    name = "sslutils",
    versions = VERSIONS,
    pg_targets = PG_CFG.targets,
    repo_name = REPO_NAME,
    dependencies = [
        "@pgext_sslutils_deps_debian12//libssl-dev",
    ],
    metadata = METADATA,
)
