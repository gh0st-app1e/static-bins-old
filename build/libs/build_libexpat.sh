#!/bin/bash
. "${GITHUB_WORKSPACE}/build/common_lib.sh"
. "${GITHUB_WORKSPACE}/build/build_lib.sh"


build_libexpat() {
  local libexpat_version='2.3.0'
  local libexpat_url="https://github.com/libexpat/libexpat/releases/download/R_2_3_0/expat-2.3.0.tar.gz"
  local libexpat_build_dir="${BUILD_DIRECTORY}/libexpat-src"
  export LIBEXPAT_DIR="${BUILD_DIRECTORY}/libexpat"

  curl -sLo 'libexpat.tar.gz' "${libexpat_url}"
  common::extract 'libexpat.tar.gz' "${libexpat_build_dir}"
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