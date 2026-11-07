# Validação — conversão GDScript, 06/11/2026

- Engine utilizada: Godot **4.4.1 padrão**, `4.4.1.stable.official.49a5bc7b6`, Linux x86_64. Nenhum SDK .NET foi usado para executar esta versão.
- Importação e análise dos scripts GDScript: sem erros.
- Suíte de integração em GDScript: **39 verificações aprovadas**.
- Percurso físico: **cinco fases e tutorial concluídos** com movimentos, saltos, dash e colisões de chave/porta. Sem teletransportes nessa suíte.
- Exportação **Web release** gerada com sucesso pela Godot padrão 4.4.1 e template oficial `web_nothreads_release.zip` da mesma versão. O preset usa uma thread e nenhuma extensão nativa.
- Testes executados por `testar.sh`; logs em `self-test.log` e `traversal-test.log`.

## Limites da verificação

O navegador Chromium automatizado deste ambiente encerrou durante o teste da página exportada. A exportação Web foi concluída, mas a execução do jogo dentro do navegador não foi confirmada aqui. Para verificá-la localmente, execute `bash exportar-web.sh` e sirva `builds/web` com `python3 -m http.server 8000 --directory builds/web`.

Não houve teste com controle físico ou execução em Windows/macOS. Os bindings de joystick foram conferidos pela suíte. A configuração de exportação Web foi verificada na versão 4.4.1; use templates correspondentes à versão 4.4.x do seu editor.

Os patches são produzidos contra o ZIP original `Ice-Grim-main.zip` e contra a entrega anterior `Ice-Grim-Godot44-CSharp.zip`. O aplicador faz `git apply --check` antes de escrever e salva os arquivos afetados em um backup ZIP. Nenhum commit ou push é feito no repositório do usuário.
