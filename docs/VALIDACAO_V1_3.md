# Validação — Ice Grim v1.3

Validação executada em 7 de novembro de 2026, Godot **4.4.1 padrão** para Linux, física a 60 Hz. Código GDScript, sem .NET. O aplicador foi testado em cópias locais das entregas conhecidas; não acessou a máquina da Maria Vitória.

## Resultados

| Verificação | Resultado |
| --- | --- |
| Importação limpa na engine | Sem erro de script ou recurso |
| Cena principal configurada | Abre fase 1 jogável; personagem apoiado no chão |
| Interface | 13 verificações com eventos roteados de mouse e teclado |
| Mecânicas e progressão | 43 verificações de integração |
| Pegadinhas e fase 4 | 24 verificações; fase 4 concluída a pé, sem corrida/dash, com três tempos de partida |
| Percurso da fase 6 | 4.800 pixels, plataformas, vãos, túnel e arena, por movimento físico |
| Boss | Nove acertos reais com salto/dash, atravessando as três etapas de combate |
| Duração da luta no replay | Cerca de 57 segundos após posicionamento na arena; percurso de aproximação separado |
| Regras do boss | Pausa congela chefe e projéteis; núcleo fechado rejeita dash; aberto exige dash; contato é letal |
| Progressão final | Quinta saída leva à sexta; boss libera chave; porta após boss gera vitória |
| Reinício | Morte no boss volta à fase 1; recarregar a sexta restaura HP, arena, chave e ataques |
| Campanha completa | Seis fases, boss e tutorial concluídos por controlador/colisão |
| Renderização nativa | Arena e créditos capturados e inspecionados em OpenGL Compatibility, Mesa llvmpipe |
| Créditos | Sprites de Maria Vitória; composição de Juliano; todas as músicas incluídas atribuídas a Juliano (corrigido em 1.3.1) |
| Música sem substituições opcionais | Trilha original de Juliano mantém o jogo executável |
| Música com arquivos de teste | Cinco nomes importados, associação de fases e preferência por OGG verificados |
| Aplicador | Atualização v1.2, v1.1 e conversão GDScript inicial; execução repetida sem alterações |
| Preservação | Nome/configuração extra, arquivo local, Git e arte/música customizadas preservados |
| Conflitos | Script local incompatível interrompe atualização antes de qualquer escrita |

A suíte de percurso completo e a rota do boss não usam teletransporte, invulnerabilidade, alteração de HP ou coleta direta. As suítes de estado isoladas usam posições/condições injetadas para verificar colisões específicas, progressão e falhas. Não alteram o recorde pessoal. A validação musical usou cópias dos MP3 incluídos de Juliano e uma conversão curta para OGG **somente em uma cópia de teste**; nenhuma dessas cópias foi incluída na pasta autoral da entrega. Correção de autoria na versão 1.3.1: os três MP3 incluídos já são músicas autorais de Juliano.

## Reproduzir

```bash
bash testar.sh
```

Marcas esperadas: `UI_TEST_OK: 13`, `SELF_TEST_OK: 43`, `TRAPS_TEST_OK: 24`, `BOSS_TEST_OK:` e `TRAVERSAL_OK:`. Logs: `testes_v1_3.log`, `inicio_direto_v1_3.log` e `musicas_autorais_v1_3.log`.

## Limites

Os testes demonstram uma rota possível e regras consistentes; não medem dificuldade humana, diversão nem vontade de repetir. A sexta usa trechos da campanha remixados como aproximação, além do boss novo. A morte reinicia toda a campanha, por continuidade com a regra anterior; isso torna a fase final bastante punitiva. O comando `bash jogar.sh -- --dev-level 6` permite experimentar só a fase nova durante desenvolvimento.

O preset Web permanece em GDScript e Compatibility, sem threads. Esta revisão foi testada na engine nativa; não houve novo teste de execução em navegador. É necessário importar e exportar novamente depois de adicionar as músicas autorais.
