"""e2e testing"""

load("//:utils.bzl", "list_files")

def build_test(name):
    list_files(
        name = name,
        target = "@monogres//postgres:%s" % name,
    )
