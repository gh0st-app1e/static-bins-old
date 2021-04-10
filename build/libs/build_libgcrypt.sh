#!/bin/bash
set -e
set -x
set -o pipefail

. "${GITHUB_WORKSPACE}/build/common_lib.sh"
. "${GITHUB_WORKSPACE}/build/build_lib.sh"

LIBGCRYPT_VERSION=${LIBGCRYPT_VERSION:-1.9.2}
LIBGCRYPT_URL="https://gnupg.org/ftp/gcrypt/libgcrypt/libgcrypt-${LIBGCRYPT_VERSION}.tar.bz2"
LIBGCRYPT_BUILD_DIR="${BUILD_DIRECTORY}/libgcrypt-src"
export LIBGCRYPT_DIR="${BUILD_DIRECTORY}/libgcrypt"


# Requires:
# - libgpg-error
build_libgcrypt() (
  curl -sLo 'libgcrypt.tar.bz2' "${LIBGCRYPT_URL}"
  common::extract 'libgcrypt.tar.bz2' "${LIBGCRYPT_BUILD_DIR}"
  common::safe_cd "${LIBGCRYPT_BUILD_DIR}"

  CFLAGS="${GCC_OPTS}" \
    CXXFLAGS="${GXX_OPTS}" \
    ./configure \
      --host="$(build::get_host_triplet)" \
      --disable-dependency-tracking \
      --prefix="${LIBGCRYPT_DIR}" \
      --disable-shared \
      --enable-static \
      --with-libgpg-error-prefix="${LIBGPGERROR_DIR}"
  make -j"$(nproc)"
  make install

  echo "[+] Finished building libgcrypt for ${CURRENT_ARCH}"
)