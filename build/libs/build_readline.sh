#!/bin/bash
set -e
set -x
set -o pipefail

. "${GITHUB_WORKSPACE}/build/common_lib.sh"
. "${GITHUB_WORKSPACE}/build/build_lib.sh"

READLINE_GIT='https://git.savannah.gnu.org/git/readline.git'
READLINE_BUILD_DIR="${BUILD_DIRECTORY}/readline-src"
export READLINE_DIR="${BUILD_DIRECTORY}/readline"


# TODO: build release version instead of master
build_readline() (
  git clone "${READLINE_GIT}" "${READLINE_BUILD_DIR}"
  common::safe_cd "${READLINE_BUILD_DIR}"
  git clean -fdx

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