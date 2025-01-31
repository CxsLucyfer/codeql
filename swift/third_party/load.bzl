load("@bazel_tools//tools/build_defs/repo:http.bzl", "http_archive")

_swift_prebuilt_version = "swift-5.7.3-RELEASE.142"
_swift_sha_map = {
    "Linux-X64": "398d8de54c8775c939dff95ed5bb0e04a9308a1982b4c1900cd4a5d01223f63b",
    "macOS-ARM64": "397dd67ea99b9c9455794c6eb0f1664b6179fe542c7c1d3010314a3e8a905ae4",
    "macOS-X64": "4b9d8e4e89f16a7c1e7edc7893aa189b37d5b4412be724a86ef59c49d11a6f75",
}

_swift_arch_map = {
    "Linux-X64": "linux",
    "macOS-X64": "darwin_x86_64",
}

def _get_label(workspace_name, package, target):
    return "@%s//swift/third_party/%s:%s" % (workspace_name, package, target)

def _get_build(workspace_name, package):
    return _get_label(workspace_name, package, "BUILD.%s.bazel" % package)

def _get_patch(workspace_name, package, patch):
    return _get_label(workspace_name, package, "patches/%s.patch" % patch)

def _github_archive(*, name, workspace_name, repository, commit, sha256 = None, patches = None):
    github_name = repository[repository.index("/") + 1:]
    patches = [_get_patch(workspace_name, name, p) for p in patches or []]
    http_archive(
        name = name,
        url = "https://github.com/%s/archive/%s.zip" % (repository, commit),
        strip_prefix = "%s-%s" % (github_name, commit),
        build_file = _get_build(workspace_name, name),
        sha256 = sha256,
        patch_args = ["-p1"],
        patches = patches,
    )

def load_dependencies(workspace_name):
    for repo_arch, arch in _swift_arch_map.items():
        sha256 = _swift_sha_map[repo_arch]

        http_archive(
            name = "swift_prebuilt_%s" % arch,
            url = "https://github.com/dsp-testing/codeql-swift-artifacts/releases/download/%s/swift-prebuilt-%s.zip" % (
                _swift_prebuilt_version,
                repo_arch,
            ),
            build_file = _get_build(workspace_name, "swift-llvm-support"),
            sha256 = sha256,
            patch_args = ["-p1"],
            patches = [],
        )

    _github_archive(
        name = "picosha2",
        workspace_name = workspace_name,
        repository = "okdshin/PicoSHA2",
        commit = "27fcf6979298949e8a462e16d09a0351c18fcaf2",
        sha256 = "d6647ca45a8b7bdaf027ecb68d041b22a899a0218b7206dee755c558a2725abb",
    )

    _github_archive(
        name = "binlog",
        workspace_name = workspace_name,
        repository = "morganstanley/binlog",
        commit = "3fef8846f5ef98e64211e7982c2ead67e0b185a6",
        sha256 = "f5c61d90a6eff341bf91771f2f465be391fd85397023e1b391c17214f9cbd045",
    )
