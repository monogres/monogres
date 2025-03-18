"""
# Starlark source code generation.

This module provides functions for converting native Starlark-compatible values
(e.g., `dict`, `list`, `struct`, `depset`) into valid Starlark source code,
either as compact strings or with readable indentation.

It's useful for code generation tasks such as emitting `.bzl` files or `BUILD`
snippets programmatically.

The `starlark` module has the following functions:
- `gen(value, ...)`: Generate compact single-line Starlark code.
- `igen(value, ...)`: Generate indented multi-line Starlark string.
- `assignments(assignments, ...)`: Generate `key = value` assignments.
- `load_(label, *args, **kwargs)`: Generate a Starlark `load()` statement.
"""

__MAX_ITERATIONS__ = 2 << 31 - 2

_BRACKETS = {
    "close": {
        "depset_list": "])",
        "dict": "}",
        "list": "]",
        "ltda": "@",
        "struct_dict": ")",
        "tuple": ")",
    },
    "open": {
        "depset_list": "depset([",
        "dict": "{",
        "list": "[",
        "ltda": "@",
        "struct_dict": "struct(",
        "tuple": "(",
    },
}

def _escape(s):
    return s.replace("\\", "\\\\").replace("\n", "\\n")

def _gen(
        value,
        indent = False,
        indent_count = 0,
        indent_size = 4,
        quote_strings = True,
        quote_keys = True,
        ltd_as_assignments = False):
    """
    Generates a Starlark source string representation of a value.

    Supports nested data structures, including `list`, `tuple`, `dict`,
    `depset`, and `struct`, and applies quoting/formatting as configured.

    Args:
        value: The value to render. Can be any Starlark-compatible type.
        indent (bool): If `True`, pretty-print with indentation.
        indent_count (int): Base indentation level.
        indent_size (int): Number of spaces per indent level.
        quote_strings (bool): Whether to quote `string` values.
        quote_keys (bool): Whether to quote `dict` keys.
        ltd_as_assignments (bool): If `True`, render dicts using `=` instead of `:`.

    Returns:
        A Starlark-compatible source string.
    """
    result = []

    stack = [(value, type(value), None)]

    for i in range(__MAX_ITERATIONS__):
        if not stack:
            break

        if i == __MAX_ITERATIONS__:
            msg = "starlark.gen: __MAX_ITERATIONS__ reached trying to codegen: %r"
            fail(msg % value)

        current, current_type, context = stack.pop()

        if current_type in ("NoneType", "int", "float", "bool"):
            result.append(str(current))

        elif current_type == "string":
            v = _escape(current)
            result.append("%r" % v if quote_strings else "%s" % v)

        elif current_type in ("list", "tuple", "dict", "depset_list", "struct_dict"):
            brackets = "ltda" if ltd_as_assignments else current_type

            if context == None and not current:
                result.append(_BRACKETS["open"][brackets])
                result.append(_BRACKETS["close"][brackets])

            elif context == None and current:
                if current_type in ("dict", "struct_dict"):
                    current = current.items()

                result.append(_BRACKETS["open"][brackets])

                if indent:
                    indent_count += 1

                stack.append((None, current_type, "close"))

                items = [(item, current_type, "item") for item in current]
                stack.extend(reversed(items))

            elif context == "item":
                if result[-1] != _BRACKETS["open"][brackets]:
                    result.append(",\n" if indent else ", ")
                elif indent:
                    result.append("\n")

                if current_type in ("dict", "struct_dict"):
                    k, v = current

                    if indent:
                        tab = " " * indent_size
                        result.append(tab * indent_count)

                    if ltd_as_assignments or current_type == "struct_dict":
                        sep = " = "
                    else:
                        sep = ": "

                    if quote_keys and current_type != "struct_dict":
                        k = "%r" % str(k)
                    else:
                        k = "%s" % str(k)

                    result.append("%s%s" % (k, sep))

                    current = v
                elif indent and result[-1] != _BRACKETS["open"][brackets]:
                    tab = " " * indent_size
                    result.append(tab * indent_count)

                stack.append((current, type(current), None))

            elif context == "close":
                if indent:
                    result.append(",\n")
                    indent_count -= 1

                    tab = " " * indent_size
                    result.append(tab * indent_count)

                result.append(_BRACKETS["close"][brackets])

        elif current_type == "depset":
            stack.append((current.to_list(), "depset_list", None))

        elif current_type == "struct":
            struct_dict = {
                key: getattr(current, key)
                for key in reversed(dir(current))
                if key != "to_json" and key != "to_proto"
            }
            stack.append((struct_dict, "struct_dict", None))

        else:
            fail("Unsupported type: %s" % current_type)

    return "".join(result)

def _assignments(assignments, inline = True, quote_values = True):
    """
    Generates a Starlark assignment strings from a `dict` or `list` of key-value pairs.

    Args:
        assignments: A `dict`, `list` of 2-tuples, or `tuple` of 2-tuples.
        inline (bool): If `True`, return a single-line comma-separated list. If
            `False`, return a newline-separated block.
        quote_values (bool): If `True`, quote string values.

    Returns:
        A string of the form `key1 = value1, key2 = value2, ...`.
    """
    sep = ", " if inline else "\n"

    if type(assignments) == "dict":
        items = assignments.items()
    elif type(assignments) in ("list", "tuple"):
        items = assignments
    else:
        fail("Invalid assignments type: %s" % type(assignments))

    return sep.join([
        ("%s = %r" if quote_values else "%s = %s") % (k, v)
        for k, v in items
    ])

def _load(*args, **kwargs):
    """
    Generates a Starlark `load()` statement.

    Args:
        *args: Positional arguments — first must be the label of the file,
            followed by symbols to import.
        **kwargs: Keyword arguments for symbol renaming (e.g., `alias =
            "actual"`).

    Returns:
        A valid Starlark `load()` statement as a string.
    """
    load_ = [", ".join(["%r" % arg for arg in args])]

    kwargs_ = _assignments(kwargs)
    if kwargs_:
        load_.append(kwargs_)

    return "load(%s)" % ", ".join(load_)

starlark = struct(
    gen = _gen,
    igen = lambda value, **kwargs: _gen(value, indent = True, **kwargs),
    assignments = _assignments,
    load_ = _load,
    __test__ = struct(
        _escape = _escape,
    ),
)
