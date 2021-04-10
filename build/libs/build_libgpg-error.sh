#!/bin/bash
set -e
set -x
set -o pipefail

. "${GITHUB_WORKSPACE}/build/common_lib.sh"
. "${GITHUB_WORKSPACE}/build/build_lib.sh"

LIBGPGERROR_VERSION=${LIBGPGERROR_VERSION:-1.42}
LIBGPGERROR_URL="https://gnupg.org/ftp/gcrypt/libgpg-error/libgpg-error-${LIBGPGERROR_VERSION}.tar.bz2"
LIBGPGERROR_BUILD_DIR="${BUILD_DIRECTORY}/libgpg-error-src"
export LIBGPGERROR_DIR="${BUILD_DIRECTORY}/libgpg-error"


# --with-libiconv-prefix[=DIR]  search for libiconv in DIR/include and DIR/lib
#   --with-libintl-prefix[=DIR]  search for libintl in DIR/include and DIR/lib
#   --with-readline=DIR
build_libgpgerror() (
  curl -sLo 'libgpg-error.tar.bz2' "${LIBGPGERROR_URL}"
  common::extract 'libgpg-error.tar.bz2' "${LIBGPGERROR_BUILD_DIR}"
  common::safe_cd "${LIBGPGERROR_BUILD_DIR}"

  CFLAGS="${GCC_OPTS}" \
    CXXFLAGS="${GXX_OPTS}" \
    ./configure \
      --host="$(build::get_host_triplet)" \
      --disable-dependency-tracking \
      --prefix="${LIBGPGERROR_DIR}" \
      --disable-shared \
      --enable-static \
      --disable-nls
  make -j"$(nproc)"
  make install

  echo "[+] Finished building libgpg-error for ${CURRENT_ARCH}"
)