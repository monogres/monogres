"""e2e testing"""

load("//:utils.bzl", "list_files")

def build_test(package, name):
    list_files(
        name = name,
        target = "@monogres//extensions/%s:%s--tar" % (package, name),
    )

def build_all_test(name, cfg):
    for target in cfg.targets:
        build_test(name, target.name)
