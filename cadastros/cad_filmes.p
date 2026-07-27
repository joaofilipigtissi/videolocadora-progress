USING Progress.Json.ObjectModel.*.

DEFINE VARIABLE wJanela AS WIDGET-HANDLE NO-UNDO.
DEFINE VARIABLE wJanelaAnterior AS WIDGET-HANDLE NO-UNDO.

CREATE WINDOW wJanela
    ASSIGN
        TITLE   = "Cadastro de Filmes"
        WIDTH   = 140
        HEIGHT  = 30
        VISIBLE = TRUE.

CURRENT-WINDOW = wJanela.

DEFINE BUFFER bfItemVerifica FOR Aluguel_Filmes.
DEFINE BUFFER bfFilme        FOR Filmes.
DEFINE BUFFER bfFilmeAux     FOR Filmes.
DEFINE BUFFER bfFilmeNav     FOR Filmes.
DEFINE BUFFER bfFilmeExp     FOR Filmes.

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

DEFINE VARIABLE fi_cod_filme AS INTEGER FORMAT ">>>>9"
    LABEL "C¢digo"
    VIEW-AS FILL-IN SIZE 10 BY 1 NO-UNDO.

DEFINE VARIABLE fi_nom_filme AS CHARACTER FORMAT "X(50)"
    LABEL "Nome"
    VIEW-AS FILL-IN SIZE 50 BY 1 NO-UNDO.

DEFINE VARIABLE fi_val_filme AS DECIMAL FORMAT "->>>,>>9.99"
    LABEL "Valor"
    VIEW-AS FILL-IN SIZE 15 BY 1 NO-UNDO.

DEFINE VARIABLE fi_cod_categoria AS INTEGER FORMAT ">>>>9"
    LABEL "Categoria"
    VIEW-AS FILL-IN SIZE 10 BY 1 NO-UNDO.

DEFINE VARIABLE fi_genero AS CHARACTER FORMAT "X(30)"
    LABEL "Gˆnero"
    VIEW-AS FILL-IN SIZE 30 BY 1 NO-UNDO.

DEFINE VARIABLE fi_sinopse AS CHARACTER FORMAT "X(255)"
    LABEL "Sinopse"
    VIEW-AS EDITOR
    SIZE 60 BY 4
    NO-UNDO.


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

    fi_cod_filme      AT ROW 2 COL 20
    fi_nom_filme      AT ROW 3 COL 20
    fi_val_filme      AT ROW 4 COL 20
    fi_cod_categoria  AT ROW 5 COL 20
    fi_genero         AT ROW 6 COL 20
    fi_sinopse        AT ROW 7 COL 20

WITH FRAME fr_principal
    TITLE "Cadastro de Filmes"
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

ON CHOOSE OF bt_export IN FRAME fr_principal
DO:
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

    FIND FIRST bfFilme
        USE-INDEX CodFilme
        NO-LOCK
        NO-ERROR.

    IF AVAILABLE bfFilme THEN
        RUN pi-atualiza-tela.

END PROCEDURE.


PROCEDURE pi-carrega-ultimo:

    FIND LAST bfFilme
        USE-INDEX CodFilme
        NO-LOCK
        NO-ERROR.

    IF AVAILABLE bfFilme THEN
        RUN pi-atualiza-tela.

END PROCEDURE.


PROCEDURE pi-carrega-proximo:

    IF NOT AVAILABLE bfFilme THEN
    DO:
        RUN pi-carrega-primeiro.
        RETURN.
    END.

    FIND NEXT bfFilme
        USE-INDEX CodFilme
        NO-LOCK
        NO-ERROR.

    IF NOT AVAILABLE bfFilme THEN
        FIND FIRST bfFilme
            USE-INDEX CodFilme
            NO-LOCK
            NO-ERROR.

    IF AVAILABLE bfFilme THEN
        RUN pi-atualiza-tela.

END PROCEDURE.

PROCEDURE pi-carrega-anterior:

    IF NOT AVAILABLE bfFilme THEN
    DO:
        RUN pi-carrega-ultimo.
        RETURN.
    END.

    FIND PREV bfFilme
        USE-INDEX CodFilme
        NO-LOCK
        NO-ERROR.

    IF NOT AVAILABLE bfFilme THEN
        FIND LAST bfFilme
            USE-INDEX CodFilme
            NO-LOCK
            NO-ERROR.

    IF AVAILABLE bfFilme THEN
        RUN pi-atualiza-tela.

