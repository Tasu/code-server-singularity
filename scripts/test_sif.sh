#!/usr/bin/env bash
set -euo pipefail

# Validate that code-server commands from the built image are executable.
# Usage:
#   ./scripts/test_sif.sh [SIF_PATH]
#
# Environment variables:
#   SINGULARITY_CMD  Full command to invoke singularity/apptainer.
#                    e.g. "conda run -n nf-env singularity"
#                    Defaults to auto-detecting singularity or apptainer.

if [[ -n "${SINGULARITY_CMD:-}" ]]; then
  read -ra RUNTIME_ARGS <<< "${SINGULARITY_CMD}"
elif command -v singularity >/dev/null 2>&1; then
  RUNTIME_ARGS=(singularity)
elif command -v apptainer >/dev/null 2>&1; then
  RUNTIME_ARGS=(apptainer)
else
  echo "ERROR: singularity/apptainer command was not found in PATH." >&2
  echo "       Set SINGULARITY_CMD to override (e.g. 'conda run -n nf-env singularity')." >&2
  exit 1
fi

REPO_ROOT="$(cd "$(dirname "$0")/.." && pwd)"
DEFAULT_SIF="$(ls -1t "${REPO_ROOT}"/sif/*.sif 2>/dev/null | head -n 1 || true)"
SIF_PATH="${1:-${DEFAULT_SIF}}"

if [[ -z "${SIF_PATH}" ]]; then
  echo "ERROR: no .sif file found under sif/. Pass the image path explicitly." >&2
  exit 1
fi

if [[ ! -f "${SIF_PATH}" ]]; then
  echo "ERROR: image not found: ${SIF_PATH}" >&2
  exit 1
fi

echo "Testing image: ${SIF_PATH}"
echo "Runtime command: ${RUNTIME_ARGS[*]}"

echo "[1/2] code-server --help"
"${RUNTIME_ARGS[@]}" exec "${SIF_PATH}" code-server --help >/dev/null

echo "[2/2] code-server --version"
VERSION_OUTPUT="$("${RUNTIME_ARGS[@]}" exec "${SIF_PATH}" code-server --version)"
if [[ -z "${VERSION_OUTPUT}" ]]; then
  echo "ERROR: code-server --version returned empty output." >&2
  exit 1
fi

echo "code-server version output: ${VERSION_OUTPUT}"
echo "Test passed."
