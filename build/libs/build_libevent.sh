#!/bin/bash
set -e
set -x
set -o pipefail

. "${GITHUB_WORKSPACE}/build/common_lib.sh"
. "${GITHUB_WORKSPACE}/build/build_lib.sh"

LIBEVENT_VERSION="${LIBEVENT_VERSION:-2.1.12}"
LIBEVENT_URL="https://github.com/libevent/libevent/releases/download/release-${LIBEVENT_VERSION}-stable/libevent-${LIBEVENT_VERSION}-stable.tar.gz"
LIBEVENT_BUILD_DIR="${BUILD_DIRECTORY}/libevent-src"
export LIBEVENT_DIR="${BUILD_DIRECTORY}/libevent"


# TODO: enable openssl
build_libevent() (
  curl -sLo 'libevent.tar.gz' "${LIBEVENT_URL}"
  common::extract 'libevent.tar.gz' "${LIBEVENT_BUILD_DIR}"
  common::safe_cd "${LIBEVENT_BUILD_DIR}"

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