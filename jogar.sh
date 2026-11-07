#!/usr/bin/env bash
set -euo pipefail
source "$(dirname -- "$0")/ambiente.sh"
cd "$ICE_GRIM_DIR"
"$ICE_GRIM_GODOT" --headless --editor --import --quit
if [[ "${1:-}" == '--editor' ]]; then
  shift
  exec "$ICE_GRIM_GODOT" --editor --path "$ICE_GRIM_DIR" "$@"
fi
exec "$ICE_GRIM_GODOT" --path "$ICE_GRIM_DIR" "$@"
