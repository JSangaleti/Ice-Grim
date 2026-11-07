#!/usr/bin/env bash
set -euo pipefail
if [[ "$(uname -m)" != x86_64 ]]; then
  echo 'Este instalador é para Linux x86_64. Use sua Godot 4.4 e importe project.godot.' >&2
  exit 1
fi
ICE_GRIM_ENGINE_HOME="${XDG_DATA_HOME:-$HOME/.local/share}/ice-grim-tools/godot-standard-4.4.1"
mkdir -p "$ICE_GRIM_ENGINE_HOME"
if [[ ! -x "$ICE_GRIM_ENGINE_HOME/Godot_v4.4.1-stable_linux.x86_64" ]]; then
  curl --fail --location --retry 3 --max-time 240 \
    'https://github.com/godotengine/godot-builds/releases/download/4.4.1-stable/Godot_v4.4.1-stable_linux.x86_64.zip' \
    -o "$ICE_GRIM_ENGINE_HOME/engine.zip"
  python3 -m zipfile -e "$ICE_GRIM_ENGINE_HOME/engine.zip" "$ICE_GRIM_ENGINE_HOME"
  chmod +x "$ICE_GRIM_ENGINE_HOME/Godot_v4.4.1-stable_linux.x86_64"
  rm "$ICE_GRIM_ENGINE_HOME/engine.zip"
fi
"$ICE_GRIM_ENGINE_HOME/Godot_v4.4.1-stable_linux.x86_64" --version
echo 'Godot configurada. Execute: bash jogar-direto.sh'
