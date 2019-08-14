load(
    "//:flutter/internal/defs.bzl",
    _FlutterJvmInfo = "FlutterJvmInfo",
)

load(
    "//:flutter/internal/utils/utils.bzl",
    _utils = "utils",
)

def _partition_srcs(srcs):
    """Partition sources for the jvm aspect."""
    dart_srcs = []

    for f in srcs:
        if f.path.endswith(".dart"):
            dart_srcs.append(f)

    return struct(
        dart = depset(dart_srcs),
        all_srcs = depset(dart_srcs),
    )

def _declare_output_directory(ctx, aspect, dir_name):
    return ctx.actions.declare_directory("_flutter/%s_%s/%s_%s" % (ctx.label.name, aspect, ctx.label.name, dir_name))

def _fold_jars_action(ctx, rule_kind, output_jar, input_jars):
    """Set up an action to Fold the input jars into a normalized ouput jar."""
    args = ctx.actions.args()
    args.add_all([
        "--normalize",
        "--compression",
    ])
    args.add_all([
        "--deploy_manifest_lines",
        "Target-Label: %s" % str(ctx.label),
        "Injecting-Rule-Kind: %s" % rule_kind,
    ])
    args.add("--output", output_jar)
    args.add_all(input_jars, before_each = "--sources")
    ctx.actions.run(
        mnemonic = "FlutterFoldJars",
        outputs = [output_jar],
        executable = ctx.executable._singlejar,
        arguments = [args],
        progress_message = "Merging Flutter output jar %s from %d inputs" % (ctx.label, len(input_jars)),
    )
    return output_jar

def _resource_flutter_jar_action(ctx):
    arch = "android-arm"
    flutter_jar_file = ctx.actions.declare_file("%s/flutter.jar" % arch)

    ctx.actions.run_shell(
        outputs = [flutter_jar_file],
        command = ("cp {flutter_root}/bin/cache/artifacts/engine/{arch}/flutter.jar {flutter_jar_out}").format(
            flutter_root = getattr(ctx.attr, "flutter_root"),
            arch = arch,
            flutter_jar_out = flutter_jar_file.path,
        ),
        progress_message = "Copy flutter jar to path",
        use_default_shell_env = True,
        execution_requirements = {
            "no-sandbox": "1"
        }
    )

    return flutter_jar_file

def _build_aot_action(ctx):
    srcs = _partition_srcs(ctx.files.srcs)
    if not srcs.dart:
        fail("no sources provided")

    resources_aot_output_path = ctx.actions.declare_directory(ctx.label.name + "-aot")

    aot_args = ctx.actions.args()
    aot_args.add("build", "aot")
    aot_args.add("--target", srcs.dart.to_list()[0].path)
    aot_args.add("--target-platform", "android-arm") # todo add platform arch map
    aot_args.add("--suppress-analytics" , "")
    aot_args.add("--output-dir" , resources_aot_output_path.path)
    aot_args.add("--release" , "")

    ctx.actions.run(
        outputs = [resources_aot_output_path],
        executable = ("{flutter_root}/bin/flutter").format(flutter_root = getattr(ctx.attr, "flutter_root")),
        arguments = [aot_args],
        progress_message = "Compiling flutter app aot",
        use_default_shell_env = True,
        execution_requirements = {
            "no-sandbox": "1"
        }
    )

    resources_so_output = ctx.actions.declare_file(ctx.label.name + "-aot-lib/lib/libapp.so")
    so_args = ctx.actions.args()
    so_args.add(resources_aot_output_path.path + "/app.so", resources_so_output.path)

    ctx.actions.run(
        outputs = [resources_so_output],
        inputs = [resources_aot_output_path],
        executable = ("cp"),
        arguments = [so_args],
        progress_message = "CP flutter app so file to out dir",
        use_default_shell_env = True,
        execution_requirements = {
            "no-sandbox": "1"
        }
    )

    return resources_aot_output_path

