USING Progress.Json.ObjectModel.*.

DEFINE VARIABLE wJanela AS WIDGET-HANDLE NO-UNDO.
DEFINE VARIABLE wJanelaAnterior AS WIDGET-HANDLE NO-UNDO.

CREATE WINDOW wJanela
    ASSIGN
        TITLE   = "Cadastro de Cidades"
        WIDTH   = 140
        HEIGHT  = 18
        VISIBLE = TRUE.

CURRENT-WINDOW = wJanela.

DEFINE BUFFER bfCidade    FOR Cidades.
DEFINE BUFFER bfCidadeAux FOR Cidades.
DEFINE BUFFER bfCidadeNav FOR Cidades.
DEFINE BUFFER bfCidadeExp FOR Cidades.
DEFINE BUFFER bfCliente FOR Clientes.

DEFINE VARIABLE cArquivoCSV  AS CHARACTER NO-UNDO.
DEFINE VARIABLE cArquivoJSON AS CHARACTER NO-UNDO.
DEFINE VARIABLE oArray  AS JsonArray  NO-UNDO.
DEFINE VARIABLE oObject AS JsonObject NO-UNDO.

DEFINE VARIABLE lIncluindo AS LOGICAL NO-UNDO.
DEFINE VARIABLE lAlterando AS LOGICAL NO-UNDO.

DEFINE BUTTON bt_first  LABEL "<<".
DEFINE BUTTON bt_prev   LABEL "<".
DEFINE BUTTON bt_next   LABEL ">".
DEFINE BUTTON bt_last   LABEL ">>".

DEFINE BUTTON bt_add    LABEL "Adicionar".
DEFINE BUTTON bt_upd    LABEL "Modificar".
DEFINE BUTTON bt_del    LABEL "Eliminar".

DEFINE BUTTON bt_save   LABEL "Salvar".
DEFINE BUTTON bt_canc   LABEL "Cancelar".

DEFINE BUTTON bt_export LABEL "Exportar".
DEFINE BUTTON bt_end    LABEL "Sair".

DEFINE VARIABLE fi_cod_cidade AS INTEGER FORMAT ">>>>9"
    LABEL "C¢digo"
    VIEW-AS FILL-IN SIZE 10 BY 1 NO-UNDO.

DEFINE VARIABLE fi_nom_cidade AS CHARACTER FORMAT "X(30)"
    LABEL "Cidade"
    VIEW-AS FILL-IN SIZE 35 BY 1 NO-UNDO.

DEFINE VARIABLE fi_cod_uf AS CHARACTER FORMAT "X(2)"
    LABEL "UF"
    VIEW-AS FILL-IN SIZE 5 BY 1 NO-UNDO.


FORM
    bt_first
    bt_prev
    bt_next
    bt_last
    SPACE(6)
    bt_add
    bt_upd
    bt_del
    SPACE(6)
    bt_save
    bt_canc
    SPACE(6)
    bt_export
    bt_end
    SKIP(2)

    fi_cod_cidade SKIP
    fi_nom_cidade SKIP
    fi_cod_uf

WITH FRAME fr_principal
    TITLE "Cadastro de Cidades"
    SIDE-LABELS
    THREE-D
    WIDTH 140.

VIEW FRAME fr_principal.


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

ON CHOOSE OF bt_end DO:
    APPLY "WINDOW-CLOSE" TO CURRENT-WINDOW.
END.

ON CHOOSE OF bt_canc DO:
    RUN pi-cancelar.
END.

ON CHOOSE OF bt_save DO:
    RUN pi-salvar.
END.

ON CHOOSE OF bt_upd DO:
    RUN pi-modificar.
END.

ON CHOOSE OF bt_del DO:
    RUN pi-eliminar.
END.

ON CHOOSE OF bt_export DO:
    RUN pi-exportar.
END.

RUN pi-carrega-primeiro.
RUN pi-habilita-consulta.

WAIT-FOR WINDOW-CLOSE OF wJanela.
IF VALID-HANDLE(wJanela) THEN
    DELETE WIDGET wJanela.

IF VALID-HANDLE(wJanelaAnterior) THEN
    CURRENT-WINDOW = wJanelaAnterior.

