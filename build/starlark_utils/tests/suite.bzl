"""suite.bzl"""

def test_suite(name, tests):
    for test_name, test in tests.items():
        test(name = "%s/%s" % (name, test_name))

    native.test_suite(
        name = name,
        tests = [
            ":%s/%s" % (name, test_name)
            for test_name in tests
        ],
    )
