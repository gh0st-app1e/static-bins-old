#!/bin/bash
set -e
set -x
set -o pipefail

. "${GITHUB_WORKSPACE}/build/common_lib.sh"
. "${GITHUB_WORKSPACE}/build/build_lib.sh"

# The project seems to be abandoned, so it is better to use the latest version used by everyone else.
ARGP_VERSION='1.3'
ARGP_URL="https://www.lysator.liu.se/~nisse/misc/argp-standalone-${ARGP_VERSION}.tar.gz"
ARGP_BUILD_DIR="${BUILD_DIRECTORY}/argp-src"
export ARGP_DIR="${BUILD_DIRECTORY}/argp"


build_libargp() (
  curl -sLo 'argp.tar.gz' "${ARGP_URL}"
  common::extract 'argp.tar.gz' "${ARGP_BUILD_DIR}"
  common::safe_cd "${ARGP_BUILD_DIR}"

  # NOTE: Compiling original code will fail with GCC version >= 8 as it is
  #   more strict about attribute placement => they should be moved.
  # TODO: Make a patch file with these changes
  sed -i 's/__argp_usage (__const struct argp_state *__state) __THROW/__THROW __argp_usage (__const struct argp_state *__state)/g' "${ARGP_BUILD_DIR}/argp-parse.c"
  sed -i 's/__option_is_short (__const struct argp_option *__opt) __THROW/__THROW __option_is_short (__const struct argp_option *__opt)/g' "${ARGP_BUILD_DIR}/argp-parse.c"
  sed -i 's/__option_is_end (__const struct argp_option *__opt) __THROW/__THROW __option_is_end (__const struct argp_option *__opt)/g' "${ARGP_BUILD_DIR}/argp-parse.c"
  # NOTE: Without "-DFNM_EXTMATCH=0" compilation will fail.
  CFLAGS="${GCC_OPTS} -DFNM_EXTMATCH=0" \
    CXXFLAGS="${GXX_OPTS}" \
    LDFLAGS="-static" \
    ./configure \
      --host="$(build::get_host_triplet)" \
      --disable-dependency-tracking
  make -j"$(nproc)"
  # make install does not do anything
  "${ARGP_BUILD_DIR}/install-sh" "${ARGP_BUILD_DIR}/libargp.a" "${ARGP_DIR}/lib/libargp.a"
  "${ARGP_BUILD_DIR}/install-sh" "${ARGP_BUILD_DIR}/argp.h" "${ARGP_DIR}/include/argp.h"

  echo "[+] Finished building argp for ${CURRENT_ARCH}"
)