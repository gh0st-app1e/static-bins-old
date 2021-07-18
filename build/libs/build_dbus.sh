#!/bin/bash
. "${GITHUB_WORKSPACE}/build/common_lib.sh"
. "${GITHUB_WORKSPACE}/build/build_lib.sh"


# Requires:
# - libexpat
build_dbus() {
  local dbus_version=${DBUS_VERSION:-1.13.18}
  local dbus_url="https://dbus.freedesktop.org/releases/dbus/dbus-${dbus_version}.tar.xz"
  local dbus_build_dir="${BUILD_DIRECTORY}/dbus-src"
  export DBUS_DIR="${BUILD_DIRECTORY}/dbus"

  curl -sLo 'dbus.tar.xz' "${dbus_url}"
  common::extract 'dbus.tar.xz' "${dbus_build_dir}"
  common::safe_cd "${dbus_build_dir}"

  # NOTE: dbus has many optional --with-* options. 
  CFLAGS="${GCC_OPTS}" \
    CXXFLAGS="${GXX_OPTS}" \
    ./configure \
      --host="$(build::get_host_triplet)" \
      --disable-dependency-tracking \
      --prefix="${DBUS_DIR}" \
      --disable-shared \
      --enable-static \
      --disable-maintainer-mode \
      --disable-debug
  make -j"$(nproc)"
  make install
  build::append_to_pkgconfig_libdir "${DBUS_DIR}/lib/pkgconfig"

  echo "[+] Finished building dbus for ${CURRENT_ARCH}"
}