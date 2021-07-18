#!/bin/bash
# Due to difficulties in determining path to a script when it is sourced 
#   by another one, it is quite hard to source a lib from a sourced lib.
# Thus, all dependencies must be already sourced by the sourcing script.

# Dependencies:
#   - common_lib.sh

# NOTE: Every build script must source this lib.
export BUILD_DIRECTORY="/build"
export OUTPUT_DIRECTORY="/output"
export GCC_OPTS="-static -fPIC"
export GXX_OPTS="-static -static-libstdc++ -fPIC"


#######################################
# Initialise the library and building env.
# Must be called before any other function.
# Globals:
#   CURRENT_ARCH - w
#   BUILD_DIRECTORY - r
#   OUTPUT_DIRECTORY - r
# Arguments:
#   Arch for which the bins will be compiled
# Outputs:
#   None
#######################################
build::init() {
  if [ "$#" -ne 1 ]; then
    common::print_to_stderr "[!] Arch is not specified"
  fi
  case "$1" in
    'x86'|'x86-64'|'armhf'|'aarch64')  : ;;
    *)  common::print_to_stderr "[!] Arch '$1' is not supported"; exit 1 ;;
  esac
  # Every binary/library is built by a separate script - need to use env var.
  # CURRENT_ARCH is the arch of the host which will run the built binaries.
  export CURRENT_ARCH="${1}"

  if [ ! -d "${BUILD_DIRECTORY}" ]; then
    mkdir -p "${BUILD_DIRECTORY}"
  fi
  if [ ! -d "${OUTPUT_DIRECTORY}" ]; then
    mkdir -p "${OUTPUT_DIRECTORY}"
  fi
}


#######################################
# Get host triplet for CURRENT_ARCH.
# Globals:
#   CURRENT_ARCH - r
# Arguments:
#   None
# Outputs:
#   Host triplet -> stdout
#######################################
build::get_host_triplet() (
  case "${CURRENT_ARCH}" in
    'x86')      echo 'i686-linux-musl'      ;;
    'x86-64')   echo 'x86_64-linux-musl'    ;;
    'armhf')    echo 'arm-linux-musleabihf' ;;
    'aarch64')  echo 'aarch64-linux-musl'   ;;
    *)          common::print_to_stderr "[!] Arch '${CURRENT_ARCH}' is not supported"; exit 1 ;;
  esac
)


#######################################
# Get bitness of CURRENT_ARCH.
# Globals:
#   CURRENT_ARCH - r
# Arguments:
#   None
# Outputs:
#   Arch bitness -> stdout
#######################################
build::get_current_arch_bitness() (
  case "${CURRENT_ARCH}" in
    'x86')      echo '32' ;;
    'x86-64')   echo '64' ;;
    'armhf')    echo '32' ;;
    'aarch64')  echo '64' ;;
    *)          common::print_to_stderr "[!] Arch '${CURRENT_ARCH}' is not supported"; exit 1 ;;
  esac
)


#######################################
# Get architecture for which a library was built.
# Globals:
#   None
# Arguments:
#   Library to check
# Outputs:
#   Library architecture -> stdout
#######################################
build::get_lib_arch() (
  lib="${1:?[!] Library is not specified}"
  if [ ! -f "${lib}" ]; then
    # TODO: error?
    echo ""
    return
  fi

  tmp_dir="$(common::create_temp_dir)"
  cp "${lib}" "${tmp_dir}"
  sh -c "cd ${tmp_dir}; ar x $(basename "${lib}")"
  output="$(find "${tmp_dir}" -name "*.o" -exec file {} \;)"
  if echo "$output" | grep -q "Intel 80386"; then
    echo "x86"
  elif echo "$output" | grep -q "x86-64"; then
    echo "x64"
  elif echo "$output" | grep -q "ARM aarch64";then
    echo "armhf"
  elif echo "$output" | grep -q "ARM,";then
    echo "aarch64"
  else
    common::print_to_stderr "[!] Library ${lib} is for an unsupported arch"
    echo ""
  fi
)


#######################################
# Determine the version of a built binary by querying it.
# Globals:
#   CURRENT_ARCH - r
# Arguments:
#   Binary to check
# Outputs:
#   Binary version -> stdout
#######################################
build::get_binary_version() (
  cmd="$1"
  if [ -z "${cmd}" ]; then
    error_text="[!] Please provide a command to determine the version"
    error_text="${error_text}\nExample: /build/test --version | awk '{print \$2}'"
    common::print_to_stderr "${error_text}"
    exit 1
  fi
  version="-"
  if [ "${CURRENT_ARCH}" = "armhf" ]; then
    if command -v qemu-arm 1>&2 2>/dev/null; then
      cmd="qemu-arm ${cmd}"
      version="${version}$(eval "${cmd}")"
    else
      common::print_to_stderr "[i] qemu-arm not found, skipping ARMhf version checks"
    fi
  elif [ "${CURRENT_ARCH}" = "aarch64" ]; then
    if command -v qemu-aarch64 1>&2 2>/dev/null; then
      cmd="qemu-aarch64 ${cmd}"
      version="${version}$(eval "${cmd}")"
    else
      common::print_to_stderr "[i] qemu-aarch64 not found, skipping AArch64 version checks"
    fi
  else
    version="${version}$(eval "${cmd}")"
  fi
  if [ "${version}" = "-" ]; then
    version="${version}${CURRENT_ARCH}"
  else
    version="${version}-${CURRENT_ARCH}"
  fi
  echo "${version}"
)


#######################################
# Append value to PKG_CONFIG_LIBDIR env var.
# Globals:
#   PKG_CONFIG_LIBDIR - rw
# Arguments:
#   Path to append
# Outputs:
#   None
#######################################
build::append_to_pkgconfig_libdir() {
  path_to_append="${1:?[!] Path is not specified}"
  if [ -z "${PKG_CONFIG_LIBDIR}" ]; then
    export PKG_CONFIG_LIBDIR="${path_to_append}"
  else
    export PKG_CONFIG_LIBDIR="${PKG_CONFIG_LIBDIR}:${path_to_append}"
  fi
}