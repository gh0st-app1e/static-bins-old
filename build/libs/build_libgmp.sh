#!/bin/bash
. "${GITHUB_WORKSPACE}/build/common_lib.sh"
. "${GITHUB_WORKSPACE}/build/build_lib.sh"


build_libgmp() {
  local libgmp_version=${LIBGMP_VERSION:-6.2.1}
  local libgmp_url="https://gmplib.org/download/gmp/gmp-${libgmp_version}.tar.xz"
  local libgmp_build_dir="${BUILD_DIRECTORY}/libgmp-src"
  export LIBGMP_DIR="${BUILD_DIRECTORY}/libgmp"

  curl -sLo 'libgmp.tar.xz' "${libgmp_url}"
  common::extract 'libgmp.tar.xz' "${libgmp_build_dir}"
  common::safe_cd "${libgmp_build_dir}"

  CFLAGS="${GCC_OPTS}" \
    CXXFLAGS="${GXX_OPTS}" \
    ./configure \
      --host="$(build::get_host_triplet)" \
      --prefix="${LIBGMP_DIR}" \
      --disable-shared \
      --enable-static
  make -j"$(nproc)"
  #make check
  make install
  build::append_to_pkgconfig_libdir "${LIBGMP_DIR}/lib/pkgconfig"

  echo "[+] Finished building libgmp for ${CURRENT_ARCH}"
}