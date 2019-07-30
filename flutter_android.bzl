def _flutter_build_aot_and_bundle(ctx, src, out, arch, flutter_root):
    aot_bundle_path = "app/intermediates/flutter/release/{arch}".format(
            arch = ctx.attr.arch,
        )
    cmd_aot_tpl = (" {flutter_root}/bin/flutter.bat build aot --suppress-analytics " # --quiet
                + "--target {src} "
                + "--output-dir {out} "
                + "--target-platform android-arm "
                + "--release"
        )
    cmd_aot = cmd_aot_tpl.format(
            flutter_root = flutter_root,
            out = aot_bundle_path,
            src = src.path,
#            arch = arch, todo add platform arch map
        )
    cmd_bundle_tpl = (" {flutter_root}/bin/flutter.bat build bundle "
                + "--target {src} "
                + "--target-platform android-arm "
                + "--precompiled "
                + "--asset-dir {out} "
                + "--release"
        )
    cmd_bundle = cmd_bundle_tpl.format(
            flutter_root = flutter_root,
            out = aot_bundle_path + "/flutter_assets",
            src = src.path,
#            arch = arch, todo add platform arch map
        )

    cmd_cp_app_so_tpl = ("mkdir -p {solib_out}; cp {solib_in}/app.so {solib_out}/libapp.so")
    cmd_cp_app_so = cmd_cp_app_so_tpl.format(
            solib_in = aot_bundle_path,
            solib_out = (out.path + "/lib/{arch}").format(arch = arch),
        )
    cmd_cp_assets_tpl = ("mkdir -p {assets_out}; cp -R {assets_in} {assets_out}")
    cmd_cp_assets = cmd_cp_assets_tpl.format(
            assets_in = aot_bundle_path + "/flutter_assets",
            assets_out = out.path + "/assets",
        )

    cmd_cp_flutter_jar_tpl = ("cp {flutter_root}/bin/cache/artifacts/engine/android-arm/flutter.jar {flutter_jar_out}")
    cmd_cp_flutter_jar = cmd_cp_flutter_jar_tpl.format(
            flutter_root = flutter_root,
#            arch = arch, todo add platform arch map
            flutter_jar_out = out.path,
        )

    ctx.actions.run_shell(
        outputs = [out],
        command = cmd_aot + "; " + cmd_bundle + "; " + cmd_cp_app_so + "; " + cmd_cp_assets + "; " + cmd_cp_flutter_jar,
        progress_message = "Compiling flutter app so file and assets",
        use_default_shell_env = True,
        execution_requirements = {
            "no-sandbox": "1"
        }
    )

def _flutter_build_impl(ctx):
    result_path = "app/result/flutter/release"
    executable = ctx.actions.declare_directory(result_path)
    _flutter_build_aot_and_bundle(
        ctx,
        src = ctx.files.src[0],
        out = executable,
        arch = ctx.attr.arch,
        flutter_root = ctx.attr.flutter_root,
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
            mandatory = True,
            doc = "Source files to compile for the main package of this binary",
        ),
        "flutter_root": attr.string(
            mandatory = True,
            doc = "Source files to compile for the main package of this binary",
        ),
    },
    doc = "...",
    executable = True,
)

#flutter_build_all(
#    name = "app_android_aot",
#    src = "lib/main.dart",
#    arch = "armeabi-v7a",
#)