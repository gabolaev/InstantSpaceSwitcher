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

# Build for arm64
echo "Building for arm64..."
swift build -c "${BUILD_CONFIG}" --arch arm64 --build-path "${BUILD_DIR}/arm64" --disable-sandbox

echo ""
echo "Building for x86_64..."
swift build -c "${BUILD_CONFIG}" --arch x86_64 --build-path "${BUILD_DIR}/x86_64" --disable-sandbox

echo ""
echo "Creating universal binaries..."
mkdir -p "${BUILD_PATH}"
lipo -create \
  "${BUILD_DIR}/arm64/${BUILD_CONFIG}/${PRODUCT_NAME}" \
  "${BUILD_DIR}/x86_64/${BUILD_CONFIG}/${PRODUCT_NAME}" \
  -output "${BUILD_PATH}/${PRODUCT_NAME}"

lipo -create \
  "${BUILD_DIR}/arm64/${BUILD_CONFIG}/ISSCli" \
  "${BUILD_DIR}/x86_64/${BUILD_CONFIG}/ISSCli" \
  -output "${BUILD_PATH}/ISSCli"

echo ""
echo "Bundling..."
mkdir -p "${APP_BUNDLE}/Contents/MacOS"
mkdir -p "${APP_BUNDLE}/Contents/Resources"
cp "${BUILD_PATH}/${PRODUCT_NAME}" "${APP_BUNDLE}/Contents/MacOS/"
cp "${BUILD_PATH}/ISSCli" "${APP_BUNDLE}/Contents/MacOS/"
cp Info.plist "${APP_BUNDLE}/Contents/"

GIT_SHA=$(git rev-parse --short HEAD 2>/dev/null || echo "unknown")
echo "Injecting git SHA: ${GIT_SHA}"
/usr/libexec/PlistBuddy -c "Add :GitCommitHash string ${GIT_SHA}" "${APP_BUNDLE}/Contents/Info.plist" 2>/dev/null || \
/usr/libexec/PlistBuddy -c "Set :GitCommitHash ${GIT_SHA}" "${APP_BUNDLE}/Contents/Info.plist"

echo ""
echo "Signing (ad-hoc)..."
codesign --force --deep --sign - "${APP_BUNDLE}"

echo ""
echo "App bundled at $(pwd)/${APP_BUNDLE} (${BUILD_CONFIG})"
