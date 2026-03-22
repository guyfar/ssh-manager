#!/usr/bin/env bash
# Legacy alias for Nook.

set -euo pipefail

SCRIPT_DIR="$(CDPATH= cd -- "$(dirname -- "$0")" && pwd)"

if [[ -x "${SCRIPT_DIR}/nk" ]]; then
    exec "${SCRIPT_DIR}/nk" "$@"
fi

exec nk "$@"
