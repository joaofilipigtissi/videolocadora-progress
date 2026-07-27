USING Progress.Json.ObjectModel.*.

DEFINE VARIABLE wJanela AS WIDGET-HANDLE NO-UNDO.
DEFINE VARIABLE wJanelaAnterior AS WIDGET-HANDLE NO-UNDO.

CREATE WINDOW wJanela
    ASSIGN
        TITLE   = "Cadastro de Clientes"
        WIDTH   = 140
        HEIGHT  = 18
        VISIBLE = TRUE.

CURRENT-WINDOW = wJanela.

DEFINE BUFFER bfClienteExp FOR Clientes.
DEFINE BUFFER bfCliente    FOR Clientes.
DEFINE BUFFER bfClienteAux FOR Clientes.
DEFINE BUFFER bfClienteNav FOR Clientes.
DEFINE BUFFER bfCidade     FOR Cidades.
DEFINE BUFFER bfAluguel    FOR Alugueis.

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

DEFINE VARIABLE fi_cod_cliente AS INTEGER FORMAT ">>>>9"
    LABEL "C¢digo"
    VIEW-AS FILL-IN SIZE 10 BY 1 NO-UNDO.

DEFINE VARIABLE fi_nom_cliente AS CHARACTER FORMAT "X(50)"
    LABEL "Nome"
    VIEW-AS FILL-IN SIZE 50 BY 1 NO-UNDO.

DEFINE VARIABLE fi_endereco AS CHARACTER FORMAT "X(60)"
    LABEL "Endereáo"
    VIEW-AS FILL-IN SIZE 60 BY 1 NO-UNDO.

DEFINE VARIABLE fi_cod_cidade AS INTEGER FORMAT ">>>>9"
    LABEL "Cidade"
    VIEW-AS FILL-IN SIZE 10 BY 1 NO-UNDO.

DEFINE VARIABLE fi_observacao AS CHARACTER FORMAT "X(200)"
    LABEL "Observacao"
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

    fi_cod_cliente SKIP
    fi_nom_cliente SKIP
    fi_endereco SKIP
    fi_cod_cidade SKIP
    fi_observacao

WITH FRAME fr_principal
    TITLE "Cadastro de Clientes"
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

    FIND FIRST bfCliente
        USE-INDEX CodCliente
        NO-LOCK
        NO-ERROR.

    IF AVAILABLE bfCliente THEN
        RUN pi-atualiza-tela.

END PROCEDURE.


PROCEDURE pi-carrega-ultimo:

    FIND LAST bfCliente
        USE-INDEX CodCliente
        NO-LOCK
        NO-ERROR.

    IF AVAILABLE bfCliente THEN
        RUN pi-atualiza-tela.

END PROCEDURE.


PROCEDURE pi-carrega-proximo:

    FIND NEXT bfCliente
        USE-INDEX CodCliente
        NO-LOCK
        NO-ERROR.

    IF NOT AVAILABLE bfCliente THEN
        FIND FIRST bfCliente
            USE-INDEX CodCliente
            NO-LOCK
            NO-ERROR.

    IF AVAILABLE bfCliente THEN
        RUN pi-atualiza-tela.

END PROCEDURE.

PROCEDURE pi-carrega-anterior:

    FIND PREV bfCliente
        USE-INDEX CodCliente
        NO-LOCK
        NO-ERROR.

    IF NOT AVAILABLE bfCliente THEN
        FIND LAST bfCliente
            USE-INDEX CodCliente
            NO-LOCK
            NO-ERROR.

    IF AVAILABLE bfCliente THEN
        RUN pi-atualiza-tela.

END PROCEDURE.


PROCEDURE pi-atualiza-tela:

    ASSIGN
        fi_cod_cliente = IF AVAILABLE bfCliente THEN bfCliente.CodCliente ELSE ?
        fi_nom_cliente = IF AVAILABLE bfCliente THEN bfCliente.NomCliente ELSE ""
        fi_endereco    = IF AVAILABLE bfCliente THEN bfCliente.Endereco ELSE ""
        fi_cod_cidade  = IF AVAILABLE bfCliente THEN bfCliente.CodCidade ELSE ?
        fi_observacao  = IF AVAILABLE bfCliente THEN bfCliente.Observacao ELSE "".

    DISPLAY
        fi_cod_cliente
        fi_nom_cliente
        fi_endereco
        fi_cod_cidade
        fi_observacao
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

        fi_cod_cliente
        fi_nom_cliente
        fi_endereco
        fi_cod_cidade
        fi_observacao

    WITH FRAME fr_principal.

