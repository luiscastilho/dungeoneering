#!/bin/bash
#
# Generate a release from an exported Processing application.
#
# By default, dungeoneering is exported in standalone mode. The main folder
# (dungeoneering) and code file (dungeoneering.pde) have to be renamed to be
# exported in other modes - dungeoneeringDm/dungeoneeringDm.pde for DM mode and
# dungeoneeringPlayers/dungeoneeringPlayers.pde for Players' mode. The main
# code file has to be edited, commenting or uncommenting these lines
# accordingly:
#    appMode = AppMode.standalone;
#    // appMode = AppMode.dm;
#    // appMode = AppMode.players;
#
# When exporting in Players' mode, also swap these lines, so the app will run
# on the second monitor:
#    fullScreen(P2D, 1);
#    // fullScreen(P2D, 2);
#
# Also, remember to sync info between index.md and TXT files on docs/releases.
#
# Requirements: bash, coreutils, zip
# macOS requirements: Homebrew, coreutils, findutils
#

set -euo pipefail
IFS=$'\n\t'

version="${1:-}"
platform="${2:-}"
app_mode="${3:-}"
root_dir="../.."
working_dir=""
working_subdir=""

usage() {
    echo "usage: $(basename "$0") version platform [app_mode]"
    echo "Creates a dungeoneering release"
    echo "version should be vX.Y.Z"
    echo "platform should be windows, linux, or macos"
    echo "app_mode is used only in macOS and should be standalone, dm, or players"
    exit 1
}

# Check if we have everything we need

if [ -z "${version}" ] || [ -z "${platform}" ]; then
    usage
fi
if [ "${platform}" != "windows" ] && [ "${platform}" != "linux" ] && [ "${platform}" != "macos" ]; then
    usage
fi
if [ -n "${app_mode}" ] && [ "${app_mode}" != "standalone" ] && [ "${app_mode}" != "dm" ] && [ "${app_mode}" != "players" ]; then
    usage
fi

spaces_regex="[[:space:]]+"
version_regex="v[[:digit:]]+\.[[:digit:]]+\.[[:digit:]]+"
if [[ "${version}" =~ $spaces_regex ]]; then
    echo "ERROR: version shouldn't contain spaces"
    exit 1
fi
if [[ "${platform}" =~ $spaces_regex ]]; then
    echo "ERROR: platform shouldn't contain spaces"
    exit 1
fi
if [[ "${app_mode}" =~ $spaces_regex ]]; then
    echo "ERROR: app_mode shouldn't contain spaces"
    exit 1
fi
if [[ ! "${version}" =~ $version_regex ]]; then
    echo "ERROR: version should be in format vX.Y.Z"
    exit 1
fi

if [ "${platform}" == "windows" ] && [ ! -d "${root_dir}/dungeoneering/windows-amd64/" ]; then
    echo "ERROR: dir windows-amd64 not found"
    exit 1
elif [ "${platform}" == "linux" ] && [ ! -d "${root_dir}/dungeoneering/linux-amd64/" ]; then
    echo "ERROR: dir linux-amd64 not found"
    exit 1
elif [ "${platform}" == "macos" ] && [ ! -d "${root_dir}/dungeoneering/macos-x86_64/" ]; then
    echo "ERROR: dir macos-x86_64 not found"
    exit 1
fi

if [ "${platform}" == "windows" ] && [ -d "${root_dir}/releases/${version}/dungeoneering-windows-amd64/" ]; then
    echo "ERROR: dir dungeoneering-windows-amd64 already exists"
    exit 1
elif [ "${platform}" == "linux" ] && [ -d "${root_dir}/releases/${version}/dungeoneering-linux-amd64/" ]; then
    echo "ERROR: dir dungeoneering-linux-amd64 already exists"
    exit 1
elif [ "${platform}" == "macos" ] && [ "${app_mode}" == "standalone" ] && [ -d "${root_dir}/releases/${version}/dungeoneering-macos-amd64/" ]; then
    echo "ERROR: dir dungeoneering-macos-amd64 already exists"
    exit 1
fi

echo "Creating release dungeoneering-${platform}-amd64.zip..."

# Go to application root dir

cd ${root_dir}

# Exclude unnecessary exported applications

if [ "${platform}" == "macos" ]; then
    if [ -d dungeoneering/macos-aarch64/ ]; then
        echo -n "  Exclude macos-aarch64 directory..."
        rm -r dungeoneering/macos-aarch64/
        echo " done"
    fi
fi

# Fix file permissions

