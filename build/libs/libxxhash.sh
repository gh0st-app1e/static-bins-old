#!/bin/bash
set -euxo pipefail

. "${GITHUB_WORKSPACE}/build/common_lib.sh"
. "${GITHUB_WORKSPACE}/build/build_lib.sh"

LIBXXHASH_VERSION="0.8.3"
LIBXXHASH_ARCHIVE="v${LIBXXHASH_VERSION}.tar.gz"
LIBXXHASH_URL="https://github.com/Cyan4973/xxHash/archive/refs/tags/${LIBXXHASH_ARCHIVE}"
LIBXXHASH_BUILD_DIR="${BUILD_DIRECTORY}/libxxhash-build"
# temporary compat fix for the old build system
export LIBXXHASH_DIR="/$(cc -dumpmachine)/usr"


# TODO: make check can be run with cross-compiled binaries on emulated environments (qemu user mode)
#   by setting $(RUN_ENV) to the target emulation environment
build_libxxhash() (
  curl -sLo "${LIBXXHASH_ARCHIVE}" "${LIBXXHASH_URL}"
  common::extract "${LIBXXHASH_ARCHIVE}" "${LIBXXHASH_BUILD_DIR}"
  common::safe_cd "${LIBXXHASH_BUILD_DIR}"

  # TODO: make prefix a global shell var.
  # So simple that it comes without 'configure'.
  PREFIX=/x86_64-linux-musl/usr make -j"$(nproc)"
  PREFIX=/x86_64-linux-musl/usr make install
  # Delete installed dynamic libraries as they won't be needed.
  rm -f /x86_64-linux-musl/usr/lib/libxxhash.so*

  echo "[+] Finished building libxxhash for ${CURRENT_ARCH}"
)