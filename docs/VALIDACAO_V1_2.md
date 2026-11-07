# Validação da versão 1.2

Engine: Godot 4.4.1 padrão, Linux x86_64, física a 60 Hz.

- UI_TEST_OK: 13 verificações com eventos roteados de mouse e teclado.
- SELF_TEST_OK: 40 verificações de movimento, perigos, progressão, chave/porta e vitória.
- TRAPS_TEST_OK: 24 verificações de ausência de dicas, espinhos surpresa, camuflagem, colisões, pausa, reinício e chave que escapa.
- Fase 4 concluída fisicamente a velocidade de caminhada, sem corrida ou dash, com esperas de 0, 24 e 72 frames em ponto seguro antes dos degraus. Nessas travessias a chave e a porta são acionadas por colisão real, sem teletransporte.
- TRAVERSAL_OK: cinco fases consecutivas e tutorial concluídos por entradas de movimento, salto e dash e colisões reais.

O ponto exato que a usuária considerou impossível não foi identificado por imagem ou coordenada. Foi revista a sequência túnel/vão/plataforma elevada e a chegada à saída, removendo a necessidade de encaixar um salto longo imediatamente após o teto baixo.

A dificuldade para jogadores humanos ainda deve ser avaliada ao jogar. Os testes confirmam percursos executáveis na física da engine e o reinício consistente das armadilhas. Não houve teste com joystick físico nem nova execução Web nesta revisão.
