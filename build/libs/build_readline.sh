#!/bin/bash
set -e
set -x
set -o pipefail

. "${GITHUB_WORKSPACE}/build/common_lib.sh"
. "${GITHUB_WORKSPACE}/build/build_lib.sh"

READLINE_VERSION=${READLINE_VERSION:-8.1}
READLINE_URL="ftp://ftp.cwru.edu/pub/bash/readline-${READLINE_VERSION}.tar.gz"
READLINE_BUILD_DIR="${BUILD_DIRECTORY}/readline-src"
export READLINE_DIR="${BUILD_DIRECTORY}/readline"


build_readline() (
  curl -sLo 'readline.tar.gz' "${READLINE_URL}"
  common::extract 'readline.tar.gz' "${READLINE_BUILD_DIR}"
  common::safe_cd "${READLINE_BUILD_DIR}"

  CFLAGS="${GCC_OPTS}" \
    CXXFLAGS="${GXX_OPTS}" \
    ./configure \
      --host="$(build::get_host_triplet)" \
      --disable-dependency-tracking \
      --prefix="${READLINE_DIR}" \
      --disable-shared \
      --enable-static
  make -j4
  make install

  echo "[+] Finished building readline for ${CURRENT_ARCH}"
)