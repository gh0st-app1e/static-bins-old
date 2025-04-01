#!/bin/bash
set -euxo pipefail

. "${GITHUB_WORKSPACE}/build/common_lib.sh"
. "${GITHUB_WORKSPACE}/build/build_lib.sh"

# There is only one distributed version.
LIBPOPT_VERSION="1.19"
LIBPOPT_ARCHIVE="popt-${LIBPOPT_VERSION}.tar.gz"
LIBPOPT_URL="http://ftp.rpm.org/popt/releases/popt-1.x/${LIBPOPT_ARCHIVE}"
LIBPOPT_BUILD_DIR="${BUILD_DIRECTORY}/libpopt-build"
# temporary compat fix for the old build system
export LIBPOPT_DIR="/$(cc -dumpmachine)/usr"


build_libpopt() (
  curl -sLo "${LIBPOPT_ARCHIVE}" "${LIBPOPT_URL}"
  common::extract "${LIBPOPT_ARCHIVE}" "${LIBPOPT_BUILD_DIR}"
  common::safe_cd "${LIBPOPT_BUILD_DIR}"

  CFLAGS="${GCC_OPTS}" \
    CXXFLAGS="${GXX_OPTS}" \
    ./configure \
      --host="$(build::get_host_triplet)" \
      --disable-dependency-tracking \
      --prefix="${LIBPOPT_DIR}" \
      --disable-shared \
      --enable-static \
      --disable-nls
  make -j"$(nproc)"
  make install

  echo "[+] Finished building libpopt for ${CURRENT_ARCH}"
)