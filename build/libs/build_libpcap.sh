#!/bin/bash
set -e
set -x
set -o pipefail

. "${GITHUB_WORKSPACE}/build/common_lib.sh"
. "${GITHUB_WORKSPACE}/build/build_lib.sh"

LIBPCAP_VERSION="${LIBPCAP_VERSION:-1.9.1}"
LIBPCAP_GIT='https://github.com/the-tcpdump-group/libpcap.git'
LIBPCAP_BUILD_DIR="${BUILD_DIRECTORY}/libpcap-src"
export LIBPCAP_DIR="${BUILD_DIRECTORY}/libpcap"


build_libpcap() (
  git clone "${LIBPCAP_GIT}" "${LIBPCAP_BUILD_DIR}"
  common::safe_cd "${LIBPCAP_BUILD_DIR}"
  git clean -fdx
  git checkout "libpcap-${LIBPCAP_VERSION}"

  # Does not support --disable-dependency-tracking 
  CFLAGS="${GCC_OPTS}" \
    CXXFLAGS="${GXX_OPTS}" \
    ./configure \
      --host="$(build::get_host_triplet)" \
      --prefix="${LIBPCAP_DIR}" \
      --disable-shared \
      --with-pcap=linux
  make -j4
  make install

  echo "[+] Finished building libpcap for ${CURRENT_ARCH}"
)