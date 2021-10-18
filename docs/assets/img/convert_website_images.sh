#!/bin/bash
#
# Convert website images to JPG and WEBP formats.
#
# Requirements: bash, coreutils, imagemagick
#

set -euo pipefail
IFS=$'\n\t'

# Convert no-transparency images to JPG
for image_path in $(find ./icons ./screenshot -iname *.jpeg -o -iname *.png -not -path "./favicons/*"); do

    echo -n "Converting ${image_path} to JPG..."
    image_path_no_ext="${image_path%.*}"
    jpg_image_path="${image_path_no_ext}.jpg"
    convert ${image_path} -quality 90 ${jpg_image_path}
    echo " done"

    image_extension="${image_path##*.}"
    if [ "${image_extension}" == "jpeg" ]; then
        echo "  WARNING: rename this .jpeg file to .jpg"
    fi

done

# Convert all images to WEBP
for image_path in $(find . -iname *.jpeg -o -iname *.png -not -path "./favicons/*" -not -path "./screenshot/*"); do

    echo -n "Converting ${image_path} to WEBP..."
    image_path_no_ext="${image_path%.*}"
    webp_image_path="${image_path_no_ext}.webp"
    convert ${image_path} -quality 90 ${webp_image_path}
    echo " done"

done
