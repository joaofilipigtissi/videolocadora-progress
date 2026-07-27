USING Progress.Json.ObjectModel.*.

DEFINE VARIABLE wJanela         AS WIDGET-HANDLE NO-UNDO.
DEFINE VARIABLE wJanelaAnterior AS WIDGET-HANDLE NO-UNDO.

wJanelaAnterior = CURRENT-WINDOW.

CREATE WINDOW wJanela
    ASSIGN
        TITLE   = "Cadastro de Alugueis"
        WIDTH   = 140
        HEIGHT  = 34
        VISIBLE = TRUE.

CURRENT-WINDOW = wJanela.

DEFINE BUFFER bfAluguel    FOR Alugueis.
DEFINE BUFFER bfAluguelNav FOR Alugueis.
DEFINE BUFFER bfAluguelExp FOR Alugueis.

DEFINE BUFFER bfCliente    FOR Clientes.
DEFINE BUFFER bfCidade     FOR Cidades.
DEFINE BUFFER bfFilme      FOR Filmes.
DEFINE BUFFER bfItem       FOR Aluguel_Filmes.
DEFINE BUFFER bfItemExp    FOR Aluguel_Filmes.

DEFINE VARIABLE lIncluindo AS LOGICAL NO-UNDO.
DEFINE VARIABLE lAlterando AS LOGICAL NO-UNDO.
DEFINE VARIABLE lResposta  AS LOGICAL NO-UNDO.

DEFINE VARIABLE cArquivoCSV  AS CHARACTER NO-UNDO.
DEFINE VARIABLE cArquivoJSON AS CHARACTER NO-UNDO.

DEFINE VARIABLE fi_cod_aluguel AS INTEGER FORMAT ">>>>9"
    LABEL "Aluguel"
    VIEW-AS FILL-IN SIZE 10 BY 1 NO-UNDO.

DEFINE VARIABLE fi_dat_aluguel AS DATE
    LABEL "Data"
    VIEW-AS FILL-IN SIZE 12 BY 1 NO-UNDO.

DEFINE VARIABLE fi_cod_cliente AS INTEGER FORMAT ">>>>9"
    LABEL "Cliente"
    VIEW-AS FILL-IN SIZE 10 BY 1 NO-UNDO.

DEFINE VARIABLE fi_nom_cliente AS CHARACTER FORMAT "X(50)"
    VIEW-AS FILL-IN SIZE 35 BY 1 NO-UNDO.

DEFINE VARIABLE fi_endereco AS CHARACTER FORMAT "X(60)"
    LABEL "Endereco"
    VIEW-AS FILL-IN SIZE 60 BY 1 NO-UNDO.

DEFINE VARIABLE fi_cod_cidade AS INTEGER FORMAT ">>>>9"
    LABEL "Cidade"
    VIEW-AS FILL-IN SIZE 10 BY 1 NO-UNDO.

DEFINE VARIABLE fi_nom_cidade AS CHARACTER FORMAT "X(30)"
    VIEW-AS FILL-IN SIZE 30 BY 1 NO-UNDO.

DEFINE VARIABLE fi_observacao AS CHARACTER FORMAT "X(200)"
    LABEL "Observacao"
    VIEW-AS FILL-IN SIZE 60 BY 1 NO-UNDO.

/* Total do aluguel: mantido so internamente (nao aparece mais na tela
   principal), usado para gravar em ValAluguel e para a exportacao. */
DEFINE VARIABLE fi_val_total AS DECIMAL NO-UNDO.

/* ================================================================
   VARIAVEIS/BUFFERS EXCLUSIVOS DO DIALOG-BOX DE ITEM (2a TELA)
   ================================================================ */

DEFINE BUFFER bfFilmeDlg FOR Filmes.
DEFINE BUFFER bfItemDlg  FOR Aluguel_Filmes.

DEFINE VARIABLE lIncluindoItem     AS LOGICAL NO-UNDO.
DEFINE VARIABLE giItemCodAluguel   AS INTEGER NO-UNDO.
DEFINE VARIABLE giItemCodFilmeOrig AS INTEGER NO-UNDO.
DEFINE VARIABLE lItemGravou        AS LOGICAL NO-UNDO.
DEFINE VARIABLE cAcaoDlg           AS CHARACTER NO-UNDO.

DEFINE VARIABLE fi_dlg_cod_filme  AS INTEGER FORMAT ">>>>9"
    LABEL "Filme"
    VIEW-AS FILL-IN SIZE 10 BY 1 NO-UNDO.

DEFINE VARIABLE fi_dlg_nom_filme  AS CHARACTER FORMAT "X(50)"
    VIEW-AS FILL-IN SIZE 35 BY 1 NO-UNDO.

DEFINE VARIABLE fi_dlg_quantidade AS INTEGER FORMAT ">>>>9"
    LABEL "Quantidade"
    VIEW-AS FILL-IN SIZE 10 BY 1 NO-UNDO.

DEFINE VARIABLE fi_dlg_val_filme  AS DECIMAL NO-UNDO.