def _build_bundle_assets_action(ctx):
    srcs = _partition_srcs(ctx.files.srcs)
    if not srcs.dart:
        fail("no sources provided")

    resources_so_output = ctx.actions.declare_directory(ctx.label.name + "-assets/assets")

    args = ctx.actions.args()
    args.add("build", "bundle")
    args.add("--target", srcs.dart.to_list()[0].path)
    args.add("--target-platform", "android-arm") # todo add platform arch map
    args.add("--precompiled" , "")
    args.add("--asset-dir" , resources_so_output.path + "/flutter_assets")
    args.add("--release" , "")

    ctx.actions.run(
        outputs = [resources_so_output],
        executable = ("{flutter_root}/bin/flutter").format(flutter_root = getattr(ctx.attr, "flutter_root")),
        arguments = [args],
        progress_message = "Compiling flutter app assets",
        use_default_shell_env = True,
        execution_requirements = {
            "no-sandbox": "1"
        }
    )

    return resources_so_output

def _build_resourcejar_action(ctx, so_lib_output):
    """sets up an action to build a resource jar for the target being compiled.
    Returns:
        The file resource jar file.
    """
    resources_jar_output = ctx.actions.declare_file(ctx.label.name + "-resources.jar")
    ctx.actions.run_shell(
        mnemonic = "KotlinZipResourceJar",
        inputs = [so_lib_output],
        tools = [ctx.executable._zipper],
        outputs = [resources_jar_output],
        command = "{zipper} -r {resources_jar_output} @{path}".format(
            path = so_lib_output.path,
            resources_jar_output = resources_jar_output.path,
            zipper = ctx.executable._zipper.path,
        ),
        progress_message = "Creating intermediate resource jar %s" % ctx.label,
    )
    return resources_jar_output

def flutter_jvm_compile_action(ctx, rule_kind, output_jar):
    """This macro sets up a compile action for a Kotlin jar.

    Args:
        rule_kind: The rule kind --e.g., `kt_jvm_library`.
        output_jar: The jar file that this macro will use as the output.
    Returns:
        A struct containing the providers JavaInfo (`java`) and `kt` (KtJvmInfo). This struct is not intended to be
        used as a legacy provider -- rather the caller should transform the result.
    """
    srcs = _partition_srcs(ctx.files.srcs)
    if not srcs.dart:
        fail("no sources provided")

    # TODO extract and move this into common. Need to make it generic first.
    friends = []
    deps = [d[JavaInfo] for d in friends + ctx.attr.deps]
    compile_jars = java_common.merge(deps).compile_jars

    module_name = _utils.derive_module_name(ctx)
    friend_paths = depset()

    args = _utils.init_args(ctx, rule_kind, module_name)

    # Collect and prepare plugin descriptor for the worker.
    progress_message = "Merging SO %s { dart: %d }" % (
        ctx.label,
        len(srcs.dart.to_list()),
    )

    return struct(
        java = JavaInfo(
            output_jar = ctx.outputs.jar,
            compile_jar = ctx.outputs.jar,
            deps = deps,
            runtime_deps = [d[JavaInfo] for d in ctx.attr.runtime_deps],
            exports = [d[JavaInfo] for d in getattr(ctx.attr, "exports", [])],
            neverlink = getattr(ctx.attr, "neverlink", False),
        ),
        flutter = _FlutterJvmInfo(
            srcs = ctx.files.srcs,
            module_name = module_name,
            # intelij aspect needs this.
            outputs = struct(
                jars = [struct(
                    class_jar = ctx.outputs.jar,
                    ijar = None,
                )],
            ),
        ),
    )

def flutter_jvm_produce_jar_actions(ctx, rule_kind):
    """Setup The actions to compile a jar and if any resources or resource_jars were provided to merge these in with the
    compilation output.

    Returns:
        see `kt_jvm_compile_action`.
    """

    # The jar that is compiled from sources.
    output_jar = ctx.outputs.jar

    # A list of jars that should be merged with the output_jar, start with the resource jars if any were provided.
    output_merge_list = []

    # If this rule has any resources declared setup a zipper action to turn them into a jar and then add the declared
    # zipper output to the merge list.
    output_merge_list = output_merge_list + [_build_resourcejar_action(ctx, _build_bundle_assets_action(ctx))]
    output_merge_list = output_merge_list + [_resource_flutter_jar_action(ctx)]
    output_merge_list = output_merge_list + [_build_aot_action(ctx)]

    # Setup the compile action.
    return flutter_jvm_compile_action(
        ctx,
        rule_kind = rule_kind,
        output_jar = _fold_jars_action(ctx, rule_kind, output_jar, output_merge_list),
    )