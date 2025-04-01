#!/bin/bash
. "${GITHUB_WORKSPACE}/build/common_lib.sh"
. "${GITHUB_WORKSPACE}/build/build_lib.sh"


build_zlib() {
  # Only the latest release is available at zlib.net
  local zlib_version='1.3.1'
  local zlib_archive="zlib-${zlib_version}.tar.gz"
  local zlib_url="https://zlib.net/${zlib_archive}"
  local zlib_build_dir="${BUILD_DIRECTORY}/zlib-src"
  #export ZLIB_DIR="${BUILD_DIRECTORY}/zlib"
  # temporary compat fix for the old build system
  export ZLIB_DIR="/$(cc -dumpmachine)/usr"

  curl -sLo "${zlib_archive}" "${zlib_url}"
  common::extract "${zlib_archive}" "${zlib_build_dir}"
  common::safe_cd "${zlib_build_dir}"

  make distclean
  # Does not have --host option, use CHOST instead
  #   (but we won't need it - in our container cross compiler is the default one).
  CFLAGS="${GCC_OPTS}" \
    CXXFLAGS="${GXX_OPTS}" \
    ./configure \
      --prefix="${ZLIB_DIR}" \
      --static
  make -j"$(nproc)"
  make install
  build::append_to_pkgconfig_libdir "${ZLIB_DIR}/lib/pkgconfig"

  echo "[+] Finished building zlib for ${CURRENT_ARCH}"
}