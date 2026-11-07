#!/usr/bin/env bash
set -euo pipefail
source "$(dirname -- "$0")/ambiente.sh"
if [[ "$("$ICE_GRIM_GODOT" --version)" == *mono* ]]; then
  echo 'Para exportar Web use a edição padrão da Godot 4.4, sem .NET. Defina GODOT_BIN para ela.' >&2
  exit 1
fi
cd "$ICE_GRIM_DIR"
mkdir -p builds/web
"$ICE_GRIM_GODOT" --headless --editor --import --quit
"$ICE_GRIM_GODOT" --headless --path "$ICE_GRIM_DIR" --export-release Web "$ICE_GRIM_DIR/builds/web/index.html"
echo 'Exportação em builds/web/index.html. Para testar:'
echo 'python3 -m http.server 8000 --directory builds/web'
echo 'Abra http://localhost:8000/index.html no navegador.'
