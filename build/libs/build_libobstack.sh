#!/bin/bash
set -e
set -x
set -o pipefail

. "${GITHUB_WORKSPACE}/build/common_lib.sh"
. "${GITHUB_WORKSPACE}/build/build_lib.sh"

OBSTACK_VERSION="${OBSTACK_VERSION:-1.2.2}"
OBSTACK_URL="https://github.com/void-linux/musl-obstack/archive/refs/tags/v${OBSTACK_VERSION}.tar.gz"
OBSTACK_BUILD_DIR="${BUILD_DIRECTORY}/obstack-src"
export OBSTACK_DIR="${BUILD_DIRECTORY}/obstack"


build_libobstack() (
  curl -sLo 'obstack.tar.gz' "${OBSTACK_URL}"
  common::extract 'obstack.tar.gz' "${OBSTACK_BUILD_DIR}"
  common::safe_cd "${OBSTACK_BUILD_DIR}"

  ./bootstrap.sh
  CFLAGS="${GCC_OPTS}" \
    CXXFLAGS="${GXX_OPTS}" \
    ./configure \
      --host="$(build::get_host_triplet)" \
      --disable-dependency-tracking \
      --prefix="${OBSTACK_DIR}" \
      --disable-shared
  make -j"$(nproc)"
  make install

  echo "[+] Finished building obstack for ${CURRENT_ARCH}"
)