"""mock.bzl"""

def _fail(msg):
    return msg

def _print(logs):
    return lambda msg: logs.append(msg)

mock = struct(
    fail = _fail,
    print = _print,
)
