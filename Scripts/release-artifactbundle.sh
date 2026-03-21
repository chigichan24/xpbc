#!/bin/bash
set -euo pipefail

VERSION_STRING="$1"

# Validate version format
if ! echo "$VERSION_STRING" | grep -qE '^v[0-9]+\.[0-9]+\.[0-9]+$'; then
  echo "Error: invalid version format '$VERSION_STRING' (expected vX.Y.Z)" >&2
  exit 1
fi

mkdir -p "xpbc.artifactbundle/xpbc-$VERSION_STRING-macos/bin"

sed "s|__VERSION__|$VERSION_STRING|g" ./Scripts/info.json > "xpbc.artifactbundle/info.json"

cp -f "./.build/apple/Products/Release/xpbc" "xpbc.artifactbundle/xpbc-$VERSION_STRING-macos/bin"

zip -yr - "xpbc.artifactbundle" > "./xpbc-macos.artifactbundle.zip"
