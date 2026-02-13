# Build options

## Triggers

Builds can be triggered through:

1. Manual workflow dispatch. This should be used only for testing or
   in exceptional cases.
2. Pushing a tag that starts with 'v', for example, v1.2.3. This
   should be the approach for production releases. For example:
   `git tag -a v1.2.3 -m "Release v1.2.3"`.

## Build process for binaries

We set the environment variable CGO_ENABLED to 0 to build static
binaries and set the variable to 1 for building dynamically linked
binaries. The binaries are built on `ubuntu-latest` runner for `amd64`
and on `ubuntu-24.02-arm` for `arm64`. The `Makefile` was modified to
use `ARCH` environment variable to compile for different architecture
other than the host architecture.

We use the `matrix` strategy in Github action to build for multiple
architectures: `amd64` and `arm64`.

## Build process for packages

For building packages for different Linux distributions for different
architectures, we use container images on native architecture runners
for the Linux distributions to get the maximum compatibility and
speed as compared to cross compilation or emulation.

We use the `matrix` strategy in Github action to build for multiple
distributions across multiple architectures.

## Build process for container images

For building non-FIPS container image, we use the `golang:1.26-alpine`
image as the builder image to compile a statically linked binary and
use a scratch image as base for the final image.

For building the FIPS container image, we use `golang:1.26-trixie`
image as the builder image. This is because FIPS compliance requires
glibc based distribution. Additionally, FIPS compliance requires usage
of BoringCrypto implementation which is available only for `amd64`.

## Build artifacts

We build the following artifacts as part of this Github action
workflow.

- statically linked httpbin binary for Ubuntu (amd64)
- statically linked httpbin binary for Ubuntu (arm64)
- dynamically linked httpbin binary for Ubuntu (amd64)
- dynamically linked httpbin binary for Ubuntu (arm64)
- httpbin RPM for RHEL8 (amd64)
- httpbin RPM for RHEL8 (arm64)
- httpbin RPM for RHEL9 (amd64)
- httpbin RPM for RHEL9 (arm64)
- httpbin DEB for Debian 12 (old stable) (amd64)
- httpbin DEB for Debian 12 (old stable) (arm64)
- httpbin DEB for Debian 13 (stable) (amd64)
- httpbin DEB for Debian 13 (stable) (arm64)

In addition to these, we build container images that are pushed to
Github container registry.

## Extending github action workflow

Q. How do I add new platforms to build packages for?

A. Update the strategy matrix in build_packages: section in the
   workflow. The configuration for each platform requires the
   following:
   - distro (name of the docker image on hub.docker.com)
   - distro_name (name of the distribution)
   - package_type (type of the package: deb or rpm)
   - install_test_cmd (command to install packages on the distribution)
   - arch (architecture)
   - runner (name of the github runner)

Q. How do I add new architectures to build statically linked and
   dynamically linked binaries for?

A. Update the strategy matrix in the build-binaries: section in the
   workflow. The configuration for each architecture requires the
   following:
   - arch (architecture; used by go build and so should match GOARCH)
   - runner (name of the github runner)

## Triggering releases for multiple major versions

Assuming that we have multiple release branches e.g. release-5.x,
release-6.x, release-7.x, the current Github action workflow will
still work if the release builds are triggered by creating tags in the
respective branches. For example, when we want to create a release
v5.1.3, we create a corresponding tag in the release-5.x branch. The
github action workflow will checkout the commit ID associated with the
tag, build the artifacts and upload those to Github releases. There
will be no change required in the workflow.

## Future development

1. Investigate why goreleaser did not work.
