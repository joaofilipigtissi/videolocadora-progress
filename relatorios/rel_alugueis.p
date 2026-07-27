DEFINE BUFFER bfCliente FOR Clientes.
DEFINE BUFFER bfCidade  FOR Cidades.
DEFINE BUFFER bfAluguel FOR Alugueis.
DEFINE BUFFER bfItem    FOR Aluguel_Filmes.
DEFINE BUFFER bfFilme   FOR Filmes.

DEFINE VARIABLE cRelatorio    AS CHARACTER NO-UNDO.
DEFINE VARIABLE cLinha        AS CHARACTER NO-UNDO.
DEFINE VARIABLE cArquivo      AS CHARACTER NO-UNDO.
DEFINE VARIABLE dTotalAluguel AS DECIMAL   NO-UNDO.

DEFINE VARIABLE ed_relatorio AS CHARACTER
    VIEW-AS EDITOR
    SIZE 100 BY 28
    SCROLLBAR-VERTICAL
    NO-UNDO.

DEFINE BUTTON bt_exportar LABEL "Exportar".
DEFINE BUTTON bt_fechar   LABEL "Fechar".

FORM
    ed_relatorio

    SKIP(1)

    bt_exportar
    bt_fechar

WITH FRAME fr_principal
    THREE-D
    WIDTH 106
    TITLE "Relatorio de Alugueis".

DEFINE VARIABLE wJanela         AS WIDGET-HANDLE NO-UNDO.
DEFINE VARIABLE wJanelaAnterior AS WIDGET-HANDLE NO-UNDO.

wJanelaAnterior = CURRENT-WINDOW.

CREATE WINDOW wJanela
    ASSIGN
        TITLE   = "Relatorio de Alugueis"
        WIDTH   = 106
        HEIGHT  = 32
        VISIBLE = TRUE.

CURRENT-WINDOW = wJanela.

VIEW FRAME fr_principal.

ENABLE
    ed_relatorio
    bt_exportar
    bt_fechar
WITH FRAME fr_principal.

ed_relatorio:READ-ONLY IN FRAME fr_principal = TRUE.

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
        TITLE "Exportar Relatorio de Alugueis".

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
   MONTAGEM DO RELATORIO (agrupado por cliente)
   ================================================================ */

cRelatorio = "RELATORIO DE ALUGUEIS POR CLIENTE" + CHR(10) + CHR(10).

FOR EACH bfCliente NO-LOCK BY bfCliente.CodCliente:

    /* So imprime o cliente se ele tiver ao menos um aluguel */
    IF NOT CAN-FIND(FIRST bfAluguel
                     WHERE bfAluguel.CodCliente = bfCliente.CodCliente)
    THEN
        NEXT.

    FIND FIRST bfCidade
        WHERE bfCidade.CodCidade = bfCliente.CodCidade
        NO-LOCK NO-ERROR.

    cRelatorio = cRelatorio
               + FILL("=", 96) + CHR(10)
               + "Cliente: " + STRING(bfCliente.CodCliente) + " - " + bfCliente.NomCliente + CHR(10)
               + "Endereco: " + bfCliente.Endereco
               + (IF AVAILABLE bfCidade
                     THEN " / " + bfCidade.NomCidade + "-" + bfCidade.CodUF
                     ELSE "")
               + CHR(10)
               + FILL("=", 96) + CHR(10).

    FOR EACH bfAluguel
        WHERE bfAluguel.CodCliente = bfCliente.CodCliente
        NO-LOCK
        BY bfAluguel.CodAluguel:

        cRelatorio = cRelatorio
                   + CHR(10)
                   + "  Aluguel: " + STRING(bfAluguel.CodAluguel)
                   + "    Data: " + STRING(bfAluguel.DatAluguel) + CHR(10)
                   + "  Observacao: " + bfAluguel.Observacao + CHR(10)
                   + CHR(10)
                   + "  " + STRING("Item","x(6)")
                           + STRING("Filme","x(30)")
                           + STRING("Qtde","x(8)")
                           + STRING("Valor","x(12)")
                           + STRING("Total","x(12)")
                   + CHR(10)
                   + "  " + FILL("-",5)  + " "
                          + FILL("-",29) + " "
                          + FILL("-",7)  + " "
                          + FILL("-",11) + " "
                          + FILL("-",11) + CHR(10).

        dTotalAluguel = 0.

        FOR EACH bfItem
            WHERE bfItem.CodAluguel = bfAluguel.CodAluguel
            NO-LOCK
            BY bfItem.CodItem:

            FIND FIRST bfFilme
                WHERE bfFilme.CodFilme = bfItem.CodFilme
                NO-LOCK NO-ERROR.

            cLinha = "  "
                   + STRING(bfItem.CodItem, ">>>9") + "  "
                   + STRING(
                        (IF AVAILABLE bfFilme
                            THEN STRING(bfFilme.CodFilme) + "-" + bfFilme.NomFilme
                            ELSE ""),
                        "x(28)") + " "
                   + STRING(bfItem.NumQuantidade, ">>>9") + "    "
                   + STRING(
                        (IF AVAILABLE bfFilme THEN bfFilme.ValFilme ELSE 0),
                        "->>>,>>9.99") + "  "
                   + STRING(bfItem.ValTotal, "->>>,>>9.99").

            cRelatorio = cRelatorio + cLinha + CHR(10).

            dTotalAluguel = dTotalAluguel + bfItem.ValTotal.

        END.

        cRelatorio = cRelatorio
                   + CHR(10)
                   + "  Total do Aluguel = " + STRING(dTotalAluguel, "->>>,>>9.99") + CHR(10)
                   + CHR(10).

    END.

END.

ed_relatorio:SCREEN-VALUE IN FRAME fr_principal = cRelatorio.

WAIT-FOR WINDOW-CLOSE OF wJanela.

IF VALID-HANDLE(wJanela) THEN
    DELETE WIDGET wJanela.

IF VALID-HANDLE(wJanelaAnterior) THEN
    CURRENT-WINDOW = wJanelaAnterior.