DEFINE VARIABLE fi_dlg_val_total  AS DECIMAL FORMAT "->>>,>>9.99"
    LABEL "Valor Total"
    VIEW-AS FILL-IN SIZE 12 BY 1 NO-UNDO.

DEFINE BUTTON bt_dlg_salvar    LABEL "Salvar".
DEFINE BUTTON bt_dlg_cancelar  LABEL "Cancelar".

DEFINE QUERY qItens FOR bfItem, bfFilme SCROLLING.
DEFINE BROWSE brItens
    QUERY qItens
    DISPLAY
        bfItem.CodItem               COLUMN-LABEL "Item"
        bfItem.CodFilme              COLUMN-LABEL "Filme"
        bfFilme.NomFilme             COLUMN-LABEL "Filme"
        bfItem.NumQuantidade         COLUMN-LABEL "Quantidade"
        bfFilme.ValFilme             COLUMN-LABEL "Valor"
        bfItem.ValTotal              COLUMN-LABEL "Total"

    WITH SIZE 120 BY 10.

DEFINE BUTTON bt_first LABEL "<<".
DEFINE BUTTON bt_prev  LABEL "<".
DEFINE BUTTON bt_next  LABEL ">".
DEFINE BUTTON bt_last  LABEL ">>".

DEFINE BUTTON bt_add  LABEL "Adicionar".
DEFINE BUTTON bt_upd  LABEL "Modificar".
DEFINE BUTTON bt_del  LABEL "Eliminar".

DEFINE BUTTON bt_save LABEL "Salvar".
DEFINE BUTTON bt_canc LABEL "Cancelar".

DEFINE BUTTON bt_item_add LABEL "Adicionar".
DEFINE BUTTON bt_item_upd LABEL "Modificar".
DEFINE BUTTON bt_item_del LABEL "Eliminar".

DEFINE BUTTON bt_export LABEL "Exportar".
DEFINE BUTTON bt_end    LABEL "Sair".

FORM
    bt_first
    bt_prev
    bt_next
    bt_last
    SPACE(5)
    bt_add
    bt_upd
    bt_del
    SPACE(5)
    bt_save
    bt_canc
    SPACE(5)
    bt_export
    bt_end

    SKIP(2)

    fi_cod_aluguel                AT ROW 3 COL 20
    fi_dat_aluguel                AT ROW 3 COL 50

    fi_cod_cliente                AT ROW 4 COL 20
    fi_nom_cliente    NO-LABEL    AT ROW 4 COL 33

    fi_endereco                   AT ROW 5 COL 20

    fi_cod_cidade                 AT ROW 6 COL 20
    fi_nom_cidade     NO-LABEL    AT ROW 6 COL 33

    fi_observacao                 AT ROW 7 COL 20

    SKIP(2)

    "Filmes Alugados"            AT ROW 9 COL 2

    brItens                      AT ROW 10 COL 2

    SKIP(11)

    bt_item_add
    bt_item_upd
    bt_item_del

WITH FRAME fr_principal
    SIDE-LABELS
    THREE-D
    WIDTH 140
    TITLE "Cadastro de Alugueis".

VIEW FRAME fr_principal.

ENABLE brItens WITH FRAME fr_principal.

/* ================================================================
   FORM DA SEGUNDA TELA (DIALOG-BOX DE ITEM)
   Salvar/Cancelar como botoes proprios, dentro da dialog.
   ================================================================ */

FORM
    fi_dlg_cod_filme               AT ROW 2 COL 20
    fi_dlg_nom_filme   NO-LABEL    AT ROW 2 COL 33

    fi_dlg_quantidade              AT ROW 3 COL 20

    fi_dlg_val_total                AT ROW 4 COL 20

    SKIP(1)

    bt_dlg_salvar
    bt_dlg_cancelar

WITH FRAME fr_item_dialog
    VIEW-AS DIALOG-BOX
    TITLE "Filmes A Alugar"
    SIDE-LABELS
    THREE-D
    WIDTH 90.

ON LEAVE OF fi_dlg_cod_filme IN FRAME fr_item_dialog
DO:
    RUN pi-dlg-busca-filme.
END.

ON LEAVE OF fi_dlg_quantidade IN FRAME fr_item_dialog
DO:
    RUN pi-dlg-calcula-total.
END.

ON CHOOSE OF bt_dlg_salvar IN FRAME fr_item_dialog
DO:
    cAcaoDlg = "SALVAR".
END.

ON CHOOSE OF bt_dlg_cancelar IN FRAME fr_item_dialog
DO:
    cAcaoDlg = "CANCELAR".
END.

ON WINDOW-CLOSE OF FRAME fr_item_dialog
DO:
    /* "X" da titlebar equivale a clicar Cancelar */
    APPLY "CHOOSE" TO bt_dlg_cancelar IN FRAME fr_item_dialog.
    RETURN NO-APPLY.
END.

ON ENDKEY OF FRAME fr_item_dialog ANYWHERE
DO:
    /* ESC equivale a clicar Cancelar */
    APPLY "CHOOSE" TO bt_dlg_cancelar IN FRAME fr_item_dialog.
    RETURN NO-APPLY.
END.

