load(
    "//:flutter/internal/jvm/jvm.bzl",
    _flutter_jvm_library = "flutter_jvm_library",
)

def _flutter_android_artifact(name, flutter_root, srcs = [], deps = [], **kwargs):
    """Delegates Android related build attributes to the native rules but uses the Kotlin builder to compile Java and
    Kotlin srcs. Returns a sequence of labels that a wrapping macro should export.
    """
    base_name = name + "_base"
    flutter_name = name + "_flutter"

    base_deps = deps + ["@io_bazel_rules_kotlin//kotlin/internal/jvm:android_sdk"]

    native.android_library(
        name = base_name,
        visibility = ["//visibility:private"],
        exports = base_deps,
        **kwargs
    )
    _flutter_jvm_library(
        name = flutter_name,
        srcs = srcs,
        deps = base_deps + [base_name],
        visibility = ["//visibility:private"],
    )
    return [base_name, flutter_name]

def flutter_android_library(name, exports = [], visibility = None, **kwargs):
    """Creates an Android sandwich library. `srcs`, `deps`, `plugins` are routed to `flutter_jvm_library` the other android
    related attributes are handled by the native `android_library` rule.
    """
    native.android_library(
        name = name,
        exports = exports + _flutter_android_artifact(name, **kwargs),
        visibility = visibility,
    )
