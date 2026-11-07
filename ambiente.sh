#!/usr/bin/env bash
ICE_GRIM_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
ICE_GRIM_GODOT="${GODOT_BIN:-}"
if [[ -z "$ICE_GRIM_GODOT" ]]; then
  for ICE_GRIM_CMD in godot godot4 godot-mono godot4-mono; do
    if command -v "$ICE_GRIM_CMD" >/dev/null 2>&1; then
      ICE_GRIM_GODOT="$(command -v "$ICE_GRIM_CMD")"
      break
    fi
  done
fi
if [[ -z "$ICE_GRIM_GODOT" ]]; then
  ICE_GRIM_STANDARD="${XDG_DATA_HOME:-$HOME/.local/share}/ice-grim-tools/godot-standard-4.4.1/Godot_v4.4.1-stable_linux.x86_64"
  [[ ! -x "$ICE_GRIM_STANDARD" ]] || ICE_GRIM_GODOT="$ICE_GRIM_STANDARD"
fi
if [[ -z "$ICE_GRIM_GODOT" ]]; then
  ICE_GRIM_OLD="${XDG_DATA_HOME:-$HOME/.local/share}/ice-grim-tools/godot/Godot_v4.4.1-stable_mono_linux_x86_64/Godot_v4.4.1-stable_mono_linux.x86_64"
  [[ ! -x "$ICE_GRIM_OLD" ]] || ICE_GRIM_GODOT="$ICE_GRIM_OLD"
fi
if [[ -z "$ICE_GRIM_GODOT" ]]; then
  echo 'Informe o executável da sua Godot 4.4 ou execute: bash instalar-godot.sh' >&2
  echo 'GODOT_BIN="/caminho/para/Godot_v4.4.1-stable_linux.x86_64" bash jogar.sh --editor' >&2
  return 1
fi
if ! "$ICE_GRIM_GODOT" --version | python3 -c 'import sys;sys.exit(0 if sys.stdin.read().startswith("4.4.") else 1)'; then
  echo 'Este projeto foi preparado para Godot 4.4.x.' >&2
  return 1
fi
