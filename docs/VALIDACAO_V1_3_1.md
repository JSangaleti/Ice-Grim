# Validação — Ice Grim 1.3.1

Godot 4.4.1 padrão para Linux, física a 60 Hz. Validação executada em 7 de novembro de 2026. Correção da colisão do chefe e da autoria exibida nos créditos.

## Problema reproduzido

Na versão 1.3, o retângulo do corpo era letal mesmo durante a abertura, exceto durante os instantes exatos do dash. O personagem podia tocar esse retângulo antes de chegar ao núcleo ou depois de o dash acabar. Além disso, pulo e dash simultâneos descartavam a subida do salto. A reprodução com entrada normal de teclado resultou em 16 mortes entre 28 combinações de posição, tempo de pulo e intervalo até o dash.

O teste anterior do boss demonstrava uma rota com tempo preciso de comandos injetados no controlador, mas não cobria essas variações da entrada normal. Esta revisão adiciona testes com `InputEventKey` passando pelo sistema de entrada da Godot, sem ativar os atalhos de controle do personagem.

## Correções

Durante a abertura, o corpo deixa de matar. Só o dash no núcleo causa dano. O alvo corresponde ao anel luminoso, com margem de colisão, e considera todo o deslocamento do dash, inclusive o último passo. Um dash iniciado enquanto o núcleo está aberto pode terminar depois de a abertura fechar. Pulo e dash simultâneos deixam o personagem sair do chão antes do impulso horizontal.

Não há invulnerabilidade geral: espinhos e ataques continuam letais, assim como entrar no corpo fechado sem um dash iniciado na abertura. O chefe mantém nove pontos de vida, as três etapas, os padrões e tempos de abertura. A morte continua levando à fase 1 ao tentar novamente.

## Resultados

| Suíte | Resultado |
| --- | --- |
| Importação | Sem erro de script ou recurso |
| Interface | 13 verificações de mouse e teclado |
| Mecânicas e progressão | 43 verificações |
| Armadilhas | 24 verificações; fase 4 percorrida a pé em três tempos |
| Entrada do boss | 263 verificações, incluindo 84 combinações de ataque nas três etapas, recuo, limite da abertura, contato aberto/fechado e espinhos |
| Luta por teclado | Nove acertos com todos os ataques habilitados; cerca de 57,4 segundos na arena |
| Boss/progressão | Percurso longo, nove acertos, chave, porta final, pausa, reinício e créditos |
| Campanha | Seis fases e tutorial concluídos com física e colisões reais |
| Renderização | Arena e créditos conferidos em OpenGL Compatibility com Mesa llvmpipe |
| Créditos | Arte e sprites de Maria Vitória; todas as músicas incluídas são autorais de Juliano; sem indicação de trilha pendente |

Os testes isolados de 84 combinações posicionam o jogador na plataforma, selecionam a etapa pela vida do chefe e suprimem disparos para isolar a colisão. O ataque usa eventos de teclado, incluindo pulo curto/longo, duas posições e sete intervalos. A luta completa por teclado mantém todos os ataques ativos e vence os nove pontos de vida sem teletransporte durante o confronto, alteração de HP ou invulnerabilidade. O trajeto até a arena usa o controlador físico automatizado já existente. A suíte separada percorre toda a campanha e o tutorial.

Os créditos foram corrigidos conforme confirmação de Maria Vitória: os três MP3 já incluídos são de autoria de Juliano. A pasta `assets/music/juliano/` continua opcional para substituir faixas por grupo de fases; sua presença não determina autoria nem altera os créditos. Arte e sprites são atribuídos a Maria Vitória. Os arquivos de áudio e imagem são preservados pelo aplicador.

## Reproduzir

```bash
bash testar.sh
```

Marcas esperadas: `UI_TEST_OK: 13`, `SELF_TEST_OK: 43`, `TRAPS_TEST_OK: 24`, `BOSS_INPUT_TEST_OK: 263`, `BOSS_KEYBOARD_FIGHT_OK:`, `BOSS_TEST_OK:` e `TRAVERSAL_OK:`.

Logs: `testes_v1_3_1.log`, `creditos_v1_3_1.log` e `reproducao_contato_v1_3.log`. O último registra o defeito da versão anterior. Os logs de versões anteriores são históricos.

## Aplicação e limites

O aplicador atualiza as entregas conhecidas, cria backup e preserva Git, arquivos locais, configurações extras, sprites e músicas. Conflitos em scripts alterados interrompem a operação antes das escritas; documentos locais customizados são preservados. O texto padrão sobre as músicas na pasta opcional é atualizado apenas se corresponder à versão conhecida. O ZIP contém uma cópia completa independente em `jogo/`.

Uma execução de importação nativa encerrou com SIGSEGV ao fechar o editor, após concluir a importação e sem erro de GDScript. A repetição da importação concluiu normalmente; a luta completa por teclado também passou na cópia instalada. A causa desse encerramento isolado não foi confirmada.

Os testes não substituem a avaliação humana de dificuldade e diversão. Não houve novo teste em navegador nesta revisão; o preset Web em GDScript permanece incluído.
