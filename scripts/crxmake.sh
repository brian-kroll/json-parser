#!/usr/bin/env bash
#
# Purpose: Pack a Chromium extension directory into crx format


dir="../extension"
name=$(basename "$dir")
crx="../packaged/JsonParser.crx"
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
        printf "   crxmake.sh -k <sign_key> -o <package>\n\n"
        printf "Options:\n"
        printf "   sign_key  Path to key-file to sign package\n"
        printf "   package   Path to output package\n\n"
    )
    exit 0
}

function _run () {
    [ 3 -gt ${#} ] && print_help

    local key_file=""
    local output_file="${crx}"
    while getopts "k:o:h" opt; do
        case ${opt} in
            \?)
                printf "Invalid option ${1}\n"
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
                dir_path="$(cd "$(dirname "${output_file}")"; pwd -P)"
                if [ ! -d "${dir_path}" ]; then
                    printf "The directory\n   ${dir_path} \ndoes not exist."
                    exit 1
                fi
                crx="${dir_path}/$(basename ${output_file})"
                ;;
        esac
    done
echo $key_file
exit

    # zip up the crx dir
    cwd=$(pwd -P)
    (cd "$dir" && zip -qr -9 -X "$cwd/$zip" .)

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
    ) > "${crx}"
    echo "Wrote ${crx}"
}

## dont't run if sourced
[ "$0" = "$BASH_SOURCE" ] && _run "${@}"
