#!/bin/bash
set -e
set -x
set -o pipefail

. "${GITHUB_WORKSPACE}/build/common_lib.sh"
. "${GITHUB_WORKSPACE}/build/build_lib.sh"

ELFUTILS_VERSION="${ELFUTILS_VERSION:-0.183}"
ELFUTILS_URL="https://sourceware.org/elfutils/ftp/${ELFUTILS_VERSION}/elfutils-${ELFUTILS_VERSION}.tar.bz2"
ELFUTILS_BUILD_DIR="${BUILD_DIRECTORY}/elfutils-src"
export ELFUTILS_DIR="${BUILD_DIRECTORY}/elfutils"


# Requires:
#   - zlib
#   - argp
#   - fts
#   - obstack
# TODO:
# gzip support
# bzip2 support
# lzma/xz support
# zstd support
# NOTE: argp, fts and obstack are included in glibc, but we are using musl so we need them as standalone libs
build_elfutils() (
  curl -sLo 'elfutils.tar.bz2' "${ELFUTILS_URL}"
  common::extract 'elfutils.tar.bz2' "${ELFUTILS_BUILD_DIR}"
  common::safe_cd "${ELFUTILS_BUILD_DIR}"

  # NOTE: During configure this command is used:
  #   gcc -o conftest -fPIC -static -fPIC -fPIC  -shared -Wl,-z,defs -Wl,-z,relro -static -Wl,--build-id conftest.c
  # It fails on relocations because of -shared flag (displayed in config.log like "__thread is not supported").
  # We need to replace -shared with -static.
  # NOTE: dso_LDFLAGS is also present in configure.ac.
  sed -i 's/dso_LDFLAGS="-shared"/dso_LDFLAGS="-static"/g' /build/elfutils-src/configure
  # TODO: satisfy dependencies for libdebuginfod (e.g. libcurl) for building standalone elfutils
  CFLAGS="${GCC_OPTS}" \
    CXXFLAGS="${GXX_OPTS}" \
    CPPFLAGS="-I${ZLIB_DIR}/include -I${ARGP_DIR}/include -I${FTS_DIR}/include -I${OBSTACK_DIR}/include"
    LDFLAGS="-L${ZLIB_DIR}/lib -L${ARGP_DIR}/lib -L${FTS_DIR}/lib -L${OBSTACK_DIR}/lib -static" \
    ./configure \
      --host="$(build::get_host_triplet)" \
      --disable-dependency-tracking \
      --prefix="${ELFUTILS_DIR}" \
      --disable-nls \
      --disable-debuginfod \
      --disable-libdebuginfod
  make -j"$(nproc)"
  make install

  echo "[+] Finished building elfutils for ${CURRENT_ARCH}"
)