END PROCEDURE. 


PROCEDURE pi-habilita-edicao:

    ENABLE
        bt_save
        bt_canc

        fi_nom_cliente
        fi_endereco
        fi_cod_cidade
        fi_observacao

    WITH FRAME fr_principal.

    IF lIncluindo THEN
        ENABLE fi_cod_cliente WITH FRAME fr_principal.
    ELSE
        DISABLE fi_cod_cliente WITH FRAME fr_principal.

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

    RELEASE bfCliente.

    ASSIGN
        lIncluindo = TRUE
        lAlterando = FALSE.

    ASSIGN
        fi_cod_cliente = ?
        fi_nom_cliente = ""
        fi_endereco    = ""
        fi_cod_cidade  = ?
        fi_observacao  = "".

    DISPLAY
        fi_cod_cliente
        fi_nom_cliente
        fi_endereco
        fi_cod_cidade
        fi_observacao
    WITH FRAME fr_principal.

    RUN pi-habilita-edicao.

    APPLY "ENTRY" TO fi_nom_cliente IN FRAME fr_principal.

END PROCEDURE.

PROCEDURE pi-modificar:

    IF NOT AVAILABLE bfCliente THEN
        RETURN.

    ASSIGN
        lIncluindo = FALSE
        lAlterando = TRUE.

    RUN pi-habilita-edicao.

    APPLY "ENTRY" TO fi_nom_cliente IN FRAME fr_principal.

END PROCEDURE.

PROCEDURE pi-cancelar:

    ASSIGN
        lIncluindo = FALSE
        lAlterando = FALSE.

    IF AVAILABLE bfCliente THEN
        RUN pi-atualiza-tela.
    ELSE
    DO:
        ASSIGN
            fi_cod_cliente = ?
            fi_nom_cliente = ""
            fi_endereco    = ""
            fi_cod_cidade  = ?
            fi_observacao  = "".

        DISPLAY
            fi_cod_cliente
            fi_nom_cliente
            fi_endereco
            fi_cod_cidade
            fi_observacao
        WITH FRAME fr_principal.
    END.

    RUN pi-habilita-consulta.

END PROCEDURE.

PROCEDURE pi-salvar:

    DO WITH FRAME fr_principal:

        ASSIGN
            fi_nom_cliente
            fi_endereco
            fi_cod_cidade
            fi_observacao.

    END.

    IF fi_nom_cliente = "" THEN DO:

        MESSAGE
            "Informe o nome do cliente."
            VIEW-AS ALERT-BOX ERROR.

        APPLY "ENTRY" TO fi_nom_cliente IN FRAME fr_principal.
        RETURN.

    END.

    FIND FIRST bfCidade
        WHERE bfCidade.CodCidade = fi_cod_cidade
        NO-LOCK
        NO-ERROR.

    IF NOT AVAILABLE bfCidade THEN DO:

        MESSAGE
            "Cidade n∆o encontrada."
            VIEW-AS ALERT-BOX ERROR.

        APPLY "ENTRY" TO fi_cod_cidade IN FRAME fr_principal.
        RETURN.

    END.

    IF lIncluindo THEN DO:

        CREATE bfCliente.

        ASSIGN
            bfCliente.CodCliente  = NEXT-VALUE(seqCliente)
            bfCliente.NomCliente  = fi_nom_cliente
            bfCliente.Endereco    = fi_endereco
            bfCliente.CodCidade   = fi_cod_cidade
            bfCliente.Observacao  = fi_observacao.

    END.

    ELSE IF lAlterando THEN DO:

        FIND CURRENT bfCliente EXCLUSIVE-LOCK NO-ERROR.

        IF LOCKED bfCliente THEN DO:

            MESSAGE
                "Registro bloqueado por outro usu†rio."
                VIEW-AS ALERT-BOX ERROR.

            RETURN.

        END.

        ASSIGN
            bfCliente.NomCliente = fi_nom_cliente
            bfCliente.Endereco   = fi_endereco
            bfCliente.CodCidade  = fi_cod_cidade
            bfCliente.Observacao = fi_observacao.

    END.

    ASSIGN
        lIncluindo = FALSE
        lAlterando = FALSE.

    RUN pi-atualiza-tela.
    RUN pi-habilita-consulta.

