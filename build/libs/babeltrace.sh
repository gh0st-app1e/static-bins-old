#!/bin/bash
set -e
set -x
set -o pipefail

. "${GITHUB_WORKSPACE}/build/common_lib.sh"
. "${GITHUB_WORKSPACE}/build/build_lib.sh"

#  Babeltrace 1 is replaced by Babeltrace 2, this is the last release.
BABELTRACE_VERSION="1.5.8"
BABELTRACE_URL="https://www.efficios.com/files/babeltrace/babeltrace-${BABELTRACE_VERSION}.tar.bz2"
BABELTRACE_BUILD_DIR="${BUILD_DIRECTORY}/babeltrace-build"
# temporary compat fix for the old build system
export BABELTRACE_DIR="/$(cc -dumpmachine)/usr"


# Requires:
# - glib 2.28+
# - libpopt
# - libuuid (uuid may be built in libc, but it seems that it is missing from musl)
# NOTE: babeltrace has some problems with static linking (e.g. https://bugs.lttng.org/issues/1055, more in the code below).
build_babeltrace() (
  curl -sLo 'babeltrace.tar.bz2' "${BABELTRACE_URL}"
  common::extract 'babeltrace.tar.bz2' "${BABELTRACE_BUILD_DIR}"
  common::safe_cd "${BABELTRACE_BUILD_DIR}"

  # '--disable-debug-info' is used to avoid dependency on elfutils, which cannot be built yet.
  CFLAGS="${GCC_OPTS}" \
    CXXFLAGS="${GXX_OPTS}" \
    ./configure \
      --host="$(build::get_host_triplet)" \
      --disable-dependency-tracking \
      --prefix="${BABELTRACE_DIR}" \
      --disable-shared \
      --enable-static \
      --disable-maintainer-mode \
      --disable-debug-info
  make -j"$(nproc)"
  make install

  # PROBLEM (solved): Babeltrace does not add glib dependency to pkg-config file => fails to link with users.


  echo "[+] Finished building babeltrace for ${CURRENT_ARCH}"
)