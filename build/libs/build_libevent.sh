#!/bin/bash
set -e
set -x
set -o pipefail

. "${GITHUB_WORKSPACE}/build/common_lib.sh"
. "${GITHUB_WORKSPACE}/build/build_lib.sh"

LIBEVENT_VERSION="${LIBEVENT_VERSION:-2.1.12}"
LIBEVENT_GIT='https://github.com/libevent/libevent.git'
LIBEVENT_BUILD_DIR="${BUILD_DIRECTORY}/libevent-src"
export LIBEVENT_DIR="${BUILD_DIRECTORY}/libevent"


# TODO: enable openssl
build_libevent() (
  git clone "${LIBEVENT_GIT}" "${LIBEVENT_BUILD_DIR}"
  common::safe_cd "${LIBEVENT_BUILD_DIR}" 
  git clean -fdx
  git checkout "release-${LIBEVENT_VERSION}-stable"

  ./autogen.sh
  CFLAGS="${GCC_OPTS}" \
    CXXFLAGS="${GXX_OPTS}" \
    ./configure \
      --host="$(build::get_host_triplet)" \
      --disable-dependency-tracking \
      --prefix="${LIBEVENT_DIR}" \
      --disable-shared \
      --disable-openssl
  make -j4
  make install

  echo "[+] Finished building libevent for ${CURRENT_ARCH}"
)