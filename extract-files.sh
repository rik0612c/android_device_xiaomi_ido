#!/bin/bash
#
# Copyright (C) 2016 The CyanogenMod Project
# Copyright (C) 2017-2020 The LineageOS Project
#
# SPDX-License-Identifier: Apache-2.0
#

set -e

DEVICE=ido
VENDOR=xiaomi

# Load extract_utils and do some sanity checks
MY_DIR="${BASH_SOURCE%/*}"
if [[ ! -d "${MY_DIR}" ]]; then MY_DIR="${PWD}"; fi

ANDROID_ROOT="${MY_DIR}/../../.."

HELPER="${ANDROID_ROOT}/tools/extract-utils/extract_utils.sh"
if [ ! -f "${HELPER}" ]; then
    echo "Unable to find helper script at ${HELPER}"
    exit 1
fi
source "${HELPER}"

# Default to sanitizing the vendor folder before extraction
CLEAN_VENDOR=true

KANG=
SECTION=

while [ "${#}" -gt 0 ]; do
    case "${1}" in
        -n | --no-cleanup )
                CLEAN_VENDOR=false
                ;;
        -k | --kang )
                KANG="--kang"
                ;;
        -s | --section )
                SECTION="${2}"; shift
                CLEAN_VENDOR=false
                ;;
        * )
                SRC="${1}"
                ;;
    esac
    shift
done

if [ -z "${SRC}" ]; then
    SRC="adb"
fi

function blob_fixup() {
    case "${1}" in
        # Patch DRM blob to resolve moved symbol
        vendor/lib/mediadrm/libwvdrmengine.so)
        "${PATCHELF}" --replace-needed "libprotobuf-cpp-lite.so" "libprotobuf-cpp-lite-v29.so" "${2}"
            ;;
    esac
}

# Initialize the helper
setup_vendor "${DEVICE}" "${VENDOR}" "${ANDROID_ROOT}" false "${CLEAN_VENDOR}"

extract "${MY_DIR}/proprietary-files.txt" "${SRC}" "${KANG}" --section "${SECTION}"

BLOB_ROOT="${ANDROID_ROOT}/vendor/${VENDOR}/${DEVICE}/proprietary"

sed -i "s|/system/etc/aanc_tuning_mixer.txt|/vendor/etc/aanc_tuning_mixer.txt|g" "${BLOB_ROOT}/vendor/lib/libacdbloader.so"
sed -i "s|/system/etc/aanc_tuning_mixer.txt|/vendor/etc/aanc_tuning_mixer.txt|g" "${BLOB_ROOT}/vendor/lib64/libacdbloader.so"
sed -i "s|system/etc|vendor/etc|g" "${BLOB_ROOT}/vendor/lib/hw/sound_trigger.primary.msm8916.so"
sed -i "s|system/lib|vendor/lib|g" "${BLOB_ROOT}/vendor/lib/hw/sound_trigger.primary.msm8916.so"

"${MY_DIR}/setup-makefiles.sh"
