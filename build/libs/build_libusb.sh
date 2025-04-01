#!/bin/bash
set -euxo pipefail

. "${GITHUB_WORKSPACE}/build/common_lib.sh"
. "${GITHUB_WORKSPACE}/build/build_lib.sh"

LIBUSB_VERSION=${LIBUSB_VERSION:-1.0.28}
LIBUSB_ARCHIVE="libusb-${LIBUSB_VERSION}.tar.bz2"
LIBUSB_URL="https://github.com/libusb/libusb/releases/download/v${LIBUSB_VERSION}/${LIBUSB_ARCHIVE}"
LIBUSB_BUILD_DIR="${BUILD_DIRECTORY}/libusb-src"
export LIBUSB_DIR="${BUILD_DIRECTORY}/libusb"


build_libusb() (
  curl -sLo "${LIBUSB_ARCHIVE}" "${LIBUSB_URL}"
  common::extract "${LIBUSB_ARCHIVE}" "${LIBUSB_BUILD_DIR}"
  common::safe_cd "${LIBUSB_BUILD_DIR}"

  # Disabling udev which is not recommended (but its support requires another lib)
  CFLAGS="${GCC_OPTS}" \
    CXXFLAGS="${GXX_OPTS}" \
    ./configure \
      --host="$(build::get_host_triplet)" \
      --disable-dependency-tracking \
      --prefix="${LIBUSB_DIR}" \
      --disable-shared \
      --enable-static \
      --disable-udev
  make -j"$(nproc)"
  make install

  echo "[+] Finished building libusb for ${CURRENT_ARCH}"
)