PROCEDURE pi-carrega-primeiro:

    FIND FIRST bfCidade
        USE-INDEX CodCidade
        NO-LOCK
        NO-ERROR.

    IF AVAILABLE bfCidade THEN
        RUN pi-atualiza-tela.

END PROCEDURE.


PROCEDURE pi-carrega-ultimo:

    FIND LAST bfCidade
        USE-INDEX CodCidade
        NO-LOCK
        NO-ERROR.

    IF AVAILABLE bfCidade THEN
        RUN pi-atualiza-tela.

END PROCEDURE.


PROCEDURE pi-carrega-proximo:

    FIND NEXT bfCidade
        USE-INDEX CodCidade
        NO-LOCK
        NO-ERROR.

    IF NOT AVAILABLE bfCidade THEN
        FIND FIRST bfCidade
            USE-INDEX CodCidade
            NO-LOCK
            NO-ERROR.

    IF AVAILABLE bfCidade THEN
        RUN pi-atualiza-tela.

END PROCEDURE.


PROCEDURE pi-carrega-anterior:

    FIND PREV bfCidade
        USE-INDEX CodCidade
        NO-LOCK
        NO-ERROR.

    IF NOT AVAILABLE bfCidade THEN
        FIND LAST bfCidade
            USE-INDEX CodCidade
            NO-LOCK
            NO-ERROR.

    IF AVAILABLE bfCidade THEN
        RUN pi-atualiza-tela.

END PROCEDURE.


PROCEDURE pi-atualiza-tela:

    ASSIGN
        fi_cod_cidade = IF AVAILABLE bfCidade THEN bfCidade.CodCidade ELSE ?
        fi_nom_cidade = IF AVAILABLE bfCidade THEN bfCidade.NomCidade ELSE ""
        fi_cod_uf     = IF AVAILABLE bfCidade THEN bfCidade.CodUF ELSE "".

    DISPLAY
        fi_cod_cidade
        fi_nom_cidade
        fi_cod_uf
    WITH FRAME fr_principal.

END PROCEDURE.


PROCEDURE pi-habilita-consulta:

    ENABLE
        bt_first
        bt_prev
        bt_next
        bt_last

        bt_add
        bt_upd
        bt_del

        bt_export
        bt_end

    WITH FRAME fr_principal.

    DISABLE
        bt_save
        bt_canc

        fi_cod_cidade
        fi_nom_cidade
        fi_cod_uf

    WITH FRAME fr_principal.

END PROCEDURE.


PROCEDURE pi-habilita-edicao:

    ENABLE
        bt_save
        bt_canc

        fi_nom_cidade
        fi_cod_uf

    WITH FRAME fr_principal.

    IF lIncluindo THEN
        ENABLE fi_cod_cidade WITH FRAME fr_principal.
    ELSE
        DISABLE fi_cod_cidade WITH FRAME fr_principal.

    DISABLE
        bt_first
        bt_prev
        bt_next
        bt_last

        bt_add
        bt_upd
        bt_del

        bt_export
        bt_end

    WITH FRAME fr_principal.

END PROCEDURE.


PROCEDURE pi-adicionar:

    RELEASE bfCidade.

    ASSIGN
        lIncluindo = TRUE
        lAlterando = FALSE.

    ASSIGN
        fi_cod_cidade = ?
        fi_nom_cidade = ""
        fi_cod_uf     = "".

    DISPLAY
        fi_cod_cidade
        fi_nom_cidade
        fi_cod_uf
    WITH FRAME fr_principal.

    RUN pi-habilita-edicao.

    APPLY "ENTRY" TO fi_nom_cidade IN FRAME fr_principal.

END PROCEDURE.

PROCEDURE pi-modificar:

    IF NOT AVAILABLE bfCidade THEN
        RETURN.

    ASSIGN
        lIncluindo = FALSE
        lAlterando = TRUE.

    RUN pi-habilita-edicao.

    APPLY "ENTRY" TO fi_nom_cidade IN FRAME fr_principal.

END PROCEDURE.

