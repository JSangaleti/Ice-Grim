# Ice Grim completo — versão 1.1

Esta entrega abre **diretamente na fase 1** ao executar o projeto com F5. Para acessar Jogar, Tutorial, Opções e Créditos, pressione **Esc > Menu principal**. O jogo contém o tutorial e cinco fases.

Também pode abrir `scenes/JogarDireto.tscn` e pressionar F6. Para iniciar pelo menu tradicional, abra `scenes/Main.tscn` e pressione F6.

Teclado: A/D para mover, W para pular, S para abaixar, Shift para correr, Espaço para dash, Esc para pausa. Pegue a chave dourada e entre na porta. A morte reinicia a campanha na fase 1 ao tentar novamente.

No Linux:

```bash
bash jogar-direto.sh
```

Se o executável da sua Godot não for encontrado, informe seu caminho com `GODOT_BIN` ou use o instalador opcional da edição padrão 4.4.1:

```bash
bash instalar-godot.sh
bash jogar-direto.sh
```

O instalador opcional baixa a engine oficial no seu usuário. Não instala .NET e não precisa de sudo.

Verificação:

```bash
bash testar.sh
```

Resultados esperados: `UI_TEST_OK: 13`, `SELF_TEST_OK: 39` e `TRAVERSAL_OK`. A suíte de interface usa eventos roteados de mouse e teclado para abrir Jogar, Tutorial, Pausa, Créditos e Opções. A suíte de percurso conclui fisicamente as cinco fases e o tutorial.

A versão anterior também abriu a fase 1 por mouse e Enter no teste local. O bloqueio observado no computador da usuária não foi reproduzido; esta entrega torna a entrada na fase explícita e independente do menu e permite executar uma cópia completa isolada.
