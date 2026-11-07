# Versão 1.3 — Rei da Nevasca

- Créditos dos sprites para Maria Vitória e composição musical para Juliano, conforme atribuição corrigida na versão 1.3.1: todas as músicas incluídas são de Juliano.
- Sexta fase de 4.800 pixels de largura com câmera lateral, quatro travessias e arena fechada.
- Rei da Nevasca com nove pontos de vida, três fases e quatro tipos de ataque.
- Combate por salto + dash no núcleo vulnerável; reação e abertura visuais, sem avisos escritos de perigo.
- Chave liberada pela derrota do boss, porta final e vitória atualizadas.
- Melhor progresso de combate salvo e exibido no Game Over do boss.
- Recorde da campanha de seis fases separado do recorde antigo de cinco.
- Pasta opcional para substituir faixas por grupo de fases, com seleção automática.
- Testes físicos do percurso longo, luta completa e regressão da campanha.

A dificuldade pode ser ajustada em `gd/boss.gd`: HP, duração do ciclo, exposição, intervalos e velocidades. A geometria está em `levels/06.tscn`. A travessia reaproveita desafios existentes com posições deslocadas; o confronto, a câmera e a progressão são novos. A vontade de tentar de novo depende de jogadores reais; os testes automatizados demonstram uma rota possível, não garantem diversão nem medem dificuldade humana.