ON LEAVE OF fi_cod_cliente IN FRAME fr_principal
DO:
    RUN pi-busca-cliente.
END.

ON VALUE-CHANGED OF brItens IN FRAME fr_principal
DO:
    RUN pi-atualiza-botoes-item.
END.

ON CHOOSE OF bt_first DO:
    RUN pi-carrega-primeiro.
END.

ON CHOOSE OF bt_prev DO:
    RUN pi-carrega-anterior.
END.

ON CHOOSE OF bt_next DO:
    RUN pi-carrega-proximo.
END.

ON CHOOSE OF bt_last DO:
    RUN pi-carrega-ultimo.
END.

ON CHOOSE OF bt_add DO:
    RUN pi-adicionar.
END.

ON CHOOSE OF bt_upd DO:
    RUN pi-modificar.
END.

ON CHOOSE OF bt_del DO:
    RUN pi-eliminar.
END.

ON CHOOSE OF bt_save DO:
    RUN pi-salvar.
END.

ON CHOOSE OF bt_canc DO:
    RUN pi-cancelar.
END.

ON CHOOSE OF bt_export DO:
    RUN pi-exportar.
END.

ON CHOOSE OF bt_item_add DO:
    RUN pi-item-adicionar.
END.

ON CHOOSE OF bt_item_upd DO:
    RUN pi-item-modificar.
END.

ON CHOOSE OF bt_item_del DO:
    RUN pi-item-eliminar.
END.

ON CHOOSE OF bt_end DO:
    APPLY "WINDOW-CLOSE" TO CURRENT-WINDOW.
END.

RUN pi-carrega-primeiro.

RUN pi-habilita-consulta.

WAIT-FOR WINDOW-CLOSE OF wJanela.

IF VALID-HANDLE(wJanela) THEN
    DELETE WIDGET wJanela.

IF VALID-HANDLE(wJanelaAnterior) THEN
    CURRENT-WINDOW = wJanelaAnterior.

PROCEDURE pi-atualiza-tela:

    IF AVAILABLE bfAluguel THEN
    DO:

        FIND FIRST bfCliente
            WHERE bfCliente.CodCliente = bfAluguel.CodCliente
            NO-LOCK NO-ERROR.

        IF AVAILABLE bfCliente THEN
            FIND FIRST bfCidade
                WHERE bfCidade.CodCidade = bfCliente.CodCidade
                NO-LOCK NO-ERROR.
        ELSE
            RELEASE bfCidade.

        ASSIGN
            fi_cod_aluguel = bfAluguel.CodAluguel
            fi_dat_aluguel = bfAluguel.DatAluguel
            fi_cod_cliente = bfAluguel.CodCliente
            fi_nom_cliente = IF AVAILABLE bfCliente THEN bfCliente.NomCliente ELSE ""
            fi_endereco    = IF AVAILABLE bfCliente THEN bfCliente.Endereco   ELSE ""
            fi_cod_cidade  = IF AVAILABLE bfCliente THEN bfCliente.CodCidade  ELSE ?
            fi_nom_cidade  = IF AVAILABLE bfCidade  THEN bfCidade.NomCidade   ELSE ""
            fi_observacao  = bfAluguel.Observacao
            fi_val_total   = bfAluguel.ValAluguel.

    END.
    ELSE
    DO:

        ASSIGN
            fi_cod_aluguel = ?
            fi_dat_aluguel = TODAY
            fi_cod_cliente = ?
            fi_nom_cliente = ""
            fi_endereco    = ""
            fi_cod_cidade  = ?
            fi_nom_cidade  = ""
            fi_observacao  = ""
            fi_val_total   = 0.

    END.

    DISPLAY

        fi_cod_aluguel
        fi_dat_aluguel
        fi_cod_cliente
        fi_nom_cliente
        fi_endereco
        fi_cod_cidade
        fi_nom_cidade
        fi_observacao

    WITH FRAME fr_principal.

    RUN pi-atualiza-browse.

END PROCEDURE.

PROCEDURE pi-atualiza-browse:

    CLOSE QUERY qItens.

    IF AVAILABLE bfAluguel THEN
    DO:

        OPEN QUERY qItens FOR

            EACH bfItem NO-LOCK
                WHERE bfItem.CodAluguel = bfAluguel.CodAluguel,

            FIRST bfFilme NO-LOCK
                WHERE bfFilme.CodFilme = bfItem.CodFilme

            BY bfItem.CodItem.

    END.
    ELSE
    DO:

        OPEN QUERY qItens FOR

            EACH bfItem
                WHERE FALSE,

            FIRST bfFilme
                WHERE FALSE.

    END.

    RUN pi-atualiza-botoes-item.

END PROCEDURE.

PROCEDURE pi-atualiza-botoes-item:

    ASSIGN
        bt_item_add:SENSITIVE IN FRAME fr_principal = AVAILABLE bfAluguel
        bt_item_upd:SENSITIVE IN FRAME fr_principal = AVAILABLE bfItem
        bt_item_del:SENSITIVE IN FRAME fr_principal = AVAILABLE bfItem.

END PROCEDURE.

