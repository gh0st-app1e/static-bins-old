#!/bin/bash
set -euxo pipefail

. "${GITHUB_WORKSPACE}/build/common_lib.sh"
. "${GITHUB_WORKSPACE}/build/build_lib.sh"

LIBEVENT_VERSION="${LIBEVENT_VERSION:-2.1.12}"
LIBEVENT_ARCHIVE="libevent-${LIBEVENT_VERSION}-stable.tar.gz"
LIBEVENT_URL="https://github.com/libevent/libevent/releases/download/release-${LIBEVENT_VERSION}-stable/${LIBEVENT_ARCHIVE}"
LIBEVENT_BUILD_DIR="${BUILD_DIRECTORY}/libevent-src"
export LIBEVENT_DIR="${BUILD_DIRECTORY}/libevent"


# TODO: enable openssl
build_libevent() (
  curl -sLo "${LIBEVENT_ARCHIVE}" "${LIBEVENT_URL}"
  common::extract "${LIBEVENT_ARCHIVE}" "${LIBEVENT_BUILD_DIR}"
  common::safe_cd "${LIBEVENT_BUILD_DIR}"

  CFLAGS="${GCC_OPTS}" \
    CXXFLAGS="${GXX_OPTS}" \
    ./configure \
      --host="$(build::get_host_triplet)" \
      --disable-dependency-tracking \
      --prefix="${LIBEVENT_DIR}" \
      --disable-shared \
      --disable-openssl
  make -j"$(nproc)"
  make install

  echo "[+] Finished building libevent for ${CURRENT_ARCH}"
)