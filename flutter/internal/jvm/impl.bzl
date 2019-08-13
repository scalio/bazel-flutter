load(
    "//:flutter/internal/jvm/compile.bzl",
    _flutter_jvm_produce_jar_actions = "flutter_jvm_produce_jar_actions",
)
load(
    "//:flutter/internal/defs.bzl",
    _FlutterJvmInfo = "FlutterJvmInfo",
)

def _make_providers(ctx, providers, transitive_files = depset(order = "default")):
    return struct(
        flutter = providers.flutter,
        providers = [
            providers.flutter,
            providers.java,
            DefaultInfo(
                files = depset([ctx.outputs.jar]),
                runfiles = ctx.runfiles(
                    transitive_files = transitive_files,
                    collect_default = True,
                ),
            ),
        ],
    )

def flutter_jvm_library_impl(ctx):
    return _make_providers(
        ctx,
        _flutter_jvm_produce_jar_actions(ctx, "flutter_jvm_library"),
    )
