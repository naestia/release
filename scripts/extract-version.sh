#!/usr/bin/env bash

set -euo pipefail

TAG="${GITHUB_REF_NAME}"
VERSION="${TAG#"$TAG_PREFIX"}"
MAJOR="${TAG_PREFIX}$(echo "$VERSION" | cut -d. -f1)"

echo "Extracted tag     : $TAG"
echo "Extracted version : $VERSION"
echo "Major tag         : $MAJOR"

echo "tag=$TAG"         >> "$GITHUB_OUTPUT"
echo "version=$VERSION" >> "$GITHUB_OUTPUT"
echo "major=$MAJOR"     >> "$GITHUB_OUTPUT"