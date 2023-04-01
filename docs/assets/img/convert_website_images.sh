#!/bin/bash
#
# Remove metadata from website images and convert them to JPG and WEBP formats.
#
# Requirements: bash, coreutils, imagemagick
#

set -euo pipefail
IFS=$'\n\t'

# Remove metadata from images
find ./ -iname "*.jpg" -o -iname "*.jpeg" -o -iname "*.png" -o -iname "*.svg" -o -iname "*.ico" | while read -r image_path; do

    echo -n "Removing metadata from ${image_path}..."
    mogrify -strip "${image_path}" &> /dev/null && echo " done" || echo " FAILED"

done

# Minify SVGs
find ./ -iname "*.svg" | while read -r image_path; do

    echo -n "Minifying SVG ${image_path}... "
    image_extension="${image_path##*.}"
    image_path_tmp="${image_path%.*}_tmp.${image_extension}"
    svgcleaner "${image_path}" "${image_path_tmp}"
    mv "${image_path_tmp}" "${image_path}"

done

# Convert non-transparent images to JPG
find ./icons ./screenshot -iname "*.jpeg" -o -iname "*.png" | while read -r image_path; do

    echo -n "Converting ${image_path} to JPG..."
    image_path_no_ext="${image_path%.*}"
    jpg_image_path="${image_path_no_ext}.jpg"
    convert "${image_path}" -strip -quality 90 "${jpg_image_path}" &> /dev/null && echo " done" || echo " FAILED"

    image_extension="${image_path##*.}"
    if [ "${image_extension}" == "jpeg" ]; then
        echo "  WARNING: rename this .jpeg file to .jpg"
    fi

done

# Convert all images to WEBP
find . -iname "*.jpg" -o -iname "*.png" -not -path "./brands/*" -not -path "./emojis/*" -not -path "./favicons/*" | while read -r image_path; do

    echo -n "Converting ${image_path} to WEBP..."
    image_path_no_ext="${image_path%.*}"
    webp_image_path="${image_path_no_ext}.webp"
    convert "${image_path}" -strip -quality 90 "${webp_image_path}" &> /dev/null && echo " done" || echo " FAILED"

done