PROCEDURE pi-cancelar:

    ASSIGN
        lIncluindo = FALSE
        lAlterando = FALSE.

    RUN pi-habilita-consulta.

    IF AVAILABLE bfCidade THEN
        RUN pi-atualiza-tela.
    ELSE
        RUN pi-carrega-primeiro.

END PROCEDURE.

PROCEDURE pi-salvar:

    DO WITH FRAME fr_principal:

        ASSIGN
            fi_nom_cidade
            fi_cod_uf.

    END.

    /* Validaá∆o dos campos obrigat¢rios */

    IF fi_nom_cidade = "" THEN DO:

        MESSAGE
            "Informe o nome da cidade."
            VIEW-AS ALERT-BOX ERROR.

        APPLY "ENTRY" TO fi_nom_cidade IN FRAME fr_principal.

        RETURN.

    END.

    IF fi_cod_uf = "" THEN DO:

        MESSAGE
            "Informe a UF."
            VIEW-AS ALERT-BOX ERROR.

        APPLY "ENTRY" TO fi_cod_uf IN FRAME fr_principal.

        RETURN.

    END.

    /* Inclus∆o */

    IF lIncluindo THEN DO:

        FIND FIRST bfCidadeAux
            WHERE bfCidadeAux.NomCidade = fi_nom_cidade
              AND bfCidadeAux.CodUF      = fi_cod_uf
            NO-LOCK
            NO-ERROR.

        IF AVAILABLE bfCidadeAux THEN DO:

            MESSAGE
                "Esta cidade j† est† cadastrada."
                VIEW-AS ALERT-BOX ERROR.

            APPLY "ENTRY" TO fi_nom_cidade IN FRAME fr_principal.

            RETURN.

        END.

        CREATE bfCidade.

        ASSIGN
            bfCidade.CodCidade = NEXT-VALUE(seqCidade)
            bfCidade.NomCidade = fi_nom_cidade
            bfCidade.CodUF     = fi_cod_uf.

    END.

    /* Alteraá∆o */

    ELSE IF lAlterando THEN DO:

        FIND FIRST bfCidadeAux
            WHERE bfCidadeAux.NomCidade = fi_nom_cidade
              AND bfCidadeAux.CodUF      = fi_cod_uf
              AND bfCidadeAux.CodCidade <> bfCidade.CodCidade
            NO-LOCK
            NO-ERROR.

        IF AVAILABLE bfCidadeAux THEN DO:

            MESSAGE
                "J† existe outra cidade cadastrada com este nome e UF."
                VIEW-AS ALERT-BOX ERROR.

            APPLY "ENTRY" TO fi_nom_cidade IN FRAME fr_principal.

            RETURN.

        END.

        FIND CURRENT bfCidade EXCLUSIVE-LOCK NO-ERROR.

        IF LOCKED bfCidade THEN DO:

            MESSAGE
                "Registro em uso por outro usu†rio."
                VIEW-AS ALERT-BOX ERROR.

            RETURN.

        END.

        IF AVAILABLE bfCidade THEN DO:

            ASSIGN
                bfCidade.NomCidade = fi_nom_cidade
                bfCidade.CodUF     = fi_cod_uf.

        END.

    END.

    ASSIGN
        lIncluindo = FALSE
        lAlterando = FALSE.

    RUN pi-atualiza-tela.

    RUN pi-habilita-consulta.

END PROCEDURE.