if [ "${platform}" == "linux" ] || [ "${platform}" == "macos" ]; then
    echo -n "  Fix file permissions..."
    chmod 644 docs/releases/*.txt
    chmod 644 docs/*.md
    if [ "${platform}" == "linux" ]; then
        find dungeoneering/data/ -type f -exec chmod 644 {} \;
        find dungeoneering/code/ -type f -exec chmod 644 {} \;
        find dungeoneering/linux-amd64/data/ -type f -exec chmod 644 {} \;
        find dungeoneering/linux-amd64/lib/ -type f -exec chmod 644 {} \;
        find dungeoneering/linux-amd64/source/ -type f -exec chmod 644 {} \;
    elif [ "${platform}" == "macos" ]; then
        gfind dungeoneering/data/ -type f -exec chmod 644 {} \;
        gfind dungeoneering/code/ -type f -exec chmod 644 {} \;
    fi
    echo " done"
fi

# Create version root dir

echo -n "  Create ${version} directory..."
mkdir -p "releases/${version}"
echo " done"

# Move application dir to version dir

if [ "${platform}" == "windows" ]; then
    working_dir=dungeoneering-windows-amd64
    echo -n "  Move windows-amd64 to ${working_dir}..."
    mv dungeoneering/windows-amd64 "releases/${version}/${working_dir}"
    echo " done"
elif [ "${platform}" == "linux" ]; then
    working_dir=dungeoneering-linux-amd64
    echo -n "  Move linux-amd64 to ${working_dir}..."
    mv dungeoneering/linux-amd64 "releases/${version}/${working_dir}"
    echo " done"
elif [ "${platform}" == "macos" ]; then
    working_dir=dungeoneering-macos-amd64
    if [ "${app_mode}" == "standalone" ]; then
        working_subdir=dungeoneering.app
    elif [ "${app_mode}" == "dm" ]; then
        working_subdir=dungeoneeringDm.app
    elif [ "${app_mode}" == "players" ]; then
        working_subdir=dungeoneeringPlayers.app
    fi
    echo -n "  Move macos-x86_64 to ${working_dir}..."
    mkdir -p "releases/${version}/${working_dir}"
    mv dungeoneering/macos-x86_64/dungeoneering* "releases/${version}/${working_dir}/"
    if [ ! -d "releases/${version}/${working_dir}/source" ]; then
        mv dungeoneering/macos-x86_64/source "releases/${version}/${working_dir}/"
    fi
    rm -r dungeoneering/macos-x86_64
    echo " done"
fi

# Copy release files to version dir

echo -n "  Copy release files to ${working_dir}..."
cp docs/releases/*.txt "releases/${version}/${working_dir}/"
cp docs/CHANGELOG.md "releases/${version}/${working_dir}/CHANGELOG.txt"
echo " done"

# Copy non-exported libraries to lib dir

echo -n "  Copy libraries to ${working_dir}..."
if [ "${platform}" == "windows" ]; then
    cp -r dungeoneering/code/shader "releases/${version}/${working_dir}/lib"
elif [ "${platform}" == "linux" ]; then
    cp -r dungeoneering/code/shader "releases/${version}/${working_dir}/lib"
elif [ "${platform}" == "macos" ]; then
    gcp -r dungeoneering/code/shader "releases/${version}/${working_dir}/${working_subdir}/Contents/Java/"
fi
echo " done"

# In macOS, copy data to working dir

if [ "${platform}" == "macos" ]; then
    if [ ! -d "releases/${version}/${working_dir}/data" ]; then
        echo -n "  Copy data to ${working_dir}..."
        gcp -r dungeoneering/data "releases/${version}/${working_dir}/"
        rm -r "releases/${version}/${working_dir}/data/conditions/"
        rm -r "releases/${version}/${working_dir}/data/cursors/"
        rm -r "releases/${version}/${working_dir}/data/fonts/"
        rm -r "releases/${version}/${working_dir}/data/icons/"
        echo " done"
    else
        echo "  Skipping copy of data to ${working_dir} - already present"
    fi
fi

# Remove unnecessary files from version dir

echo -n "  Remove unnecessary files from ${working_dir}..."
if [ -f "releases/${version}/${working_dir}/source/dungeoneering.java" ]; then
    rm "releases/${version}/${working_dir}/source/dungeoneering.java"
fi
if [ -d "releases/${version}/${working_dir}/data/icons/orig/" ]; then
    rm -r "releases/${version}/${working_dir}/data/icons/orig/"
fi
if [ "${platform}" == "macos" ]; then
    if [ -d "releases/${version}/${working_dir}/${working_subdir}/Contents/Java/data/icons/orig/" ]; then
        rm -r "releases/${version}/${working_dir}/${working_subdir}/Contents/Java/data/icons/orig/"
    fi
fi
if [ -d "releases/${version}/${working_dir}/data/campaign/" ]; then
    rm -r "releases/${version}/${working_dir}/data/campaign/"
fi
if [ -d "releases/${version}/${working_dir}/log/" ]; then
    rm -r "releases/${version}/${working_dir}/log/"
fi
echo " done"

# Create release zip file

echo -n "  Create a ZIP file with ${working_dir} contents..."
cd "releases/${version}"
if [ "${platform}" == "macos" ]; then
    if [ -f "${working_dir}.zip" ]; then
        rm "${working_dir}.zip"
    fi
fi
zip -qr ${working_dir}.zip ${working_dir}/
echo " done"

echo "Done"
