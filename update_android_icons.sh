#!/bin/bash

# Script to update Android app icons with monochrome version
SOURCE_ICON="assets/images/app_icon_mono.png"
ANDROID_DIR="android/app/src/main/res"

# Function to resize and copy icon
resize_android_icon() {
    local size=$1
    local mipmap_dir=$2
    mkdir -p "$ANDROID_DIR/$mipmap_dir"
    magick "$SOURCE_ICON" -resize "${size}x${size}" "$ANDROID_DIR/$mipmap_dir/ic_launcher.png"
}

# Update all Android icons
resize_android_icon 48 "mipmap-mdpi"
resize_android_icon 72 "mipmap-hdpi"
resize_android_icon 96 "mipmap-xhdpi"
resize_android_icon 144 "mipmap-xxhdpi"
resize_android_icon 192 "mipmap-xxxhdpi"

echo "Android app icons updated successfully!"