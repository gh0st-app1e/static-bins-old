#!/bin/bash
set -euxo pipefail

. "${GITHUB_WORKSPACE}/build/common_lib.sh"
. "${GITHUB_WORKSPACE}/build/build_lib.sh"

# Only the latest version is available as a release.
GLIB_VERSION="${GLIB_VERSION:-2.9.6}"
GLIB_ARCHIVE="glib-${GLIB_VERSION}.tar.bz2"
GLIB_URL="https://download.gnome.org/sources/glib/${GLIB_VERSION%.*}/${GLIB_ARCHIVE}"
GLIB_SRC_DIR="${BUILD_DIRECTORY}/glib-build"
GLIB_BUILD_DIR="${BUILD_DIRECTORY}/glib-build/build"
# temporary compat fix for the old build system
export GLIB_DIR="/$(cc -dumpmachine)/usr"


# Recommended:
# - PCRE1 (not sure if included is better due to possible undefined behavior,
#     see https://developer.gnome.org/glib/stable/glib-building.html)
# Optional (TODO):
# - libmount
# - libelf
# NOTE: Glib itself supports static build, but most of other GTK stack does not.
build_glib() (
  curl -sLo "${GLIB_ARCHIVE}" "${GLIB_URL}"
  common::extract "${GLIB_ARCHIVE}" "${GLIB_SRC_DIR}"
  common::safe_cd "${GLIB_SRC_DIR}"

  # A patch is recommended by LFS to reduce warnings:
  #   https://www.linuxfromscratch.org/blfs/view/svn/general/glib2.html
  if [ "${GLIB_VERSION}" = "2.68.3" ]; then
    curl "https://www.linuxfromscratch.org/patches/blfs/svn/glib-2.68.3-skip_warnings-1.patch" | patch -Np1
  else
    common::print_to_stderr "[!] Warning: not applying patch due to glib version mismatch"
  fi

  # Requires out-of-tree build.
  mkdir -p "${GLIB_BUILD_DIR}"
  common::safe_cd "${GLIB_BUILD_DIR}"

  # Meson built-in options: https://mesonbuild.com/Builtin-options.html
  # Glib build options manual: https://developer.gnome.org/glib/stable/glib-building.html
  # Cross-compilation:
  #   (general) http://mesonbuild.com/Cross-compilation.html
  #   (glib)    https://developer.gnome.org/glib/stable/glib-cross-compiling.html
  # LFS build options: https://www.linuxfromscratch.org/blfs/view/svn/general/glib2.html
  # WARNING: '..' implies that build dir is subdir of src dir.
  meson \
    --buildtype=release \
    --prefix="${GLIB_DIR}" \
    -Dc_args="${GCC_OPTS}" \
    -Dcpp_args="${GXX_OPTS}" \
    -Ddefault_library=static \
    -Dnls=disabled \
    -Dselinux=disabled \
    ..
  ninja
  ninja install

  # these were incorrect options (didn't understand meson docs on c_args?)
  #-Dc_args="$(echo ${GCC_OPTS} | tr -s ' ' | tr ' ' ',')" \
  #-Dcpp_args="$(echo ${GXX_OPTS} | tr -s ' ' | tr ' ' ',')" \

  echo "[+] Finished building glib for ${CURRENT_ARCH}"
)