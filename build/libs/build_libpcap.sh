#!/bin/bash
set -e
set -x
set -o pipefail

. "${GITHUB_WORKSPACE}/build/common_lib.sh"
. "${GITHUB_WORKSPACE}/build/build_lib.sh"

LIBPCAP_VERSION="${LIBPCAP_VERSION:-1.10.0}"
LIBPCAP_URL="https://www.tcpdump.org/release/libpcap-${LIBPCAP_VERSION}.tar.gz"
LIBPCAP_BUILD_DIR="${BUILD_DIRECTORY}/libpcap-src"
export LIBPCAP_DIR="${BUILD_DIRECTORY}/libpcap"


build_libpcap() (
  curl -sLo 'libpcap.tar.gz' "${LIBPCAP_URL}"
  common::extract 'libpcap.tar.gz' "${LIBPCAP_BUILD_DIR}"
  common::safe_cd "${LIBPCAP_BUILD_DIR}"

  # Does not support --disable-dependency-tracking 
  CFLAGS="${GCC_OPTS}" \
    CXXFLAGS="${GXX_OPTS}" \
    ./configure \
      --host="$(build::get_host_triplet)" \
      --prefix="${LIBPCAP_DIR}" \
      --disable-shared \
      --with-pcap=linux
  make -j"$(nproc)"
  make install

  echo "[+] Finished building libpcap for ${CURRENT_ARCH}"
)