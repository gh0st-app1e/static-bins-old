#!/bin/bash
set -euxo pipefail

. "${GITHUB_WORKSPACE}/build/common_lib.sh"
. "${GITHUB_WORKSPACE}/build/build_lib.sh"

NCURSES_VERSION="${NCURSES_VERSION:-6.5}"
NCURSES_ARCHIVE="ncurses-${NCURSES_VERSION}.tar.gz"
NCURSES_URL="https://ftp.gnu.org/pub/gnu/ncurses/${NCURSES_ARCHIVE}"
NCURSES_BUILD_DIR="${BUILD_DIRECTORY}/ncurses-src"
#export NCURSES_DIR="${BUILD_DIRECTORY}/ncurses"
# temporary compat fix for the old build system
export NCURSES_DIR="/$(cc -dumpmachine)/usr"


# NOTE: ncurses require second compiler for the build machine arch when cross-compiling
build_ncurses() (
  curl -sLo "${NCURSES_ARCHIVE}" "${NCURSES_URL}"
  common::extract "${NCURSES_ARCHIVE}" "${NCURSES_BUILD_DIR}"
  common::safe_cd "${NCURSES_BUILD_DIR}"

  CMD="CFLAGS=\"${GCC_OPTS}\" "
  CMD+="CXXFLAGS=\"${GXX_OPTS}\" "
  # WARNING: avoid --with-termlib as it makes impossible to link nano with ncurses
  CMD+="./configure --host=$(build::get_host_triplet) --disable-dependency-tracking "
  CMD+="--prefix=${NCURSES_DIR} "
  CMD+="--disable-shared --enable-static "
  CMD+="--without-debug --without-ada --enable-widec "
  # Nano might have troubles without these options
  CMD+="--with-default-terminfo-dir=/usr/share/terminfo --with-terminfo-dirs=\"/etc/terminfo:/lib/terminfo:/usr/share/terminfo:/usr/lib/terminfo\" "
  if [ "${CURRENT_ARCH}" != "x86" ] && [ "${CURRENT_ARCH}" != "x86-64" ]; then
    CMD+="--with-build-cc=/x86_64-linux-musl-cross/bin/x86_64-linux-musl-gcc"
  fi
  eval "${CMD}"
  make -j"$(nproc)"

  # Installation is required as ncurses adjusts headers during it
  #   (e.g. generates headers for ncursesw).
  # Do not do 'make install', as it requires running tic compiled for the build host,
  #   which we do not want to compile.
  make install.includes install.libs

  # Some applications don't know about ncursesw and expect only plain old ncurses in include/.
  # Some applications explicitly do '#include <ncursesw/smth.h>'.
  # To satisfy both, creating symlinks in include/ to files in include/ncursesw/.
  for file_name in $(ls "${NCURSES_DIR}/include/ncursesw"); do
    ln -sv "ncursesw/${file_name}" "${NCURSES_DIR}/include/${file_name}"
  done

  # The same goes for libraries.
  ln -sv "libncursesw.a" "${NCURSES_DIR}/lib/libncurses.a"
  ln -sv "libncursesw.a" "${NCURSES_DIR}/lib/libcurses.a"

  echo "[+] Finished building ncurses for ${CURRENT_ARCH}"
)