"""
Macro to create a rule that maps the given target files to template variables.
"""

def template_variable_info_rule(is_mapped, get_name, other_template_vars = None):
    """
    Returns a rule to make template variables from the files of a target.

    Args:

        is_mapped (function): f(path, target), returns if the path should be
          mapped to a template variable.
        get_name (function): f(path, target), returns the template name onto
          which to map the given path.
        other_template_vars (function, optional): f(context, target), returns
          other template variables.

    Returns:
        template_variable_info (rule)
    """
    other_template_vars = other_template_vars or (lambda context, target: {})

    def template_variable_info_impl(ctx):
        target = ctx.attr.target

        files = target[DefaultInfo].files.to_list()

        if not files:
            return []

        template_variables_ = {
            get_name(file.path, target): file.path
            for file in files
            if is_mapped(file.path, target)
        }

        template_variables_ |= other_template_vars(template_variables_, target)

        return [platform_common.TemplateVariableInfo(template_variables_)]

    return rule(
        implementation = template_variable_info_impl,
        attrs = dict(
            target = attr.label(
                providers = [DefaultInfo],
            ),
        ),
    )
