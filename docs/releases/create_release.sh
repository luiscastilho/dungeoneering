#!/bin/bash
#
# Generate a release from an exported Processing application.
#
# Requirements: bash, coreutils, zip
#

set -euo pipefail
IFS=$'\n\t'

version="${1:-}"
root_dir="../.."

# Check if we have everything we need

if [ -z "$version" ]; then
    echo "usage: $(basename $0) version"
    exit 1
fi

spaces_regex="[[:space:]]+"
if [[ "$version" =~ $spaces_regex ]]; then
    echo "ERROR: version shouldn't contain spaces"
    exit 1
fi

if [ ! -d "$root_dir/dungeoneering/application.windows64/" ]; then
    echo "ERROR: dir application.windows64 not found"
    exit 1
fi

if [ -d "$root_dir/releases/$version/dungeoneering-$version-win64/" ]; then
    echo "ERROR: dir dungeoneering-$version-win64 already exists"
    exit 1
fi

echo "Creating release dungeoneering-$version-win64.zip..."

# Go to application root dir

cd $root_dir

# Exclude exported application.windows32 dir

echo -n "  Exclude application.windows32 directory..."
if [ -d dungeoneering/application.windows32/ ]; then
    rm -r dungeoneering/application.windows32/
fi
echo " done"

# Create version root dir

echo -n "  Create $version directory..."
mkdir -p releases/$version
echo " done"

# Move application.windows64 to version dir

echo -n "  Move application.windows64 to dungeoneering-$version-win64..."
mv dungeoneering/application.windows64 releases/$version/dungeoneering-$version-win64
echo " done"

# Copy release files to version dir

echo -n "  Copy release filess to dungeoneering-$version-win64..."
cp docs/releases/*.txt releases/$version/dungeoneering-$version-win64/
echo " done"

# Copy libraries to lib dir and then remove platform specific files

echo -n "  Copy libraries to dungeoneering-$version-win64/lib..."
cp -r dungeoneering/code/* releases/$version/dungeoneering-$version-win64/lib
rm -r releases/$version/dungeoneering-$version-win64/lib/macosx64/
rm -r releases/$version/dungeoneering-$version-win64/lib/windows32/
echo " done"

# Remove unnecessary files from version dir

echo -n "  Remove unnecessary files from dungeoneering-$version-win64..."
rm releases/$version/dungeoneering-$version-win64/source/dungeoneering.java
rm -r releases/$version/dungeoneering-$version-win64/data/campaign/
rm -r releases/$version/dungeoneering-$version-win64/data/icons/orig/
echo " done"

# Create release zip file

echo -n "  Create a ZIP file with dungeoneering-$version-win64 contents..."
cd releases/$version
zip -qr dungeoneering-$version-win64.zip dungeoneering-$version-win64/
echo " done"

echo "Done"
