#!/usr/bin/env bash
# Downloads the latest GitHub release of a macOS app and installs it to /Applications
# if the installed version is missing or out of date.
#
# Usage: install-github-app.sh <AppName> <owner/repo>
# Requires curl, jq, unzip, hdiutil, /usr/libexec/PlistBuddy on PATH.
# Honors DRY_RUN_CMD (set by home-manager activation) for the copy/remove steps.

set -uo pipefail

APP_NAME="$1"
REPO="$2"
DRY_RUN_CMD="${DRY_RUN_CMD:-}"

APP_PATH="/Applications/${APP_NAME}.app"
GITHUB_API="https://api.github.com/repos/${REPO}/releases/latest"

echo "Checking ${APP_NAME} installation..."

RELEASE_INFO=$(curl -sf -H "Accept: application/vnd.github.v3+json" "$GITHUB_API" 2>/dev/null || echo "")

if [ -z "$RELEASE_INFO" ]; then
  echo "⚠️  Could not fetch ${APP_NAME} release info, skipping..."
  exit 0
fi

LATEST_VERSION=$(echo "$RELEASE_INFO" | jq -r '.tag_name // empty' | sed 's/^v//')
DOWNLOAD_URL=$(echo "$RELEASE_INFO" | jq -r '.assets[] | select(.name | test("\\.(dmg|zip)$"; "i")) | .browser_download_url' | head -1)

if [ -z "$LATEST_VERSION" ] || [ -z "$DOWNLOAD_URL" ]; then
  echo "⚠️  Could not determine ${APP_NAME} version or download URL, skipping..."
  exit 0
fi

INSTALLED_VERSION="none"
if [ -d "$APP_PATH" ]; then
  INSTALLED_VERSION=$(/usr/libexec/PlistBuddy -c "Print :CFBundleShortVersionString" \
    "$APP_PATH/Contents/Info.plist" 2>/dev/null || echo "none")
fi

if [ "$INSTALLED_VERSION" = "$LATEST_VERSION" ]; then
  echo "${APP_NAME} $INSTALLED_VERSION is already up to date ✅"
  exit 0
fi

echo "Installing ${APP_NAME} $LATEST_VERSION (installed: $INSTALLED_VERSION)..."
TEMP_DIR=$(mktemp -d)
FILENAME=$(basename "$DOWNLOAD_URL")

if ! curl -L -o "$TEMP_DIR/$FILENAME" "$DOWNLOAD_URL"; then
  echo "⚠️  Failed to download ${APP_NAME}"
  rm -rf "$TEMP_DIR"
  exit 0
fi

echo "Download complete, installing..."

if echo "$FILENAME" | grep -qi '\.dmg$'; then
  MOUNT_POINT=$(mktemp -d)
  hdiutil attach "$TEMP_DIR/$FILENAME" -mountpoint "$MOUNT_POINT" -quiet -nobrowse
  APP_SRC=$(find "$MOUNT_POINT" -name "*.app" -maxdepth 2 | head -1)
  if [ -n "$APP_SRC" ]; then
    [ -d "$APP_PATH" ] && $DRY_RUN_CMD rm -rf "$APP_PATH"
    $DRY_RUN_CMD cp -R "$APP_SRC" /Applications/
    echo "${APP_NAME} $LATEST_VERSION installed ✅"
  else
    echo "⚠️  Could not find .app in DMG"
  fi
  hdiutil detach "$MOUNT_POINT" -quiet
  rm -rf "$MOUNT_POINT"
elif echo "$FILENAME" | grep -qi '\.zip$'; then
  mkdir -p "$TEMP_DIR/extracted"
  unzip -q "$TEMP_DIR/$FILENAME" -d "$TEMP_DIR/extracted"
  APP_SRC=$(find "$TEMP_DIR/extracted" -name "*.app" -maxdepth 3 | head -1)
  if [ -n "$APP_SRC" ]; then
    [ -d "$APP_PATH" ] && $DRY_RUN_CMD rm -rf "$APP_PATH"
    $DRY_RUN_CMD cp -R "$APP_SRC" /Applications/
    echo "${APP_NAME} $LATEST_VERSION installed ✅"
  else
    echo "⚠️  Could not find .app in ZIP"
  fi
else
  echo "⚠️  Unknown file format: $FILENAME"
fi

rm -rf "$TEMP_DIR"
