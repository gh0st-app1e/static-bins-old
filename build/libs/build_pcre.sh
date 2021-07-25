#!/bin/bash
set -e
set -x
set -o pipefail

. "${GITHUB_WORKSPACE}/build/common_lib.sh"
. "${GITHUB_WORKSPACE}/build/build_lib.sh"

PCRE_VERSION=${PCRE_VERSION:-8.44}
PCRE_URL="https://ftp.pcre.org/pub/pcre/pcre-${PCRE_VERSION}.tar.gz"
PCRE_BUILD_DIR="${BUILD_DIRECTORY}/pcre-src"
#export PCRE_DIR="${BUILD_DIRECTORY}/pcre"
# temporary compat fix for the old build system
export PCRE_DIR="/$(cc -dumpmachine)/usr"

# The old PCRE library, not PCRE2!
build_pcre() (
  curl -sLo 'pcre.tar.gz' "${PCRE_URL}"
  common::extract 'pcre.tar.gz' "${PCRE_BUILD_DIR}"
  common::safe_cd "${PCRE_BUILD_DIR}"

  CFLAGS="${GCC_OPTS}" \
    CXXFLAGS="${GXX_OPTS}" \
    ./configure \
      --host="$(build::get_host_triplet)" \
      --disable-dependency-tracking \
      --prefix="${PCRE_DIR}" \
      --disable-shared \
      --enable-static \
      --enable-utf \
      --enable-unicode-properties \
      --enable-pcre16 \
      --enable-pcre32 \
      --enable-jit
  make -j"$(nproc)"
  make install

  echo "[+] Finished building pcre for ${CURRENT_ARCH}"
)