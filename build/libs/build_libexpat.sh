#!/bin/bash
. "${GITHUB_WORKSPACE}/build/common_lib.sh"
. "${GITHUB_WORKSPACE}/build/build_lib.sh"


build_libexpat() {
  local libexpat_version='2.3.0'
  local libexpat_archive="expat-${libexpat_version}.tar.xz"
  local libexpat_url="https://github.com/libexpat/libexpat/releases/download/R_${libexpat_version//./_}/${libexpat_archive}"
  local libexpat_build_dir="${BUILD_DIRECTORY}/libexpat-src"
  #export LIBEXPAT_DIR="${BUILD_DIRECTORY}/libexpat"
  # temporary compat fix for the old build system
  export LIBEXPAT_DIR="/$(cc -dumpmachine)/usr"

  curl -sLo "${libexpat_archive}" "${libexpat_url}"
  common::extract "${libexpat_archive}" "${libexpat_build_dir}"
  common::safe_cd "${libexpat_build_dir}"

  CFLAGS="${GCC_OPTS}" \
    CXXFLAGS="${GXX_OPTS}" \
    ./configure \
      --host="$(build::get_host_triplet)" \
      --disable-dependency-tracking \
      --prefix="${LIBEXPAT_DIR}" \
      --disable-shared \
      --enable-static
  make -j"$(nproc)"
  make install
  build::append_to_pkgconfig_libdir "${LIBEXPAT_DIR}/lib/pkgconfig"

  echo "[+] Finished building libexpat for ${CURRENT_ARCH}"
}