PROCEDURE pi-carrega-primeiro:

    FIND FIRST bfAluguel
        USE-INDEX codAluguel
        NO-LOCK NO-ERROR.

    RUN pi-atualiza-tela.

END PROCEDURE.


PROCEDURE pi-carrega-ultimo:

    FIND LAST bfAluguel
        USE-INDEX codAluguel
        NO-LOCK NO-ERROR.

    RUN pi-atualiza-tela.

END PROCEDURE.


PROCEDURE pi-carrega-proximo:

    FIND NEXT bfAluguel
        USE-INDEX codAluguel
        NO-LOCK NO-ERROR.

    IF NOT AVAILABLE bfAluguel THEN
        FIND FIRST bfAluguel
            USE-INDEX codAluguel
            NO-LOCK NO-ERROR.

    RUN pi-atualiza-tela.

END PROCEDURE.


PROCEDURE pi-carrega-anterior:

    FIND PREV bfAluguel
        USE-INDEX codAluguel
        NO-LOCK NO-ERROR.

    IF NOT AVAILABLE bfAluguel THEN
        FIND LAST bfAluguel
            USE-INDEX codAluguel
            NO-LOCK NO-ERROR.

    RUN pi-atualiza-tela.

END PROCEDURE.

PROCEDURE pi-adicionar:

    ASSIGN
        lIncluindo = TRUE
        lAlterando = FALSE.

    ASSIGN
        fi_cod_aluguel = NEXT-VALUE(seqAluguel)
        fi_dat_aluguel = TODAY
        fi_cod_cliente = ?
        fi_nom_cliente = ""
        fi_endereco    = ""
        fi_cod_cidade  = ?
        fi_nom_cidade  = ""
        fi_observacao  = ""
        fi_val_total   = 0.

    DISPLAY

        fi_cod_aluguel
        fi_dat_aluguel
        fi_cod_cliente
        fi_nom_cliente
        fi_endereco
        fi_cod_cidade
        fi_nom_cidade
        fi_observacao

    WITH FRAME fr_principal.

    RUN pi-habilita-edicao.

END PROCEDURE.

PROCEDURE pi-modificar:

    IF NOT AVAILABLE bfAluguel THEN
        RETURN.

    ASSIGN
        lIncluindo = FALSE
        lAlterando = TRUE.

    RUN pi-habilita-edicao.

END PROCEDURE.

PROCEDURE pi-busca-cliente:

    /* Ignora enquanto o codigo ainda nao foi digitado -
       evita disparar "Cliente nao encontrado" antes de o usuario
       ter chance de preencher o campo. */
    IF fi_cod_cliente = 0 OR fi_cod_cliente = ? THEN
        RETURN.

    FIND bfCliente
        WHERE bfCliente.CodCliente = fi_cod_cliente
        NO-LOCK NO-ERROR.

    IF NOT AVAILABLE bfCliente THEN
    DO:
        MESSAGE
            "Cliente nao encontrado."
            VIEW-AS ALERT-BOX ERROR.

        ASSIGN
            fi_nom_cliente:SCREEN-VALUE IN FRAME fr_principal = ""
            fi_endereco:SCREEN-VALUE   IN FRAME fr_principal = ""
            fi_cod_cidade:SCREEN-VALUE IN FRAME fr_principal = ""
            fi_nom_cidade:SCREEN-VALUE IN FRAME fr_principal = "".

        RETURN.
    END.

    FIND FIRST bfCidade
        WHERE bfCidade.CodCidade = bfCliente.CodCidade
        NO-LOCK NO-ERROR.

    ASSIGN
        fi_nom_cliente:SCREEN-VALUE IN FRAME fr_principal = bfCliente.NomCliente
        fi_endereco:SCREEN-VALUE   IN FRAME fr_principal = bfCliente.Endereco
        fi_cod_cidade:SCREEN-VALUE IN FRAME fr_principal = STRING(bfCliente.CodCidade)
        fi_nom_cidade:SCREEN-VALUE IN FRAME fr_principal =
            (IF AVAILABLE bfCidade THEN bfCidade.NomCidade ELSE "").

END PROCEDURE.

PROCEDURE pi-salvar:

    DO WITH FRAME fr_principal:

    ASSIGN
        fi_cod_cliente
        fi_dat_aluguel
        fi_observacao.

    END.

    FIND bfCliente
        WHERE bfCliente.CodCliente = fi_cod_cliente
        NO-LOCK NO-ERROR.

    IF NOT AVAILABLE bfCliente THEN
    DO:
        MESSAGE
            "Cliente nao encontrado."
            VIEW-AS ALERT-BOX ERROR.

        APPLY "ENTRY" TO fi_cod_cliente IN FRAME fr_principal.
        RETURN.
    END.

    IF lIncluindo THEN
    DO:

        CREATE bfAluguel.

        ASSIGN
            bfAluguel.CodAluguel = fi_cod_aluguel.

    END.
    ELSE
    DO:

        FIND bfAluguel
            WHERE bfAluguel.CodAluguel = fi_cod_aluguel
            EXCLUSIVE-LOCK
            NO-ERROR.

        IF NOT AVAILABLE bfAluguel THEN
            RETURN.

    END.

    ASSIGN

        bfAluguel.CodCliente = fi_cod_cliente
        bfAluguel.DatAluguel = fi_dat_aluguel
        bfAluguel.Observacao = fi_observacao
        bfAluguel.ValAluguel = fi_val_total.

    RELEASE bfAluguel.

    FIND bfAluguel
        WHERE bfAluguel.CodAluguel = fi_cod_aluguel
        NO-LOCK no-error.

    ASSIGN
        lIncluindo = FALSE
        lAlterando = FALSE.

    RUN pi-atualiza-tela.
    RUN pi-habilita-consulta.
