"""
Rules to build Postgres from source using rules_foreign_cc.

This module defines the `pg_build` macro, which wraps the [`rules_foreign_cc`
`meson` rule] to build Postgres from source. It sets up the required
environment variables, toolchain references, and Meson options needed for the
build.

[`rules_foreign_cc` `meson` rule]: https://bazel-contrib.github.io/rules_foreign_cc/meson.html
"""

load("@rules_foreign_cc//foreign_cc:meson.bzl", "meson")
load("@rules_pkg//pkg:tar.bzl", "pkg_tar")
load(":toolchain.bzl", "pg_template_variable_info")

def _meson_common_args(pg_src, build_options, auto_features, sysroot = None):
    build_data = [
        "@m4//bin:m4",
        "@flex//bin:flex",
        "@bison//bin:bison",
        "@python_3_11//:python3",
    ]

    if sysroot:
        build_data.append(sysroot)

    toolchains = [
        "@rules_m4//m4:current_m4_toolchain",
        "@rules_flex//flex:current_flex_toolchain",
        "@rules_bison//bison:current_bison_toolchain",
    ]

    # NOTE:
    # For env vars that have relative paths starting with 'external/'
    # rules_foreign_cc makes them absolute prepending $$EXT_BUILD_ROOT$$
    # automatically, see:
    # https://github.com/bazel-contrib/rules_foreign_cc/blob/0.12.0/foreign_cc/private/make_env_vars.bzl#L123-L124
    # https://github.com/bazel-contrib/rules_foreign_cc/blob/0.12.0/foreign_cc/private/cc_toolchain_util.bzl#L352
    #
    # HOWEVER! this seems to only apply to $(execpath ...) So, if you have an
    # env variable (e.g. TEST = "external/foo/bar") or a Make variable from a
    # toolchain (e.g. "$(TEST)") that resolves to "external/foo/bar" IT WON'T
    # WORK without explicitly adding the $$EXT_BUILD_ROOT prefix.
    env = dict(
        BISON = "$(execpath @bison//bin:bison)",
        FLEX = "$(execpath @flex//bin:flex)",
        # NOTE:
        # The flex binary from rules_flex doesn't have a macro processor
        # defined at compile time so flex will try to find the m4 binary using
        # the M4 env variable and if not set, it will just call `m4` and will
        # let `execvp` to resolve it using `PATH`.
        M4 = "$(execpath @m4//bin:m4)",
        PYTHON = "$(execpath @python_3_11//:python3)",
    )

    # NOTE:
    # Sysroot setup for dependencies from rules_distroless packages.
    # The sysroot tarball contains merged dependencies with standard Linux
    # directory structure. We extract it at build time and set up paths so
    # that pkg-config, the compiler, and linker can find the libraries.
    #
    # PKG_CONFIG_SYSROOT_DIR tells pkg-config to prepend this path to all
    # directories in .pc files, avoiding the need to modify them.
    env_sysroot = dict()

    if sysroot:
        # NOTE:
        # The SYSROOT_DIR env var extracts the sysroot tarball and outputs
        # the path. This must be evaluated before other vars that use it.
        # Shell command substitution ensures extraction happens once.
        #
        # For meson builds, we use several mechanisms to find dependencies:
        # 1. PKG_CONFIG_SYSROOT_DIR: prepends sysroot path to all .pc file paths
        # 2. CFLAGS with -idirafter: adds sysroot includes AFTER system paths
        #
        # We use -idirafter instead of C_INCLUDE_PATH because -idirafter
        # directories are searched AFTER standard system directories. This
        # prevents sysroot headers from conflicting with system libc headers
        # while still making them available for headers like dns_sd.h.
        env_sysroot = dict(
            # Extract sysroot tarball and set SYSROOT_DIR
            # The $$(...) ensures this runs once and captures the path
            SYSROOT_DIR = "$$({cmd})".format(
                cmd = " && ".join([
                    "mkdir -p $$EXT_BUILD_ROOT/sysroot",
                    "tar -xf $(execpath {sysroot}) -C $$EXT_BUILD_ROOT/sysroot".format(
                        sysroot = sysroot,
                    ),
                    "echo $$EXT_BUILD_ROOT/sysroot",
                ]),
            ),
            # pkg-config will prepend SYSROOT_DIR to all paths in .pc files
            PKG_CONFIG_SYSROOT_DIR = "$$SYSROOT_DIR",
            PKG_CONFIG_PATH = ":".join([
                "$$SYSROOT_DIR/usr/lib/$$(uname -m)-linux-gnu/pkgconfig",
                "$$SYSROOT_DIR/usr/share/pkgconfig",
            ]),
            # Add sysroot include paths searched AFTER system directories
            # Using -idirafter avoids conflicts with system libc headers
            CFLAGS = " ".join([
                "-idirafter $$SYSROOT_DIR/usr/include",
                "-idirafter $$SYSROOT_DIR/usr/include/$$(uname -m)-linux-gnu",
            ]),
            CXXFLAGS = " ".join([
                "-idirafter $$SYSROOT_DIR/usr/include",
                "-idirafter $$SYSROOT_DIR/usr/include/$$(uname -m)-linux-gnu",
            ]),
            # Add sysroot library path for linking
            LIBRARY_PATH = "$$SYSROOT_DIR/usr/lib/$$(uname -m)-linux-gnu",
            # Add sysroot library path for runtime (needed by tools like msgfmt)
            LD_LIBRARY_PATH = ":".join([
                "$$SYSROOT_DIR/usr/lib/$$(uname -m)-linux-gnu",
                "$$SYSROOT_DIR/usr/lib",
            ]),
        )

    # NOTE:
    # Build PATH with python3 directory and optionally sysroot bin directories.
    # This ensures scripts using `/usr/bin/env python3` can find python, and
    # tools from the sysroot (like llvm-config for JIT, msgfmt for i18n) are
    # available. The system LLVM path (/usr/lib/llvm-14/bin) must come before
    # the sysroot path so that meson finds the system clang (which is in
    # Docker) rather than looking for clang in the sysroot (where only
    # llvm-config exists).
    path_components = ["$$(dirname $(execpath @python_3_11//:python3))"]

    if sysroot:
        # Add system LLVM bin directory first (for clang from system toolchain)
        path_components.append("/usr/lib/llvm-14/bin")

        # Add sysroot bin directories for tools
        path_components.append("$$SYSROOT_DIR/usr/bin")
        path_components.append("$$SYSROOT_DIR/usr/lib/llvm-14/bin")

    path_components.append("$$PATH")

    env_meson = dict(
        # NOTE:
        # https://github.com/jmillikin/rules_bison/issues/17#issuecomment-2399677539
        #
        # I'm not sure who's responsible (Bazel or rules_foreign_cc) but
        # rules_foreign_cc meson is using a wrapper script that does some
        # runfiles initialization that ends up being wrong: it points to the
        # Meson runfiles dir when running tools from Meson and Bison can't find
        # some of its data files.
        #
        # Looking at the rules_foreign_cc wrapper script:
        # https://github.com/bazel-contrib/rules_foreign_cc/blob/0.12.0/foreign_cc/private/runnable_binary_wrapper.sh
        # I found that if the RUNFILES_DIR was set to the Bison runfiles dir,
        # it would use it. Now, this hack seems to "fix" it but IMHO it's very
        # fragile and it seems to work by sheer luck, probably because the rest
        # of the tools are not needing it. If another tool does, I think it
        # would probably fail...
        RUNFILES_DIR = "$(execpath @bison//bin:bison).runfiles/",
        PATH = ":".join(path_components),
    )

    # NOTE:
    # Postgres configure-make build uses env variables to find / override the
    # tools but the Meson build uses find_program(get_option('<TOOL>'), ...) so
    # we have to pass the tools as Meson options pointing them at the env
    # variables.
    meson_tool_options = dict(
        BISON = "$BISON",
        FLEX = "$FLEX",
        PYTHON = "$PYTHON",
    )

    # NOTE: env_sysroot must be merged first so SYSROOT_DIR is set before
    # other variables that reference it (PKG_CONFIG_SYSROOT_DIR, etc.)
    return dict(
        build_data = build_data,
        env = env_sysroot | env | env_meson,
        lib_source = pg_src,
        options = build_options | meson_tool_options,
        target_args = {
            "setup": [
                "--auto-features=%s" % auto_features,
            ],
        },
        toolchains = toolchains,
        visibility = ["//visibility:public"],
    )

