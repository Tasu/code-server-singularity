#!/usr/bin/env bash
set -euo pipefail

HOOK_SOURCE=".githooks/pre-push"
HOOK_TARGET=".git/hooks/pre-push"

if [[ ! -d .git ]]; then
  echo "ERROR: .git directory not found. Run from repository root." >&2
  exit 1
fi

if [[ ! -f "${HOOK_SOURCE}" ]]; then
  echo "ERROR: ${HOOK_SOURCE} not found." >&2
  exit 1
fi

mkdir -p .git/hooks
cp "${HOOK_SOURCE}" "${HOOK_TARGET}"
chmod +x "${HOOK_TARGET}"

echo "Installed pre-push hook to ${HOOK_TARGET}."
echo "Default mode is 'full' (all branch pushes run local_full_check.sh)."
echo "To use smart mode (main=full, others=light): git config hooks.prePushCheckMode smart"
echo "To always run lightweight checks: git config hooks.prePushCheckMode light"