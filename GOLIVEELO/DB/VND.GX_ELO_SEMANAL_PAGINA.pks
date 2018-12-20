CREATE OR REPLACE PACKAGE VND."GX_ELO_SEMANAL_PAGINA" AS 

  /* TODO enter package declarations (types, exceptions, methods etc) here */ 

TYPE T_CURSOR IS REF CURSOR;

FUNCTION FX_INTERVAL_TO_STRING (P_INTERVAL IN VND.ELO_MARCACAO.IT_TMAC_CLIENTE%TYPE) RETURN varchar2;

PROCEDURE PX_GET_CENTROS (
        P_RETORNO     OUT T_CURSOR
    );

PROCEDURE PX_GET_CENTRO_FROM_MAQUINA (
                                        P_CD_MACHINE VARCHAR2,
                                        P_RETORNO     OUT T_CURSOR
    );

PROCEDURE PX_GET_MAQUINAS (
         P_RETORNO     OUT T_CURSOR
    );

PROCEDURE PX_GET_MAQUINAS_FROM_CENTRO (
        P_CD_CENTRO_EXPEDIDOR VARCHAR2,
        P_RETORNO     OUT T_CURSOR
    );

PROCEDURE PX_GET_SEMANAS (
         P_RETORNO     OUT T_CURSOR
    );

 PROCEDURE PX_GET_BLOCO_SEMANAS( 	P_CD_CENTRO_EXPEDIDOR VARCHAR2,
                                    P_CD_MACHINE VARCHAR2,
                                    P_CD_WEEK_LIST VARCHAR2,
                                    P_RETORNO     OUT T_CURSOR
    );

PROCEDURE PX_GET_SEMANAL_LINHAS (   P_CD_CENTRO_EXPEDIDOR VARCHAR2,
                                    P_CD_MACHINE VARCHAR2,
                                    P_CD_WEEK VARCHAR2,
                                    P_LINHA_TO_EXEC VARCHAR2,
                                    P_CD_ELO_AGENDAMENTO VARCHAR,
                                    P_RETORNO     OUT T_CURSOR
    );

END GX_ELO_SEMANAL_PAGINA;


/