END PROCEDURE.


PROCEDURE pi-atualiza-tela:

    IF AVAILABLE bfFilme THEN
    DO:
        ASSIGN
            fi_cod_filme      = bfFilme.CodFilme
            fi_nom_filme      = bfFilme.NomFilme
            fi_val_filme      = bfFilme.ValFilme
            fi_cod_categoria  = bfFilme.CodCategoria
            fi_genero         = bfFilme.Genero
            fi_sinopse        = bfFilme.Sinopse.
    END.
    ELSE
    DO:
        ASSIGN
            fi_cod_filme      = ?
            fi_nom_filme      = ""
            fi_val_filme      = ?
            fi_cod_categoria  = ?
            fi_genero         = ""
            fi_sinopse        = "".
    END.

    DISPLAY
        fi_cod_filme
        fi_nom_filme
        fi_val_filme
        fi_cod_categoria
        fi_genero
        fi_sinopse
    WITH FRAME fr_principal.

END PROCEDURE.

PROCEDURE pi-habilita-consulta:

    DISABLE
        fi_cod_filme
        fi_nom_filme
        fi_val_filme
        fi_cod_categoria
        fi_genero
        fi_sinopse
    WITH FRAME fr_principal.

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
    WITH FRAME fr_principal.

END PROCEDURE.

PROCEDURE pi-habilita-edicao:

    ENABLE
        fi_nom_filme
        fi_val_filme
        fi_cod_categoria
        fi_genero
        fi_sinopse
    WITH FRAME fr_principal.

    IF lIncluindo THEN
        ENABLE fi_cod_filme WITH FRAME fr_principal.
    ELSE
        DISABLE fi_cod_filme WITH FRAME fr_principal.

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

    ENABLE
        bt_save
        bt_canc
    WITH FRAME fr_principal.

END PROCEDURE.

PROCEDURE pi-adicionar:

    RELEASE bfFilme.

    ASSIGN
        lIncluindo = TRUE
        lAlterando = FALSE.

    RUN pi-atualiza-tela.
    RUN pi-habilita-edicao.

    APPLY "ENTRY" TO fi_nom_filme IN FRAME fr_principal.

END PROCEDURE.

PROCEDURE pi-modificar:

    IF NOT AVAILABLE bfFilme THEN
        RETURN.

    ASSIGN
        lIncluindo = FALSE
        lAlterando = TRUE.

    RUN pi-habilita-edicao.

    APPLY "ENTRY" TO fi_nom_filme IN FRAME fr_principal.

END PROCEDURE.

PROCEDURE pi-cancelar:

    ASSIGN
        lIncluindo = FALSE
        lAlterando = FALSE.

    IF AVAILABLE bfFilme THEN
        RUN pi-atualiza-tela.
    ELSE
    DO:
        ASSIGN
            fi_cod_filme     = ?
            fi_nom_filme     = ""
            fi_val_filme     = ?
            fi_cod_categoria = ?
            fi_genero        = ""
            fi_sinopse       = "".

        DISPLAY
            fi_cod_filme
            fi_nom_filme
            fi_val_filme
            fi_cod_categoria
            fi_genero
            fi_sinopse
        WITH FRAME fr_principal.
    END.

    RUN pi-habilita-consulta.

END PROCEDURE.

