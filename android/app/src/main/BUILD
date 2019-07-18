load("@rules_jvm_external//:defs.bzl", "artifact")
load("@rules_android//android:rules.bzl", "android_library")

package(default_visibility = ["//visibility:private"])
load("@io_bazel_rules_kotlin//kotlin:kotlin.bzl", "kt_android_library")


PACKAGE = "io.scal.flutter_bazel_starter"
MANIFEST = "AndroidManifest.xml"

android_library(
    name = "bazel_res",
    custom_package = PACKAGE,
    manifest = MANIFEST,
    resource_files = glob(["res/**"]),
    enable_data_binding = False,
    deps = [
        artifact("androidx.constraintlayout:constraintlayout"),
        artifact("com.google.android.material:material"),
    ],
)

android_library(
    name = "bazel_java",
    custom_package = PACKAGE,
    manifest = MANIFEST,
    srcs = glob(["java/**/*.java"]),
    enable_data_binding = False,
    deps = [
        artifact("flutter:flutter"),
        artifact("androidx.constraintlayout:constraintlayout"),
        artifact("com.google.android.material:material"),
    ],
)

kt_android_library(
    name = "bazel_kt",
    srcs = glob(["kotlin/**/*.kt"]),
    deps = [
        ":bazel_res",
        artifact("flutter:flutter"),
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
    manifest = MANIFEST,
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
        ":bazel_java",
        artifact("androidx.appcompat:appcompat"),
    ],
)