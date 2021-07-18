#!/bin/bash
set -e
set -x
set -o pipefail

. "${GITHUB_WORKSPACE}/build/common_lib.sh"
. "${GITHUB_WORKSPACE}/build/build_lib.sh"

# Project is abandoned
LIBMEMCACHED_VERSION='1.0.18'
LIBMEMCACHED_URL="https://launchpad.net/libmemcached/1.0/${LIBMEMCACHED_VERSION}/+download/libmemcached-${LIBMEMCACHED_VERSION}.tar.gz"
LIBMEMCACHED_BUILD_DIR="${BUILD_DIRECTORY}/libmemcached-src"
export LIBMEMCACHED_DIR="${BUILD_DIRECTORY}/libmemcached"


build_libmemcached() (
  curl -sLo 'libmemcached.tar.gz' "${LIBMEMCACHED_URL}"
  common::extract 'libmemcached.tar.gz' "${LIBMEMCACHED_BUILD_DIR}"
  common::safe_cd "${LIBMEMCACHED_BUILD_DIR}"

  # The code is so bad that modern compiler won't compile it without '-fpermissive'.
  CFLAGS="${GCC_OPTS}" \
    CXXFLAGS="${GXX_OPTS} -fpermissive" \
    ./configure \
      --host="$(build::get_host_triplet)" \
      --disable-dependency-tracking \
      --prefix="${LIBMEMCACHED_DIR}" \
      --disable-shared \
      --enable-static \
      --enable-hsieh_hash \
      --enable-libmemcachedprotocol
      #--enable-deprecated fails to build
  make -j"$(nproc)"
  make install

  echo "[+] Finished building libmemcached for ${CURRENT_ARCH}"
)