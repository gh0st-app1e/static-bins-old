#!/bin/bash
set -e
set -x
set -o pipefail

. "${GITHUB_WORKSPACE}/build/common_lib.sh"
. "${GITHUB_WORKSPACE}/build/build_lib.sh"

LIBUNWIND_VERSION="${LIBUNWIND_VERSION:-1.5.0}"
LIBUNWIND_URL="https://download.savannah.nongnu.org/releases/libunwind/libunwind-${LIBUNWIND_VERSION}.tar.gz"
LIBUNWIND_BUILD_DIR="${BUILD_DIRECTORY}/libunwind-src"
export LIBUNWIND_DIR="${BUILD_DIRECTORY}/libunwind"


build_libunwind() (
  curl -sLo 'libunwind.tar.gz' "${LIBUNWIND_URL}"
  common::extract 'libunwind.tar.gz' "${LIBUNWIND_BUILD_DIR}"
  common::safe_cd "${LIBUNWIND_BUILD_DIR}"

  CFLAGS="${GCC_OPTS}" \
    CXXFLAGS="${GXX_OPTS}" \
    ./configure \
      --host="$(build::get_host_triplet)" \
      --disable-dependency-tracking \
      --prefix="${LIBUNWIND_DIR}" \
      --disable-shared
  make -j"$(nproc)"
  make install

  echo "[+] Finished building libunwind for ${CURRENT_ARCH}"
)