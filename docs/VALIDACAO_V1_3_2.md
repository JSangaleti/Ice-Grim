# Validação — Ice Grim 1.3.2

Godot 4.4.1 padrão para Linux, física a 60 Hz. Código GDScript. Verificações executadas em 7 de novembro de 2026.

## Música

A mudança de fase ou menu atualiza uma única solicitação de próxima faixa. A reprodução atual não é parada nem reiniciada. O fim real do AudioStreamPlayer seleciona a próxima faixa, ou repete a atual se não houver mudança. Pedidos intermediários são descartados. Retornar à situação da faixa atual cancela a troca pendente. Fechar o jogo interrompe a reprodução e limpa a solicitação.

O stream é duplicado antes de desativar seu loop interno, preservando o recurso importado. A repetição é controlada pelo evento de término para permitir a troca no fim. Efeitos sonoros, volume e mudo mantêm seus controles.

Os testes usam os MP3 incluídos e o evento nativo `finished`. Somente na suíte, a reprodução é posicionada perto do fim para não aguardar vários minutos. O código de produção não faz seek. Foram verificados: início, preservação do recurso, cursor sem reinício, fila mais recente, pedidos repetidos, troca apenas após término, cancelamento, repetição, retorno ao menu e encerramento.

## Três vidas na arena

O personagem recebe três vidas utilizáveis apenas na arena do boss. O HUD exibe `VIDAS 3 / 3`, separadamente dos nove pontos de vida do chefe. Cada dano consome uma vida, limpa os ataques já ativos, retorna o personagem à plataforma segura e dá 1,5 segundo de proteção com efeito de piscar. A vida e a etapa do boss são preservadas, assim como o relógio e a tentativa da campanha. A pausa congela a proteção.

Dois ataques sobrepostos não gastam vidas adicionais durante a proteção. O terceiro dano válido causa Game Over. Tentar novamente volta à fase 1. Uma nova visita à sexta fase restaura as três vidas. As fases anteriores e o percurso de aproximação ao boss continuam com a regra de morte por contato. O botão/comando de reiniciar campanha continua sendo uma reinicialização explícita.

## Resultados

| Suíte | Resultado |
| --- | --- |
| Importação na engine | Sem erro de recurso ou GDScript |
| Música e vidas | 31 verificações, incluindo término real de MP3, danos por contato/projétil, proteção, pausa, HUD, Game Over e reinício |
| Interface | 13 verificações com eventos de mouse e teclado |
| Mecânicas e progressão | 43 verificações |
| Armadilhas | 24 verificações; fase 4 percorrida a pé em três tempos |
| Entrada do boss | 263 verificações; 84 variações de ataque por teclado nas três etapas |
| Luta completa por teclado | Nove acertos com todos os ataques habilitados e as três vidas intactas |
| Percurso completo | Seis fases, chefe e tutorial concluídos por movimento e colisões |
| Renderização | Contador de vidas e créditos conferidos em OpenGL Compatibility, Mesa llvmpipe |
| Créditos | Arte e sprites de Maria Vitória; todas as músicas incluídas são autorais de Juliano |

Os testes isolados posicionam o personagem e selecionam o estado do chefe para verificar cada dano. Os percursos completos não usam teletransporte de teste, alteração de HP ou proteção extra. O teste da luta por teclado exige terminar com as três vidas intactas; a proteção da nova mecânica não mascara uma falha na rota anterior.

## Reproduzir

```bash
bash testar.sh
```

Marcas: `UI_TEST_OK: 13`, `SELF_TEST_OK: 43`, `TRAPS_TEST_OK: 24`, `MUSIC_LIVES_TEST_OK: 31`, `BOSS_INPUT_TEST_OK: 263`, `BOSS_KEYBOARD_FIGHT_OK:`, `BOSS_TEST_OK:` e `TRAVERSAL_OK:`. Logs em `testes_v1_3_2.log` e `musica_vidas_v1_3_2.log`.

## Aplicação e limites

O aplicador atualiza as entregas conhecidas, faz backup e preserva arquivos locais, Git, configurações não relacionadas, sprites e músicas. Conflitos em scripts alterados interrompem a atualização antes de escrever. O pacote inclui uma cópia completa independente em `jogo/`.

A duração e o arranjo dos arquivos musicais não foram alterados. Não há crossfade: a mudança ocorre no término natural da faixa. Se você atravessar várias fases durante uma música longa, ouvirá a faixa da situação mais recente depois do fim, sem uma fila de fases antigas.

A verificação foi feita na engine nativa; não houve novo teste em navegador. O preset Web permanece incluído. Não houve avaliação humana de dificuldade ou audição crítica nesta revisão; o término das faixas foi verificado pelo sistema de reprodução da engine.
