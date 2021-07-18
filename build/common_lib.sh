#!/bin/bash

#######################################
# Print provided text to stderr.
# Globals:
#   None
# Arguments:
#   Text to print
# Outputs:
#   The text -> stderr
#######################################
common::print_to_stderr() (
  text_to_print="${1:?[!] The text to print is not specified}"
  printf '%b' "${text_to_print}" >&2
)


#######################################
# Changes directory and exits on fail.
# Globals:
#   None
# Arguments:
#   Directory to enter
# Outputs:
#   None
#######################################
common::safe_cd() {
  local target_dir="${1:?[!] Target directory is not specified}"
  cd "${target_dir}" || {
    common::print_to_stderr "[!] Cannot cd to ${target_dir}"
    exit 1
  }
}


#######################################
# Extract an archive to destination directory.
# Globals:
#   None
# Arguments:
#   Archive to extract, absolute path
#   Destintaion directory, absolute path
# Outputs:
#   None
#######################################
common::extract() (
  archive="${1:?[!] Path to the archive is not specified}"
  destination="${2:?[!] Destination path is not specified}"
  if [ ! -d "$destination" ]; then
    mkdir -p "$destination"
  fi
  if [ -f "$archive" ]; then
    case "$archive" in
      *.tar.bz2)  tar xjf "$archive" -C "$destination" --strip-components 1  ;;
      *.tar.gz)   tar xzf "$archive" -C "$destination" --strip-components 1  ;;
      *.tar.xz)   tar xvfJ "$archive" -C "$destination" --strip-components 1 ;;
      *.tar)      tar xf "$archive" -C "$destination" --strip-components 1   ;;
      *.tbz2)     tar xjf "$archive" -C "$destination" --strip-components 1  ;;
      *.tgz)      tar xzf "$archive" -C "$destination" --strip-components 1  ;;
      *)          common::print_to_stderr "[!] '${archive}' cannot be extracted with extract()"; return 1 ;;
    esac
  else
    common::print_to_stderr "[!] '${archive}' is not a valid file"
    return 1
  fi  
)


#######################################
# Remove leading and trailing whitespaces.
# Globals:
#   None
# Arguments:
#   Text to trim
# Outputs:
#   Trimmed text -> stdout
#######################################
common::trim() (
  text_to_trim="$*"
  echo "${text_to_trim}" | sed 's/^ *//g' | sed 's/ *$//g'
)


#######################################
# Check if a word is in a list delimited by spaces.
# Globals:
#   None
# Arguments:
#   Word (e.g. "dog")
#   List (e.g. "cat dog mouse")
# Outputs:
#   None
#######################################
common::is_word_in_spaced_list() (
  searched_word="${1:?[!] Word is not specified}"
  list="${2:?[!] List is not specified}"

  # Won't need to restore IFS - running in a subshell
  IFS=' '
  set -f
  for word in ${list}; do
    if [ "${word}" = "${searched_word}" ]; then
      return 0
    fi
  done
  return 1
)


#######################################
# Create temporary directory.
# Globals:
#   None
# Arguments:
#   Base directory (absolute path?)
# Outputs:
#   Created temp directory (absolute path) -> stdout
#######################################
common::create_temp_dir() (
  base_dir="${1}"
  tmp_dir="$(mktemp -dt -p "${base_dir}" tmpdir.XXXXXX)"
  echo "${tmp_dir}"
)