param([string]$Godot = $env:GODOT_BIN, [switch]$Editor, [switch]$Testes, [switch]$Web)
$ErrorActionPreference = 'Stop'
Set-Location $PSScriptRoot
if (-not $Godot) { throw 'Informe -Godot "C:\Godot\Godot_v4.4.1-stable_win64.exe" ou defina GODOT_BIN.' }
$Version = & $Godot --version
if ($Version -notmatch '^4\.4\.') { throw 'Use Godot 4.4.x.' }
& $Godot --headless --editor --import --quit
if ($LASTEXITCODE -ne 0) { exit $LASTEXITCODE }
if ($Web) {
  if ($Version -match 'mono') { throw 'Para exportar Web use Godot 4.4 padrão, sem .NET.' }
  New-Item -ItemType Directory -Force builds/web | Out-Null
  & $Godot --headless --path $PSScriptRoot --export-release Web "$PSScriptRoot/builds/web/index.html"
} elseif ($Testes) {
  foreach ($Suite in @('self-test','traversal-test')) {
    & $Godot --headless --fixed-fps 60 --disable-render-loop --path $PSScriptRoot --quit-after 20000 -- "--$Suite"
    if ($LASTEXITCODE -ne 0) { exit $LASTEXITCODE }
  }
} elseif ($Editor) { & $Godot --editor --path $PSScriptRoot }
else { & $Godot --path $PSScriptRoot }
exit $LASTEXITCODE
