#!/bin/bash
set -e
set -x
set -o pipefail

. "${GITHUB_WORKSPACE}/build/common_lib.sh"
. "${GITHUB_WORKSPACE}/build/build_lib.sh"

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

# Ordinary OpenSSL.
OPENSSL_VERSION="${OPENSSL_VERSION:-1_1_1k}"
OPENSSL_URL="https://github.com/openssl/openssl/archive/refs/tags/OpenSSL_${OPENSSL_VERSION}.tar.gz"
OPENSSL_BUILD_DIR="${BUILD_DIRECTORY}/openssl-src"
export OPENSSL_DIR="${BUILD_DIRECTORY}/openssl"

# OpenSSL fork that has many security restrictions removed:
#OPENSSL_GIT='https://github.com/drwetter/openssl-pm-snapshot.git'

build_openssl() (
  curl -sLo 'openssl.tar.gz' "${OPENSSL_URL}"
  common::extract 'openssl.tar.gz' "${OPENSSL_BUILD_DIR}"
  common::safe_cd "${OPENSSL_BUILD_DIR}"

  CFLAGS="${GCC_OPTS}" \
    ./Configure \
      no-shared \
      --prefix=${OPENSSL_DIR} \
      "$(get_openssl_arch)"
  make -j"$(nproc)"
  # Do not install mans to speed up the process
  make install_sw

  echo "[+] Finished building OpenSSL for ${CURRENT_ARCH}"
)


# Old, FIPS-compatible OpenSSL.
OPENSSL_FIPS_MODULE_URL='https://www.openssl.org/source/old/fips/openssl-fips-2.0.16.tar.gz'
OPENSSL_FIPS_MODULE_BUILD_DIR="${BUILD_DIRECTORY}/openssl_fips_module-src"
OPENSSL_FIPS_MODULE_DIR="${BUILD_DIRECTORY}/openssl_fips_module"
OPENSSL_FIPS_URL='https://www.openssl.org/source/old/1.0.2/openssl-1.0.2u.tar.gz'
OPENSSL_FIPS_BUILD_DIR="${BUILD_DIRECTORY}/openssl_fips-src"
export OPENSSL_FIPS_DIR="${BUILD_DIRECTORY}/openssl_fips"

# Manual: https://www.openssl.org/docs/fips/UserGuide-1.2.pdf
build_openssl_fips_module() (

# Configuring for linux-x86_64
#     no-bf           [option]   OPENSSL_NO_BF (skip dir)
#     no-camellia     [option]   OPENSSL_NO_CAMELLIA (skip dir)
#     no-cast         [option]   OPENSSL_NO_CAST (skip dir)
#     no-ec_nistp_64_gcc_128 [default]  OPENSSL_NO_EC_NISTP_64_GCC_128 (skip dir)
#     no-gmp          [default]  OPENSSL_NO_GMP (skip dir)
#     no-idea         [option]   OPENSSL_NO_IDEA (skip dir)
#     no-jpake        [experimental] OPENSSL_NO_JPAKE (skip dir)
#     no-krb5         [krb5-flavor not specified] OPENSSL_NO_KRB5
#     no-md2          [option]   OPENSSL_NO_MD2 (skip dir)
#     no-md5          [option]   OPENSSL_NO_MD5 (skip dir)
#     no-mdc2         [option]   OPENSSL_NO_MDC2 (skip dir)
#     no-rc2          [option]   OPENSSL_NO_RC2 (skip dir)
#     no-rc4          [option]   OPENSSL_NO_RC4 (skip dir)
#     no-rc5          [option]   OPENSSL_NO_RC5 (skip dir)
#     no-rfc3779      [default]  OPENSSL_NO_RFC3779 (skip dir)
#     no-ripemd       [option]   OPENSSL_NO_RIPEMD (skip dir)
#     no-seed         [option]   OPENSSL_NO_SEED (skip dir)
#     no-shared       [option]
#     no-srp          [forced]   OPENSSL_NO_SRP (skip dir)
#     no-ssl2         [forced]   OPENSSL_NO_SSL2 (skip dir)
#     no-ssl3         [forced]   OPENSSL_NO_SSL3 (skip dir)
#     no-store        [experimental] OPENSSL_NO_STORE (skip dir)
#     no-tls1         [forced]   OPENSSL_NO_TLS1 (skip dir)
#     no-tlsext       [forced]   OPENSSL_NO_TLSEXT (skip dir)
#     no-zlib         [default]
#     no-zlib-dynamic [default]

  curl -sLo 'openssl_fips_module.tar.gz' "${OPENSSL_FIPS_MODULE_URL}"
  common::extract 'openssl_fips_module.tar.gz' "${OPENSSL_FIPS_MODULE_BUILD_DIR}"
  common::safe_cd "${OPENSSL_FIPS_MODULE_BUILD_DIR}"

  CFLAGS="${GCC_OPTS}" \
    ./config \
      no-shared \
      --prefix=${OPENSSL_FIPS_DIR} \
      enable-weak-ssl-ciphers \
      enable-deprecated \
      enable-rc4
  # Make may fail (non-critically).
  make -j"$(nproc)" || true
  make install

  echo "[+] Finished building OpenSSL FIPS module for ${CURRENT_ARCH}"
)

build_openssl_fips() (
  build_openssl_fips_module

  curl -sLo 'openssl-fips.tar.gz' "${OPENSSL_FIPS_URL}"
  common::extract 'openssl-fips.tar.gz' "${OPENSSL_FIPS_BUILD_DIR}"
  common::safe_cd "${OPENSSL_FIPS_BUILD_DIR}"

  CFLAGS="${GCC_OPTS}" \
    ./config \
      fips \
      --with-fipsdir="${OPENSSL_FIPS_DIR}" \
      no-shared \
      --prefix=${OPENSSL_FIPS_DIR} \
      enable-weak-ssl-ciphers \
      enable-deprecated \
      enable-rc4
  make depend
  make -j"$(nproc)"
  make install_sw

  echo "[+] Finished building OpenSSL (FIPS version) for ${CURRENT_ARCH}"
)