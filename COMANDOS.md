# Comandos — Ice Grim em GDScript

Depois de aplicar o patch na pasta que contém `project.godot`:

```bash
cd /caminho/do/seu/projeto
export GODOT_BIN="/caminho/para/Godot_v4.4.1-stable_linux.x86_64"
bash jogar.sh --editor
```

Ou importe `project.godot` na sua Godot 4.4 e pressione F5. Não precisa de .NET.

```bash
# Jogar diretamente:
bash jogar.sh
# Verificar mecânicas e percorrer todas as fases:
bash testar.sh
```

Para Web: use Godot 4.4 **padrão**, instale seus templates por Editor > Manage Export Templates e execute:

```bash
bash exportar-web.sh
python3 -m http.server 8000 --directory builds/web
```

Abra http://localhost:8000/index.html. Para Itch.io, compacte todos os arquivos gerados em `builds/web`, com `index.html` na raiz do ZIP.

Para abrir só a sexta fase durante desenvolvimento:

```bash
bash jogar.sh -- --dev-level 6
```

Músicas futuras: `assets/music/juliano/LEIA-ME.md`.

O preset Web já está configurado sem threads. O código inteiro do jogo está em `gd/`, as fases em `levels/`, e os testes em `tests/`.