PROCEDURE pi-salvar:

    DO WITH FRAME fr_principal:

        ASSIGN
            fi_nom_filme
            fi_val_filme
            fi_cod_categoria
            fi_genero
            fi_sinopse.

    END.

    IF TRIM(fi_nom_filme) = "" THEN
    DO:
        MESSAGE "Informe o nome do filme."
            VIEW-AS ALERT-BOX ERROR.

        APPLY "ENTRY" TO fi_nom_filme IN FRAME fr_principal.

        RETURN.
    END.

    IF fi_val_filme = ? THEN
    DO:
        MESSAGE "Informe o valor do filme."
            VIEW-AS ALERT-BOX ERROR.

        APPLY "ENTRY" TO fi_val_filme IN FRAME fr_principal.

        RETURN.
    END.

    DO TRANSACTION:

        IF lIncluindo THEN
        DO:
            CREATE bfFilme.

            ASSIGN
                bfFilme.CodFilme     = NEXT-VALUE(seqFilme)
                bfFilme.NomFilme     = fi_nom_filme
                bfFilme.ValFilme     = fi_val_filme
                bfFilme.CodCategoria = fi_cod_categoria
                bfFilme.Genero       = fi_genero
                bfFilme.Sinopse      = fi_sinopse.
        END.

        ELSE IF lAlterando THEN
        DO:
            FIND CURRENT bfFilme EXCLUSIVE-LOCK NO-ERROR.

            ASSIGN
                bfFilme.NomFilme     = fi_nom_filme
                bfFilme.ValFilme     = fi_val_filme
                bfFilme.CodCategoria = fi_cod_categoria
                bfFilme.Genero       = fi_genero
                bfFilme.Sinopse      = fi_sinopse.
        END.

    END.

    ASSIGN
        lIncluindo = FALSE
        lAlterando = FALSE.

    RUN pi-atualiza-tela.
    RUN pi-habilita-consulta.

END PROCEDURE.

PROCEDURE pi-eliminar:
    IF NOT AVAILABLE bfFilme THEN
        RETURN.

    /* Verifica se existe algum aluguel utilizando este filme */

    FIND FIRST bfItemVerifica
        WHERE bfItemVerifica.CodFilme = bfFilme.CodFilme
        NO-LOCK
        NO-ERROR.

    IF AVAILABLE bfItemVerifica THEN DO:
        MESSAGE
            "Nao e possivel eliminar este filme."
            SKIP
            "Existem alugueis cadastrados utilizando-o."
            VIEW-AS ALERT-BOX ERROR.
        RETURN.
    END.

    MESSAGE
        "Confirma a exclusao deste filme?"
        VIEW-AS ALERT-BOX QUESTION
        BUTTONS YES-NO
        UPDATE lResposta AS LOGICAL.

    IF NOT lResposta THEN
        RETURN.

    FIND CURRENT bfFilme EXCLUSIVE-LOCK NO-ERROR.

    IF AVAILABLE bfFilme THEN
        DELETE bfFilme.
    RUN pi-carrega-primeiro.
END PROCEDURE.
    
PROCEDURE pi-exportar:

    DEFINE VARIABLE cArquivoCSV  AS CHARACTER NO-UNDO.
    DEFINE VARIABLE cArquivoJSON AS CHARACTER NO-UNDO.
    DEFINE VARIABLE oArray       AS JsonArray  NO-UNDO.
    DEFINE VARIABLE oObj         AS JsonObject NO-UNDO.

    ASSIGN
        cArquivoCSV  = "c:\trabalho-final-progress\filmes.csv"
        cArquivoJSON = "c:\trabalho-final-progress\filmes.json".

    OUTPUT TO VALUE(cArquivoCSV).

    PUT UNFORMATTED
        "CodFilme;NomFilme;ValFilme;CodCategoria;Genero;Sinopse"
        SKIP.

    FOR EACH bfFilmeExp NO-LOCK
        BY bfFilmeExp.CodFilme:

        PUT UNFORMATTED
            STRING(bfFilmeExp.CodFilme)
            ";"
            REPLACE(bfFilmeExp.NomFilme, ";", " ")
            ";"
            STRING(bfFilmeExp.ValFilme)
            ";"
            STRING(bfFilmeExp.CodCategoria)
            ";"
            REPLACE(bfFilmeExp.Genero, ";", " ")
            ";"
            REPLACE(bfFilmeExp.Sinopse, ";", " ")
            SKIP.

    END.

    OUTPUT CLOSE.

    oArray = NEW JsonArray().

    FOR EACH bfFilmeExp NO-LOCK BY bfFilmeExp.CodFilme:

        oObj = NEW JsonObject().

        oObj:Add("CodFilme",     bfFilmeExp.CodFilme).
        oObj:Add("NomFilme",     bfFilmeExp.NomFilme).
        oObj:Add("ValFilme",     bfFilmeExp.ValFilme).
        oObj:Add("CodCategoria", bfFilmeExp.CodCategoria).
        oObj:Add("Genero",       bfFilmeExp.Genero).
        oObj:Add("Sinopse",      bfFilmeExp.Sinopse).

        oArray:Add(oObj).

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
  
