CREATE OR REPLACE PACKAGE VND.GX_ELO_MATINAL_PAGINA AS 

  /* TODO enter package declarations (types, exceptions, methods etc) here */ 
  
TYPE T_CURSOR IS REF CURSOR;
 
PROCEDURE PUI_ELO_MATINAL(  P_PK VARCHAR2,
                            P_FK VARCHAR2,
                            P_QTD number,
                            P_DAY number,
                            P_LINE varchar2
    );
    
PROCEDURE PX_GET_CENTROS (
        P_RETORNO     OUT T_CURSOR
    );
    
PROCEDURE PX_GET_MAQUINAS_FROM_CENTRO (
        P_CD_CENTRO_EXPEDIDOR VARCHAR2,
        P_RETORNO     OUT T_CURSOR
    );
    
PROCEDURE PX_GET_MAQUINAS (
         P_RETORNO     OUT T_CURSOR
    );
    
PROCEDURE PX_GET_CENTRO_FROM_MAQUINA (
                                        P_CD_MACHINE VARCHAR2,
                                        P_RETORNO     OUT T_CURSOR
    );
    
PROCEDURE PX_GET_SEMANAS (
         P_RETORNO     OUT T_CURSOR
    );

PROCEDURE PX_GET_POLOS (
         P_RETORNO     OUT T_CURSOR
    );

 PROCEDURE PX_GET_AGENDAMENTOS_OPT( P_CD_CENTRO_EXPEDIDOR VARCHAR2,
                                    P_CD_MACHINE VARCHAR2,
                                    P_CD_WEEK VARCHAR2,
                                    P_RETORNO     OUT T_CURSOR
    );

PROCEDURE PX_GET_AGEND_CAPACIDADE_MAX(  P_CD_CENTRO_EXPEDIDOR VARCHAR2,
                                        P_CD_MACHINE VARCHAR2,
                                        P_CD_WEEK VARCHAR2,
                                        P_RETORNO     OUT T_CURSOR
);

 PROCEDURE PX_GET_PREFILTRO_AGENDAMENTOS(   P_CD_CENTRO_EXPEDIDOR VARCHAR2,
                                            P_CD_MACHINE VARCHAR2,
                                            P_CD_WEEK VARCHAR2,
                                            P_CD_POLO VARCHAR2,
                                            P_RETORNO     OUT T_CURSOR
    );

PROCEDURE PX_GET_DAY_START_WEEK(P_CD_CENTRO_EXPEDIDOR VARCHAR2,
                                P_CD_MACHINE VARCHAR2,
                                P_CD_WEEK VARCHAR2,
                                P_CD_ELO_AGENDAMENTO VARCHAR,
                                P_RETORNO     OUT T_CURSOR
    );
    
PROCEDURE PX_GET_MATINAL_LINHAS (   P_CD_CENTRO_EXPEDIDOR VARCHAR2,
                                    P_CD_MACHINE VARCHAR2,
                                    P_CD_WEEK VARCHAR2,
                                    P_LINHA_TO_EXEC VARCHAR2,
                                    P_CD_ELO_AGENDAMENTO VARCHAR,
                                    P_CD_POLO VARCHAR2,
                                    P_RETORNO     OUT T_CURSOR
    );
    
PROCEDURE PX_GET_MATINAL_LINHAS_NEW(P_CD_CENTRO_EXPEDIDOR VARCHAR2,
                                    P_CD_MACHINE VARCHAR2,
                                    P_CD_WEEK VARCHAR2,
                                    P_LINHA_TO_EXEC VARCHAR2,
                                    P_CD_ELO_AGENDAMENTO VARCHAR,
                                    P_CD_POLO VARCHAR2,
                                    P_RETORNO     OUT T_CURSOR
    );
    
END GX_ELO_MATINAL_PAGINA;
/