#!/bin/bash
set -e
set -x
set -o pipefail

. "${GITHUB_WORKSPACE}/build/common_lib.sh"
. "${GITHUB_WORKSPACE}/build/build_lib.sh"

LIBMAGIC_BUILD_DIR="${BUILD_DIRECTORY}/file-src"
export LIBMAGIC_DIR="${BUILD_DIRECTORY}/libmagic"

# NOTE: libmagic comes with the file utility.
# NOTE: The file utility and libmagic have the same version.
# NOTE: The file command on the build host must be the same version as the one we are building.
# TODO: The file utility itself is currently linked dynamically - add options?
build_libmagic() (
  file_version="$(file --version | grep 'file-' | cut -d- -f2)"
  if [ -z "${file_version}" ]; then
    common::print_to_stderr '[!] Failed to get file utility version on the build host'
    exit 1
  fi
  echo "[i] file utility version on the build host is ${file_version}"

  file_url="ftp://ftp.astron.com/pub/file/file-${file_version}.tar.gz"
  curl -sLo 'file.tar.gz' "${file_url}"
  common::extract 'file.tar.gz' "${LIBMAGIC_BUILD_DIR}"
  common::safe_cd "${LIBMAGIC_BUILD_DIR}"

  # --build is crucial - without it cross-compilation will fail
  CFLAGS="${GCC_OPTS}" \
    CXXFLAGS="${GXX_OPTS}" \
    ./configure \
      --build="$(./config.guess)" \
      --host="$(build::get_host_triplet)" \
      --disable-dependency-tracking \
      --prefix="${LIBMAGIC_DIR}" \
      --disable-zlib \
      --disable-bzlib \
      --disable-xzlib \
      --disable-libseccomp
  make -j"$(nproc)"
  make install

  echo "[+] Finished building libmagic for ${CURRENT_ARCH}"
)