#!/usr/bin/env bash
set -euo pipefail

# Lightweight checks for repository consistency.
# This script is used by GitHub Actions and intentionally avoids heavy container builds.

echo "[1/4] Validate shell script syntax"
bash -n scripts/build_sif.sh scripts/test_sif.sh

echo "[2/4] Ensure helper scripts are executable"
[[ -x scripts/build_sif.sh ]]
[[ -x scripts/test_sif.sh ]]

echo "[3/4] Ensure generated SIF files are ignored"
grep -Fxq 'sif/*.sif' .gitignore

echo "[4/4] Ensure no SIF artifacts are tracked by git"
if git ls-files -- 'sif/*.sif' | grep -q .; then
  echo "ERROR: tracked .sif files found in git index." >&2
  git ls-files -- 'sif/*.sif' >&2
  exit 1
fi

echo "All lightweight checks passed."
