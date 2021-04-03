#!/bin/bash
set -e
set -x
set -o pipefail

. "${GITHUB_WORKSPACE}/build/common_lib.sh"
. "${GITHUB_WORKSPACE}/build/build_lib.sh"

OPENSSL_VERSION="${OPENSSL_VERSION:-1_1_1k}"
OPENSSL_URL="https://github.com/openssl/openssl/archive/refs/tags/OpenSSL_${OPENSSL_VERSION}.tar.gz"
OPENSSL_BUILD_DIR="${BUILD_DIRECTORY}/openssl-src"
export OPENSSL_DIR="${BUILD_DIRECTORY}/openssl"

# OpenSSL fork that has many security restrictions removed:
#OPENSSL_GIT='https://github.com/drwetter/openssl-pm-snapshot.git'


get_openssl_arch() (
  # Full list is available via './Configure LIST'
  case "${CURRENT_ARCH}" in
    'x86')      echo 'linux-x86'      ;;
    'x86-64')   echo 'linux-x86_64'   ;;
    'armhf')    echo 'linux-armv4'    ;;
    'aarch64')  echo 'linux-aarch64'  ;;
    *)          common::print_to_stderr "[!] Can't get openssl_arch for arch '${CURRENT_ARCH}'" ;;
  esac
)

build_openssl() (
  curl -sLo 'openssh.tar.gz' "${OPENSSL_URL}"
  common::extract 'openssh.tar.gz' "${OPENSSL_BUILD_DIR}"
  common::safe_cd "${OPENSSL_BUILD_DIR}"

  CFLAGS="${GCC_OPTS}" \
    ./Configure \
      no-shared \
      --prefix=${OPENSSL_DIR} \
      "$(get_openssl_arch)"
  make -j4
  # Do not install mans to speed up the process
  make install_sw

  echo "[+] Finished building OpenSSL for ${CURRENT_ARCH}"
)