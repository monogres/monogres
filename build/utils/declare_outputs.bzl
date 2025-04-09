"""
# `declare_outputs`

A Bazel rule to make explicit ("declare") named outputs files from a target
providing an `OutputGroupInfo` with a `gen_dir` attribute that contains the
files (e.g. a `rule_foreign_cc` target).

It copies all the files in `outs` from the `gen_dir` to named outputs, making
them explicitly available for use as `srcs` in other rules.
"""

load("@bazel_skylib//lib:paths.bzl", "paths")

def _impl(ctx):
    ogi = ctx.attr.src[OutputGroupInfo]

    if not getattr(ogi, "gen_dir", False):
        msg = "\nMissing 'gen_dir' attribute from the given 'src' "
        msg += "OutputGroupInfo: %r.\n" % ctx.attr.src
        msg += "This rule is meant to be used with rule_foreign_cc targets "
        msg += "or targets that\noutput an OutputGroupInfo provider with "
        msg += "a 'gen_dir' attribute that points\nto an install dir"
        fail(msg)

    install_dir = [f for f in ogi.gen_dir.to_list()][0]

    expanded_dir = "{}".format(ctx.attr.src.label.name)
    output_dir = paths.join(expanded_dir, ctx.attr.name)

    outputs = []
    command = []
    mkdir_cp = "mkdir -p {output_dir} && cp -aRL {target_path} {output_path}"
    for out in ctx.attr.outs:
        target_path = paths.join(install_dir.path, out)
        output_path = paths.join(output_dir, out)

        output = ctx.actions.declare_file(output_path)
        outputs.append(output)

        command.append(mkdir_cp.format(
            output_dir = paths.dirname(output.path),
            target_path = target_path,
            output_path = output.path,
        ))

    ctx.actions.run_shell(
        inputs = ogi.gen_dir,
        outputs = outputs,
        command = "\n".join(command),
    )

    return [
        DefaultInfo(files = depset(outputs)),
    ]

declare_outputs = rule(
    implementation = _impl,
    provides = [DefaultInfo],
    attrs = {
        "outs": attr.string_list(mandatory = True),
        "src": attr.label(mandatory = True, providers = [OutputGroupInfo]),
    },
)
