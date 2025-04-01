#!/bin/bash
. "${GITHUB_WORKSPACE}/build/common_lib.sh"
. "${GITHUB_WORKSPACE}/build/build_lib.sh"


build_libgmp() {
  local libgmp_version=${LIBGMP_VERSION:-6.3.0}
  local libgmp_archive="gmp-${libgmp_version}.tar.xz"
  local libgmp_url="https://gmplib.org/download/gmp/${libgmp_archive}"
  local libgmp_build_dir="${BUILD_DIRECTORY}/libgmp-src"
  # temporary compat fix for the old build system
  export LIBGMP_DIR="/$(cc -dumpmachine)/usr"

  curl -sLo "${libgmp_archive}" "${libgmp_url}"
  common::extract "${libgmp_archive}" "${libgmp_build_dir}"
  common::safe_cd "${libgmp_build_dir}"

  if [ "${CURRENT_ARCH}" != "x86-64" ]; then
    cc_for_build_value="/x86_64-linux-musl-cross/bin/x86_64-linux-musl-gcc"
  fi

  # Build options manual: https://gmplib.org/manual/Build-Options
  # NOTE: it is possible to pass CPU type for archs which support this option to use faster assembly instead of C code.
  #   x86 is already covered by '--enable-fat'.
  CFLAGS="${GCC_OPTS}" \
    CXXFLAGS="${GXX_OPTS}" \
    CC_FOR_BUILD="${cc_for_build_value}" \
    ./configure \
      --host="$(build::get_host_triplet)" \
      --prefix="${LIBGMP_DIR}" \
      --disable-shared \
      --enable-static \
      --enable-fat \
      --enable-cxx
  make -j"$(nproc)"
  # Tests will fail during cross-compilation.
  # make check
  make install
  build::append_to_pkgconfig_libdir "${LIBGMP_DIR}/lib/pkgconfig"

  echo "[+] Finished building libgmp for ${CURRENT_ARCH}"
}