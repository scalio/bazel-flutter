def _flutter_build_aot(ctx, src, out, arch):
    cmd_aot_tpl = (" flutter.bat build aot --suppress-analytics --quiet "
                + "--target lib/main.dart "
                + "--output-dir {out} "
                + "--target-platform android-arm "
                + "--release"
            )
    cmd_aot = cmd_aot_tpl.format(
            out = out.path,
            src = src,
#            arch = arch, todo add platform arch map
        )
    cmd_bundle_tpl = (" flutter.bat build bundle "
                + "--target lib/main.dart "
                + "--target-platform android-arm "
                + "--precompiled "
                + "--asset-dir {out} "
                + "--release"
            )
    cmd_bundle = cmd_bundle_tpl.format(
            out = out.path + "/flutter_assets",
            src = src,
#            arch = arch, todo add platform arch map
        )
    ctx.actions.run_shell(
        outputs = [out],
        command = cmd_aot + "; " + cmd_bundle,
        use_default_shell_env = True,
    )


def _flutter_build_impl(ctx):
    executable_path = "app/intermediates/flutter/release/{arch}".format(
            arch = ctx.attr.arch,
        )
    executable = ctx.actions.declare_directory(executable_path)
    _flutter_build_aot(
        ctx,
        src = ctx.files.src,
        out = executable,
        arch = ctx.attr.arch,
    )
    return [DefaultInfo(
        files = depset([executable]),
        executable = executable,
    )]

flutter_build = rule(
    implementation = _flutter_build_impl,
    attrs = {
        "src": attr.label(
            allow_files = [".dart"],
            doc = "Source files to compile for the main package of this binary",
        ),
        "arch": attr.string(
            default = "armeabi-v7a",
            doc = "Source files to compile for the main package of this binary",
        ),
    },
    doc = "...",
    executable = True,
)

def flutter_build_aot_2(name, src, **kwargs):
  """Runs flutter build appbundle.

  The generated file is prefixed with 'small_'.
  """
  native.genrule(
    name = name,
    srcs = [src],
    outs = ["bazelssss/app/intermediates/flutter/release/android-arm"],
    tags = ["no-ide"],
    cmd = " flutter.bat build aot --suppress-analytics --quiet --target $< --output-dir bazelssss/app/intermediates/flutter/release/android-arm --target-platform android-arm --release",
  )