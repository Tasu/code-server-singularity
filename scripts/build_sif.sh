#!/usr/bin/env bash
set -euo pipefail

# Build a code-server Singularity image into the repository-local sif directory.
# Usage:
#   ./scripts/build_sif.sh [VERSION] [OUTPUT_SIF]
#
# Environment variables:
#   SINGULARITY_CMD          Full command to invoke singularity/apptainer.
#                            e.g. "conda run -n nf-env singularity"
#                            Defaults to auto-detecting singularity or apptainer.
#   SINGULARITY_USE_FAKEROOT Set to "0" to disable --fakeroot (default: "1").

if [[ -n "${SINGULARITY_CMD:-}" ]]; then
  # Use the caller-supplied command as-is (split on spaces for correct exec).
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

USE_FAKEROOT="${SINGULARITY_USE_FAKEROOT:-1}"

REPO_ROOT="$(cd "$(dirname "$0")/.." && pwd)"
DEF_FILE="${REPO_ROOT}/code-server.def"
SIF_DIR="${REPO_ROOT}/sif"

if [[ ! -f "${DEF_FILE}" ]]; then
  echo "ERROR: definition file not found: ${DEF_FILE}" >&2
  exit 1
fi

DEFAULT_VERSION="$(sed -n 's/.*SINGULARITYENV_CODE_SERVER_VERSION:-\([0-9.]*\).*/\1/p' "${DEF_FILE}" | head -n 1)"
VERSION="${1:-${DEFAULT_VERSION}}"
OUTPUT_SIF="${2:-${SIF_DIR}/code-server_${VERSION}.sif}"

if [[ -z "${VERSION}" ]]; then
  echo "ERROR: VERSION is empty. Pass it as the first argument." >&2
  exit 1
fi

mkdir -p "${SIF_DIR}"

FAKEROOT_FLAG=()
[[ "${USE_FAKEROOT}" != "0" ]] && FAKEROOT_FLAG=(--fakeroot)

echo "Building image"
echo "  runtime   : ${RUNTIME_ARGS[*]}"
echo "  fakeroot  : ${USE_FAKEROOT}"
echo "  version   : ${VERSION}"
echo "  output    : ${OUTPUT_SIF}"

run_build() {
  SINGULARITYENV_CODE_SERVER_VERSION="${VERSION}" \
    "${RUNTIME_ARGS[@]}" build --force "$@" \
    "${OUTPUT_SIF}" \
    "${DEF_FILE}"
}

if [[ "${USE_FAKEROOT}" != "0" ]]; then
  set +e
  run_build "${FAKEROOT_FLAG[@]}"
  FAKEROOT_STATUS=$?
  set -e

  if [[ ${FAKEROOT_STATUS} -ne 0 ]]; then
    echo "WARNING: fakeroot build failed. Attempting sudo fallback without --fakeroot." >&2

    if [[ ${EUID} -eq 0 ]]; then
      run_build
    elif command -v sudo >/dev/null 2>&1; then
      sudo env \
        "PATH=${PATH}" \
        "SINGULARITYENV_CODE_SERVER_VERSION=${VERSION}" \
        "${RUNTIME_ARGS[@]}" build --force \
        "${OUTPUT_SIF}" \
        "${DEF_FILE}"
    else
      echo "ERROR: sudo is not available for fallback. Install uidmap/newuidmap or run as root." >&2
      exit 1
    fi
  fi
else
  run_build
fi

echo "Build completed: ${OUTPUT_SIF}"
