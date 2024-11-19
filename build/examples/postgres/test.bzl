"""e2e testing"""

load("//:utils.bzl", "list_files")

def build_test(name):
    list_files(
        name = name,
        target = "@monogres//postgres:%s" % name,
    )

def build_all_test(name, cfg):
    for target in cfg.targets:
        build_test(target.name)
