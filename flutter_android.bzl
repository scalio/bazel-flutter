def flutter_android_appbundle(name):
  """Runs flutter build appbundle.

  The generated file is prefixed with 'small_'.
  """
  native.genrule(
    name = name,
    outs = ["gradle/wrapper/gradle-wrapper.jar"],
    cmd = "pwd; flutter build appbundle",
  )



def flutter_build_tool(ctx, srcs, out):
    cmd = ("flutter.bat build aot "
                + "--target lib/main.dart "
                + "--output-dir buildssss/app/intermediates/flutter/release/android-arm "
                + "--target-platform android-arm --release"
            )
#    cmd = ("flutter.bat build apk"
#            )
    ctx.actions.run_shell(
        outputs = [out],
        command = cmd,
        use_default_shell_env = True,
    )

def _flutter_build_aot_impl(ctx):
    executable_path = "{name}%/{name}".format(name = ctx.label.name)
    executable = ctx.actions.declare_file(executable_path)
    flutter_build_tool(
        ctx,
        srcs = ctx.files.srcs,
        out = executable,
    )
    return [DefaultInfo(
        files = depset([executable]),
        executable = executable,
    )]

flutter_build_aot = rule(
    implementation = _flutter_build_aot_impl,
    attrs = {
        "srcs": attr.label_list(
            allow_files = [".dart"],
            doc = "Source files to compile for the main package of this binary",
        ),
    },
    doc = "...",
    executable = True,
)

def _flutter_build_aot_implsdsd(ctx):
    cmd = ("flutter.bat build aot --suppress-analytics --quiet "
                + "--target lib/main.dart "
                + "--output-dir buildssss/app/intermediates/flutter/release/android-arm "
                + "--target-platform android-arm --release"
            )
    ctx.actions.run_shell(
        outputs = [ctx.actions.declare_file("bazel-out/app/intermediates/flutter/release/android-arm")],
        command = cmd,
        use_default_shell_env = True,
    )

#
#def flutter_build_aot(name, src, **kwargs):
#  """Runs flutter build appbundle.
#
#  The generated file is prefixed with 'small_'.
#  """
#  native.genrule(
#    name = name,
#    srcs = [src],
#    outs = ["bazel-out/app/intermediates/flutter/release/android-arm"],
#    cmd = "flutter build aot --suppress-analytics --quiet --target lib/main.dart --output-dir C:/Users/mig35/Documents/work/projects/ip/scalio/bazelSampleFlutter/bazel-out/app/intermediates/flutter/release/android-arm --target-platform android-arm --release",
#  )