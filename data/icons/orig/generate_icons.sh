#!/bin/bash
# 
# Generate application icons with the desired background colors.
# This script will overwrite icon images (*_idle.png, *_over.png, etc) in /data/icons/.
# 
# Requirements: bash, coreutils, imagemagick
# 

set -euo pipefail
IFS=$'\n\t'

# UI color palette v1
# idle_color="#1f4c73"
# mouse_over_color="#387ca6"
# mouse_click_color="#00bbe0"
# disabled_color="#646464"

# UI color palette v2
idle_color="#222731"
mouse_over_color="#404854"
mouse_click_color="#f64b29"
disabled_color="#999999"

idle_suffix="idle"
mouse_over_suffix="over"
mouse_click_suffix="click"
disabled_suffix="disabled"

images_extension=".png"
results_dir="output"

echo -n "Creating output root dir $results_dir..."
mkdir -p "$results_dir"
echo " done"

for orig_file in $(find . -path "./$results_dir" -prune -false -o -type f -name "*$images_extension" -printf '%P\n'); do

    echo "Processing $orig_file..."

    file_dirname=$(dirname $orig_file)
    echo -n "  Creating output dir $results_dir/$file_dirname..."
    mkdir -p "$results_dir/$file_dirname"
    echo " done"

    file_basename=$(basename "$orig_file" "$images_extension")
    echo -n "  Creating files ${results_dir}/${file_dirname}/${file_basename}*..."
    convert "$orig_file" -colorspace RGB -background "$idle_color" -alpha remove -alpha off "${results_dir}/${file_dirname}/${file_basename}_${idle_suffix}.png"
    convert "$orig_file" -colorspace RGB -background "$mouse_over_color" -alpha remove -alpha off "${results_dir}/${file_dirname}/${file_basename}_${mouse_over_suffix}.png"
    convert "$orig_file" -colorspace RGB -background "$mouse_click_color" -alpha remove -alpha off "${results_dir}/${file_dirname}/${file_basename}_${mouse_click_suffix}.png"
    convert "$orig_file" -colorspace RGB -background "$disabled_color" -alpha remove -alpha off "${results_dir}/${file_dirname}/${file_basename}_${disabled_suffix}.png"
    echo " done"

    echo "Done processing $orig_file"

done

echo -n "Copying icon images from $results_dir to ../ ..."
cp -rf "$results_dir"/* ../
echo " done"
