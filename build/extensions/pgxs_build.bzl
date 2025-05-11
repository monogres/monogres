"""
Rules to build Postgres PGXS extensions from source.
"""

def pgxs_build(name, pgxs_src, dependencies, pg_version):
    """
    Generates a Bazel target to build a PGXS extension with the [PGXS build system].

    [PGXS build system]: https://www.postgresql.org/docs/current/extend-pgxs.html

    Args:
        name (str): The name of the Bazel target to generate.
        pgxs_src (str): The repo with the extension source code.
        dependencies (list[str]): List of dependencies needed to build the
            extension.
        pg_version (struct): `struct` containing metadata to select the
            Postgres build that will be used when building the extension.
    """
    tar_file, log_file = ["%s%s" % (name, file) for file in (".tar", ".log")]

    native.genrule(
        name = name,
        srcs = [
            "//postgres:%s" % pg_version.name,
            pgxs_src,
        ] + dependencies,
        outs = [tar_file, log_file],
        cmd = """
        tar_() {{
            local tar_file="$$1"; shift
            local args=("$$@")

            local tar_cmd="{tar_cmd}"
            local tar_args=(
                {tar_args}
            )

            LC_ALL=C $$tar_cmd \
                -cf "$$tar_file" \
                "$${{tar_args[@]}}" \
                "$${{args[@]}}"
        }}

        setup_dependencies() {{
            local ext_build_deps="$$1"; shift
            local dependencies=("$$@");

            echo "# $$(date) - setup_dependencies"

            [[ $${{#dependencies[@]}} -eq 0 ]] && return

            mkdir -p "$$ext_build_deps"

            echo
            echo "Extracting dependencies in ext_build_deps: $$ext_build_deps"

            for dep in "$${{dependencies[@]}}"; do
                echo "  - $$dep"
                tar -xf "$$dep" -C "$$ext_build_deps"
            done
            echo
        }}

        compile_extension() {{
            local cc="$$1"; shift
            local pgxs_src="$$1"; shift
            local ext_build_deps="$$1"; shift
            local installdir="$$1"; shift

            # NOTE:
            # Unlike Meson, configure-make builds may write to the source tree.
            # While off-tree (VPATH) builds are theoretically supported, I haven't
            # found a reliable way to use it and still get all extension files
            # installed correctly into the pgxs_installdir (lib, share, etc).
            # To avoid this, we copy the pgxs_src tree and build from the copy.

            local pgxs_src_copy="$$EXT_BUILD_ROOT/pgxs_src_copy"

            # NOTE: -L because we need to copy the actual dir and not the symlink
            cp -raL "$$pgxs_src" "$$pgxs_src_copy"

            local arch
            arch="$$(uname -m)"

            local pg_cflags=(
                "-I$$ext_build_deps/usr/include"
                "-I$$ext_build_deps/usr/include/$${{arch}}-linux-gnu"
            )
            local pg_ldflags=(
                "-L$$ext_build_deps/usr/lib/$${{arch}}-linux-gnu"
            )

            echo "# $$(date) - compile_extension"
            echo
            echo "pgxs_src: $$pgxs_src"
            echo "pgxs_src_copy: $$pgxs_src_copy"

            echo
            echo "make"
            echo
            "$$EXT_BUILD_ROOT/$(MAKE)" \
                -C "$$pgxs_src_copy" \
                CC="$$cc" \
                PG_CONFIG="$$EXT_BUILD_ROOT/$(PG_CONFIG)" \
                PG_CFLAGS="$${{pg_cflags[*]}}" \
                PG_LDFLAGS="$${{pg_ldflags[*]}}" \
                USE_PGXS=1 || return $$?

            echo
            echo "make install"
            echo
            "$$EXT_BUILD_ROOT/$(MAKE)" \
                -C "$$pgxs_src_copy" \
                CC="$$cc" \
                PG_CONFIG="$$EXT_BUILD_ROOT/$(PG_CONFIG)" \
                PG_CFLAGS="$${{pg_cflags[*]}}" \
                PG_LDFLAGS="$${{pg_ldflags[*]}}" \
                USE_PGXS=1 \
                DESTDIR="$$installdir" \
                install || return $$?

            echo
            echo "Extension compiled OK"
        }}

        make_pgxs_installdir() {{
            local installdir="$$1"; shift

            # HACK:
            # The `install` target in the [`PGXS`] Makefile ([`pgxs.mk`])
            # installs the extension at `DESTDIR/datadir/extension/`.
            #
            # `datadir` appears to be set to the absolute path from where
            # [`pg_config`] runs. This is problematic because of two reasons.
            #
            # First, the `pg_config` binary comes from a Postgres toolchain.
            # Like all external dependencies, it's read-only inside the
            # sandbox. We can work around this by setting [`DESTDIR`] to point
            # the install root to a writable directory inside the sandbox.
            #
            # Second, and where the hack is really needed: the rule that
            # creates the Postgres toolchain (template_variable_info) can't run
            # binaries. It only uses the paths of the Postgres binaries which
            # are relative to the sandbox where Postgres was compiled. Thus,
            # the `PG_INSTALL_DIR` template variable in the toolchain is not
            # set to the absolute path that we need.
            #
            # The only workaround is to run `pg_config` here and extract the
            # install path ourselves—just like the `PGXS` Makefile seems to be
            # doing.
            #
            # [`PGXS`]: https://www.postgresql.org/docs/16/extend-pgxs.html
            # [`pgxs.mk`]: https://github.com/postgres/postgres/blob/REL_16_0/src/makefiles/pgxs.mk#L237-L240
            # [`pg_config`]: https://www.postgresql.org/docs/16/app-pgconfig.html
            # [`DESTDIR`]: https://www.gnu.org/software/make/manual/html_node/DESTDIR.html

            local abs_pg_config_bindir
            abs_pg_config_bindir="$$($(PG_CONFIG) --bindir)"

            local abs_pg_install_dir
            abs_pg_install_dir="$$(dirname "$$abs_pg_config_bindir")"

            {{
                echo
                echo "installdir (DESTDIR): $$installdir"
                echo "abs_pg_install_dir: $$abs_pg_install_dir"
                echo "PG_INSTALL_DIR: $(PG_INSTALL_DIR)"
                echo
            }} >> "$$LOG_FILE"

            echo "$$installdir/$$abs_pg_install_dir"
        }}

        errors() {{
            {{
                echo
                echo
                echo "# $$(date)"
                echo
                echo

                env
            }} >> "$$LOG_FILE"

            {{
                echo
                echo
                echo "========================================================"
                echo "  >> LOG: $${{LOG_FILE#"$$EXT_BUILD_ROOT/"}}"
                echo "========================================================"
                echo
                echo
            }} | tee /dev/stderr >> "$$LOG_FILE"

            exit 1
        }}

        trap errors ERR

        # =================================================================== #

        export EXT_BUILD_ROOT="$$PWD"

        TAR_FILE="$$EXT_BUILD_ROOT/{tar_file}"
        LOG_FILE="$$EXT_BUILD_ROOT/{log_file}"
        PGXS_SRC="$$EXT_BUILD_ROOT/{pgxs_src}"
        DEPENDENCIES=({dependencies})

        EXT_BUILD_DEPS="$$EXT_BUILD_ROOT/ext_build_deps"
        INSTALLDIR="$$EXT_BUILD_ROOT/$$(basename "$$TAR_FILE" .tar)"

        PGXS_INSTALLDIR="$$(make_pgxs_installdir "$$INSTALLDIR")"

        CC="$$EXT_BUILD_ROOT/$(CC)"

        export LOG_FILE

        {{
            setup_dependencies "$$EXT_BUILD_DEPS" "$${{DEPENDENCIES[@]}}"
            compile_extension "$$CC" "$$PGXS_SRC" "$$EXT_BUILD_DEPS" "$$INSTALLDIR" 2>&1
            tar_ "$$TAR_FILE" --directory "$$PGXS_INSTALLDIR" .
        }} >> "$$LOG_FILE"
        """.format(
            tar_cmd = "$(BSDTAR_BIN)",
            # NOTE: https://reproducible-builds.org/docs/archives/
            # We are using bsd tar which has less flags available. Consider
            # writing an mtree and/or find a way to use aspect_bazel_lib tar
            # rule like we did in extensions/contrib
            tar_args = "\n".join([
                "--format=posix",
                "--numeric-owner",
                "--owner=0",
                "--group=0",
            ]),
            tar_file = "$(locations %s)" % tar_file,
            log_file = "$(locations %s)" % log_file,
            pgxs_src = "$(locations %s)" % pgxs_src,
            dependencies = " ".join([
                "$(locations %s)" % dependency
                for dependency in dependencies
            ]),
        ),
        target_compatible_with = select({
            # bsdtar.exe: -s is not supported by this version of bsdtar
            "@platforms//os:windows": ["@platforms//:incompatible"],
            "//conditions:default": [],
        }),
        toolchains = [
            "@bazel_tools//tools/cpp:current_cc_toolchain",
            "@bsd_tar_toolchains//:resolved_toolchain",
            "@rules_foreign_cc//toolchains:current_make_toolchain",
            "//postgres:%s--toolchain" % pg_version.name,
        ],
        visibility = ["//visibility:public"],
    )

def pgxs_build_all(name, cfg):
    """
    Defines Bazel targets for building all configured PGXS extensions.

    This macro calls `pgxs_build` for every extension in the config struct, and
    creates aliases for the default version.

    Args:
        name (str): The base name for the default target.
        cfg (struct): A `pgext` config `struct`.
    """
    for target in cfg.targets:
        pgxs_build(
            name = target.name,
            pgxs_src = target.pgxs_src,
            dependencies = target.dependencies,
            pg_version = target.pg_version,
        )

        for dep in target.dependencies:
            dep_name = dep.split("//")[-1]
            native.alias(
                name = "%s--%s" % (target.name, dep_name),
                actual = dep,
                visibility = ["//visibility:public"],
            )

    native.alias(
        name = name,
        actual = cfg.default.name,
        visibility = ["//visibility:public"],
    )
