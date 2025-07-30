<!-- Generated with Stardoc: http://skydoc.bazel.build -->

# `declare_outputs`

A Bazel rule to make explicit ("declare") named outputs files from a target
providing an `OutputGroupInfo` with a `gen_dir` attribute that contains the
files (e.g. a `rule_foreign_cc` target).

It copies all the files in `outs` from the `gen_dir` to named outputs, making
them explicitly available for use as `srcs` in other rules.

<a id="declare_outputs"></a>

## declare_outputs

<pre>
load("@monogres//utils:declare_outputs.bzl", "declare_outputs")

declare_outputs(<a href="#declare_outputs-name">name</a>, <a href="#declare_outputs-src">src</a>, <a href="#declare_outputs-outs">outs</a>)
</pre>



**ATTRIBUTES**


| Name  | Description | Type | Mandatory | Default |
| :------------- | :------------- | :------------- | :------------- | :------------- |
| <a id="declare_outputs-name"></a>name |  A unique name for this target.   | <a href="https://bazel.build/concepts/labels#target-names">Name</a> | required |  |
| <a id="declare_outputs-src"></a>src |  -   | <a href="https://bazel.build/concepts/labels">Label</a> | required |  |
| <a id="declare_outputs-outs"></a>outs |  -   | List of strings | required |  |


