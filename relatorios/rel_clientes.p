DEFINE BUFFER bfCliente FOR Clientes.
DEFINE BUFFER bfCidade  FOR Cidades.

DEFINE TEMP-TABLE ttCliente NO-UNDO
    FIELD CodCliente AS INTEGER   FORMAT ">>>>9"
    FIELD NomCliente AS CHARACTER FORMAT "x(25)"
    FIELD Endereco   AS CHARACTER FORMAT "x(30)"
    FIELD Cidade     AS CHARACTER FORMAT "x(20)"
    FIELD Observacao AS CHARACTER FORMAT "x(25)".

DEFINE VARIABLE cRelatorio AS CHARACTER NO-UNDO.
DEFINE VARIABLE cLinha     AS CHARACTER NO-UNDO.
DEFINE VARIABLE cArquivo   AS CHARACTER NO-UNDO.

DEFINE QUERY qRelatorio FOR ttCliente SCROLLING.
DEFINE BROWSE brRelatorio
    QUERY qRelatorio
    DISPLAY
        ttCliente.CodCliente COLUMN-LABEL "Codigo"
        ttCliente.NomCliente COLUMN-LABEL "Nome"
        ttCliente.Endereco   COLUMN-LABEL "Endereco"
        ttCliente.Cidade     COLUMN-LABEL "Cidade"
        ttCliente.Observacao COLUMN-LABEL "Observacao"
    WITH SIZE 120 BY 26.

DEFINE BUTTON bt_exportar LABEL "Exportar".
DEFINE BUTTON bt_fechar   LABEL "Fechar".

FORM
    brRelatorio

    SKIP(1)

    bt_exportar
    bt_fechar

WITH FRAME fr_principal
    THREE-D
    WIDTH 125
    TITLE "Relatorio de Clientes".

DEFINE VARIABLE wJanela         AS WIDGET-HANDLE NO-UNDO.
DEFINE VARIABLE wJanelaAnterior AS WIDGET-HANDLE NO-UNDO.

wJanelaAnterior = CURRENT-WINDOW.

CREATE WINDOW wJanela
    ASSIGN
        TITLE   = "Relatorio de Clientes"
        WIDTH   = 106
        HEIGHT  = 32
        VISIBLE = TRUE.

CURRENT-WINDOW = wJanela.

VIEW FRAME fr_principal.

ENABLE
    brRelatorio
    bt_exportar
    bt_fechar
WITH FRAME fr_principal.

ON CHOOSE OF bt_fechar DO:
    APPLY "WINDOW-CLOSE" TO wJanela.
END.

ON CHOOSE OF bt_exportar DO:

    SYSTEM-DIALOG GET-FILE cArquivo
        FILTERS "Arquivos de Texto (*.txt)" "*.txt"
        SAVE-AS
        USE-FILENAME
        DEFAULT-EXTENSION ".txt"
        INITIAL-DIR "c:\trabalho-final-progress\relatorios"
        TITLE "Exportar Relatorio de Clientes".

    IF cArquivo = ? OR cArquivo = "" THEN
        RETURN.

    OUTPUT TO VALUE(cArquivo).
    PUT UNFORMATTED cRelatorio.
    OUTPUT CLOSE.

    MESSAGE
        "Relatorio exportado com sucesso!"
        SKIP
        cArquivo
        VIEW-AS ALERT-BOX INFORMATION.

END.

/* ================================================================
   MONTAGEM DO RELATORIO
   - ttCliente / brRelatorio: exibicao em tela, com alinhamento
     garantido pelo proprio browse (nao depende de fonte).
   - cRelatorio: versao em texto plano, usada so na exportacao .txt.
   ================================================================ */

ASSIGN
    cRelatorio = "RELATORIO DE CLIENTES" + CHR(10)
               + FILL("=", 96) + CHR(10)
               + STRING("Codigo","x(8)")
               + STRING("Nome","x(22)")
               + STRING("Endereco","x(28)")
               + STRING("Cidade","x(20)")
               + STRING("Observacao","x(18)")
               + CHR(10)
               + FILL("-",7)  + " "
               + FILL("-",21) + " "
               + FILL("-",27) + " "
               + FILL("-",19) + " "
               + FILL("-",18) + CHR(10).

FOR EACH bfCliente NO-LOCK BY bfCliente.CodCliente:

    FIND FIRST bfCidade
        WHERE bfCidade.CodCidade = bfCliente.CodCidade
        NO-LOCK NO-ERROR.

    /* Linha para exportacao em texto */
    cLinha = STRING(bfCliente.CodCliente, ">>>>9") + "  "
           + STRING(bfCliente.NomCliente, "x(21)")
           + STRING(bfCliente.Endereco, "x(28)")
           + STRING(
                (IF AVAILABLE bfCidade
                    THEN STRING(bfCidade.CodCidade) + "-" + bfCidade.NomCidade
                    ELSE ""),
                "x(20)")
           + STRING(bfCliente.Observacao, "x(18)").

    cRelatorio = cRelatorio + cLinha + CHR(10).

    /* Linha para exibicao no browse (alinhamento real, sem depender
       de fonte monoespacada) */
    CREATE ttCliente.

    ASSIGN
        ttCliente.CodCliente = bfCliente.CodCliente
        ttCliente.NomCliente = bfCliente.NomCliente
        ttCliente.Endereco   = bfCliente.Endereco
        ttCliente.Cidade     = IF AVAILABLE bfCidade
                                   THEN STRING(bfCidade.CodCidade) + "-" + bfCidade.NomCidade
                                   ELSE ""
        ttCliente.Observacao = bfCliente.Observacao.

END.

cRelatorio = cRelatorio + FILL("=", 96) + CHR(10).

OPEN QUERY qRelatorio FOR EACH ttCliente.

WAIT-FOR WINDOW-CLOSE OF wJanela.

IF VALID-HANDLE(wJanela) THEN
    DELETE WIDGET wJanela.

IF VALID-HANDLE(wJanelaAnterior) THEN
    CURRENT-WINDOW = wJanelaAnterior.

