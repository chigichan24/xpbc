#!/bin/bash
set -euo pipefail

VERSION_STRING="$1"

mkdir -p "xpbc.artifactbundle/xpbc-$VERSION_STRING-macos/bin"

sed "s/__VERSION__/$VERSION_STRING/g" ./Scripts/info.json > "xpbc.artifactbundle/info.json"

cp -f "./.build/apple/Products/Release/xpbc" "xpbc.artifactbundle/xpbc-$VERSION_STRING-macos/bin"

zip -yr - "xpbc.artifactbundle" > "./xpbc-macos.artifactbundle.zip"
