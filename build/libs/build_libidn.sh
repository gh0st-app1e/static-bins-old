#!/bin/bash
set -e
set -x
set -o pipefail

. "${GITHUB_WORKSPACE}/build/common_lib.sh"
. "${GITHUB_WORKSPACE}/build/build_lib.sh"

LIBIDN_VERSION=${LIBIDN_VERSION:-1.36}
LIBIDN_URL="https://ftp.gnu.org/gnu/libidn/libidn-${LIBIDN_VERSION}.tar.gz"
LIBIDN_BUILD_DIR="${BUILD_DIRECTORY}/libidn-src"
export LIBIDN_DIR="${BUILD_DIRECTORY}/libidn"


build_libidn() (
  curl -sLo 'libidn.tar.gz' "${LIBIDN_URL}"
  common::extract 'libidn.tar.gz' "${LIBIDN_BUILD_DIR}"
  common::safe_cd "${LIBIDN_BUILD_DIR}"

# TODO:
# --with-libiconv-prefix[=DIR]  search for libiconv in DIR/include and DIR/lib
#   --without-libiconv-prefix     don't search for libiconv in includedir and libdir
#   --with-libpth-prefix[
#   --with-libintl-prefix[=DIR]  search for libintl in DIR/include and DIR/lib
#   --without-libintl-prefix

  CFLAGS="${GCC_OPTS}" \
    CXXFLAGS="${GXX_OPTS}" \
    ./configure \
      --host="$(build::get_host_triplet)" \
      --disable-dependency-tracking \
      --prefix="${LIBIDN_DIR}" \
      --disable-shared \
      --enable-static \
      --disable-nls \
      --disable-valgrind-tests \
      --disable-doc \
      --enable-cross-guesses=conservative
  make -j"$(nproc)"
  make install

  echo "[+] Finished building libidn for ${CURRENT_ARCH}"
)