END PROCEDURE.

PROCEDURE pi-cancelar:

    ASSIGN
        lIncluindo = FALSE
        lAlterando = FALSE.

    RUN pi-habilita-consulta.

    RUN pi-atualiza-tela.

END PROCEDURE.

PROCEDURE pi-eliminar:

    IF NOT AVAILABLE bfAluguel THEN
        RETURN.

    MESSAGE
        "Confirma a exclusao do aluguel?"
        VIEW-AS ALERT-BOX QUESTION
        BUTTONS YES-NO
        UPDATE lResposta.

    IF NOT lResposta THEN
        RETURN.

    FIND CURRENT bfAluguel EXCLUSIVE-LOCK NO-ERROR.

    IF NOT AVAILABLE bfAluguel THEN
        RETURN.

    FOR EACH bfItem
        WHERE bfItem.CodAluguel = bfAluguel.CodAluguel
        EXCLUSIVE-LOCK:

        DELETE bfItem.

    END.

    DELETE bfAluguel.

    RUN pi-carrega-primeiro.

END PROCEDURE.

PROCEDURE pi-habilita-consulta:

    ASSIGN

        fi_cod_aluguel:SENSITIVE IN FRAME fr_principal = FALSE
        fi_dat_aluguel:SENSITIVE IN FRAME fr_principal = FALSE
        fi_cod_cliente:SENSITIVE IN FRAME fr_principal = FALSE
        fi_nom_cliente:SENSITIVE IN FRAME fr_principal = FALSE
        fi_endereco:SENSITIVE   IN FRAME fr_principal = FALSE
        fi_cod_cidade:SENSITIVE IN FRAME fr_principal = FALSE
        fi_nom_cidade:SENSITIVE IN FRAME fr_principal = FALSE
        fi_observacao:SENSITIVE IN FRAME fr_principal = FALSE.

    ASSIGN

        bt_first:SENSITIVE  IN FRAME fr_principal = TRUE
        bt_prev:SENSITIVE   IN FRAME fr_principal = TRUE
        bt_next:SENSITIVE   IN FRAME fr_principal = TRUE
        bt_last:SENSITIVE   IN FRAME fr_principal = TRUE

        bt_add:SENSITIVE    IN FRAME fr_principal = TRUE
        bt_upd:SENSITIVE    IN FRAME fr_principal = AVAILABLE bfAluguel
        bt_del:SENSITIVE    IN FRAME fr_principal = AVAILABLE bfAluguel

        bt_save:SENSITIVE   IN FRAME fr_principal = FALSE
        bt_canc:SENSITIVE   IN FRAME fr_principal = FALSE

        bt_export:SENSITIVE IN FRAME fr_principal = TRUE
        bt_end:SENSITIVE    IN FRAME fr_principal = TRUE.

    ENABLE brItens WITH FRAME fr_principal.

    RUN pi-atualiza-botoes-item.

END PROCEDURE.

PROCEDURE pi-habilita-edicao:

    ASSIGN

        fi_cod_aluguel:SENSITIVE IN FRAME fr_principal = lIncluindo
        fi_dat_aluguel:SENSITIVE IN FRAME fr_principal = TRUE
        fi_cod_cliente:SENSITIVE IN FRAME fr_principal = TRUE
        fi_nom_cliente:SENSITIVE IN FRAME fr_principal = FALSE
        fi_endereco:SENSITIVE   IN FRAME fr_principal = FALSE
        fi_cod_cidade:SENSITIVE IN FRAME fr_principal = FALSE
        fi_nom_cidade:SENSITIVE IN FRAME fr_principal = FALSE
        fi_observacao:SENSITIVE IN FRAME fr_principal = TRUE.

    ASSIGN

        bt_first:SENSITIVE  IN FRAME fr_principal = FALSE
        bt_prev:SENSITIVE   IN FRAME fr_principal = FALSE
        bt_next:SENSITIVE   IN FRAME fr_principal = FALSE
        bt_last:SENSITIVE   IN FRAME fr_principal = FALSE

        bt_add:SENSITIVE    IN FRAME fr_principal = FALSE
        bt_upd:SENSITIVE    IN FRAME fr_principal = FALSE
        bt_del:SENSITIVE    IN FRAME fr_principal = FALSE

        bt_save:SENSITIVE   IN FRAME fr_principal = TRUE
        bt_canc:SENSITIVE   IN FRAME fr_principal = TRUE

        bt_export:SENSITIVE IN FRAME fr_principal = FALSE
        bt_end:SENSITIVE    IN FRAME fr_principal = FALSE

        bt_item_add:SENSITIVE = FALSE
        bt_item_upd:SENSITIVE = FALSE
        bt_item_del:SENSITIVE = FALSE.

    DISABLE brItens WITH FRAME fr_principal.

    APPLY "ENTRY" TO fi_cod_cliente IN FRAME fr_principal.

