DEFINE VARIABLE cCaminhoDB AS CHARACTER NO-UNDO INITIAL "c:\dados\videoloc".

IF NOT CONNECTED("videoloc") THEN
DO:
    CONNECT VALUE("-db " + cCaminhoDB + " -1") NO-ERROR.

    IF NOT CONNECTED("videoloc") THEN
    DO:
        MESSAGE
            "Nao foi possivel conectar ao banco de dados."
            SKIP
            "Caminho esperado: " + cCaminhoDB + ".db"
            SKIP
            "Verifique se o arquivo existe e se nenhum outro"
            SKIP
            "processo esta com o banco aberto (single-user)."
            VIEW-AS ALERT-BOX ERROR.

        QUIT.
    END.
END.

DEFINE BUTTON bt_cidades      LABEL "Cidades"              SIZE 25 BY 2.
DEFINE BUTTON bt_filmes       LABEL "Filmes"                SIZE 25 BY 2.
DEFINE BUTTON bt_clientes     LABEL "Clientes"              SIZE 25 BY 2.
DEFINE BUTTON bt_alugueis     LABEL "Alugueis"               SIZE 25 BY 2.
DEFINE BUTTON bt_rel_clientes LABEL "Relatorio de Clientes"  SIZE 25 BY 2.
DEFINE BUTTON bt_rel_alugueis LABEL "Relatorio de Alugueis"  SIZE 25 BY 2.
DEFINE BUTTON bt_sair         LABEL "Sair"                   SIZE 12 BY 1.

FORM
    "Video Locadora Progress"          AT ROW 2 COL 4
    bt_sair                            AT ROW 2 COL 96

    bt_cidades                         AT ROW 4  COL 8
    bt_alugueis                        AT ROW 4  COL 48

    bt_clientes                        AT ROW 7  COL 8
    bt_rel_clientes                    AT ROW 7  COL 48

    bt_filmes                          AT ROW 10 COL 8
    bt_rel_alugueis                    AT ROW 10 COL 48

    SKIP(1)

    "Feito por: Joao Filipi Girardi Tissi"                                AT ROW 13 COL 3
    "E-mail: joaofilipigtissi@gmail.com"                                  AT ROW 13 COL 44

    "Github: https://github.com/joaofilipigtissi/videolocadora-progress" AT ROW 14 COL 3

WITH FRAME fr_principal
    THREE-D
    WIDTH 130
    TITLE "Videolocadora VL".

DEFINE VARIABLE wJanela AS WIDGET-HANDLE NO-UNDO.

CREATE WINDOW wJanela
    ASSIGN
        TITLE   = "Videolocadora VL"
        WIDTH   = 130
        HEIGHT  = 16
        VISIBLE = TRUE.

CURRENT-WINDOW = wJanela.

VIEW FRAME fr_principal.

ENABLE
    bt_cidades
    bt_filmes
    bt_clientes
    bt_alugueis
    bt_sair
    bt_rel_clientes
    bt_rel_alugueis
WITH FRAME fr_principal.

ON CHOOSE OF bt_cidades DO:
    RUN c:\trabalho-final-progress\cadastros\cad_cidades.p.
END.

ON CHOOSE OF bt_filmes DO:
    RUN c:\trabalho-final-progress\cadastros\cad_filmes.p.
END.

ON CHOOSE OF bt_clientes DO:
    RUN c:\trabalho-final-progress\cadastros\cad_clientes.p.
END.

ON CHOOSE OF bt_alugueis DO:
    RUN c:\trabalho-final-progress\cadastros\cad_alugueis.p.
END.

ON CHOOSE OF bt_rel_clientes DO:
    RUN c:\trabalho-final-progress\relatorios\rel_clientes.p.
END.

ON CHOOSE OF bt_rel_alugueis DO:
    RUN c:\trabalho-final-progress\relatorios\rel_alugueis.p.
END.

ON CHOOSE OF bt_sair DO:
    APPLY "WINDOW-CLOSE" TO wJanela.
END.

WAIT-FOR WINDOW-CLOSE OF wJanela.
