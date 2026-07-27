# Video Locadora Progress

Trabalho final do treinamento **Progress OpenEdge** — BootCamp TOTVS 2026.

Sistema de gestão para uma locadora de filmes, desenvolvido em **Progress ABL (4GL)**, com cadastros completos, validações de integridade referencial, relatórios e exportação de dados em CSV/JSON.

---

## 📺 Vídeo Demonstrativo

> **[Assista ao vídeo demonstrativo aqui](https://youtu.be/92uF_du82_s)**

[![Assista ao vídeo](https://img.youtube.com/vi/92uF_du82_s/0.jpg)](https://youtu.be/92uF_du82_s)

---

## Funcionalidades

- **Cadastro de Cidades** — código, nome e UF, com sequência automática e bloqueio de exclusão quando vinculada a algum cliente.
- **Cadastro de Clientes** — nome, endereço, cidade (com validação de FK) e observação, com bloqueio de exclusão quando vinculado a algum aluguel.
- **Cadastro de Filmes** — nome, valor, categoria, gênero e sinopse, com bloqueio de exclusão quando vinculado a algum aluguel.
- **Cadastro de Aluguéis e Filmes Alugados** — tela principal com dados do aluguel (cliente, endereço e cidade preenchidos automaticamente a partir do cliente) e uma grade de itens (filmes alugados), com dialog-box própria para adicionar/alterar cada item.
- **Relatório de Clientes** — listagem geral com código, nome, endereço, cidade e observação.
- **Relatório de Aluguéis** — agrupado por cliente, com todos os aluguéis, itens, quantidades, valores e total por aluguel.
- **Exportação CSV + JSON** em todos os cadastros, e exportação em `.txt` nos relatórios — todos abrindo automaticamente no Bloco de Notas ao final da exportação.
- **Menu de Acesso** centralizado, com conexão automática ao banco de dados.

---

## Estrutura do repositório

```
/cadastros
    menu.p              Menu de acesso do sistema (ponto de entrada)
    cad_cidades.p        Cadastro de Cidades
    cad_clientes.p       Cadastro de Clientes
    cad_filmes.p         Cadastro de Filmes
    cad_alugueis.p       Cadastro de Alugueis e Filmes Alugados
    videoloc.df          Estrutura do banco de dados (tabelas, indices, sequencias)
    cidades.d            Dump de dados - Cidades
    clientes.d           Dump de dados - Clientes
    filmes.d             Dump de dados - Filmes
    alugueis.d           Dump de dados - Alugueis
    aluguel_filmes.d     Dump de dados - Aluguel_Filmes

/relatorios
    rel_clientes.p       Relatorio de Clientes
    rel_alugueis.p       Relatorio de Alugueis por Cliente
```

---

## Modelo de dados

| Tabela | Descrição |
|---|---|
| `Cidades` | Código, nome e UF |
| `Clientes` | Código, nome, endereço, cidade (FK), observação |
| `Filmes` | Código, nome, valor, categoria, gênero, sinopse |
| `Alugueis` | Código, cliente (FK), data, valor total, observação |
| `Aluguel_Filmes` | Aluguel (FK), item, filme (FK), quantidade, valor total |

O esquema completo, com índices e sequências, está em [`cadastros/videoloc.df`](./cadastros/videoloc.df).

---

## Como executar

### Pré-requisitos

- Progress OpenEdge instalado (ambiente de desenvolvimento / cliente GUI para Windows).
- Banco de dados criado a partir de `videoloc.df` (e, opcionalmente, populado com os arquivos `.d` inclusos).

### Passos

1. Clone ou baixe este repositório, mantendo a estrutura de pastas `cadastros/` e `relatorios/`.
2. Crie um banco de dados vazio a partir de `cadastros/videoloc.df` (via Data Administration ou `prodict/dump_df.p`).
3. Ajuste, se necessário, o caminho do banco no início de `cadastros/menu.p`:
   ```progress
   DEFINE VARIABLE cCaminhoDB AS CHARACTER NO-UNDO INITIAL "c:\dados\videoloc".
   ```
4. Ajuste, se necessário, os caminhos usados nas chamadas `RUN` dentro do `menu.p` para apontarem para onde você salvou as pastas `cadastros/` e `relatorios/` na sua máquina.
5. Execute `menu.p` — esse é o ponto de entrada único do sistema.

---

## Padrões técnicos do projeto

- Cada tela roda em sua própria `WINDOW`, evitando conflito com a janela do Menu ao navegar entre telas.
- Código de cada cadastro (`CodCidade`, `CodCliente`, `CodFilme`, `CodAluguel`) fica habilitado apenas durante a inclusão, e é sempre preenchido pela sequência correspondente (`NEXT-VALUE`), nunca pelo valor digitado.
- Botões padronizados em todas as telas: `<<`, `<`, `>`, `>>`, Adicionar, Modificar, Eliminar, Salvar, Cancelar, Exportar, Sair — com habilitação correta conforme o modo (consulta vs. edição).
- Todos os arquivos usam apenas caracteres ASCII (sem acentuação) nos identificadores, labels e mensagens, para evitar problemas de codificação entre ambientes.

---

## Autor

**João Filipi Girardi Tissi**
📧 joaofilipigtissi@gmail.com
🔗 [github.com/joaofilipigtissi](https://github.com/joaofilipigtissi)

BootCamp TOTVS 2026
