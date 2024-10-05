"""e2e testing utils"""

def list_files(name, target):
    native.genrule(
        name = name,
        srcs = [target],
        outs = ["%s.files" % name],
        cmd = """
        echo "$(locations {target})" >| $@
        """.format(
            target = target,
        ),
        testonly = True,
        visibility = ["//visibility:public"],
    )