END PROCEDURE.
PROCEDURE pi-eliminar:

    IF NOT AVAILABLE bfCliente THEN
    DO:
        MESSAGE "Nenhum cliente selecionado para exclus∆o."
            VIEW-AS ALERT-BOX INFORMATION.
        RETURN.
    END.

    FIND FIRST bfAluguel
        WHERE bfAluguel.CodCliente = bfCliente.CodCliente
        NO-LOCK
        NO-ERROR.

    IF AVAILABLE bfAluguel THEN DO:
    MESSAGE
        "N∆o Ç poss°vel eliminar este cliente."
        SKIP
        "Existem aluguÇis cadastrados para ele."
        VIEW-AS ALERT-BOX ERROR.
        RETURN.
    END.

    MESSAGE
        "Confirma a exclus∆o do cliente?"
        VIEW-AS ALERT-BOX QUESTION
        BUTTONS YES-NO
        UPDATE lResposta AS LOGICAL.

    IF NOT lResposta THEN
        RETURN.

    FIND CURRENT bfCliente EXCLUSIVE-LOCK NO-ERROR.

    IF AVAILABLE bfCliente THEN
        DELETE bfCliente.

    RUN pi-carrega-primeiro.

    IF AVAILABLE bfCliente THEN
        RUN pi-atualiza-tela.
    ELSE
    DO:
        ASSIGN
            fi_cod_cliente = ?
            fi_nom_cliente = ""
            fi_endereco    = ""
            fi_cod_cidade  = ?
            fi_observacao  = "".

        DISPLAY
            fi_cod_cliente
            fi_nom_cliente
            fi_endereco
            fi_cod_cidade
            fi_observacao
        WITH FRAME fr_principal.
    END.

END PROCEDURE.
    
PROCEDURE pi-exportar:

    DEFINE VARIABLE cArquivoCSV  AS CHARACTER NO-UNDO.
    DEFINE VARIABLE cArquivoJSON AS CHARACTER NO-UNDO.
    DEFINE VARIABLE oArray       AS JsonArray  NO-UNDO.
    DEFINE VARIABLE oObject      AS JsonObject NO-UNDO.

    ASSIGN
        cArquivoCSV  = "c:\trabalho-final-progress\clientes.csv"
        cArquivoJSON = "c:\trabalho-final-progress\clientes.json".

    OUTPUT TO VALUE(cArquivoCSV).

    PUT UNFORMATTED
        "CodCliente;NomCliente;Endereco;CodCidade;Observacao"
        SKIP.

    FOR EACH bfClienteExp NO-LOCK
        BY bfClienteExp.CodCliente:

        PUT UNFORMATTED
            STRING(bfClienteExp.CodCliente)
            ";"
            REPLACE(bfClienteExp.NomCliente, ";", " ")
            ";"
            REPLACE(bfClienteExp.Endereco, ";", " ")
            ";"
            STRING(bfClienteExp.CodCidade)
            ";"
            REPLACE(bfClienteExp.Observacao, ";", " ")
            SKIP.

    END.

    OUTPUT CLOSE.

    oArray = NEW JsonArray().

    FOR EACH bfClienteExp NO-LOCK BY bfClienteExp.CodCliente:

        oObject = NEW JsonObject().

        oObject:Add("CodCliente", bfClienteExp.CodCliente).
        oObject:Add("NomCliente", bfClienteExp.NomCliente).
        oObject:Add("Endereco", bfClienteExp.Endereco).
        oObject:Add("CodCidade", bfClienteExp.CodCidade).
        oObject:Add("Observacao", bfClienteExp.Observacao).

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
  
