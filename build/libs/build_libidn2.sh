#!/bin/bash
set -e
set -x
set -o pipefail

. "${GITHUB_WORKSPACE}/build/common_lib.sh"
. "${GITHUB_WORKSPACE}/build/build_lib.sh"

LIBIDN2_VERSION=${LIBIDN2_VERSION:-2.3.0}
LIBIDN2_URL="https://ftp.gnu.org/gnu/libidn/libidn2-${LIBIDN2_VERSION}.tar.gz"
LIBIDN2_BUILD_DIR="${BUILD_DIRECTORY}/libidn2-src"
export LIBIDN2_DIR="${BUILD_DIRECTORY}/libidn2"


# Need to add for cross-compile: !!!
# Libiconv:          
#  Libunistring
build_libidn2() (
  curl -sLo 'libidn2.tar.gz' "${LIBIDN2_URL}"
  common::extract 'libidn2.tar.gz' "${LIBIDN2_BUILD_DIR}"
  common::safe_cd "${LIBIDN2_BUILD_DIR}"

# TODO:
# --with-libiconv-prefix[=DIR]  search for libiconv in DIR/include and DIR/lib
#   --without-libiconv-prefix     don't search for libiconv in includedir and libdir
#   --with-libunistring-prefix[=DIR]  search for libunistring in DIR/include and DIR/lib
#   --without-libunistring-prefix     don't search for libunistring in includedir and libdir
#   --with-html-dir=PATH    path to installed docs
#   --with-libintl-prefix[=DIR]  search for libintl in DIR/include and DIR/lib
#   --without-libintl-prefix

  CFLAGS="${GCC_OPTS}" \
    CXXFLAGS="${GXX_OPTS}" \
    ./configure \
      --host="$(build::get_host_triplet)" \
      --disable-dependency-tracking \
      --prefix="${LIBIDN2_DIR}" \
      --disable-shared \
      --enable-static \
      --disable-nls \
      --disable-valgrind-tests
  make -j"$(nproc)"
  make install

  echo "[+] Finished building libidn2 for ${CURRENT_ARCH}"
)