END PROCEDURE.

/* ================================================================
   ITEM: ADICIONAR / MODIFICAR (dialog-box interno com Salvar/Cancelar)
   ================================================================ */

PROCEDURE pi-item-adicionar:

    DEFINE VARIABLE lGravouItem AS LOGICAL NO-UNDO.

    IF NOT AVAILABLE bfAluguel THEN
        RETURN.

    RUN pi-item-dialog (INPUT bfAluguel.CodAluguel, INPUT 0, OUTPUT lGravouItem).

    IF lGravouItem THEN
    DO:
        RUN pi-recalcula-total.
        RUN pi-atualiza-browse.
        RUN pi-habilita-consulta.
    END.

END PROCEDURE.


PROCEDURE pi-item-modificar:

    DEFINE VARIABLE lGravouItem    AS LOGICAL NO-UNDO.
    DEFINE VARIABLE iCodFilmeAtual AS INTEGER NO-UNDO.

    IF NOT AVAILABLE bfAluguel THEN
        RETURN.

    IF NOT AVAILABLE bfItem THEN
        RETURN.

    iCodFilmeAtual = bfItem.CodFilme.

    RUN pi-item-dialog (INPUT bfAluguel.CodAluguel, INPUT iCodFilmeAtual, OUTPUT lGravouItem).

    IF lGravouItem THEN
    DO:
        RUN pi-recalcula-total.
        RUN pi-atualiza-browse.
        RUN pi-habilita-consulta.
    END.

END PROCEDURE.


PROCEDURE pi-item-eliminar:

    IF NOT AVAILABLE bfItem THEN
    RETURN.

    MESSAGE
        "Confirma exclusao do item?"
        VIEW-AS ALERT-BOX QUESTION
        BUTTONS YES-NO
        UPDATE lResposta.

    IF NOT lResposta THEN
        RETURN.

    FIND CURRENT bfItem EXCLUSIVE-LOCK NO-ERROR.

    IF AVAILABLE bfItem THEN
        DELETE bfItem.

    RUN pi-recalcula-total.
    RUN pi-atualiza-browse.

END PROCEDURE.

PROCEDURE pi-recalcula-total:

    DEFINE VARIABLE dTotal      AS DECIMAL NO-UNDO.
    DEFINE VARIABLE iCodAluguel AS INTEGER NO-UNDO.

    IF NOT AVAILABLE bfAluguel THEN
        RETURN.

    iCodAluguel = bfAluguel.CodAluguel.
    dTotal      = 0.

    FOR EACH bfItem
        WHERE bfItem.CodAluguel = iCodAluguel
        NO-LOCK:

        dTotal = dTotal + bfItem.ValTotal.

    END.

    FIND bfAluguel
        WHERE bfAluguel.CodAluguel = iCodAluguel
        EXCLUSIVE-LOCK
        NO-ERROR.

    IF AVAILABLE bfAluguel THEN
        bfAluguel.ValAluguel = dTotal.

    RELEASE bfAluguel.

    FIND bfAluguel
        WHERE bfAluguel.CodAluguel = iCodAluguel
        NO-LOCK
        NO-ERROR.

    RUN pi-atualiza-tela.

END PROCEDURE.

PROCEDURE pi-exportar:
    ASSIGN
        cArquivoCSV  = "c:\trabalho-final-progress\alugueis.csv"
        cArquivoJSON = "c:\trabalho-final-progress\alugueis.json".

    /* ==========================
       EXPORTACAO CSV
       ========================== */

    OUTPUT TO VALUE(cArquivoCSV).

    PUT UNFORMATTED
        "Codigo;Cliente;Data;Observacao;Valor" SKIP.

    FOR EACH bfAluguelExp NO-LOCK
        BY bfAluguelExp.CodAluguel:

        PUT UNFORMATTED

            STRING(bfAluguelExp.CodAluguel) ";"
            STRING(bfAluguelExp.CodCliente) ";"
            STRING(bfAluguelExp.DatAluguel) ";"
            REPLACE(bfAluguelExp.Observacao,";"," ") ";"
            STRING(bfAluguelExp.ValAluguel)

            SKIP.

    END.

    OUTPUT CLOSE.


    /* ==========================
       EXPORTACAO JSON
       ========================== */

    DEFINE VARIABLE oArray      AS JsonArray  NO-UNDO.
    DEFINE VARIABLE oObjeto     AS JsonObject NO-UNDO.
    DEFINE VARIABLE oItens      AS JsonArray  NO-UNDO.
    DEFINE VARIABLE oItem       AS JsonObject NO-UNDO.

    oArray = NEW JsonArray().

    FOR EACH bfAluguelExp NO-LOCK
        BY bfAluguelExp.CodAluguel:

        oObjeto = NEW JsonObject().

        oObjeto:Add("CodAluguel", bfAluguelExp.CodAluguel).
        oObjeto:Add("CodCliente", bfAluguelExp.CodCliente).
        oObjeto:Add("Data", STRING(bfAluguelExp.DatAluguel)).
        oObjeto:Add("Observacao", bfAluguelExp.Observacao).
        oObjeto:Add("ValorTotal", bfAluguelExp.ValAluguel).

        /* Array de itens */
        oItens = NEW JsonArray().

        FOR EACH bfItemExp NO-LOCK
            WHERE bfItemExp.CodAluguel = bfAluguelExp.CodAluguel
            BY bfItemExp.CodItem:

            oItem = NEW JsonObject().

            oItem:Add("CodItem", bfItemExp.CodItem).
            oItem:Add("CodFilme", bfItemExp.CodFilme).
            oItem:Add("Quantidade", bfItemExp.NumQuantidade).
            oItem:Add("ValorTotal", bfItemExp.ValTotal).

            oItens:Add(oItem).

        END.

        oObjeto:Add("Itens", oItens).

        oArray:Add(oObjeto).

    END.

    oArray:WriteFile(cArquivoJSON, TRUE).

    MESSAGE
        "Arquivos exportados com sucesso!"
         VIEW-AS ALERT-BOX INFORMATION.

    OS-COMMAND NO-WAIT VALUE("notepad.exe " + cArquivoCSV).
    OS-COMMAND NO-WAIT VALUE("notepad.exe " + cArquivoJSON).

