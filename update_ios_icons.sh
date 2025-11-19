#!/bin/bash

# Script to update iOS app icons with monochrome version
SOURCE_ICON="assets/images/app_icon_mono.png"
ICON_DIR="ios/Runner/Assets.xcassets/AppIcon.appiconset"

# Function to resize and copy icon
resize_icon() {
    local size=$1
    local filename=$2
    magick "$SOURCE_ICON" -resize "${size}x${size}" "$ICON_DIR/$filename"
}

# Update all iOS icons
resize_icon 20 "Icon-App-20x20@1x.png"
resize_icon 40 "Icon-App-20x20@2x.png"
resize_icon 60 "Icon-App-20x20@3x.png"
resize_icon 29 "Icon-App-29x29@1x.png"
resize_icon 58 "Icon-App-29x29@2x.png"
resize_icon 87 "Icon-App-29x29@3x.png"
resize_icon 40 "Icon-App-40x40@1x.png"
resize_icon 80 "Icon-App-40x40@2x.png"
resize_icon 120 "Icon-App-40x40@3x.png"
resize_icon 50 "Icon-App-50x50@1x.png"
resize_icon 100 "Icon-App-50x50@2x.png"
resize_icon 57 "Icon-App-57x57@1x.png"
resize_icon 114 "Icon-App-57x57@2x.png"
resize_icon 120 "Icon-App-60x60@2x.png"
resize_icon 180 "Icon-App-60x60@3x.png"
resize_icon 72 "Icon-App-72x72@1x.png"
resize_icon 144 "Icon-App-72x72@2x.png"
resize_icon 76 "Icon-App-76x76@1x.png"
resize_icon 152 "Icon-App-76x76@2x.png"
resize_icon 167 "Icon-App-83.5x83.5@2x.png"
resize_icon 1024 "Icon-App-1024x1024@1x.png"

echo "iOS app icons updated successfully!"