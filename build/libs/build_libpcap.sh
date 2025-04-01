#!/bin/bash
set -euxo pipefail

. "${GITHUB_WORKSPACE}/build/common_lib.sh"
. "${GITHUB_WORKSPACE}/build/build_lib.sh"

LIBPCAP_VERSION="${LIBPCAP_VERSION:-1.10.5}"
LIBPCAP_ARCHIVE="libpcap-${LIBPCAP_VERSION}.tar.gz"
LIBPCAP_URL="https://www.tcpdump.org/release/${LIBPCAP_ARCHIVE}"
LIBPCAP_BUILD_DIR="${BUILD_DIRECTORY}/libpcap-src"
export LIBPCAP_DIR="${BUILD_DIRECTORY}/libpcap"


build_libpcap() (
  curl -sLo "${LIBPCAP_ARCHIVE}" "${LIBPCAP_URL}"
  common::extract "${LIBPCAP_ARCHIVE}" "${LIBPCAP_BUILD_DIR}"
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