#!/bin/bash
. "${GITHUB_WORKSPACE}/build/common_lib.sh"
. "${GITHUB_WORKSPACE}/build/build_lib.sh"


# Requires:
# - libgmp (>= v6.1.0)
build_libnettle() {
  local libnettle_version=${LIBNETTLE_VERSION:-3.7.2}
  local libnettle_url="https://ftp.gnu.org/gnu/nettle/nettle-${libnettle_version}.tar.gz"
  local libnettle_build_dir="${BUILD_DIRECTORY}/libnettle-src"
  export LIBNETTLE_DIR="${BUILD_DIRECTORY}/libnettle"

  curl -sLo 'libnettle.tar.gz' "${libnettle_url}"
  common::extract 'libnettle.tar.gz' "${libnettle_build_dir}"
  common::safe_cd "${libnettle_build_dir}"

  CFLAGS="${GCC_OPTS}" \
    CXXFLAGS="${GXX_OPTS}" \
    CPPFLAGS="-I${LIBGMP_DIR}/include" \
    LDFLAGS="-L${LIBGMP_DIR}/lib" \
    ./configure \
      --host="$(build::get_host_triplet)" \
      --disable-dependency-tracking \
      --prefix="${LIBNETTLE_DIR}" \
      --disable-shared \
      --enable-static \
      --disable-documentation
  make -j"$(nproc)"
  make install
  build::append_to_pkgconfig_libdir "${LIBNETTLE_DIR}/lib/pkgconfig"

  echo "[+] Finished building libnettle for ${CURRENT_ARCH}"
}