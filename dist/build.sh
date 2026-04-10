#!/bin/bash
set -e

if [[ "${1:-}" == "--help" ]]; then
  echo "Usage: $0 [--debug] [--help]"
  echo ""
  echo "Options:"
  echo "  --debug    Build in debug mode (default: release)"
  echo "  --help     Show this help message"
  exit 0
fi

PRODUCT_NAME="InstantSpaceSwitcher"
BUILD_DIR="build"
BUILD_CONFIG="release"

if [[ "${1:-}" == "--debug" ]]; then
  BUILD_CONFIG="debug"
fi

BUILD_PATH="${BUILD_DIR}/${BUILD_CONFIG}"
APP_BUNDLE="${BUILD_DIR}/${PRODUCT_NAME}.app"

# --disable-sandbox: Allows SPM to access files outside the package directory during build
# (required for building C modules that may reference system frameworks)
swift build -c "${BUILD_CONFIG}" --build-path "${BUILD_DIR}" --disable-sandbox

echo ""
echo "Bundling..."
mkdir -p "${APP_BUNDLE}/Contents/MacOS"
mkdir -p "${APP_BUNDLE}/Contents/Resources"
cp "${BUILD_PATH}/${PRODUCT_NAME}" "${APP_BUNDLE}/Contents/MacOS/"
cp Info.plist "${APP_BUNDLE}/Contents/"

echo ""
echo "Signing (ad-hoc)..."
codesign --force --deep --sign - "${APP_BUNDLE}"

echo ""
echo "App bundled at $(pwd)/${APP_BUNDLE} (${BUILD_CONFIG})"
