#!/bin/bash
set -e
set -x
set -o pipefail

. "${GITHUB_WORKSPACE}/build/common_lib.sh"
. "${GITHUB_WORKSPACE}/build/build_lib.sh"

FREERDP_VERSION=${FREERDP_VERSION:-2.3.2}
FREERDP_URL="https://pub.freerdp.com/releases/freerdp-${FREERDP_VERSION}.tar.gz"
FREERDP_SRC_DIR="${BUILD_DIRECTORY}/freerdp-src"
export FREERDP_DIR="${BUILD_DIRECTORY}/freerdp"


# Requires:
# - openssl
# - zlib
# NOTE: Currently fails on arm (CMake cannot find pthread.h, although it is present).
build_freerdp() (
  curl -sLo 'freerdp.tar.gz' "${FREERDP_URL}"
  common::extract 'freerdp.tar.gz' "${FREERDP_SRC_DIR}"
  common::safe_cd "${FREERDP_SRC_DIR}"

  # -DBUILD_SHARED_LIBS=OFF is required to prevent fail when linking shared libs.
  # -DCMAKE_SKIP_INSTALL_RPATH=ON is required to prevent fail on editing RPATH during installation.
  # TODO: add missing libraries (that are ignored with WITH_***=OFF).
  CFLAGS="${GCC_OPTS}" \
    CXXFLAGS="${GXX_OPTS}" \
    cmake \
      -DCMAKE_BUILD_TYPE=Release \
      -DCMAKE_INSTALL_PREFIX="${FREERDP_DIR}" \
      -DBUILD_SHARED_LIBS=OFF \
      -DCMAKE_SKIP_INSTALL_RPATH=ON \
      -DZLIB_INCLUDE_DIR="${ZLIB_DIR}/include" \
      -DZLIB_LIBRARY_RELEASE="${ZLIB_DIR}/lib/libz.a" \
      -DOPENSSL_INCLUDE_DIR="${OPENSSL_DIR}/include" \
      -DOPENSSL_SSL_LIBRARY="${OPENSSL_DIR}/lib/libssl.a" \
      -DOPENSSL_CRYPTO_LIBRARY="${OPENSSL_DIR}/lib/libcrypto.a" \
      -DLIBUSB_1_INCLUDE_DIR="${LIBUSB_DIR}/include/libusb-1.0" \
      -DLIBUSB_1_LIBRARY="${LIBUSB_DIR}/lib/libusb-1.0.a" \
      -DWITH_LIBSYSTEMD=OFF \
      -DWITH_X11=OFF \
      -DWITH_WAYLAND=OFF \
      -DWITH_ALSA=OFF \
      -DWITH_PULSE=OFF \
      -DWITH_CUPS=OFF \
      -DWITH_PCSC=OFF \
      -DWITH_FFMPEG=OFF \
      -DWITH_SWSCALE=OFF \
      -DWITH_CAIRO=OFF \
      .
      # -DWITH_SSE2=OFF is needed for arm if not auto guessed
  make -j"$(nproc)"
  make install

  echo "[+] Finished building freerdp for ${CURRENT_ARCH}"
)