END PROCEDURE.

/* ================================================================
   DIALOG-BOX DE ITEM (2a TELA) - "Filmes A Alugar"
   ================================================================ */

PROCEDURE pi-item-dialog:

    DEFINE INPUT  PARAMETER ipCodAluguelDlg AS INTEGER NO-UNDO.
    DEFINE INPUT  PARAMETER ipCodFilmeDlg   AS INTEGER NO-UNDO.
    DEFINE OUTPUT PARAMETER opGravouDlg     AS LOGICAL NO-UNDO.

    ASSIGN
        giItemCodAluguel   = ipCodAluguelDlg
        giItemCodFilmeOrig = ipCodFilmeDlg
        lIncluindoItem     = (ipCodFilmeDlg = 0)
        lItemGravou        = FALSE.

    RUN pi-dlg-carregar.

    ENABLE
        fi_dlg_cod_filme
        fi_dlg_quantidade
        bt_dlg_salvar
        bt_dlg_cancelar
    WITH FRAME fr_item_dialog.

    APPLY "ENTRY" TO fi_dlg_cod_filme IN FRAME fr_item_dialog.

    REPEAT:

        cAcaoDlg = "".

        WAIT-FOR CHOOSE OF bt_dlg_salvar OR CHOOSE OF bt_dlg_cancelar
            IN FRAME fr_item_dialog.

        IF cAcaoDlg = "CANCELAR" THEN
        DO:
            lItemGravou = FALSE.
            LEAVE.
        END.

        IF cAcaoDlg = "SALVAR" THEN
        DO:
            /* Forca sincronizacao do que esta digitado na tela com
               as variaveis, mesmo que o usuario clique em Salvar
               sem antes sair do campo. */
            ASSIGN
                fi_dlg_cod_filme
                fi_dlg_quantidade.

            RUN pi-dlg-busca-filme.
            RUN pi-dlg-calcula-total.

            RUN pi-dlg-salvar.

            /* Se lItemGravou continuar FALSE, a validacao falhou
               (a mensagem de erro ja foi mostrada em pi-dlg-salvar)
               - o REPEAT volta a esperar, mantendo a dialog aberta
               para o usuario corrigir. */
            IF lItemGravou THEN
                LEAVE.
        END.

    END.

    HIDE FRAME fr_item_dialog.

    opGravouDlg = lItemGravou.

END PROCEDURE.


PROCEDURE pi-dlg-carregar:

    IF lIncluindoItem THEN
    DO:
        ASSIGN
            fi_dlg_cod_filme  = 0
            fi_dlg_nom_filme  = ""
            fi_dlg_quantidade = 1
            fi_dlg_val_filme  = 0
            fi_dlg_val_total  = 0.
    END.
    ELSE
    DO:
        FIND bfItemDlg
            WHERE bfItemDlg.CodAluguel = giItemCodAluguel
              AND bfItemDlg.CodFilme   = giItemCodFilmeOrig
            NO-LOCK NO-ERROR.

        IF AVAILABLE bfItemDlg THEN
        DO:
            FIND bfFilmeDlg
                WHERE bfFilmeDlg.CodFilme = bfItemDlg.CodFilme
                NO-LOCK NO-ERROR.

            ASSIGN
                fi_dlg_cod_filme  = bfItemDlg.CodFilme
                fi_dlg_quantidade = bfItemDlg.NumQuantidade
                fi_dlg_val_total  = bfItemDlg.ValTotal.

            IF AVAILABLE bfFilmeDlg THEN
                ASSIGN
                    fi_dlg_nom_filme = bfFilmeDlg.NomFilme
                    fi_dlg_val_filme = bfFilmeDlg.ValFilme.
        END.
    END.

    DISPLAY
        fi_dlg_cod_filme
        fi_dlg_nom_filme
        fi_dlg_quantidade
        fi_dlg_val_total
    WITH FRAME fr_item_dialog.

