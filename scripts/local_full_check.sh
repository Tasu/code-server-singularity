#!/usr/bin/env bash
set -euo pipefail

# Full local pre-PR checks:
# 1) Build image
# 2) Smoke test image
# 3) Run lightweight repository checks
#
# Usage:
#   ./scripts/local_full_check.sh [VERSION]
#
# Environment variables (optional):
#   SINGULARITY_CMD           e.g. "conda run -n nf-env singularity"
#   SINGULARITY_USE_FAKEROOT  "1" (default) or "0"

VERSION="${1:-}"

if [[ -n "${VERSION}" ]]; then
  ./scripts/build_sif.sh "${VERSION}"
  IMAGE_PATH="sif/code-server_${VERSION}.sif"
else
  ./scripts/build_sif.sh
  IMAGE_PATH="$(ls -1t sif/*.sif 2>/dev/null | head -n 1 || true)"
fi

if [[ -z "${IMAGE_PATH}" || ! -f "${IMAGE_PATH}" ]]; then
  echo "ERROR: could not determine built SIF image path." >&2
  exit 1
fi

./scripts/test_sif.sh "${IMAGE_PATH}"
./scripts/ci_check.sh

echo "All local full checks passed."
