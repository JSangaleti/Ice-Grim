#!/usr/bin/env bash
set -euo pipefail
source "$(dirname -- "$0")/ambiente.sh"
cd "$ICE_GRIM_DIR"
"$ICE_GRIM_GODOT" --headless --editor --import --quit
for ICE_GRIM_SUITE in ui-test victory-test self-test traps-test music-lives-test boss-input-test boss-test traversal-test; do
  ICE_GRIM_LOG="$(mktemp)"
  if ! "$ICE_GRIM_GODOT" --headless --fixed-fps 60 --disable-render-loop --path "$ICE_GRIM_DIR" --quit-after 20000 -- "--$ICE_GRIM_SUITE" > "$ICE_GRIM_LOG" 2>&1; then
    cat "$ICE_GRIM_LOG"
    rm -f "$ICE_GRIM_LOG"
    exit 1
  fi
  cat "$ICE_GRIM_LOG"
  if rg --version >/dev/null 2>&1; then
    ICE_GRIM_FAILED=0
    rg -q 'ERROR:|SCRIPT ERROR:|FAILED' "$ICE_GRIM_LOG" && ICE_GRIM_FAILED=1
  else
    ICE_GRIM_FAILED=0
    grep -Eq 'ERROR:|SCRIPT ERROR:|FAILED' "$ICE_GRIM_LOG" && ICE_GRIM_FAILED=1
  fi
  if [[ "$ICE_GRIM_FAILED" == 1 ]] || ! grep -q '_OK:' "$ICE_GRIM_LOG"; then
    rm -f "$ICE_GRIM_LOG"
    echo 'A suíte não concluiu corretamente.' >&2
    exit 1
  fi
  rm -f "$ICE_GRIM_LOG"
done
