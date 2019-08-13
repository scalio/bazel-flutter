load("//:flutter/flutter.bzl", "flutter_android_library")

flutter_android_library(
    name = "app_android_aot",
    srcs = glob(["lib/main.dart"]),
    flutter_root = "/e/progs/flutter",
)



load("@rules_jvm_external//:defs.bzl", "artifact")
load("@rules_android//android:rules.bzl", "android_library")

package(default_visibility = ["//visibility:private"])
load("@io_bazel_rules_kotlin//kotlin:kotlin.bzl", "kt_android_library")


PACKAGE = "io.scal.flutter_bazel_starter"
MANIFEST = "AndroidManifest.xml"
PATH_TO_APP = "android/app/src/main/"

java_import(
        name = "flutter_jar",
        jars = [
            "bazel-bin/flutter/release/flutter.jar",
        ],
        deps = [
        ]
    )

android_library(
    name = "bazel_flutter",
    custom_package = PACKAGE,
    manifest = PATH_TO_APP + MANIFEST,
    resource_files = glob([PATH_TO_APP + "res/**"]),
    assets = glob(["bazel-bin/flutter/release/assets/**"]),
    assets_dir = "bazel-bin/flutter/release/assets",
    enable_data_binding = False,
    deps = [
        ":app_android_aot",
        ":flutter_jar",
        artifact("androidx.constraintlayout:constraintlayout"),
        artifact("com.google.android.material:material"),
    ],
)

android_library(
    name = "bazel_res",
    custom_package = PACKAGE,
    srcs = glob([PATH_TO_APP + "java/**/*.java"]),
    manifest = PATH_TO_APP + MANIFEST,
    resource_files = glob([PATH_TO_APP + "res/**"]),
    enable_data_binding = False,
    deps = [
        ":bazel_flutter",
        artifact("androidx.constraintlayout:constraintlayout"),
        artifact("com.google.android.material:material"),
    ],
)

kt_android_library(
    name = "bazel_kt",
    srcs = glob([PATH_TO_APP + "kotlin/**/*.kt"]),
    deps = [
        ":bazel_res",
        ":bazel_flutter",
        artifact("androidx.appcompat:appcompat"),
        artifact("androidx.fragment:fragment"),
        artifact("androidx.core:core"),
        artifact("androidx.lifecycle:lifecycle-runtime"),
        artifact("androidx.lifecycle:lifecycle-viewmodel"),
        artifact("androidx.lifecycle:lifecycle-common"),
        artifact("androidx.drawerlayout:drawerlayout"),
        artifact("org.jetbrains.kotlinx:kotlinx-coroutines-core"),
        artifact("org.jetbrains.kotlinx:kotlinx-coroutines-android"),
    ]
)

android_binary(
    name = "bazel",
    manifest = PATH_TO_APP + MANIFEST,
    custom_package = PACKAGE,
    manifest_values = {
        "minSdkVersion": "21",
        "versionCode" : "2",
        "versionName" : "0.2",
        "targetSdkVersion": "29",
    },
    deps = [
        ":bazel_res",
        ":bazel_kt",
        artifact("androidx.appcompat:appcompat"),
    ],
)