PROCEDURE pi-eliminar:

    DEFINE VARIABLE lResposta AS LOGICAL NO-UNDO.
    DEFINE VARIABLE iProximo AS INTEGER NO-UNDO.

    IF NOT AVAILABLE bfCidade THEN
        RETURN.
        
    /* Verifica se existe algum cliente utilizando esta cidade */

    FIND FIRST bfCliente
        WHERE bfCliente.CodCidade = bfCidade.CodCidade
        NO-LOCK
        NO-ERROR.

        IF AVAILABLE bfCliente THEN DO:
            MESSAGE
            "N∆o Ç poss°vel eliminar esta cidade."
            SKIP
            "Existem clientes cadastrados utilizando-a."
            VIEW-AS ALERT-BOX ERROR.
            RETURN.
        END.
        
    MESSAGE
    "Deseja realmente eliminar esta cidade?"
    VIEW-AS ALERT-BOX QUESTION
    BUTTONS YES-NO
    UPDATE lResposta.

    IF NOT lResposta THEN
    RETURN.

    ASSIGN
        iProximo = ?.

    /* Posiciona o buffer de navegaá∆o no registro atual */

    FIND bfCidadeNav
        WHERE bfCidadeNav.CodCidade = bfCidade.CodCidade
        NO-LOCK
        NO-ERROR.

    IF AVAILABLE bfCidadeNav THEN DO:

        /* Tenta localizar o pr¢ximo registro */

        FIND NEXT bfCidadeNav
            USE-INDEX CodCidade
            NO-LOCK
            NO-ERROR.

        IF AVAILABLE bfCidadeNav THEN
            iProximo = bfCidadeNav.CodCidade.

        ELSE DO:

            /* N∆o existe pr¢ximo. Volta ao registro atual... */

            FIND bfCidadeNav
                WHERE bfCidadeNav.CodCidade = bfCidade.CodCidade
                NO-LOCK
                NO-ERROR.

            /* ...e procura o anterior */

            FIND PREV bfCidadeNav
                USE-INDEX CodCidade
                NO-LOCK
                NO-ERROR.

            IF AVAILABLE bfCidadeNav THEN
                iProximo = bfCidadeNav.CodCidade.

        END.

    END.

    /* Exclui o registro atual */

    FIND CURRENT bfCidade EXCLUSIVE-LOCK NO-ERROR.

    IF AVAILABLE bfCidade THEN
        DELETE bfCidade.

    RELEASE bfCidade.

    /* Reposiciona */

    IF iProximo <> ? THEN DO:

        FIND FIRST bfCidade
            WHERE bfCidade.CodCidade = iProximo
            NO-LOCK
            NO-ERROR.

        RUN pi-atualiza-tela.

    END.
    ELSE DO:

        ASSIGN
            fi_cod_cidade = ?
            fi_nom_cidade = ""
            fi_cod_uf     = "".

        DISPLAY
            fi_cod_cidade
            fi_nom_cidade
            fi_cod_uf
        WITH FRAME fr_principal.

    END.

    RUN pi-habilita-consulta.

END PROCEDURE.
    
PROCEDURE pi-exportar:

    ASSIGN
        cArquivoCSV  = "c:\trabalho-final-progress\cidades.csv"
        cArquivoJSON = "c:\trabalho-final-progress\cidades.json".

    /*****************************/
    /* Exportacao CSV            */
    /*****************************/

    OUTPUT TO VALUE(cArquivoCSV).

    PUT UNFORMATTED
        "CodCidade;NomCidade;CodUF"
        SKIP.

    FOR EACH bfCidadeExp NO-LOCK
        BY bfCidadeExp.CodCidade:

        PUT UNFORMATTED
            STRING(bfCidadeExp.CodCidade)
            ";"
            bfCidadeExp.NomCidade
            ";"
            bfCidadeExp.CodUF
            SKIP.

    END.

    OUTPUT CLOSE.

    /*****************************/
    /* Exportacao JSON           */
    /*****************************/

    oArray = NEW JsonArray().

    FOR EACH bfCidadeExp NO-LOCK
        BY bfCidadeExp.CodCidade:

        oObject = NEW JsonObject().

        oObject:Add("CodCidade", bfCidadeExp.CodCidade).
        oObject:Add("NomCidade", bfCidadeExp.NomCidade).
        oObject:Add("CodUF", bfCidadeExp.CodUF).

        oArray:Add(oObject).

    END.

    oArray:WriteFile(cArquivoJSON, TRUE).

    DELETE OBJECT oArray NO-ERROR.

    MESSAGE
        "Arquivos exportados com sucesso!"
        SKIP
        "CSV: " + cArquivoCSV
        SKIP
        "JSON: " + cArquivoJSON
        VIEW-AS ALERT-BOX INFORMATION.

    OS-COMMAND NO-WAIT VALUE("notepad.exe " + cArquivoCSV).
    OS-COMMAND NO-WAIT VALUE("notepad.exe " + cArquivoJSON).

END PROCEDURE.
  
