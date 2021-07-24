#!/bin/bash
set -e
set -x
set -o pipefail

. "${GITHUB_WORKSPACE}/build/common_lib.sh"
. "${GITHUB_WORKSPACE}/build/build_lib.sh"

# Only the latest version is available as a release.
LIBMPFR_VERSION="4.1.0"
LIBMPFR_URL="https://www.mpfr.org/mpfr-current/mpfr-${LIBMPFR_VERSION}.tar.xz"
LIBMPFR_BUILD_DIR="${BUILD_DIRECTORY}/libmpfr-build"
# temporary compat fix for the old build system
export LIBMPFR_DIR="/$(cc -dumpmachine)/usr"


# Requires:
# - GMP 5.0+
# TODO: Limited pkg-config support was added in the latest versions:
# https://www.mpfr.org/faq.html#detect_mpfr
build_libmpfr() (
  curl -sLo 'libmpfr.tar.xz' "${LIBMPFR_URL}"
  common::extract 'libmpfr.tar.xz' "${LIBMPFR_BUILD_DIR}"
  common::safe_cd "${LIBMPFR_BUILD_DIR}"

  # It is recommended to apply patches to fix known bugs.
  curl "https://www.mpfr.org/mpfr-${LIBMPFR_VERSION}/allpatches" | patch -N -Z -p1

  CFLAGS="${GCC_OPTS}" \
    CXXFLAGS="${GXX_OPTS}" \
    ./configure \
      --host="$(build::get_host_triplet)" \
      --disable-dependency-tracking \
      --prefix="${LIBMPFR_DIR}" \
      --disable-shared \
      --enable-static
  make -j"$(nproc)"
  make install

  echo "[+] Finished building libmpfr for ${CURRENT_ARCH}"
)