#!/usr/bin/env bash

# shellcheck disable=SC1091,SC2155

set -Eeuo pipefail

source "$(dirname "$0")"/Commons/common.sh

#################
#   CONSTANTS   #
#################

readonly SCRIPT_NAME=$(basename -s ".sh" "$0")
readonly SCRIPT_FULL_NAME=$(basename "$0")
readonly SCRIPT_ABS_PATH="$(cd "$(dirname "${BASH_SOURCE[0]}")" >/dev/null 2>&1 && pwd -P)"
readonly SCRIPT_TEMPLATES_ABS_PATH="$SCRIPT_ABS_PATH/Templates"

readonly OPTION_HELP_SHORT="-h"
readonly OPTION_HELP="--help"

readonly PRODUCT_CONFIDENTIAL="confidential"

readonly SWIFT_BUILD_ARCH_X86="x86_64"
readonly SWIFT_BUILD_ARCH_ARM="arm64" 
readonly SWIFT_BUILD_DIR_NAME=".build"

readonly UNIVERSAL_BIN_DIR_ABS_PATH="$SCRIPT_ABS_PATH/../$SWIFT_BUILD_DIR_NAME/universal"

readonly LICENSE_ABS_PATH="$SCRIPT_ABS_PATH/../LICENSE"
readonly ARTIFACT_BUNDLE_INFO_TEMPLATE_ABS_PATH="$SCRIPT_TEMPLATES_ABS_PATH/artifactbundle-info.json.template"

readonly RELEASE_DIR_NAME=".release"
readonly RELEASE_DIR_ABS_PATH="$SCRIPT_ABS_PATH/../$RELEASE_DIR_NAME"

readonly ERROR_MSG_SEE_USAGE_HELP="Use ${BOLD}$OPTION_HELP_SHORT${NORMAL} | ${BOLD}$OPTION_HELP${NORMAL} option for usage help."

########################
#   GLOBAL VARIABLES   #
########################

VERSION_STRING=""

TMP_DIR_PATH=""
UNIVERSAL_BIN_ABS_PATH=""

#################
#   FUNCTIONS   #
#################

function help() {
    cat << MANUAL

${BOLD}NAME${NORMAL}
    ${BOLD}$SCRIPT_NAME${NORMAL}

${BOLD}SYNOPSIS${NORMAL}
    ${BOLD}$SCRIPT_FULL_NAME${NORMAL} ${UNDERLINE}version${NORMAL}
    ${BOLD}$SCRIPT_FULL_NAME${NORMAL} ${BOLD}$OPTION_HELP_SHORT${NORMAL} | ${BOLD}$OPTION_HELP${NORMAL}

${BOLD}DESCRIPTION${NORMAL}
    ${BOLD}$SCRIPT_NAME${NORMAL} is a script that generates the release artifacts tagging
    them with the supplied ${UNDERLINE}version${NORMAL} string. The generated artifacts are saved in the
    ${BOLD}$RELEASE_DIR_NAME${NORMAL} directory located in the package's root directory.

    Generated artifacts include:
        • The zip archive containing SwiftPM artifact bundle with ${BOLD}$PRODUCT_CONFIDENTIAL${NORMAL} CLI tool
          binary for macOS.

${BOLD}DEPENDENCIES${NORMAL}
    The ${BOLD}$SCRIPT_NAME${NORMAL} script has the following dependencies:
        • ${BOLD}Bash 4.2 or newer${NORMAL} - you can upgrade Bash with ${UNDERLINE}upgrade_bash.sh${NORMAL} script.
        • ${BOLD}Swift 5.6${NORMAL} - Swift toolchain comes bundled with Xcode.

    Make sure that all dependencies are installed before you start using the script.

${BOLD}ARGUMENTS${NORMAL}
    
    ${UNDERLINE}version${NORMAL}
        The release version following the MAJOR.MINOR.PATCH scheme.

${BOLD}OPTIONS${NORMAL}
    Options start with one or two dashes.

    ${BOLD}$OPTION_HELP_SHORT${NORMAL}, ${BOLD}$OPTION_HELP${NORMAL}
        Show usage description.

${BOLD}EXAMPLE USAGE${NORMAL}
    Generate artifacts for release tagged with version 0.0.1.
    ${BOLD}$SCRIPT_FULL_NAME 0.0.1${NORMAL}

MANUAL
}

