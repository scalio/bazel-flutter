load("@bazel_tools//tools/build_defs/repo:http.bzl", "http_archive")

android_sdk_repository(
    name = "androidsdk",
    api_level = 29,
    build_tools_version = "29.0.0"
)

http_archive(
    name = "rules_android",
    urls = ["https://github.com/bazelbuild/rules_android/archive/v0.1.1.zip"],
    sha256 = "cd06d15dd8bb59926e4d65f9003bfc20f9da4b2519985c27e190cddc8b7a7806",
    strip_prefix = "rules_android-0.1.1",
)

RULES_JVM_EXTERNAL_TAG = "2.2"
RULES_JVM_EXTERNAL_SHA = "f1203ce04e232ab6fdd81897cf0ff76f2c04c0741424d192f28e65ae752ce2d6"

http_archive(
    name = "rules_jvm_external",
    strip_prefix = "rules_jvm_external-%s" % RULES_JVM_EXTERNAL_TAG,
    sha256 = RULES_JVM_EXTERNAL_SHA,
    url = "https://github.com/bazelbuild/rules_jvm_external/archive/%s.zip" % RULES_JVM_EXTERNAL_TAG,
)

load("@rules_jvm_external//:defs.bzl", "maven_install")

maven_install(
    artifacts = [
        "flutter:flutter:0.0.7",
        "androidx.appcompat:appcompat:1.0.2",
        "androidx.fragment:fragment:1.0.0",
        "androidx.core:core:1.0.1",
        "androidx.lifecycle:lifecycle-runtime:2.0.0",
        "androidx.lifecycle:lifecycle-viewmodel:2.0.0",
        "androidx.lifecycle:lifecycle-common:2.0.0",
        "androidx.drawerlayout:drawerlayout:1.0.0",
        "androidx.constraintlayout:constraintlayout:1.1.3",
        "com.google.android.material:material:1.0.0",
        "org.jetbrains.kotlinx:kotlinx-coroutines-core:1.3.0-M2",
        "org.jetbrains.kotlinx:kotlinx-coroutines-android:1.1.1"
    ],
    repositories = [
        "https://maven.google.com",
        "https://jcenter.bintray.com",
    ],
    fetch_sources = True,
)

load("@bazel_tools//tools/build_defs/repo:http.bzl", "http_archive")

rules_kotlin_version = "VERSION_0.1"
rules_kotlin_compiler_release = {
    "urls": [
        "https://github.com/JetBrains/kotlin/releases/download/v1.3.41/kotlin-compiler-1.3.41.zip",
    ],
    "sha256": "c44ab6866895606e408b60934ebe45d4befcbc33ea0e4ea73c4b3b89ad770132",
}

http_archive(
    name = "io_bazel_rules_kotlin",
    urls = ["https://github.com/scalio/rules_kotlin/archive/%s.zip" % rules_kotlin_version],
    type = "zip",
    strip_prefix = "rules_kotlin-%s" % rules_kotlin_version,
    sha256 = "7a463fa65b49fb686ad0e24eca7a4a8f6dc884bb7392ad8dcbfe44e0616091e5"
)

load("@io_bazel_rules_kotlin//kotlin:kotlin.bzl", "kotlin_repositories", "kt_register_toolchains")
kotlin_repositories(compiler_release = rules_kotlin_compiler_release)
kt_register_toolchains()