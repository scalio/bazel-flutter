load(
    "//:flutter/internal/defs.bzl",
    _FlutterJvmInfo = "FlutterJvmInfo",
)
load(
    "//:flutter/internal/jvm/impl.bzl",
    _flutter_jvm_library_impl = "flutter_jvm_library_impl",
)

load("//:flutter/internal/utils/utils.bzl", "utils")

_implicit_deps = {
    "_singlejar": attr.label(
        executable = True,
        cfg = "host",
        default = Label("@bazel_tools//tools/jdk:singlejar"),
        allow_files = True,
    ),
    "_zipper": attr.label(
        executable = True,
        cfg = "host",
        default = Label("@bazel_tools//tools/zip:zipper"),
        allow_files = True,
    ),
    "_java_runtime": attr.label(
        default = Label("@bazel_tools//tools/jdk:current_java_runtime"),
    ),
    "_java_stub_template": attr.label(
        cfg = "host",
        default = Label("@kt_java_stub_template//file"),
    ),
}

_common_attr = utils.add_dicts(
    _implicit_deps,
    {
        "srcs": attr.label_list(
            doc = """The list of source files that are processed to create the target, this can contain only dart files.""",
            default = [],
            allow_files = [".dart"],
        ),
        "flutter_root": attr.string(
            doc = """Flutter execution path""",
        ),
        "deps": attr.label_list(
            doc = """A list of dependencies of this rule.See general comments about `deps` at
        [Attributes common to all build rules](https://docs.bazel.build/versions/master/be/common-definitions.html#common-attributes).""",
            providers = [
            ],
            allow_files = False,
        ),
        "runtime_deps": attr.label_list(
            doc = """Libraries to make available to the final binary or test at runtime only. Like ordinary deps, these will
        appear on the runtime classpath, but unlike them, not on the compile-time classpath.""",
            default = [],
            allow_files = False,
        ),
        "resources": attr.label_list(
            doc = """A list of files that should be include in a Java jar.""",
            default = [],
            allow_files = True,
        ),
        "resource_strip_prefix": attr.string(
            doc = """The path prefix to strip from Java resources, files residing under common prefix such as
        `src/main/resources` or `src/test/resources` will have stripping applied by convention.""",
            default = "",
        ),
        "resource_jars": attr.label_list(
            doc = """Set of archives containing Java resources. If specified, the contents of these jars are merged into
        the output jar.""",
            default = [],
        ),
        "data": attr.label_list(
            doc = """The list of files needed by this rule at runtime. See general comments about `data` at
        [Attributes common to all build rules](https://docs.bazel.build/versions/master/be/common-definitions.html#common-attributes).""",
            allow_files = True,
        ),
        "module_name": attr.string(
            doc = """The name of the module, if not provided the module name is derived from the label. --e.g.,
        `//some/package/path:label_name` is translated to
        `some_package_path-label_name`.""",
            mandatory = False,
        ),
    },
)

_lib_common_attr = utils.add_dicts(_common_attr, {
    "exports": attr.label_list(
        doc = """Exported libraries.

        Deps listed here will be made available to other rules, as if the parents explicitly depended on
        these deps. This is not true for regular (non-exported) deps.""",
        default = [],
        providers = [JavaInfo],
    ),
    "neverlink": attr.bool(
        doc = """If true only use this library for compilation and not at runtime.""",
        default = False,
    ),
})

_common_outputs = dict(
    jar = "%{name}.jar",
    jdeps = "%{name}.jdeps",
    # The params file, declared here so that validate it can be validated for testing.
    #    jar_2_params = "%{name}.jar-2.params",
    srcjar = "%{name}-sources.jar",
)

flutter_jvm_library = rule(
    doc = """This rule compiles and links Flutter Dart sources into a .jar file.""",
    attrs = _lib_common_attr,
    outputs = _common_outputs,
    implementation = _flutter_jvm_library_impl,
    provides = [JavaInfo, _FlutterJvmInfo],
)