function read_version_argument() {
    if [[ $# -eq 0 ]]
    then
        echoerr "No version provided. $ERROR_MSG_SEE_USAGE_HELP"
        exit 1
    fi
    if [[ ! $1 =~ ^[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}$ ]]
    then
        echoerr "Invalid version format: $1"
        exit 1
    fi

    VERSION_STRING="$1"
}

function set_up() {
    echo "---------------------------- SET UP ----------------------------"
    echo "🍳"

    echo "Cleaning up SPM build artifacts"
    swift package clean

    echo "Making temporary output directory"
    TMP_DIR_PATH=$(mktemp -d "$(pwd -P)/$SCRIPT_NAME.tmp.XXXXXXXXXX")

    echo "-------------------------- END SET UP --------------------------"
}

function clean_up() {
    echo "--------------------------- CLEAN UP ---------------------------"
    echo "🧽"

    # SPM .build directory generated by SPM interferes with 
    # Xcode build system, so it needs to be removed once script execution is done.
    local -r swift_build_dir_path="$SCRIPT_ABS_PATH/../$SWIFT_BUILD_DIR_NAME"
    if [[ -d "$swift_build_dir_path" ]]
    then
        echo "Deleting SPM $SWIFT_BUILD_DIR_NAME directory"
        rm -rf "$swift_build_dir_path"
    fi

    if [[ -d "$TMP_DIR_PATH" ]]
    then
        echo "Removing temporary output directory"
        rm -rf "$TMP_DIR_PATH"
    fi

    echo "------------------------- END CLEAN UP -------------------------"
}

function swift_build_cmd() {
    echo "swift build --product $1 --configuration release -Xlinker -dead_strip --arch $2"
}

function build_product() {
    eval "$(swift_build_cmd "$1" "$2") > /dev/null"
    local -r bin_path=$(eval "$(swift_build_cmd "$1" "$2") --show-bin-path")

    echo "$bin_path/$1"
}

function build_universal_binary() {
    local -r product="$1"
    echo_progress "Building $product product for $SWIFT_BUILD_ARCH_X86 architecture"
    local -r x86_bin_path=$(build_product "$product" "$SWIFT_BUILD_ARCH_X86")
    echo_progress "Building $product product for $SWIFT_BUILD_ARCH_ARM architecture"
    local -r arm_bin_path=$(build_product "$product" "$SWIFT_BUILD_ARCH_ARM")

    echo_progress "Creating fat binary for $SWIFT_BUILD_ARCH_X86+$SWIFT_BUILD_ARCH_ARM"
    mkdir -p "$UNIVERSAL_BIN_DIR_ABS_PATH"
    UNIVERSAL_BIN_ABS_PATH="$UNIVERSAL_BIN_DIR_ABS_PATH/$product"
    lipo "$x86_bin_path" "$arm_bin_path" -create -output "$UNIVERSAL_BIN_ABS_PATH"
    strip -rSTx "$UNIVERSAL_BIN_ABS_PATH"
}

function spm_artifactbundle() {
    echo "---------------------- SPM ARTIFACT BUNDLE ---------------------"

    local -r product="$1"
    build_universal_binary "$product"

    echo_progress "Generating SPM artifact bundle"
    local -r bundle_name="$product.artifactbundle"
    local -r bundle_path="$TMP_DIR_PATH/$bundle_name"
    local -r bundle_bin_path="$bundle_path/$product-$VERSION_STRING-macos/bin"
    mkdir -p "$bundle_bin_path"
    sed "s/__NAME__/$product/g; s/__VERSION__/$VERSION_STRING/g" "$ARTIFACT_BUNDLE_INFO_TEMPLATE_ABS_PATH" > "$bundle_path/info.json"
    cp -f "$UNIVERSAL_BIN_ABS_PATH" "$bundle_bin_path"
    cp -f "$LICENSE_ABS_PATH" "$bundle_path"

    mkdir -p "$RELEASE_DIR_ABS_PATH"

    echo_progress "Archiving SPM artifact bundle"
    local -r bundle_archive_name="${product^}Binary-macos.artifactbundle.zip"
    pushd_quiet "$TMP_DIR_PATH"
    zip -qr "$RELEASE_DIR_ABS_PATH/$bundle_archive_name" "$bundle_name"
    popd_quiet

    pushd_quiet "$SCRIPT_ABS_PATH/.."
    echo -e "Bundle checksum:\n$(swift package compute-checksum "./$RELEASE_DIR_NAME/$bundle_archive_name")"
    popd_quiet

    echo "-------------------- END SPM ARTIFACT BUNDLE -------------------"
}

###################
#   ENTRY POINT   #
###################

while [[ $# -gt 0 ]]
do
key="$1"

case $key in
    "$OPTION_HELP_SHORT" | "$OPTION_HELP")
        help
        exit 0
        ;;
    *)
        break
        ;;
esac
done

read_version_argument "$@"

trap clean_up EXIT

set_up

spm_artifactbundle "$PRODUCT_CONFIDENTIAL"
