# 1.3.1 — Correção do contato com o boss

A versão 1.3 podia matar o jogador no corpo antes de o dash alcançar o núcleo aceso. O teste anterior cobria uma sequência precisa de movimentos por controle injetado; não verificava variações suficientes da entrada normal de teclado. O problema foi reproduzido com eventos de teclado: 16 de 28 combinações de posição, duração do pulo e intervalo até o dash terminavam em morte.

## Correções

- O corpo não mata durante a abertura do núcleo. Encostar sem atacar continua sem causar dano ao chefe.
- O alvo acompanha o anel luminoso do núcleo, com uma pequena margem de acerto.
- O jogo considera todo o deslocamento real do dash, incluindo o último passo de física.
- Um dash iniciado durante a abertura permanece válido até terminar, mesmo se a armadura fechar no caminho.
- Ao apertar pulo e dash juntos, o salto inicia antes do impulso horizontal, em vez de ser descartado.
- Espinhos, projéteis e contato com o chefe fechado continuam letais. Vida, padrões, duração das aberturas e regra de reinício da campanha foram mantidos.

- Créditos corrigidos: arte e sprites de Maria Vitória; todas as músicas já incluídas são autorais de Juliano. Removida a indicação de trilha pendente.

## Validação

84 variações de ataque usando eventos de teclado, com pulos curtos/longos, sete intervalos e duas posições nas três etapas do chefe; recuo seguro ao soltar as teclas; limite de fechamento da abertura; contato sem ataque; chefe fechado; espinhos. Mais uma luta inteira de nove acertos por teclado com todos os ataques habilitados e regressão da campanha. Veja `docs/VALIDACAO_V1_3_1.md`.