END PROCEDURE.


PROCEDURE pi-dlg-busca-filme:

    /* Ignora enquanto o codigo ainda nao foi digitado (0) -
       valor inicial em modo "Adicionar". Validar aqui geraria
       o erro falso "Filme nao encontrado" assim que a tela abre. */
    IF fi_dlg_cod_filme = 0 THEN
    DO:
        ASSIGN
            fi_dlg_nom_filme = ""
            fi_dlg_val_filme = 0
            fi_dlg_val_total = 0.

        DISPLAY
            fi_dlg_nom_filme
            fi_dlg_val_total
        WITH FRAME fr_item_dialog.

        RETURN.
    END.

    FIND bfFilmeDlg
        WHERE bfFilmeDlg.CodFilme = fi_dlg_cod_filme
        NO-LOCK NO-ERROR.

    IF NOT AVAILABLE bfFilmeDlg THEN
    DO:
        MESSAGE "Filme nao encontrado." VIEW-AS ALERT-BOX ERROR.

        ASSIGN
            fi_dlg_cod_filme = 0
            fi_dlg_nom_filme = ""
            fi_dlg_val_filme = 0
            fi_dlg_val_total = 0.

        DISPLAY
            fi_dlg_cod_filme
            fi_dlg_nom_filme
            fi_dlg_val_total
        WITH FRAME fr_item_dialog.

        APPLY "ENTRY" TO fi_dlg_cod_filme.
        RETURN.
    END.

    ASSIGN
        fi_dlg_nom_filme = bfFilmeDlg.NomFilme
        fi_dlg_val_filme = bfFilmeDlg.ValFilme.

    RUN pi-dlg-calcula-total.

    DISPLAY
        fi_dlg_nom_filme
        fi_dlg_val_total
    WITH FRAME fr_item_dialog.

END PROCEDURE.


PROCEDURE pi-dlg-calcula-total:

    fi_dlg_val_total = fi_dlg_quantidade * fi_dlg_val_filme.

    DISPLAY fi_dlg_val_total WITH FRAME fr_item_dialog.

END PROCEDURE.


PROCEDURE pi-dlg-salvar:

    DEFINE VARIABLE iProxItem AS INTEGER NO-UNDO.

    lItemGravou = FALSE.

    IF fi_dlg_cod_filme = 0 THEN
    DO:
        MESSAGE "Informe um filme." VIEW-AS ALERT-BOX ERROR.
        RETURN.
    END.

    IF fi_dlg_quantidade <= 0 THEN
    DO:
        MESSAGE "Quantidade invalida." VIEW-AS ALERT-BOX ERROR.
        RETURN.
    END.

    FIND bfFilmeDlg
        WHERE bfFilmeDlg.CodFilme = fi_dlg_cod_filme
        NO-LOCK NO-ERROR.

    IF NOT AVAILABLE bfFilmeDlg THEN
    DO:
        MESSAGE "Filme nao encontrado." VIEW-AS ALERT-BOX ERROR.
        RETURN.
    END.

    DO TRANSACTION:

        IF lIncluindoItem THEN
        DO:

            FIND bfItemDlg
                WHERE bfItemDlg.CodAluguel = giItemCodAluguel
                  AND bfItemDlg.CodFilme   = fi_dlg_cod_filme
                NO-LOCK NO-ERROR.

            IF AVAILABLE bfItemDlg THEN
            DO:
                MESSAGE "Este filme ja foi incluido neste aluguel." VIEW-AS ALERT-BOX ERROR.
                RETURN.
            END.

            /* proximo numero de item dentro deste aluguel */
            iProxItem = 0.

            FOR EACH bfItemDlg
                WHERE bfItemDlg.CodAluguel = giItemCodAluguel
                NO-LOCK:

                IF bfItemDlg.CodItem > iProxItem THEN
                    iProxItem = bfItemDlg.CodItem.

            END.

            CREATE bfItemDlg.

            bfItemDlg.CodItem = iProxItem + 1.

        END.
        ELSE
        DO:
            FIND bfItemDlg
                WHERE bfItemDlg.CodAluguel = giItemCodAluguel
                  AND bfItemDlg.CodFilme   = giItemCodFilmeOrig
                EXCLUSIVE-LOCK NO-ERROR.

            IF NOT AVAILABLE bfItemDlg THEN
            DO:
                MESSAGE "Item nao encontrado." VIEW-AS ALERT-BOX ERROR.
                RETURN.
            END.
        END.

        ASSIGN
            bfItemDlg.CodAluguel    = giItemCodAluguel
            bfItemDlg.CodFilme      = fi_dlg_cod_filme
            bfItemDlg.NumQuantidade = fi_dlg_quantidade
            bfItemDlg.ValTotal      = fi_dlg_quantidade * bfFilmeDlg.ValFilme.

    END.

    lItemGravou = TRUE.

END PROCEDURE.

