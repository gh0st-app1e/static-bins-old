#!/bin/bash
set -euxo pipefail

. "${GITHUB_WORKSPACE}/build/common_lib.sh"
. "${GITHUB_WORKSPACE}/build/build_lib.sh"

LIBIPT_VERSION=${LIBIPT_VERSION:-2.1.2}
LIBIPT_ARCHIVE="v${LIBIPT_VERSION}.tar.gz"
LIBIPT_URL="https://github.com/intel/libipt/archive/refs/tags/${LIBIPT_ARCHIVE}"
LIBIPT_SRC_DIR="${BUILD_DIRECTORY}/libipt-src"
LIBIPT_BUILD_DIR="${BUILD_DIRECTORY}/libipt-build"
# temporary compat fix for the old build system
export LIBIPT_DIR="/$(cc -dumpmachine)/usr"


build_libipt() (
  curl -sLo "${LIBIPT_ARCHIVE}" "${LIBIPT_URL}"
  common::extract "${LIBIPT_ARCHIVE}" "${LIBIPT_SRC_DIR}"
  mkdir -p "${LIBIPT_BUILD_DIR}"
  common::safe_cd "${LIBIPT_BUILD_DIR}"

  CFLAGS="${GCC_OPTS}" \
    CXXFLAGS="${GXX_OPTS}" \
    cmake \
      -DCMAKE_BUILD_TYPE=Release \
      -DCMAKE_INSTALL_PREFIX="${LIBIPT_DIR}" \
      -DBUILD_SHARED_LIBS=OFF \
      -DFEATURE_ELF=ON \
      -DFEATURE_THREADS=ON \
      "${LIBIPT_SRC_DIR}"
  make -j"$(nproc)"
  make install

  echo "[+] Finished building libipt for ${CURRENT_ARCH}"
)