#!/usr/bin/env bash

set -u
set -e
set -x

ARCH="$1"
REPO="$2"
EXPORT_ARGS="$3"
FB_ARGS="$4"
SUBJECT=${5:-"Build started at $(LC_ALL=C date)"}

FLATPAK_ID="io.winebar.Sdk"
#FIXME: unhardcode
BRANCH="master"

TOP_BUILDDIR="builddir"
BUILDDIR="${TOP_BUILDDIR}/${FLATPAK_ID}-${ARCH}-${BRANCH}"

declare -A EXPORT_ARCHES
EXPORT_ARCHES[i386]="x86_64"

flatpak-builder --force-clean --ccache --sandbox \
                --arch="${ARCH}" --repo="${REPO}" \
                --default-branch="${BRANCH}" \
                --subject="${SUBJECT}" \
                ${FB_ARGS} ${EXPORT_ARGS} \
                "${BUILDDIR}" "${FLATPAK_ID}.yml"

if [[ "${!EXPORT_ARCHES[*]}" =~ ${ARCH} ]]; then
    for export_arch in ${EXPORT_ARCHES[$ARCH]}; do
        compat_metadata="platform-compat-${ARCH}"
        cp "metadata/${compat_metadata}" "${BUILDDIR}/${compat_metadata}"
        flatpak build-export \
                --runtime --arch="${export_arch}" \
                --metadata="${compat_metadata}" \
                --files="platform/lib/${ARCH}-linux-gnu" \
                ${EXPORT_ARGS} \
                --subject="${SUBJECT}" \
                "${REPO}" "${BUILDDIR}" "${BRANCH}"
    done
fi

rm -rf "${BUILDDIR}"
