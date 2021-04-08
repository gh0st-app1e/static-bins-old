#!/bin/bash
set -e
set -x
set -o pipefail

. "${GITHUB_WORKSPACE}/build/common_lib.sh"
. "${GITHUB_WORKSPACE}/build/build_lib.sh"

FTS_VERSION="${FTS_VERSION:-1.2.7}"
FTS_URL="https://github.com/void-linux/musl-fts/archive/refs/tags/v${FTS_VERSION}.tar.gz"
FTS_BUILD_DIR="${BUILD_DIRECTORY}/fts-src"
export FTS_DIR="${BUILD_DIRECTORY}/fts"


build_libfts() (
  curl -sLo 'fts.tar.gz' "${FTS_URL}"
  common::extract 'fts.tar.gz' "${FTS_BUILD_DIR}"
  common::safe_cd "${FTS_BUILD_DIR}"

  ./bootstrap.sh
  CFLAGS="${GCC_OPTS}" \
    CXXFLAGS="${GXX_OPTS}" \
    ./configure \
      --host="$(build::get_host_triplet)" \
      --disable-dependency-tracking \
      --prefix="${FTS_DIR}" \
      --disable-shared
  make -j"$(nproc)"
  make install

  echo "[+] Finished building fts for ${CURRENT_ARCH}"
)