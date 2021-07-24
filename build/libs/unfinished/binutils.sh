#!/bin/bash
set -e
set -x
set -o pipefail

. "${GITHUB_WORKSPACE}/build/common_lib.sh"
. "${GITHUB_WORKSPACE}/build/build_lib.sh"

BINUTILS_VERSION="${BINUTILS_VERSION:-2.37}"
BINUTILS_URL="https://ftp.gnu.org/gnu/binutils/binutils-${BINUTILS_VERSION}.tar.xz"
BINUTILS_SRC_DIR="${BUILD_DIRECTORY}/binutils-src"
BINUTILS_BUILD_DIR="${BUILD_DIRECTORY}/binutils-build"
# temporary compat fix for the old build system
export BINUTILS_DIR="/$(cc -dumpmachine)/usr"


# Requires:
# - GMP 5.0+
# TODO: Limited pkg-config support was added in the latest versions:
# https://www.mpfr.org/faq.html#detect_mpfr
build_binutils() (
  curl -sLo 'binutils.tar.xz' "${BINUTILS_URL}"
  common::extract 'binutils.tar.xz' "${BINUTILS_BUILD_DIR}"
  common::safe_cd "${BINUTILS_BUILD_DIR}"

  # binutils require a separate build dir.
  mkdir -p "${BINUTILS_BUILD_DIR}"
  common::safe_cd "${BINUTILS_BUILD_DIR}"

  CFLAGS="${GCC_OPTS}" \
    CXXFLAGS="${GXX_OPTS}" \
    LDFLAGS="-static" \
    CC_FOR_BUILD="${cc_for_build_value}" \
    CXX_FOR_BUILD="${cxx_for_build_value}" \
    "${GDB_SRC_DIR}/configure" \
      --build="x86_64-linux-musl" \
      --host="$(build::get_host_triplet)" \
      --disable-dependency-tracking \
      --disable-shared \
      --enable-static \
      --disable-nls \
      --disable-gdb \
      --disable-gdbserver \
      --disable-binutils \
      --disable-ld \
      --disable-gold \
      --disable-gas \
      --disable-sim \
      --disable-gprof \
      --disable-inprocess-agent
  make -j"$(nproc)"
  make -j"$(nproc)"
  make install

  echo "[+] Finished building binutils for ${CURRENT_ARCH}"
)