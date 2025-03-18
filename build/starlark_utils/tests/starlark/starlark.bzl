"""
Starlark codegen unit tests
"""

load("@bazel_skylib//lib:unittest.bzl", "asserts", "unittest")
load("//starlark:starlark.bzl", Starlark = "starlark")
load("//tests:suite.bzl", _test_suite = "test_suite")

_DICT = dict(
    key = [1, 2, {"a": 1}],
    flag = True,
    name = "example",
    a = "{foo}",
)
_DICT[42] = None

def _escape_test_impl(ctx):
    env = unittest.begin(ctx)

    parameters = {
        "": "",
        "\n": "\\n",
        '"foo"': '"foo"',
        "\\e": "\\\\e",
        "foo": "foo",
    }

    for s, expected in parameters.items():
        actual = Starlark.__test__._escape(s)
        asserts.equals(env, expected, actual)

    return unittest.end(env)

escape_test = unittest.make(_escape_test_impl)

def _indent_test_impl(ctx):
    env = unittest.begin(ctx)

    expected = """
   {
      "key": [
         1,
         2,
         {
            "a": 1,
         },
      ],
      "flag": True,
      "name": "example",
      "a": "{foo}",
      "42": None,
   }
    """.strip()
    actual = Starlark.igen(_DICT, indent_count = 1, indent_size = 3)

    asserts.equals(env, expected, actual)

    return unittest.end(env)

indent_test = unittest.make(_indent_test_impl)

def _inline_test_impl(ctx):
    env = unittest.begin(ctx)

    expected = "".join([
        "{",
        '"key": [1, 2, {"a": 1}], ',
        '"flag": True, ',
        '"name": "example", ',
        '"a": "{foo}", ',
        '"42": None',
        "}",
    ])
    actual = Starlark.gen(_DICT)

    asserts.equals(env, expected, actual)

    return unittest.end(env)

inline_test = unittest.make(_inline_test_impl)

## --- list ---------------------------------------------

def _list_empty_test_impl(ctx):
    env = unittest.begin(ctx)

    ll = []
    expected = str(ll)
    actual = Starlark.igen(ll)

    asserts.equals(env, expected, actual)

    return unittest.end(env)

list_empty_test = unittest.make(_list_empty_test_impl)

def _list_1_element_test_impl(ctx):
    env = unittest.begin(ctx)

    ll = ["a"]
    expected = """
[
    "a",
]
    """.strip()
    actual = Starlark.igen(ll)

    asserts.equals(env, expected, actual)

    return unittest.end(env)

list_1_element_test = unittest.make(_list_1_element_test_impl)

def _list_2p_elements_test_impl(ctx):
    env = unittest.begin(ctx)

    ll = ["a", 1]
    expected = """
[
    "a",
    1,
]
    """.strip()
    actual = Starlark.igen(ll)

    asserts.equals(env, expected, actual)

    return unittest.end(env)

list_2p_elements_test = unittest.make(_list_2p_elements_test_impl)

def _list_indent_test_impl(ctx):
    env = unittest.begin(ctx)

    ll = ["a"]
    expected = """
   [
      "a",
   ]
    """.strip()
    actual = Starlark.igen(ll, indent_count = 1, indent_size = 3)

    asserts.equals(env, expected, actual)

    return unittest.end(env)

list_indent_test = unittest.make(_list_indent_test_impl)

def _list_quote_test_impl(ctx):
    env = unittest.begin(ctx)

    ll = ["a"]
    expected = """
[
    a,
]
    """.strip()
    actual = Starlark.igen(ll, quote_strings = False)

    asserts.equals(env, expected, actual)

    return unittest.end(env)

list_quote_test = unittest.make(_list_quote_test_impl)

## --- dict ---------------------------------------------

def _dict_empty_test_impl(ctx):
    env = unittest.begin(ctx)

    d = {}
    expected = str(d)
    actual = Starlark.igen(d)

    asserts.equals(env, expected, actual)

    return unittest.end(env)

dict_empty_test = unittest.make(_dict_empty_test_impl)

def _dict_1_element_test_impl(ctx):
    env = unittest.begin(ctx)

    d = {"a": "foo"}
    expected = """
{
    "a": "foo",
}
    """.strip()
    actual = Starlark.igen(d)

    asserts.equals(env, expected, actual)

    return unittest.end(env)

dict_1_element_test = unittest.make(_dict_1_element_test_impl)

def _dict_2p_elements_test_impl(ctx):
    env = unittest.begin(ctx)

    d = {"a": "foo", 1: "bar"}
    expected = """
{
    "a": "foo",
    "1": "bar",
}
    """.strip()
    actual = Starlark.igen(d)

    asserts.equals(env, expected, actual)

    return unittest.end(env)

