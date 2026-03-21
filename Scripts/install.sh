#!/bin/bash
set -euo pipefail

REPO="chigichan24/xpbc"
ASSET_NAME="xpbc-macos.artifactbundle.zip"
ASSET_URL="https://github.com/$REPO/releases/latest/download/$ASSET_NAME"
DEFAULT_INSTALL_DIR="$HOME/.local/bin"
TMPDIR_INSTALL=$(mktemp -d)

cleanup() {
  rm -rf "$TMPDIR_INSTALL"
}
trap cleanup EXIT

echo "xpbc installer"
echo ""

# Read from /dev/tty so this works even when piped via curl | bash
printf "Install directory [%s]: " "$DEFAULT_INSTALL_DIR"
read -r INSTALL_DIR < /dev/tty || true
INSTALL_DIR="${INSTALL_DIR:-$DEFAULT_INSTALL_DIR}"

# Expand ~ to $HOME
INSTALL_DIR="${INSTALL_DIR/#\~/$HOME}"

echo ""
echo "Downloading latest release..."
curl -sL -o "$TMPDIR_INSTALL/$ASSET_NAME" "$ASSET_URL"

echo "Extracting..."
unzip -qo "$TMPDIR_INSTALL/$ASSET_NAME" -d "$TMPDIR_INSTALL"

VERSION=$(ls "$TMPDIR_INSTALL/xpbc.artifactbundle" | sed -n 's/^xpbc-\([^-]*\)-macos$/\1/p' | head -n 1)
if [ -z "$VERSION" ]; then
  echo "Error: could not determine version from artifact bundle."
  exit 1
fi

mkdir -p "$INSTALL_DIR"
cp -f "$TMPDIR_INSTALL/xpbc.artifactbundle/xpbc-$VERSION-macos/bin/xpbc" "$INSTALL_DIR/xpbc"
chmod +x "$INSTALL_DIR/xpbc"

echo ""
echo "Installed xpbc $VERSION to $INSTALL_DIR/xpbc"

# Check if install dir is in PATH
if ! echo "$PATH" | tr ':' '\n' | grep -qx "$INSTALL_DIR"; then
  echo ""
  echo "Note: $INSTALL_DIR is not in your PATH."
  echo "Add the following to your shell profile (~/.zshrc or ~/.bashrc):"
  echo ""
  echo "  export PATH=\"$INSTALL_DIR:\$PATH\""
fi
