#!/bin/bash
set -e
set -x
set -o pipefail

. "${GITHUB_WORKSPACE}/build/common_lib.sh"
. "${GITHUB_WORKSPACE}/build/build_lib.sh"

# Project is abandoned
POSTGRESQL_VERSION="${POSTGRESQL_VERSION:-13.2}"
POSTGRESQL_URL="https://ftp.postgresql.org/pub/source/v${POSTGRESQL_VERSION}/postgresql-${POSTGRESQL_VERSION}.tar.gz"
POSTGRESQL_BUILD_DIR="${BUILD_DIRECTORY}/postgresql-src"
export POSTGRESQL_DIR="${BUILD_DIRECTORY}/postgresql"


# Requires:
# - zlib
# - readline - can be dropped
build_postgresql() (
  curl -sLo 'postgresql.tar.gz' "${POSTGRESQL_URL}"
  common::extract 'postgresql.tar.gz' "${POSTGRESQL_BUILD_DIR}"
  common::safe_cd "${POSTGRESQL_BUILD_DIR}"

  # Not configured to build static blibs.
  # Possible hack: grep -r '\-shared' . and replace all shared with static
  CFLAGS="${GCC_OPTS}" \
    CXXFLAGS="${GXX_OPTS}" \
    ./configure \
      --host="$(build::get_host_triplet)" \
      --prefix="${POSTGRESQL_DIR}" \
      --with-includes="${ZLIB_DIR}/include" \
      --with-libs="${ZLIB_DIR}/lib" \
      --disable-nls \
      --without-readline
  make -j"$(nproc)"
  make install

  echo "[+] Finished building postgresql for ${CURRENT_ARCH}"
)