dict_2p_elements_test = unittest.make(_dict_2p_elements_test_impl)

def _dict_indent_test_impl(ctx):
    env = unittest.begin(ctx)

    d = {"a": "foo"}
    expected = """
   {
      "a": "foo",
   }
    """.strip()
    actual = Starlark.igen(d, indent_count = 1, indent_size = 3)

    asserts.equals(env, expected, actual)

    return unittest.end(env)

dict_indent_test = unittest.make(_dict_indent_test_impl)

def _dict_quote_test_impl(ctx):
    env = unittest.begin(ctx)

    d = {"a": "foo"}
    expected = """
{
    a: foo,
}
    """.strip()
    actual = Starlark.igen(d, quote_strings = False, quote_keys = False)

    asserts.equals(env, expected, actual)

    return unittest.end(env)

dict_quote_test = unittest.make(_dict_quote_test_impl)

## --- depset ---------------------------------------------

def _depset_test_impl(ctx):
    env = unittest.begin(ctx)

    ds = depset([1, 2, 3])
    expected = """
depset([
    1,
    2,
    3,
])
    """.strip()
    actual = Starlark.igen(ds)

    asserts.equals(env, expected, actual)

    expected = "depset([1, 2, 3])"

    actual = Starlark.gen(ds)

    asserts.equals(env, expected, actual)

    return unittest.end(env)

depset_test = unittest.make(_depset_test_impl)

## --- struct ---------------------------------------------

def _struct_test_impl(ctx):
    env = unittest.begin(ctx)

    s = struct(foo = "foo", bar = 42)
    expected = """
struct(
    foo = "foo",
    bar = 42,
)
    """.strip()
    actual = Starlark.igen(s)

    asserts.equals(env, expected, actual)

    expected = 'struct(foo = "foo", bar = 42)'

    actual = Starlark.gen(s)

    asserts.equals(env, expected, actual)

    return unittest.end(env)

struct_test = unittest.make(_struct_test_impl)

## --- other helpers ---------------------------------------------

def _assignments_test_impl(ctx):
    env = unittest.begin(ctx)

    def test(assignments):
        # inline (default)
        expected = 'FOO = 42, BAR = "foobar"'
        actual = Starlark.assignments(assignments)

        asserts.equals(env, expected, actual)

        # multi-line
        expected = """
FOO = 42
BAR = "foobar"
        """.strip()
        actual = Starlark.assignments(assignments, inline = False)

        asserts.equals(env, expected, actual)

    # test all types
    params = [
        dict(FOO = 42, BAR = "foobar"),
        [("FOO", 42), ["BAR", "foobar"]],
        (["FOO", 42], ("BAR", "foobar")),
        (("FOO", 42), ("BAR", "foobar")),
    ]

    for assignments in params:
        test(assignments)

    return unittest.end(env)

assignments_test = unittest.make(_assignments_test_impl)

def _load_args_test_impl(ctx):
    env = unittest.begin(ctx)

    expected = 'load("//foo:bar.bzl", "FOO", "foobar")'
    actual = Starlark.load_("//foo:bar.bzl", "FOO", "foobar")

    asserts.equals(env, expected, actual)

    return unittest.end(env)

load_args_test = unittest.make(_load_args_test_impl)

def _load_args_and_kwargs_test_impl(ctx):
    env = unittest.begin(ctx)

    expected = 'load("//foo:bar.bzl", "FOO", _foobar = "foobar")'
    actual = Starlark.load_("//foo:bar.bzl", "FOO", _foobar = "foobar")

    asserts.equals(env, expected, actual)

    return unittest.end(env)

load_args_and_kwargs_test = unittest.make(_load_args_and_kwargs_test_impl)

TEST_SUITE_NAME = "starlark"

TEST_SUITE_TESTS = dict(
    escape = escape_test,
    indent = indent_test,
    inline = inline_test,
    # list
    list_empty = list_empty_test,
    list_1_element = list_1_element_test,
    list_2p_elements = list_2p_elements_test,
    list_quote = list_quote_test,
    list_indent = list_indent_test,
    # dict
    dict_empty = dict_empty_test,
    dict_1_element = dict_1_element_test,
    dict_2p_elements = dict_2p_elements_test,
    dict_quote = dict_quote_test,
    dict_indent = dict_indent_test,
    # depset
    depset = depset_test,
    # struct
    struct = struct_test,
    # other
    assignments = assignments_test,
    load_args = load_args_test,
    load_args_and_kwargs = load_args_and_kwargs_test,
)

test_suite = lambda: _test_suite(TEST_SUITE_NAME, TEST_SUITE_TESTS)