def _pg_build_meson(name, pg_src, build_options, auto_features, sysroot = None):
    pg_binaries = [
        "initdb",
        "postgres",
        "pg_config",
        "pg_isready",
        # NOTE: these are needed for contrib extensions
        "vacuumlo",
        "oid2name",
    ]

    # NOTE: including lib in out_data_dirs because even when it's
    # out_lib_dir's default, it's not included in declared_outputs
    out_data_dirs = [
        "lib",
        "share",
    ]

    meson_common_args = _meson_common_args(
        pg_src = pg_src,
        build_options = build_options,
        auto_features = auto_features,
        sysroot = sysroot,
    )

    meson(**(meson_common_args | dict(
        name = name,
        out_binaries = pg_binaries,
        out_data_dirs = out_data_dirs,
    )))

    # NOTE:
    # This target is useful for debugging. On failure, rules_foreign_cc does
    # print the path to the compilation log and the wrapper scripts but it can
    # also be useful to access these after a successful compilation (plus it
    # gives a nicer path to access the logs and a simple way to access it, just
    # bazel build it).
    native.filegroup(
        name = "{}--logs".format(name),
        srcs = [name],
        output_group = "Meson_logs",
    )

def _pg_build_introspect(name, pg_src, build_options, auto_features, sysroot = None):
    meson_common_args = _meson_common_args(
        pg_src = pg_src,
        build_options = build_options,
        auto_features = auto_features,
        sysroot = sysroot,
    )

    introspect_target_name = "{}--introspect".format(name)

    meson(**(meson_common_args | dict(
        name = introspect_target_name,
        out_include_dir = "",
        out_data_files = ["{}.json".format(name)],
        targets = ["introspect"],
        tags = ["manual"],
    )))

    native.filegroup(
        name = "{}--logs".format(introspect_target_name),
        srcs = [introspect_target_name],
        output_group = "Meson_logs",
        tags = ["manual"],
    )

