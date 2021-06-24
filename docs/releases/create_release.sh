#!/bin/bash
#
# Generate a release from an exported Processing application.
#
# Requirements: bash, coreutils, zip
#

set -euo pipefail
IFS=$'\n\t'

version="${1:-}"
platform="${2:-}"
root_dir="../.."

# Check if we have everything we need

if [ -z "${version}" -o -z "${platform}" ]; then
    echo "usage: $(basename $0) version platform"
    exit 1
fi
if [ "${platform}" != "windows" -a "${platform}" != "linux" ]; then
    echo "usage: $(basename $0) version platform"
    exit 1
fi

spaces_regex="[[:space:]]+"
if [[ "${version}" =~ $spaces_regex ]]; then
    echo "ERROR: version shouldn't contain spaces"
    exit 1
fi
if [[ "${platform}" =~ $spaces_regex ]]; then
    echo "ERROR: platform shouldn't contain spaces"
    exit 1
fi

if [ "${platform}" == "windows" -a ! -d "${root_dir}/dungeoneering/application.windows64/" ]; then
    echo "ERROR: dir application.windows64 not found"
    exit 1
fi
if [ "${platform}" == "linux" -a ! -d "${root_dir}/dungeoneering/application.linux64/" ]; then
    echo "ERROR: dir application.linux64 not found"
    exit 1
fi

if [ "${platform}" == "windows" -a -d "${root_dir}/releases/${version}/dungeoneering-windows64/" ]; then
    echo "ERROR: dir dungeoneering-windows64 already exists"
    exit 1
fi
if [ "${platform}" == "linux" -a -d "${root_dir}/releases/${version}/dungeoneering-linux64/" ]; then
    echo "ERROR: dir dungeoneering-linux64 already exists"
    exit 1
fi

echo "Creating release dungeoneering-${platform}64.zip..."

# Go to application root dir

cd ${root_dir}

# Exclude uneeded exported applications

if [ "${platform}" == "windows" ]; then
    echo -n "  Exclude application.windows32 directory..."
    if [ -d dungeoneering/application.windows32/ ]; then
        rm -r dungeoneering/application.windows32/
    fi
    echo " done"
fi
if [ "${platform}" == "linux" ]; then
    echo -n "  Exclude application.linux32 directory..."
    if [ -d dungeoneering/application.linux32/ ]; then
        rm -r dungeoneering/application.linux32/
    fi
    echo " done"
    echo -n "  Exclude application.linux-arm64 directory..."
    if [ -d dungeoneering/application.linux-arm64/ ]; then
        rm -r dungeoneering/application.linux-arm64/
    fi
    echo " done"
    echo -n "  Exclude application.linux-armv6hf directory..."
    if [ -d dungeoneering/application.linux-armv6hf/ ]; then
        rm -r dungeoneering/application.linux-armv6hf/
    fi
    echo " done"
fi

# Create version root dir

echo -n "  Create ${version} directory..."
mkdir -p releases/${version}
echo " done"

# Move application dir to version dir

if [ "${platform}" == "windows" ]; then
    working_dir=dungeoneering-windows64
    echo -n "  Move application.windows64 to ${working_dir}..."
    mv dungeoneering/application.windows64 releases/${version}/${working_dir}
    echo " done"
fi
if [ "${platform}" == "linux" ]; then
    working_dir=dungeoneering-linux64
    echo -n "  Move application.linux64 to ${working_dir}..."
    mv dungeoneering/application.linux64 releases/${version}/${working_dir}
    echo " done"
fi

# Copy release files to version dir

echo -n "  Copy release files to ${working_dir}..."
cp docs/releases/*.txt releases/${version}/${working_dir}/
cp docs/CHANGELOG.md releases/${version}/${working_dir}/CHANGELOG.txt
echo " done"

# Copy libraries to lib dir and then remove platform specific files

echo -n "  Copy libraries to ${working_dir}/lib..."
cp -r dungeoneering/code/* releases/${version}/${working_dir}/lib
rm -r releases/${version}/${working_dir}/lib/macosx64/
rm -r releases/${version}/${working_dir}/lib/windows32/
if [ "${platform}" == "linux" ]; then
    rm -r releases/${version}/${working_dir}/lib/windows64/
fi
echo " done"

# Remove unnecessary files from version dir

echo -n "  Remove unnecessary files from ${working_dir}..."
rm releases/${version}/${working_dir}/source/dungeoneering.java
rm -r releases/${version}/${working_dir}/data/icons/orig/
if [ -d releases/${version}/${working_dir}/data/campaign/ ]; then
    rm -r releases/${version}/${working_dir}/data/campaign/
fi
echo " done"

# Create release zip file

echo -n "  Create a ZIP file with ${working_dir} contents..."
cd releases/${version}
zip -qr ${working_dir}.zip ${working_dir}/
echo " done"

echo "Done"
