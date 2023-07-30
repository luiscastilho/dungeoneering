#!/bin/bash
#
# Remove metadata from app images.
#
# Requirements: bash, coreutils, imagemagick
#

set -euo pipefail
IFS=$'\n\t'

# Remove metadata from images
find ./ -iname "*.png" -o -iname "*.jpg" | while read -r image_path; do

    echo -n "Removing metadata from ${image_path}..."
    mogrify -strip "${image_path}" &> /dev/null && echo " done" || echo " FAILED"

done
