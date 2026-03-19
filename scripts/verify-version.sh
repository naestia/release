#!/usr/bin/env bash

set -euo pipefail

if [ -f mix.exs ]; then
  FILE_VERSION=$(grep 'version:' mix.exs | head -1 | cut -d'"' -f2)
  FILE="mix.exs"
elif [ -f pyproject.toml ]; then
  FILE_VERSION=$(grep '^version' pyproject.toml | head -1 | cut -d'"' -f2)
  FILE="pyproject.toml"
elif [ -f .version ]; then
  FILE_VERSION=$(cat .version | tr -d '[:space:]')
  FILE=".version"
else
  echo "ERROR: No version file found (mix.exs, pyproject.toml, or .version)"
  exit 1
fi

echo "Tag version  : $TAG_VERSION"
echo "File version : $FILE_VERSION (from $FILE)"

if [ "$TAG_VERSION" != "$FILE_VERSION" ]; then
  echo "ERROR: Tag version ($TAG_VERSION) does not match $FILE ($FILE_VERSION)"
  exit 1
fi

echo "✓ Version match confirmed"