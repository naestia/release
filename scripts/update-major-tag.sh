#!/usr/bin/env bash

set -euo pipefail

git config user.name  "github-actions[bot]"
git config user.email "github-actions[bot]@users.noreply.github.com"

# Force-update the major tag to point at the current commit
git tag -f "$MAJOR_VERSION"
git push origin "refs/tags/$MAJOR_VERSION" --force

echo "✓ Major tag $MAJOR_VERSION updated to $(git rev-parse HEAD)"