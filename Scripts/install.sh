#!/bin/bash
set -euo pipefail

REPO="chigichan24/xpbc"
ASSET_NAME="xpbc-macos.artifactbundle.zip"
ASSET_URL="https://github.com/$REPO/releases/latest/download/$ASSET_NAME"
INSTALL_DIR="${1:-$HOME/.local/bin}"

# Download zip file
echo "Downloading latest xpbc..."
curl -sL -o "$ASSET_NAME" "$ASSET_URL"
unzip -qo "$ASSET_NAME" -d extracted_files
rm "$ASSET_NAME"

VERSION=$(ls ./extracted_files/xpbc.artifactbundle | sed -n 's/^xpbc-\([^-]*\)-macos$/\1/p' | head -n 1)
if [ -z "$VERSION" ]; then
  echo "Error: version not found in the artifact bundle."
  rm -rf extracted_files
  exit 1
fi

mkdir -p "$INSTALL_DIR"
cp -f "./extracted_files/xpbc.artifactbundle/xpbc-$VERSION-macos/bin/xpbc" "$INSTALL_DIR/xpbc"
chmod +x "$INSTALL_DIR/xpbc"
rm -rf extracted_files

echo "Installed xpbc $VERSION to $INSTALL_DIR/xpbc"
echo "Please make sure $INSTALL_DIR is in your \$PATH"
