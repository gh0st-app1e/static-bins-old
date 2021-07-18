#!/bin/bash
. "${GITHUB_WORKSPACE}/build/common_lib.sh"
. "${GITHUB_WORKSPACE}/build/build_lib.sh"


# Requires:
# - libgmp
# - libnettle
# Optional:
# - p11-kit for PKCS #11 support
# - trousers for TPM support
# - libidn2 for Internationalized Domain Names support
# - libunbound for DNSSEC/DANE functionality
build_gnutls() {
  local gnutls_version=${GNUTLS_VERSION:-3.6.15}
  local gnutls_url="https://www.gnupg.org/ftp/gcrypt/gnutls/v${gnutls_version%.*}/gnutls-${gnutls_version}.tar.xz"
  local gnutls_build_dir="${BUILD_DIRECTORY}/gnutls-src"
  export GNUTLS_DIR="${BUILD_DIRECTORY}/gnutls"

  curl -sLo 'gnutls.tar.xz' "${gnutls_url}"
  common::extract 'gnutls.tar.xz' "${gnutls_build_dir}"
  common::safe_cd "${gnutls_build_dir}"

  # For some reason pkg-config cannot find gmp even when pointed to its .pc file with PKG_CONFIG_LIBDIR.
  # Using CPPFLAGS/LDFLAGS workaround for now.
  CFLAGS="${GCC_OPTS}" \
    CXXFLAGS="${GXX_OPTS}" \
    CPPFLAGS="-I${LIBGMP_DIR}/include" \
    LDFLAGS="-L${LIBGMP_DIR}/lib" \
    ./configure \
      --host="$(build::get_host_triplet)" \
      --disable-dependency-tracking \
      --prefix="${GNUTLS_DIR}" \
      --disable-shared \
      --enable-static \
      --disable-doc \
      --disable-tools \
      --disable-nls \
      --disable-rpath \
      --enable-cross-guesses=conservative \
      --enable-sha1-support \
      --enable-ssl3-support \
      --with-included-libtasn1 \
      --with-included-unistring \
      --without-p11-kit
  make -j"$(nproc)"
  make install
  build::append_to_pkgconfig_libdir "${GNUTLS_DIR}/lib/pkgconfig"

  echo "[+] Finished building gnutls for ${CURRENT_ARCH}"
}