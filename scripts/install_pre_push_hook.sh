#!/usr/bin/env bash
set -euo pipefail

REPO_ROOT="$(git rev-parse --show-toplevel 2>/dev/null || true)"
HOOKS_DIR="$(git rev-parse --git-path hooks 2>/dev/null || true)"
HOOKS_PATH_CONFIG="$(git config --get core.hooksPath || true)"

if [[ -z "${REPO_ROOT}" || -z "${HOOKS_DIR}" ]]; then
  echo "ERROR: not inside a git repository." >&2
  exit 1
fi

HOOK_SOURCE="${REPO_ROOT}/.githooks/pre-push"
HOOK_TARGET="${HOOKS_DIR}/pre-push"

if [[ ! -f "${HOOK_SOURCE}" ]]; then
  echo "ERROR: ${HOOK_SOURCE} not found." >&2
  exit 1
fi

mkdir -p "${HOOKS_DIR}"
cp "${HOOK_SOURCE}" "${HOOK_TARGET}"
chmod +x "${HOOK_TARGET}"

echo "Installed pre-push hook to ${HOOK_TARGET}."
if [[ -n "${HOOKS_PATH_CONFIG}" ]]; then
  echo "Detected core.hooksPath=${HOOKS_PATH_CONFIG}."
fi
echo "Default mode is 'full' (all branch pushes run local_full_check.sh)."
echo "To use smart mode (main=full, others=light): git config hooks.prePushCheckMode smart"
echo "To always run lightweight checks: git config hooks.prePushCheckMode light"