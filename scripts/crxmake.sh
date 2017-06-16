#!/usr/bin/env bash
#
# Purpose: Pack a Chromium extension directory into crx format


extension_dir="extension"
name=$(basename "$dir")
crx_file="JsonParser.crx"
pub="$name.pub"
sig="$name.sig"
zip="$name.zip"
# cleanup on exit
trap 'rm -f "$pub" "$sig" "$zip"' EXIT

byte_swap () {
  # Take "abcdefgh" and return it as "ghefcdab"
  echo "${1:6:2}${1:4:2}${1:2:2}${1:0:2}"
}

print_help () {
    (
        printf "Usage:\n"
        printf "   crxmake.sh -k <sign_key> [-o <package> -e <extension>]\n\n"
        printf "Options:\n"
        printf "   sign_key  Path to key-file to sign package - optional if not present a new key will be generated\n"
        printf "   package   Path to output package (default 'JsonParser.crx') \n"
        printf "   extension Path to unpacked extension to pack (default 'extension')\n\n"
    )
    [ -n "$1" ] && {
        printf "\n"
        printf "You must provide a private key to sign your package.\n"
        printf "If you don't have one, you can generate it:\n"
        printf "    openssl genrsa -out extension.pem 2048\n"
        printf "Keep you key in a safe place -- you need it to update the extension later"
    }
    exit 0
}

function _run () {
    local key_file=""
    local output_file="${crx_file}"
    while getopts "k:o:e:h" opt; do
        case ${opt} in
            \?)
                ;&
            h)
                print_help
                ;;
            k)
                key_file="${OPTARG}"
                file_path="$(cd "$(dirname "${key_file}")"; pwd -P)"/$(basename ${key_file})
                if [ ! -f "${file_path}" ]; then
                    printf "Could not find key file\n    ${file_path}\n".
                    exit 1
                fi
                key_file=${file_path}
                ;;
            o)
                output_file="${OPTARG}"
                ;;
            e)  extension_dir="${OPTARG}"
                ;;
        esac
    done

    out_dir_path=$(cd "$(dirname ${output_file})" 2>/dev/null && pwd -P)
    if [ ! -d "${out_dir_path}" ]; then
        printf "The directory to write the extension to\n   $(dirname ${output_file}) \ndoes not exist.\n"
        exit 1
    fi
    crx_file="${out_dir_path}/$(basename ${output_file})"
    [ "${crx_file##*.}" == "crx" ] || crx_file="${crx_file}.crx"

    input_dir_path=${extension_dir}
    if [ ! -d "${input_dir_path}" ]; then
        printf "Could not find directory to pack:\n   ${input_dir_path}\n"
        exit 1
    fi

    [ 2 -gt ${#} ] && print_help
    [ -z "${key_file}" ] && print_help 1

    # zip up the crx dir
    cwd=$(pwd -P)
    (cd "$input_dir_path" && zip -qr -9 -X "$cwd/$zip" .)

    # signature
    openssl sha1 -sha1 -binary -sign "${key_file}" < "${zip}" > "${sig}"

    # public key
    openssl rsa -pubout -outform DER < "${key_file}" > "${pub}" 2>/dev/null

    crmagic_hex="4372 3234" # Cr24
    version_hex="0200 0000" # 2
    pub_len_hex=$(byte_swap $(printf '%08x\n' $(ls -l "${pub}" | awk '{print $5}')))
    sig_len_hex=$(byte_swap $(printf '%08x\n' $(ls -l "${sig}" | awk '{print $5}')))
    (
      echo "${crmagic_hex} ${version_hex} ${pub_len_hex} ${sig_len_hex}" | xxd -r -p
      cat "${pub}" "${sig}" "${zip}"
    ) > "${crx_file}"
    echo "Wrote ${crx_file}"
}

## dont't run if sourced
[ "$0" = "$BASH_SOURCE" ] && _run "${@}"
