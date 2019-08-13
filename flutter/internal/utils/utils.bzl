def _restore_label(l):
    """Restore a label struct to a canonical label string."""
    lbl = l.workspace_root
    if lbl.startswith("external/"):
        lbl = lbl.replace("external/", "@")
    return lbl + "//" + l.package + ":" + l.name

# TODO unexport this once init builder args can take care of friends.
def _derive_module_name(ctx):
    """Gets the `module_name` attribute if it's set in the ctx, otherwise derive a unique module name using the elements
    found in the label."""
    module_name = getattr(ctx.attr, "module_name", "")
    if module_name == "":
        module_name = (ctx.label.package.lstrip("/").replace("/", "_") + "-" + ctx.label.name.replace("/", "_"))
    return module_name

def _init_builder_args(ctx, rule_kind, module_name):
    """Initialize an arg object for a task that will be executed by the Kotlin Builder."""
    args = ctx.actions.args()

    return args

# Copied from https://github.com/bazelbuild/bazel-skylib/blob/master/lib/dicts.bzl
# Remove it if we add a dependency on skylib.
def _add_dicts(*dictionaries):
    """Returns a new `dict` that has all the entries of the given dictionaries.
    If the same key is present in more than one of the input dictionaries, the
    last of them in the argument list overrides any earlier ones.
    This function is designed to take zero or one arguments as well as multiple
    dictionaries, so that it follows arithmetic identities and callers can avoid
    special cases for their inputs: the sum of zero dictionaries is the empty
    dictionary, and the sum of a single dictionary is a copy of itself.
    Args:
      *dictionaries: Zero or more dictionaries to be added.
    Returns:
      A new `dict` that has all the entries of the given dictionaries.
    """
    result = {}
    for d in dictionaries:
        result.update(d)
    return result

utils = struct(
    add_dicts = _add_dicts,
    init_args = _init_builder_args,
    restore_label = _restore_label,
    derive_module_name = _derive_module_name,
)
