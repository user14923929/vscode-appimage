#!/usr/bin/env bash

set -euo pipefail

VERSION="${VERSION:?VERSION is not set}"
ARCH="${ARCH:-x86_64}"

APPDIR="AppDir"
OUTPUT="VSCode-${ARCH}-${VERSION}.AppImage"

DEB="vscode.deb"
DATA_ARCHIVE=""

echo "==> Building VS Code AppImage ${VERSION}"

rm -rf "$APPDIR" "$DEB" control.tar.* data.tar.* debian-binary "$OUTPUT"

echo "==> Downloading VS Code ${VERSION}..."

curl \
    --fail \
    --location \
    --retry 3 \
    --output "$DEB" \
    "https://update.code.visualstudio.com/${VERSION}/linux-deb-x64/stable"

echo "==> Extracting DEB..."

mkdir -p "$APPDIR"

ar x "$DEB"

DATA_ARCHIVE="$(find . -maxdepth 1 -type f -name 'data.tar.*' -print -quit)"

if [[ -z "$DATA_ARCHIVE" ]]; then
    echo "ERROR: data archive was not found."
    exit 1
fi

tar -xf "$DATA_ARCHIVE" -C "$APPDIR"

echo "==> Installing AppRun..."

cp appimage/AppRun "$APPDIR/AppRun"
chmod +x "$APPDIR/AppRun"

echo "==> Fixing desktop entry..."

DESKTOP_FILE="$APPDIR/usr/share/applications/code.desktop"

if [[ ! -f "$DESKTOP_FILE" ]]; then
    echo "ERROR: VS Code desktop file was not found:"
    echo "$DESKTOP_FILE"
    exit 1
fi

sed -i \
    's|^Exec=/usr/share/code/code --new-window %F|Exec=AppRun --new-window %F|' \
    "$DESKTOP_FILE"

sed -i \
    's|^Exec=/usr/share/code/code %F|Exec=AppRun %F|' \
    "$DESKTOP_FILE"

echo "==> Preparing AppImage metadata..."

ln -sf \
    ./usr/share/applications/code.desktop \
    "$APPDIR/code.desktop"

ICON_FILE="$APPDIR/usr/share/pixmaps/vscode.png"

if [[ -f "$ICON_FILE" ]]; then
    ln -sf \
        ./usr/share/pixmaps/vscode.png \
        "$APPDIR/vscode.png"
else
    echo "WARNING: vscode.png was not found."
fi

echo "==> Building AppImage..."

if [[ -z "${APPIMAGETOOL:-}" ]]; then
    if [[ -f "./appimagetool" ]]; then
        APPIMAGETOOL="$PWD/appimagetool"
        chmod +x "$APPIMAGETOOL"
    else
        echo "ERROR: appimagetool was not found."
        echo "Download appimagetool or set APPIMAGETOOL manually."
        exit 1
    fi
fi

"$APPIMAGETOOL" \
    "$APPDIR" \
    "$OUTPUT"

echo
echo "========================================"
echo " AppImage successfully created!"
echo "========================================"
echo
echo "File: $OUTPUT"