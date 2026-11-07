# Ice Grim 1.2 — pegadinhas e fase 4

A campanha recebeu novas armadilhas surpresa, chão/plataformas com aparência enganosa, quedas adicionais e uma mudança inesperada no comportamento de uma chave. Todos os elementos voltam ao estado inicial em cada tentativa.

Foram removidas as dicas escritas das fases da campanha, os marcadores visuais de queda, os avisos sonoros antecipados, as mensagens que explicavam o perigo após a morte e os balões de coleta/porta. Permanecem o HUD de fase, chave, cronômetro e dash. O tutorial mantém somente controles e objetivo.

A fase 4 foi redesenhada: o vão após o túnel é menor, há mais espaço para levantar e preparar o salto, a chave tem dois degraus de aproximação e há uma área segura antes da sequência final. A travessia foi testada sem corrida e sem dash, em três variações de tempo.

O início continua direto na fase 1 com F5. Menu completo: Esc > Menu principal. Jogue na Godot 4.4 padrão; não precisa de .NET.

Verificação: `bash testar.sh`. As suítes retornam `UI_TEST_OK: 13`, `SELF_TEST_OK: 40`, `TRAPS_TEST_OK: 24` e `TRAVERSAL_OK`.
