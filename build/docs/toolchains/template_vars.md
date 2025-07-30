<!-- Generated with Stardoc: http://skydoc.bazel.build -->

Macro to create a rule that maps the given target files to template variables.

<a id="template_variable_info_rule"></a>

## template_variable_info_rule

<pre>
load("@monogres//toolchains:template_vars.bzl", "template_variable_info_rule")

template_variable_info_rule(<a href="#template_variable_info_rule-is_mapped">is_mapped</a>, <a href="#template_variable_info_rule-get_name">get_name</a>, <a href="#template_variable_info_rule-other_template_vars">other_template_vars</a>)
</pre>

Returns a rule to make template variables from the files of a target.

**PARAMETERS**


| Name  | Description | Default Value |
| :------------- | :------------- | :------------- |
| <a id="template_variable_info_rule-is_mapped"></a>is_mapped |  f(path, target), returns if the path should be mapped to a template variable.   |  none |
| <a id="template_variable_info_rule-get_name"></a>get_name |  f(path, target), returns the template name onto which to map the given path.   |  none |
| <a id="template_variable_info_rule-other_template_vars"></a>other_template_vars |  f(context, target), returns other template variables.   |  `None` |

**RETURNS**

template_variable_info (rule)


