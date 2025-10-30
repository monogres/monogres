"""
Rules to package Postgres contrib extensions from source.

Postgres contrib extensions are built as part of the main Postgres build. These
rules isolate and collect the relevant files for each extension and package
them into individual tar archives for distribution or reuse.
"""

load("@tar.bzl//tar:mtree.bzl", "mtree_mutate", "mtree_spec")
load("@tar.bzl//tar:tar.bzl", "tar")
load("//utils:declare_outputs.bzl", "declare_outputs")

def pgext_contrib(name, files, pg_target):
    """
    Create a Postgres contrib extension.

    This macro:
    - Extracts a subset of files for a specific extension from a Postgres build
      target.
    - Generates an mtree spec and applies ownership/permission metadata.
    - Packages the extension into a `.tar` file.

    Args:
        name (str): The name of the contrib extension.
        files (list[str]): The list of file paths (relative to the Postgres
            base dir) that make the contrib extension.
        pg_target (struct): A struct with the Postgres build configuration.
    """
    name_files = "%s--files" % name
    declare_outputs(
        name = name_files,
        src = "//postgres:%s" % pg_target.pg_version.name,
        outs = files,
        visibility = ["//visibility:public"],
    )

    name_mtree_spec = "%s--mtree-spec" % name
    mtree_spec(
        name = name_mtree_spec,
        srcs = [name_files],
        visibility = ["//visibility:private"],
    )

    name_mtree_mutate = "%s--mtree" % name
    mtree_mutate(
        name = name_mtree_mutate,
        mtree = name_mtree_spec,
        srcs = [name_files],
        strip_prefix = "/".join([
            Label(name_files).package,
            pg_target.name,
            name_files,
        ]),
        ownername = "postgres",
        visibility = ["//visibility:private"],
    )

    tar(
        name = "%s--tar" % name,
        out = "%s.tar" % name,
        srcs = [name_files],
        mtree = name_mtree_mutate,
        visibility = ["//visibility:public"],
    )

def pgext_contrib_all(name, cfgs):
    """
    Generate `pgext_contrib` targets for multiple Postgres contrib extensions.

    Args:
        name (str): A base name for the macro call (not used internally, but
            required by Bazel).
        cfgs (list[struct]): A list of contrib extension `cfg` `struct`s.
    """
    for cfg in cfgs:
        for target in cfg.targets:
            pgext_contrib(
                name = target.name,
                files = target.files,
                pg_target = target.pg_target,
            )
