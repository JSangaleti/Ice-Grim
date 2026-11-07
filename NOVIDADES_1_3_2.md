# 1.3.2 — Músicas completas e três vidas no boss

- A música atual termina inteira antes de mudar. A mudança de fase ou menu apenas escolhe a próxima faixa.
- Só a solicitação mais recente é mantida. Se a situação voltar à música atual, a troca é cancelada. Sem troca, a faixa repete inteira.
- O personagem tem três vidas na arena do Rei da Nevasca, com contador separado da vida do chefe.
- Cada dano consome uma vida, devolve o jogador à plataforma segura e dá 1,5 segundo de proteção visual. A vida e a etapa do boss são preservadas.
- Pausar congela a proteção. Contatos no mesmo instante não gastam várias vidas. A terceira perda causa Game Over; tentar novamente reinicia a campanha na fase 1.
- Fases anteriores e o percurso até a arena mantêm a regra anterior de morte por contato.
- Créditos mantidos: arte e sprites de Maria Vitória; todas as músicas incluídas são autorais de Juliano.

Validação: `docs/VALIDACAO_V1_3_2.md`. Execute `bash testar.sh`.
