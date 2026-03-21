#!/bin/bash
set -euo pipefail

REPO="chigichan24/xpbc"
ASSET_NAME="xpbc-macos.artifactbundle.zip"
ASSET_URL="https://github.com/$REPO/releases/latest/download/$ASSET_NAME"
CHECKSUM_URL="https://github.com/$REPO/releases/latest/download/checksums.txt"
INSTALL_DIR="${1:-$HOME/.local/bin}"

# Clean up intermediate files on any exit
cleanup() {
  rm -f "$ASSET_NAME" checksums.txt
  rm -rf extracted_files
}
trap cleanup EXIT

# Validate install directory
case "$INSTALL_DIR" in
  /*) ;;
  *) echo "Error: install directory must be an absolute path: $INSTALL_DIR" >&2; exit 1 ;;
esac
case "$INSTALL_DIR" in
  *..*) echo "Error: install directory must not contain '..': $INSTALL_DIR" >&2; exit 1 ;;
esac

# Download zip file
echo "Downloading latest xpbc..."
curl -fsSL -o "$ASSET_NAME" "$ASSET_URL"
curl -fsSL -o checksums.txt "$CHECKSUM_URL"

# Verify checksum
echo "Verifying checksum..."
shasum -a 256 -c checksums.txt --ignore-missing || {
  echo "Error: checksum verification failed!" >&2
  exit 1
}

unzip -qo "$ASSET_NAME" -d extracted_files

VERSION=$(ls ./extracted_files/xpbc.artifactbundle | sed -n 's/^xpbc-\([^-]*\)-macos$/\1/p' | head -n 1)
if [ -z "$VERSION" ]; then
  echo "Error: version not found in the artifact bundle." >&2
  exit 1
fi

mkdir -p "$INSTALL_DIR"
cp -f "./extracted_files/xpbc.artifactbundle/xpbc-$VERSION-macos/bin/xpbc" "$INSTALL_DIR/xpbc"
chmod +x "$INSTALL_DIR/xpbc"

echo "Installed xpbc $VERSION to $INSTALL_DIR/xpbc"
echo "Please make sure $INSTALL_DIR is in your \$PATH"
