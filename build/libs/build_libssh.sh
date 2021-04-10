#!/bin/bash
set -e
set -x
set -o pipefail

. "${GITHUB_WORKSPACE}/build/common_lib.sh"
. "${GITHUB_WORKSPACE}/build/build_lib.sh"

LIBSSH_VERSION=${LIBSSH_VERSION:-0.9.5}
LIBSSH_URL="https://www.libssh.org/files/${LIBSSH_VERSION%.*}/libssh-${LIBSSH_VERSION}.tar.xz"
LIBSSH_SRC_DIR="${BUILD_DIRECTORY}/libssh-src"
LIBSSH_BUILD_DIR="${BUILD_DIRECTORY}/libssh-build"
export LIBSSH_DIR="${BUILD_DIRECTORY}/libssh"


# Requires:
# - openssl
# - zlib
build_libssh() (
  curl -sLo 'libssh.tar.xz' "${LIBSSH_URL}"
  common::extract 'libssh.tar.xz' "${LIBSSH_SRC_DIR}"
  mkdir -p "${LIBSSH_BUILD_DIR}"
  common::safe_cd "${LIBSSH_BUILD_DIR}"

# -- ********** libssh build options : **********
# -- GSSAPI support : 0 !!!
# -- ********************************************
  CFLAGS="${GCC_OPTS}" \
    CXXFLAGS="${GXX_OPTS}" \
    CPPFLAGS="-I${OPENSSL_DIR}/include -I${ZLIB_DIR}/include" \
    LDFLAGS="-L${OPENSSL_DIR}/lib -L${ZLIB_DIR}/lib" \
    cmake \
      -DCMAKE_BUILD_TYPE=Release \
      -DCMAKE_INSTALL_PREFIX="${LIBSSH_DIR}" \
      -DBUILD_SHARED_LIBS=OFF \
      -DWITH_EXAMPLES=OFF \
      -DZLIB_INCLUDE_DIR="${ZLIB_DIR}/include" \
      -DZLIB_LIBRARY="${ZLIB_DIR}/lib/libz.a" \
      -DOPENSSL_ROOT_DIR="${OPENSSL_DIR}" \
      -DWITH_SSH1=ON \
      "${LIBSSH_SRC_DIR}"
  make -j"$(nproc)"
  make install

  echo "[+] Finished building libssh for ${CURRENT_ARCH}"
)