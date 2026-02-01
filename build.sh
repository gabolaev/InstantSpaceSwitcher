#!/bin/bash
set -e

PRODUCT_NAME="InstantSpaceSwitcher"
BUILD_PATH=".build/release"
APP_BUNDLE="${PRODUCT_NAME}.app"

swift build -c release --disable-sandbox

echo "Bundling..."
mkdir -p "${APP_BUNDLE}/Contents/MacOS"
mkdir -p "${APP_BUNDLE}/Contents/Resources"
cp "${BUILD_PATH}/${PRODUCT_NAME}" "${APP_BUNDLE}/Contents/MacOS/"
cp Info.plist "${APP_BUNDLE}/Contents/"

echo "Signing..."
codesign --force --deep --sign - "${APP_BUNDLE}"

echo "App bundled at ${APP_BUNDLE}"