def pg_build(name, pg_src, build_options, auto_features, deps_buildtime = None, pg_version = None):
    """
    Generates a Bazel target to build Postgres with the Meson build system.

    This rule configures the environment and invokes the rules_foreign_cc
    `meson` rule, using preconfigured options, toolchains, etc.

    Args:
        name (str): The name of the Bazel target to generate.
        pg_src (str): The external Bazel repo with the Postgres source code.
        build_options (dict): Meson build options that configure optional
            Postgres features and other compilation parameters. For the full
            list of available options, see [PostgreSQL
            Features](https://www.postgresql.org/docs/current/install-meson.html#MESON-OPTIONS-FEATURES)
            and
            [`meson_options.txt`](https://github.com/postgres/postgres/blob/master/meson_options.txt).
        auto_features (str): Controls whether Meson build options and optional
            Postgres features not specified in `build_options` will be
            `enable`d, `disable`d or `auto` (enabled or disabled based on
            detected system capabilities). For more details, see the official
            documentation for [Postgres
            `--auto-features`](https://www.postgresql.org/docs/current/install-meson.html#CONFIGURE-AUTO-FEATURES-MESON)
            and [Meson Build Options
            "Features"](https://mesonbuild.com/Build-options.html#features).
        deps_buildtime (list[str]): Optional list of dependency tarballs
            from rules_distroless packages. These will be combined into a
            sysroot and made available to the meson build via environment
            variables (PKG_CONFIG_SYSROOT_DIR, CFLAGS, LDFLAGS, etc.).
        pg_version (struct): Optional `struct` that contains the Postgres name
            and version that will be the default target.
    """
    sysroot = None

    if deps_buildtime:
        sysroot = "{}--sysroot".format(name)

        pkg_tar(
            name = sysroot,
            deps = deps_buildtime,
            extension = "tar",
            out = "{}.tar".format(sysroot),
        )

    _pg_build_meson(name, pg_src, build_options, auto_features, sysroot)
    _pg_build_introspect(name, pg_src, build_options, auto_features, sysroot)

    if pg_version:
        native.alias(
            name = pg_version.name,
            actual = name,
            visibility = ["//visibility:public"],
        )

        pg_template_variable_info(
            name = "{}--toolchain".format(pg_version.name),
            target = name,
            visibility = ["//visibility:public"],
        )

def pg_build_all(name, cfg):
    """
    Defines Bazel targets for building all configured Postgres versions.

    This macro calls `pg_build` for every version listed in the Postgres config
    struct, and creates aliases for the default version.

    Args:
        name (str): The base name for the default target (e.g. "postgres").
        cfg (struct): A Postgres config struct (see `cfg.new(...)`).
    """
    for target in cfg.targets:
        for dep in set(target.deps_buildtime + target.deps_runtime):
            dep_name = dep.split("//")[-1]
            native.alias(
                name = "%s--%s" % (target.name, dep_name),
                actual = dep,
                visibility = ["//visibility:public"],
            )
        pg_build(
            name = target.name,
            pg_src = target.pg_src,
            build_options = target.build_options,
            auto_features = target.auto_features,
            deps_buildtime = target.deps_buildtime,
            pg_version = target.pg_version,
        )

    native.alias(
        name = name,
        actual = cfg.default.name,
        visibility = ["//visibility:public"],
    )

    native.alias(
        name = "{}--logs".format(name),
        actual = "{}--logs".format(cfg.default.name),
        visibility = ["//visibility:public"],
    )

    pg_template_variable_info(
        name = "{}--toolchain".format(name),
        target = cfg.default.name,
        visibility = ["//visibility:public"],
    )
