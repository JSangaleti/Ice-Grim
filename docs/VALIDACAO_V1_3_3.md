# Validação — Ice Grim 1.3.3

Godot 4.4.1 padrão para Linux, física a 60 Hz. Verificações executadas em 7 de novembro de 2026.

## Tela de vitória

A tela antiga foi substituída por uma comemoração em tela inteira. O personagem e a plataforma reutilizam os sprites existentes de Maria Vitória. Coroa, luzes, confetes e medalhas são desenhados por código. O movimento é contínuo, com quantidade fixa de desenhos, sem criar nós de partículas a cada quadro.

A tela recebe os valores da corrida concluída: tempo, melhor tempo, tentativa, fases e vidas restantes no boss. A primeira conclusão tem destaque próprio; um tempo menor gera novo recorde; um tempo maior preserva a marca anterior. Não foram criados pontos ou conquistas artificiais.

A campanha fica congelada enquanto a comemoração anima. Os botões Jogar novamente e Menu principal funcionam por mouse e navegação de foco. Sair remove a tela e sua animação. Uma chamada duplicada à saída não reconstrói a tela nem perde a informação de novo recorde.

## Resultados

| Verificação | Resultado |
| --- | --- |
| Vitória | 22 verificações de primeira vitória, recorde melhor/pior, estatísticas, foco, clique, teclado, limpeza, congelamento e limites de layout |
| Interface existente | 13 verificações com eventos roteados |
| Mecânicas e progressão | 43 verificações |
| Armadilhas | 24 verificações; fase 4 a pé em três tempos |
| Música e vidas | 31 verificações de término de faixa, fila, três vidas, proteção e Game Over |
| Entrada do boss | 263 verificações e luta completa por teclado |
| Campanha completa | Seis fases, boss e tutorial concluídos por movimento e colisões |
| Renderização | Tela capturada e inspecionada em OpenGL Compatibility, Mesa llvmpipe |
| Prévia | Comando de desenvolvimento abre a tela sem alterar os bytes de configurações/recordes existentes, em ambiente de dados isolado |

A captura `screenshots/victory-v1.3.3.png` usa os dados fictícios da prévia. O teste de vitória injeta resultados para cobrir primeira vitória, melhoria e corrida mais lenta; a suíte de percurso completo verifica que o fim real da campanha chega à mesma tela. Os percursos não usam teletransporte de teste, HP alterado ou proteção extra.

## Reproduzir

```bash
bash testar.sh
```

Marcas esperadas: `UI_TEST_OK: 13`, `VICTORY_TEST_OK: 22`, `SELF_TEST_OK: 43`, `TRAPS_TEST_OK: 24`, `MUSIC_LIVES_TEST_OK: 31`, `BOSS_INPUT_TEST_OK: 263`, `BOSS_TEST_OK:` e `TRAVERSAL_OK:`.

Para visualizar só a nova tela:

```bash
bash jogar.sh -- --dev-victory
```

A prévia usa resultados fictícios e não carrega nem salva recordes nessa execução. Para jogar com seus dados normais, feche a prévia e inicie normalmente. F5 continua começando na fase 1. O comando de captura `--capture-screen victory` também abre a nova tela corretamente.

## Aplicação e limites

O pacote traz aplicador com backup e cópia completa independente em `jogo/`. Ele preserva Git, configurações extras, arquivos locais, arte, músicas e alterações em scripts que esta atualização não modifica. Conflitos nos scripts alterados interrompem a atualização antes de escrever.

A música continua tocando inteira antes de trocar. As três vidas da arena e os créditos corrigidos foram mantidos. Os testes não medem preferência estética humana. Esta revisão foi executada na engine nativa; não houve novo teste em navegador. O preset Web em GDScript permanece incluído.
