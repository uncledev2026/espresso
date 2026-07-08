#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
APP_NAME="espresso"
PRODUCT_NAME="Espresso"
CONFIGURATION="${CONFIGURATION:-release}"
SIGN_IDENTITY="${SIGN_IDENTITY:--}"

APP_BUNDLE="$ROOT_DIR/build/$APP_NAME.app"
CONTENTS_DIR="$APP_BUNDLE/Contents"
MACOS_DIR="$CONTENTS_DIR/MacOS"
RESOURCES_DIR="$CONTENTS_DIR/Resources"
ICONSET_DIR="$ROOT_DIR/Resources/AppIcon.iconset"
ICNS_FILE="$ROOT_DIR/Resources/Espresso.icns"

cd "$ROOT_DIR"

resolve_xcconfig_value() {
    local key="$1"
    local files=("Configs/Signing.xcconfig")

    if [ -f "Configs/Signing.local.xcconfig" ]; then
        files+=("Configs/Signing.local.xcconfig")
    fi

    awk -F= -v key="$key" '
        /^[[:space:]]*#/ { next }
        /^[[:space:]]*\/\// { next }
        /=/ {
            line = $0
            sub(/[[:space:]]*\/\/.*/, "", line)
            lhs = substr(line, 1, index(line, "=") - 1)
            rhs = substr(line, index(line, "=") + 1)
            gsub(/^[ \t]+|[ \t]+$/, "", lhs)
            gsub(/^[ \t]+|[ \t]+$/, "", rhs)
            if (lhs == key) {
                value = rhs
            }
        }
        END { print value }
    ' "${files[@]}"
}

BUNDLE_IDENTIFIER="${PRODUCT_BUNDLE_IDENTIFIER:-$(resolve_xcconfig_value PRODUCT_BUNDLE_IDENTIFIER)}"
BUNDLE_IDENTIFIER="${BUNDLE_IDENTIFIER:-com.example.espresso}"

if [ ! -d "$ICONSET_DIR" ]; then
    swift Tools/GenerateIcon.swift
fi

if [ ! -f "$ICNS_FILE" ]; then
    iconutil -c icns "$ICONSET_DIR" -o "$ICNS_FILE"
fi

swift build -c "$CONFIGURATION" --product "$PRODUCT_NAME"

rm -rf "$APP_BUNDLE"
mkdir -p "$MACOS_DIR" "$RESOURCES_DIR"

cp ".build/$CONFIGURATION/$PRODUCT_NAME" "$MACOS_DIR/$PRODUCT_NAME"
cp "Resources/Info.plist" "$CONTENTS_DIR/Info.plist"
plutil -replace CFBundleIdentifier -string "$BUNDLE_IDENTIFIER" "$CONTENTS_DIR/Info.plist"
cp "$ICNS_FILE" "$RESOURCES_DIR/Espresso.icns"

for localization_dir in Resources/*.lproj; do
    [ -d "$localization_dir" ] || continue
    cp -R "$localization_dir" "$RESOURCES_DIR/"
done

codesign \
    --force \
    --sign "$SIGN_IDENTITY" \
    --entitlements "Resources/Espresso.entitlements" \
    --options runtime \
    "$APP_BUNDLE"

echo "$APP_BUNDLE"
