#!/usr/bin/env bash
set -euo pipefail
source "$(dirname -- "$0")/ambiente.sh"
cd "$ICE_GRIM_DIR"
"$ICE_GRIM_GODOT" --headless --editor --import --quit
exec "$ICE_GRIM_GODOT" --path "$ICE_GRIM_DIR" "res://scenes/Main.tscn" -- --play
