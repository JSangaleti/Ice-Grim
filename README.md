# Ice Grim — Godot 4.4 / GDScript

Versão integralmente em GDScript. Não utiliza C#, SDK .NET nem extensões nativas. Mantém os sprites, músicas, cinco fases, tutorial, regras e controles da versão anterior. Compatível com a edição padrão da Godot 4.4.x, renderizador Compatibility.

## Abrir e jogar na sua Godot

1. Aplique o patch adequado usando o aplicador do pacote.
2. Abra a Godot 4.4 e importe o `project.godot` desta pasta.
3. Pressione **F5** para executar o jogo.

Pelo terminal, se sua Godot estiver no PATH:

```bash
bash jogar.sh --editor
# Execução direta:
bash jogar.sh
```

Se ela não estiver no PATH, informe o executável:

```bash
export GODOT_BIN="$HOME/Downloads/Godot_v4.4.1-stable_linux.x86_64"
bash jogar.sh --editor
```

Ajuste o caminho para o arquivo que existe no seu computador. Os launchers Linux usam Bash e Python 3. Você também pode abrir e executar o projeto apenas pela interface da Godot.

## Exportar para Web

Use a edição **padrão da Godot 4.4, sem .NET**, para fazer a exportação. A edição .NET executa GDScript, mas o exportador Web dessa edição da Godot 4.4 é desabilitado.

Na Godot: **Editor > Manage Export Templates**, instale os templates da mesma versão do seu editor. Depois abra **Project > Export**, selecione o preset **Web**, já incluído, e exporte para `builds/web/index.html`.

O preset usa Compatibility, WebGL 2.0, uma única thread e nenhuma GDExtension. O suporte a threads fica desativado, para não exigir cabeçalhos COOP/COEP no servidor.

Pelo terminal, com os templates instalados:

```bash
bash exportar-web.sh
python3 -m http.server 8000 --directory builds/web
```

Abra **http://localhost:8000/index.html**. Não abra o HTML por duplo clique: o jogo precisa ser servido por HTTP/HTTPS. Para Itch.io, compacte **todos os arquivos** gerados dentro de `builds/web`, com `index.html` na raiz do ZIP, e selecione o tipo de projeto HTML.

No navegador, clique no jogo antes de usar o teclado/controle. O áudio depende da interação inicial com a página. Na versão Web o botão de sair da aplicação é omitido, pois o jogo não deve tentar fechar a aba do navegador.

Referências oficiais da versão 4.4:
- https://docs.godotengine.org/en/4.4/tutorials/export/exporting_for_web.html
- https://docs.godotengine.org/en/4.4/tutorials/export/exporting_projects.html

## Controles

| Ação | Teclado | Xbox / PlayStation |
| --- | --- | --- |
| Mover | A/D ou setas | Direcional/analógico |
| Pular | W ou seta para cima | A / Cruz |
| Abaixar | S ou seta para baixo | Baixo |
| Correr | Segurar Shift | X / Quadrado |
| Dash | Espaço | B / Círculo |
| Pausa | Esc | Start / Options |
| Reiniciar tentativa | R | Back / Select |
| Menu | W/S ou setas, Enter e Esc | Direcional, A/Cruz, B/Círculo |
| Tela cheia | F11 ou botão em Opções | Botão em Opções |
| Silenciar | M | Opções de volume |

No navegador, F11 pode ser tratado pelo próprio navegador; use o botão em Opções quando necessário. Gamepads precisam ser reconhecidos pelo navegador após pressionar um botão.

## Regras e conteúdo

Pegue a chave dourada e entre na porta de saída. O dash não dá invulnerabilidade; ele recarrega ao tocar o chão. Soltar o botão de pulo antes reduz a altura. Abaixar reduz a colisão; o ninja só levanta quando há espaço acima.

Qualquer morte mostra Game Over. **Tentar novamente** reinicia a campanha desde a fase 1, restaurando os inimigos, chaves, portas e armadilhas. Não há checkpoint na campanha. No tutorial, morrer reinicia somente o tutorial, e concluí-lo retorna ao menu. A quinta saída leva à vitória. O melhor tempo e as preferências de áudio são salvos localmente.

| Cena | Foco |
| --- | --- |
| `levels/00.tscn` | Tutorial das cinco ações, túnel, buraco, chave, espinhos e porta |
| `levels/01.tscn` | Travessia e espinhos |
| `levels/02.tscn` | Geleinha patrulheira |
| `levels/03.tscn` | Plataformas quebradiças |
| `levels/04.tscn` | Bola que despenca, túnel e geleinha |
| `levels/05.tscn` | Combinação e disparador de casquinhas |

A bola tem aviso de 0,55 s antes da queda; a plataforma frágil cede em aproximadamente 0,48 s. Os comportamentos são restaurados e repetem o mesmo padrão em cada tentativa.

## Estrutura

- `scenes/Main.tscn`: cena principal, execute com F5.
- `gd/game.gd`: fluxo, menus, HUD, preferências e integração com navegador.
- `gd/player.gd`: física do ninja e animação a partir dos sprites recebidos.
- `gd/platform.gd`: plataformas e quebra.
- `gd/hazard.gd` e `gd/projectile.gd`: perigos e disparos.
- `gd/item.gd`: chave e porta.
- `gd/world.gd`: criação do personagem, fundo e partículas.
- `gd/controls.gd`, `gd/audio.gd`, `gd/sign.gd`, `gd/title_art.gd`: controles, áudio e apresentação.
- `levels/`: seis cenas editáveis, com campos exportados no Inspector.
- `tests/`: suítes em GDScript, executadas pela Godot.
- `export_presets.cfg`: preset Web.

Abra uma cena de fase para mover os nós e alterar seus campos no Inspector. `size`, `flavor`, `crumble`, `travel`, `speed` e `spawn` controlam a geometria e os comportamentos. As fases dependem do gerenciador principal, por isso não devem ser executadas sozinhas por F6. Para testar diretamente uma fase:

```bash
bash jogar.sh -- --dev-level 3
# Tutorial:
bash jogar.sh -- --dev-level 0
```

## Testar

```bash
bash testar.sh
```

Resultados esperados: `SELF_TEST_OK: 39 integration checks (GDScript)` e `TRAVERSAL_OK`. A segunda suíte percorre as cinco fases e o tutorial por movimento e colisões reais, sem teletransporte. As suítes usam física a 60 Hz e não alteram o recorde do jogador.

## Arte e créditos

Autores conforme mini GDD: Maria Vitória Polido de Souza e Juliano Rubio Sangaleti. Orientação: Prof. Dr. Marcos Silvano Almeida, UTFPR Campo Mourão. Implementação e conversão com assistência de IA.

Os sprites e as três músicas originais foram preservados. Chave, porta, casquinhas e bola de sorvete foram complementados em SVG. Os SFX foram sintetizados. A fonte DejaVu Sans tem licença em `assets/fonts/LICENSE.txt`. O logotipo gráfico oficial da UTFPR não foi fornecido; a abertura usa identificação em texto.
